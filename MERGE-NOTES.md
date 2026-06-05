# Merge Notes — `feat/disc-probe-fast-representation`

## 0. Purpose

This branch merges `dev`'s disc-probing feature (PR #451, "Discrete Probing for
Complexity-Reducing Settings") onto `ref/RepresentationBuilding`'s fast
top-down `getCandidate` path. The goal is to keep disc-probe's knob-pruning
semantics (a `DiscreteKnob` carries a `disAll` list of disallowed settings,
which reduces effective multiplicity and remaps instance indices) while
preserving the pre-merge `getCandidate` runtime. The gating constraint
throughout has been: **do not regress the ~2:50 baseline runtime on the user's
perf test** (mux6 / parity-family demo). The naive merge ran ~4:06; that
delta is what §2 is fighting.

The working tree currently sits on top of `36f240c` (tip of
`ref/RepresentationBuilding`) with **no commits authored on this branch yet**.
Everything in §2 is in the unstaged/staged working tree only.

## 1. Starting-state verification findings

- `deme/tests/expand-demes-test.metta` declares 67 unique `!(import! …)`
  statements — no duplicates among the import lines themselves.
- However, **five top-level symbols are defined in more than one of those
  imported files**. Because all imports load into a single namespace, each
  pair becomes a multi-clause definition spanning two files at load time:

  | Symbol           | File A                                              | File B                                              |
  |------------------|------------------------------------------------------|------------------------------------------------------|
  | `entropy`        | `feature-selection/feature-selection-helpers.metta`  | `feature-selection/incremental-feature-selection.metta` |
  | `range`          | `feature-selection/feature-selection-helpers.metta`  | `feature-selection/incremental-feature-selection.metta` |
  | `round`          | `feature-selection/feature-selection-helpers.metta`  | `utilities/general-helpers.metta`                    |
  | `getKnobDefault` | `deme/expand-deme.metta`                              | `representation/knob-representation.metta`           |
  | `getNodeId`      | `representation/lsk.metta`                            | `utilities/tree.metta`                               |

  These have **not** been fixed on this branch. They are flagged here because
  ambiguous dispatch is a likely source of any future regressions; see also
  §3's note on the commented-out `getKnobDefault` clauses in `expand-deme.metta`.

## 2. Fixes applied (in order)

### 2a. `logicalProbe` fast/slow split — `representation/logical-probe.metta`

**Why.** The merged `logicalProbe` had an eager `probeTreeForControlledSubtree`
call inside `probeLogicalPair`, evaluated *before* the `$disable-discprobe`
test in its `let*`. Every permutation paid:

- a `List.index $children $controlledSubtree` linear scan,
- an `appendChild` traversal (`getNodeById` + `List.append` + `updateChildren`
  internally),
- a wrapping `getNodeById` + `replaceNodeById` on the local tree.

Per call that is O(N permutations × C children) extra work **even when
disc-probe was disabled**, which is the default for the perf test.

**What.** Split the 6-arg `logicalProbe` clause by literal `Bool`
(`$disable-discprobe`):

- The `True` clause is byte-for-byte the pre-merge optimized body. It
  pattern-matches `(mkTree $node $children)` directly, builds the LSK list with
  `logicalSubtreeKnob`, and returns `(mkTree $node …)`. **Zero node-id work.**
- The `False` clause keeps the new probe-tree machinery: extract `$target` via
  `getNodeById`, build `$probedChldLskPair` via `probeLogicalPair`, filter
  using `allDisallowed`, then `replaceNodeById` to reassemble the tree.

The 3-arg and 4-arg `logicalProbe` wrappers, plus the helpers
`probeLogicalPair`, `probeTreeForControlledSubtree`, `childNodeId`, and
`targetWithChildren`, are preserved (they're only reached from the slow path).

### 2b. `getCandidate` restoration — `representation/representation.metta`

**Why.** After 2a the user still saw 4:06 (vs 2:50 baseline). Diagnosis: the
merged `getCandidateHelper` had been thickened with a third `$knobs` argument
and per-knob-hit work in `getCandidate`:

- `getCandidate` called `(getRepKnobs $kmo)` once per candidate, materializing
  `(MultiMap.values $discMap)` — O(M) per call.
- Per knob hit, `(getKnobByIdx $knobs $i)` did `List.getByIdx` — O(M).
- Per knob hit, `mapCandidateDiscSpec → mapEffectiveDiscSpec` destructured the
  knob and walked `disAll`.

Total per `getCandidate`: O(M + K·M) vs the pre-merge O(K). With M ≈ K ≈ 30
typical knobs and thousands of `getCandidate` calls per generation (every
instance scored, in every deme, in every generation), this was the bulk of the
+75s.

**What.** Restored the 2-arg `getCandidateHelper` clauses byte-for-byte
(`(mkKnob (mkNullVex …) $i)`, `(mkKnob (mkTree $node $children) $i)`, and the
generic `(mkTree $node $children)` recursion). Reverted the `getCandidate`
`Empty` branch (around line ~190 — verify with grep) to call
`(getCandidateHelper $inst $tr)` directly.

The 3-arg slow-path machinery is **kept alongside** (`getRepKnobs`,
`getKnobByIdx`, `mapCandidateDiscSpec`, and the 3-arg `getCandidateHelper`
clauses) so the new test added to `representation/tests/representation-test.metta`
still passes. With 2a + 2b in place the user reported ~2:50 restored.

### 2c. Embed-LSK redesign (in progress this session)

**Why.** After 2b the disc-probe path is dead code from the default
`getCandidate`'s perspective. The next step gets disc-probe semantics back
into `getCandidate` *without* paying any per-call overhead, *and* retires the
latent `getKnobByIdx` ordering bug (§3) in one stroke.

**Design.** Every tree-level `mkKnob` wrapper grows a field:

```
;; was
(mkKnob $subtree $i)
;; becomes
(mkKnob $subtree $lsk $i)
```

`$lsk` is the same `LogicalSubtreeKnob` already constructed during
`logicalProbe`. `getCandidateHelper` now has O(1) access to the LSK by pattern
match — no list traversal, no third argument threaded through.

A specialized fast clause short-circuits to the pre-merge behavior whenever
the LSK's `disAll` list is empty (the common case, including the entire
disc-probe-off flow):

```
(= (getCandidateHelper (mkInst $inst)
                       (mkKnob (mkTree $node $children)
                               (mkLSK (mkDiscKnob $m $c $d ()))
                               $i))
   ;; identical to the 2-arg fast body — empty disAll → no remap needed
   …)
```

The generic clause calls `mapEffectiveDiscSpec` once per knob hit, but only
when `disAll` is non-empty.

**Consequences.**

- `getRepKnobs` / `getKnobByIdx` / `mapCandidateDiscSpec` (added in 2b) become
  dead code; delete them.
- The 3-arg `getCandidateHelper` clauses become dead code; delete them.
- The new 3-arg assertion in `representation/tests/representation-test.metta`
  is rewritten to drive the 2-arg form against an exemplar carrying
  `(mkKnob $subtree (mkLSK …) 0)`. Test count and expected output unchanged.
- The `getKnobByIdx` ordering bug disappears: there is no index-based lookup
  anymore.
- The disc-probe multimap is unchanged and continues to serve
  `expand-deme.metta`, `optimization/hillclimbing/hill-climbing-helpers.metta`,
  `moses/neighborhood-sampling.metta`, and `informationTheoreticBits`.
- Slight memory cost: each tree-level `mkKnob` now carries its LSK redundantly
  with the multimap copy. Negligible for typical M.

## 3. Known issues flagged but NOT YET fixed

- **`getKnobMultip` semantic change**
  (`representation/knob-representation.metta:101-104`): pre-merge returned the
  raw multiplicity in an O(1) pattern match; post-merge returns *effective*
  multiplicity via `countNonDefaultDisallowed`, which walks `disAll`. Hot-path
  callers are `optimization/hillclimbing/hill-climbing-helpers.metta:7`
  (`informationTheoreticBits`, one call per knob),
  `optimization/hillclimbing/hill-climbing-helpers.metta:77` (per
  neighbor-count step), and `moses/neighborhood-sampling.metta:312` (every
  neighborhood expansion). Suggested fix: switch those callers to
  `getRawKnobMultip` (already added by the merge), or revert `getKnobMultip`'s
  semantics and add `getEffectiveKnobMultip` as the escape hatch.
- **`buildLogical` / `addLogicalKnobs` dispatch thickening**
  (`representation/build-logical.metta`, `representation/add-logical-knobs.metta`):
  each function picked up wrapper layers (4-arg → 5-arg → 6-arg) to thread
  `$disable-discprobe`. Small per-call cost compounds across AND/OR nodes. If
  perf is still off after §2c lands, apply the same fast/slow split that
  `logicalProbe` got.
- **Unexplained `(cut)`** at `deme/expand-deme.metta:77`: Prolog-style cut
  inserted with no comment. Verify intent.
- **Commented-out dead code**: `representation/logical-probe.metta:13-33`
  (legacy `logicalProbe`) and `deme/expand-deme.metta:28-29` (legacy
  `getKnobDefault` clauses — related to the namespace overlap noted in §1).
- **Comment style regression**: `deme/tests/expand-demes-test.metta` had a
  bulk `;;` → `;` conversion that contradicts `AGENTS.md` (`;;` is the
  codebase convention).
- **Untracked clutter** in the working tree: `TestResult.log`, `output.log`,
  `parit3.log`, `parity3.log`, `dummy.metta`. Add to `.gitignore`.
- **Latent `getKnobByIdx` ordering bug**: resolved automatically by §2c, but
  until §2c is committed it remains a real risk when disc-probe prunes knobs
  to mixed multiplicities.
- **Branch state**: nothing committed. The user wants commits onto
  `feat/disc-probe-fast-representation` (the current branch). After §2c
  passes the perf test, author a clean commit series.

## 4. Test inventory and how to run

PeTTaV1 install lives at `~/PeTTaV1`.

- Single-file: `cd ~/PeTTaV1 && ./run.sh <path/to/test.metta>`
- Full suite: `python3 scripts/run-tests.py`
- Heavy integration: `python3 scripts/test_moses.py --config moses/configs/classic_demo_config.json`
  (mux3, `max_gens=50`, `demes=2`, `count=20`)

Status with §2a + §2b in place (verified by the previous session):

| Test file                                              | Status   |
|--------------------------------------------------------|----------|
| `representation/tests/logical-probe-test.metta`        | 7/7 pass |
| `representation/tests/disc-probe-test.metta`           | 7/7 pass |
| `representation/tests/representation-test.metta`       | 13/13 pass |
| `deme/tests/expand-demes-test.metta`                   | 5/5 pass |

After §2c the new 3-arg assertion in `representation-test.metta` is rewritten
to call the 2-arg form against an exemplar with
`(mkKnob $subtree (mkLSK …) 0)`. Test count and expected outputs unchanged.

## 5. Files touched on this branch

Pulled from `git diff HEAD` against `36f240c`. File:line ranges are approximate
post-edit positions; use them as anchors, not literals.

### `representation/logical-probe.metta`
- Lines ~37-57: new helpers `childNodeId`, `probeTreeForControlledSubtree`,
  `probeLogicalPair`, `targetWithChildren`.
- Lines ~59-65: new 3-arg and 4-arg `logicalProbe` wrappers that default
  `$disable-discprobe` to `True` and add the `(mkNodeId (0)) (mkNodeId (0))`
  root ids.
- Lines ~70-85: **`logicalProbe … True` fast clause** (§2a) — pre-merge body
  restored verbatim.
- Lines ~89-107: **`logicalProbe … False` slow clause** — new probe-tree body.

### `representation/representation.metta`
- Lines ~62-74: new 7-arg `representation` constructor wrapper that defaults
  `$disable-discprobe` to `True` and forwards to the 8-arg form.
- Line ~123: `buildKnobs $xmplr () $argLabels $disable-discprobe` call site
  threaded.
- Lines ~135-137: new `getRepKnobs` clauses (becomes dead code under §2c).
- Lines ~185-195: `getCandidate` `Empty` branch reverted to
  `(getCandidateHelper $inst $tr)` (§2b).
- Lines ~301-313: new `getKnobByIdx`, `mapCandidateDiscSpec` (dead code under §2c).
- Lines ~315-321: **2-arg `getCandidateHelper` fast clauses** (§2b) restored.
- Lines ~326-345: 3-arg `getCandidateHelper` slow clauses retained for the
  added test (delete under §2c).

### `representation/knob-representation.metta`
- Lines ~63-72: new `getRawKnobMultip` clauses (DiscKnob/LSK/SSK forms).
- Lines ~74-89: `getKnobDefault` and `getDisallowedSpecs` clauses moved/added
  here.
- Lines ~91-95: new `countNonDefaultDisallowed` recursion over `disAll`.
- Lines ~101-110: **`getKnobMultip` semantics changed** to subtract
  `countNonDefaultDisallowed` from raw multiplicity — see §3 for hot-path
  impact.
- Lines ~114-118: `getKnobSpec` rewritten in terms of `getKnobMultip`.
- Lines ~120-141: new `allDisallowed`, `settingDisallowed`,
  `allowedNonDefaultSetting`, `nthAllowedActualSetting`,
  `mapEffectiveDiscSpec`.

### `representation/build-logical.metta`
- Lines ~84-86: new 4-arg `buildLogical` wrapper for the `mkKnob (mkNullVex …)`
  case.
- Lines ~87-90: new 4-arg wrappers for the `mkKnob (mkTree …)` and
  `mkTree (mkNode …)` cases, threading `$disable-discprobe`.
- Lines ~95-126: **6-arg `buildLogical` body** — same as pre-merge logic but
  calls `addLogicalKnobsFast` everywhere with the disable flag.

### `representation/add-logical-knobs.metta`
- Lines ~40-42: 4-arg `addLogicalKnobs` becomes a wrapper delegating to
  `addLogicalKnobsFast … True`.
- Lines ~43-63: new 5-arg `addLogicalKnobsFast` body — passes the new
  6-arg `logicalProbe` form (with root node ids and `$disable-discprobe`).

### `representation/build-knobs.metta`
- Lines ~7-15: 3-arg `buildKnobs` becomes a wrapper delegating to the 4-arg
  form with `$disable-discprobe = True`. The 4-arg form canonizes once, then
  dispatches to `buildLogical` with the canon root op.

### `deme/expand-deme.metta`
- Lines ~3-9: `getDefaults` now does an extra `List.map second $defaults`
  because `getKnobDefault` (now defined in `knob-representation.metta`) returns
  the `(mkDiscSpec $def)` wrapper rather than the bare number.
- Lines ~27-29: local `getKnobDefault` clauses commented out (delegated to
  `knob-representation.metta`). Related: §1 namespace overlap, §3 dead-code item.
- Line 77: stray `(cut)` — see §3.

### `representation/tests/representation-test.metta`
- Line 25: added `!(import! &self ../../representation/disc-probe)`.
- Lines ~155-161: new assertion exercising the 3-arg `getCandidateHelper` with
  a pruned LSK `((mkDiscSpec 1))` to verify the effective→actual setting
  remap. **Under §2c this is rewritten** to call the 2-arg form against an
  exemplar with `(mkKnob $subtree (mkLSK …) 0)`.

### `deme/tests/expand-demes-test.metta`
- Bulk `;;` → `;` comment-style change across the file — see §3, revert
  during cleanup.

### `optimization/hillclimbing/hill-climbing-helpers.metta`
- Line ~249: `$maxEvals` lowered `1000 → 500`. Unclear whether this is a
  perf-investigation knob or an intentional default change — verify with the
  user before committing.

### `moses/demo-problems.metta`
- Line 232: `runMoses … 1000 100 20 … → … 500 100 20 …` — same caveat as
  above.

### `moses/tests/demo-problems-benchmark-test.metta`
- Lines 76-78: the parity3 assertion is commented out and replaced with
  `!(runDemoProblem 0 10 1 None mux6)` — this is a perf-investigation
  scaffold, not a regression test. Restore the assertion before committing.
