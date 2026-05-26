# MOSES (MeTTa) performance bottlenecks

Quarter plan reference: Objective 2 (Improve Performance and Runtime Efficiency),
KR1: "Identify and document the main performance bottlenecks."

This document records the first systematic profiling pass over the MeTTa MOSES
pipeline and the bottlenecks it found. Each entry gives where the cost is, why it
is slow, its measured or estimated impact, and a recommended fix mapped to a KR.
It is meant to direct KR2 (optimize the critical execution paths) and KR3 (use
more native PeTTa/Prolog).

## Summary

On PeTTa v1.0.0, a small Boolean problem (majority3: 8-row truth table, 3
generations, 1 deme) takes about 75s wall and 700-880 MB peak RSS. CPU sits at
99%, so the engine is single-threaded and scaling depends entirely on per-core
efficiency.

The dominant cost is candidate reconstruction (getCandidate), about 98% of runtime
on majority3. All scoring together is about 1.5%. This was not obvious from the
interpreter's own diagnostics: the loudest signal (the "Not specialized" warnings)
pointed elsewhere, and the real cost only showed up under phase timers.

Two findings worth carrying into the optimization work:

- Warning count is not a proxy for time. The single largest "Not specialized"
  source (expToMMap, 181 of 206 warnings) is about 2-3% of runtime, while
  reconstruction emits no warnings and is about 98%.
- Prioritize by measured wall time. Several plausible-looking changes moved wall
  time by 3% or less; the large win came only after timers located the real
  hotspot.

## Methodology

Measured on the target interpreter (PeTTa v1.0.0 via run.sh), using four signals:

1. Wall-clock and resource usage from `/usr/bin/time -v` on a full runDemoProblem
   run.
2. Interpreter specialization warnings. PeTTa prints `Not specialized
   <pred>/<arity>` when it falls back from compiled execution to the
   meta-interpreter. Counting these by function points at code the runtime cannot
   compile.
3. Static complexity analysis, tracing the call graph from runMoses down through
   deme expansion, sampling, scoring, reduction, and merge.
4. Phase timers: `(py-call (time.time))` brackets around the expand/optimize/merge
   phases of runMoses, and around getCandidate vs getCscore per candidate. These
   located the dominant cost after the first three signals pointed at the wrong
   place.

This is wall-clock plus warning counts plus call-graph analysis, not a line-level
statistical profiler (PeTTa does not expose per-predicate timing). The numbers are
reproducible but coarse: they show where to look, and the static analysis explains
why.

### Reproduce

```sh
# Clean, completed run (about 51s on an idle machine):
printf '%s\n' "$(head -75 moses/tests/demo-problems-benchmark.metta)" \
  '!(runDemoProblem 0 3 1 None majority3)' > moses/tests/_tmp_bench.metta
/usr/bin/time -v run.sh moses/tests/_tmp_bench.metta -s > /tmp/bench.log 2>&1
rm moses/tests/_tmp_bench.metta

# Count specialization fallbacks by function:
grep -o "Not specialized [^ ]*" /tmp/bench.log | sort | uniq -c | sort -rn

# The heavy default benchmark (mux6, 64 knobs) does not finish quickly:
run.sh moses/tests/demo-problems-benchmark.metta -s
```

## Measured results

| Run | Params | Wall | CPU | Peak RSS | "Not specialized" total |
|---|---|---|---|---|---|
| majority3 | seed 0, maxGen 3, 1 deme | ~75s (51s on an idle machine) | 99% | 700-880 MB | 206 (181 from expToMMap) |
| mux6 (default benchmark) | seed 0, maxGen 10, 1 deme | did not finish 1 generation in 82s (stopped) | 99% | n/a | 196+ (partial) |

Wall time is load-sensitive: an early majority3 run on an idle machine measured
51s; same-session repeats under load measured ~75s. Only compare numbers gathered
in the same session.

### Phase breakdown (majority3)

| Phase | Time | Share |
|---|---|---|
| getCandidate (instance-to-tree reconstruction) | 73.4s | ~98% |
| getCscore (all scoring: scoreTree, cache, complexity) | 1.1s | ~1.5% |
| representation build (createDeme) plus metapopulation merge | ~1.5s | <2% |

Reconstruction cost grows across generations (gen 3: 2.7s, then gen 2: ~37s),
because each generation's hill-climbing samples and reconstructs more candidates,
and larger ones.

### Specialization warnings (majority3)

| Count | Function |
|---|---|
| 181 | expToMMap_Spec_[discSpec<]/4 |
| 4 | sortPairs_Spec_[pairMax]/5 |
| 2 | mapG_Spec_[cleanedExemplar]/3 |
| 2 | List.map_Spec_[removeInstScore]/3 |
| 2 | List.map_Spec_[preOrderDebug]/3 |
| 1 each | List.map_Spec_[treeComplexity / preOrder / getKnobMultip / getKnobDefault / initInstScore / ...], lruCache / cachePut / removeLeastRecentlyUsed_Spec_[calculateMutualInformation] |

88% of all specialization fallbacks come from a single function (expToMMap), yet
that function is only ~2-3% of runtime. This is the basis for the "warnings are
not a time proxy" point in the summary.

## Bottlenecks

Ordered by measured or estimated impact. Each entry notes its current status.

### 1. Candidate reconstruction (about 98% of runtime). Status: resolved.

Where: `representation/representation.metta`, getCandidate calling getCandidateRec.
The per-node insert went through appendChild (`utilities/tree.metta:233`, which
does getNodeById plus replaceNodeById on the candidate) and appendTo*
(`representation/lsk.metta`).

Why it was slow: getCandidateRec built the candidate top-down, threading a growing
candidate tree and inserting each node by id with appendChild. Each insert walks
the candidate path (getNodeById) and rebuilds it (replaceNodeById), so O(depth) per
node with high interpreted constant factors, repeated for every node of all ~1311
candidates while the candidate keeps growing. Phase timers put this at 73.4s of
~75s.

A relevant negative result: getNodeById on the representation tree is cheap
(removing it changed wall time by 0%). The cost was the candidate-side
appendChild/replaceNodeById rebuilds, not the lookups.

Fix (KR2): bottom-up assembly. getCandidateRec was rewritten so that buildNodeBU
returns the built subtree for a node, or () if a knob makes it absent, and a parent
assembles `(mkTree value <built children>)` directly. There is no appendChild, no
replaceNodeById, and no walking or rebuilding of a growing candidate. Knob
semantics (present, NOT-wrap for d=2, absent, and null-vertex unwrapping) are
reproduced exactly. The appendTo* helpers remain (still exercised directly by
`lsk-test.metta`); the dead applyGetCandidateRec helper was removed.

Measured effect on majority3 (same session):

| Version | Run 1 | Run 2 | Output | Tests |
|---|---|---|---|---|
| Top-down (appendChild into a growing tree) | ~75s | ~76s | baseline | 76/76 |
| Bottom-up (assemble and return subtrees) | 39.7s | 39.4s | byte-identical | 76/76 |

About 48% faster (roughly 2x), identical FinalResult, all 76 tests pass.

### 2. expToMMap is un-specialized and O(n^2). Status: open.

Where: `utilities/general-helpers.metta:710-718`, called from
`representation/add-logical-knobs.metta:40`; inserts via
`utilities/ordered-multimap.metta:5-9`.

```metta
(= (expToMMap $tuple $map $compFunc)
  (let* (
    (($head $tail) (decons-atom $tuple))
    ($updatedMap (eval (MultiMap.insert $head $map $compFunc)))  ;; eval wrapper
  )
  (if (== $tail ()) $updatedMap (eval (expToMMap $tail $updatedMap $compFunc)))))  ;; eval wrapper
```

Why it's slow: the explicit eval wrappers around the recursive call and
MultiMap.insert force the meta-interpreter path, so PeTTa cannot specialize the
predicate. That is exactly what the 181 `Not specialized
expToMMap_Spec_[discSpec<]/4` warnings report, and it runs on every knob of every
representation built in every generation. It is also O(n^2): each MultiMap.insert
is a sorted cons-list insert (O(n)), repeated once per knob (n of them). For mux6
(64 knobs) that's about 4k interpreted insertions to build one representation.

Impact: about 2-3% of wall time on majority3, measured by removing the eval
wrappers (warnings dropped 181 to 0, output byte-identical, ~2-3% faster, lower
peak RSS). This is the loudest warning source but a minor time sink.

Fix (KR2 plus KR3): drop the eval wrappers so PeTTa can specialize the predicate.
Separately, address the O(n^2) insert by building unsorted and sorting once, or by
backing the multimap with a native or Prolog-indexed structure.

### 3. O(n)/O(n^2) cons-list containers on the hot path. Status: open.

Where:

- Instances are flat expression lists of width = number of knobs (64 for mux6).
  Each neighbor update (updateInst, `moses/neighborhood-sampling.metta:132-142`)
  calls List.getByIdx and List.replaceAt (`utilities/list-methods.metta:39-42,
  93-98`), each O(n). With hundreds of neighbors sampled per iteration at distance
  d, that's O(neighbors * d * n) of pure list rebuilding.
- List.sort is selection sort, O(n^2) (`utilities/list-methods.metta:52-55`).
  List.index, List.delete, List.removeAtIdx, List.pop, and List.append are all
  O(n).
- Ordered set (`utilities/ordered-set.metta`): OS.insert, OS.contains, OS.getTopN,
  OS.union, OS.difference are O(n)/O(n^2) cons-list scans.
- Ordered multimap (`utilities/ordered-multimap.metta`): insert, findOne, contains
  are O(n) scans.

Why it matters: these sit under every other operation, so their cost compounds.
List.length and List.getByIdx already use native size-atom/index-atom, but mutation
(replaceAt) and sorted insertion still rebuild lists.

Fix (KR3): move mutation- and index-heavy structures to native PeTTa ops or
Prolog-backed companions (the repo already ships `.metta.pl` companions for
general-helpers and list-methods; extend that to instances, ordered-set, and
multimap). Replace List.sort with a merge sort or a native sort.

### 4. Debug println! in the inner loops. Status: open.

Where (hill-climbing): `optimization/hillclimbing/hill-climbing-helpers.metta:245,
257, 258, 259, 261, 283, 324`. Line 258 prints the entire center instance
(`(second $centerInst)`, all 64 values) on every iteration.
Where (merge): `deme/merge-demes.metta:248, 252, 255, 257, 264, 267, 269`.
Where (expansion): `deme/expand-deme.metta:57, 119, 124`.

Why it matters: stringifying and printing large structures (full instances, sizes,
per-iteration scores) thousands of times per deme is overhead, and it floods
stdout, which slows logged runs further. Measured wall-time effect is about 0% on
majority3 (the loop count is small), but it is a clear cleanup and is expected to
matter more on larger problems.

Fix (KR2, and the Phase-1 logging goal): gate hot-path logging behind a single
verbosity flag, off by default. This also serves the Phase-1 objective of
establishing logging so differences from the current implementation are explicit
and reviewable.

### 5. demeToTrees re-scores already-scored candidates. Status: open.

Where: `deme/merge-demes.metta:119-137` (demeToTrees) calls scoreTree
(`scoring/bscore.metta:62`) for each trimmed candidate during merge, even though
those instances were already scored by the optimizer's transform pass
(`deme/score-deme.metta:48`).

Why it matters: a second scoring pass over the surviving candidates each
generation. The &bscoreCache (`scoring/cacheSpace.metta`) softens it to a cache
lookup plus tree rebuild, but it is still redundant work on the merge path. Given
that all scoring is ~1.5% of runtime, the gain here is small.

Fix (KR2): reuse the Cscore/BScore already attached to the scored instance instead
of recomputing.

### 6. Neighborhood generation does post-hoc dedup over large lists. Status: open.

Where: `moses/neighborhood-sampling.metta:22-63` (generateAllInNeighborhood,
varyNKnobs).

Why it matters: neighbors are built with repeated append/foldl-atom, then
de-duplicated with unique-atom plus subtraction-atom over the whole, possibly
large, list. That is superlinear, and only used on the uncapped branch.

Fix (KR2): generate unique neighbors directly (avoid the post-hoc unique-atom), and
cap the count earlier in the pipeline.

### 7. Metapopulation merge is O(n*m) plus O(k^2). Status: open.

Where: `deme/merge-demes.metta`. getNewCandidates (146-149) does OS.isMember (O(n))
plus OS.insert (O(n)) per candidate. mergeCandidates (220-222) does an O(n) insert
per candidate, so O(n*m). removeDominated (187-210) is pairwise O(k^2).

Fix (KR3): batch-insert into the ordered set once, and use an indexed membership
check instead of is-member. This benefits directly from the container work in
item 3.

### 8. Per-row tree scoring. Status: investigated, not a current bottleneck.

Where: `scoring/bscore.metta:62-84`. scoreTree maps over every truth-table row into
scoreTreeHelper into replaceVarsWithTruth (`bscore.metta:140-141`), which folds
replaceVarWithTruth (`bscore.metta:120-129`), a full recursive rebuild of the
Boolean expression per row, then evaluate.

Why it is recorded here: statically this is O(rows * treeSize * labels) per
distinct candidate, which made it an early suspect. Phase timers put all of
getCscore at 1.1s (~1.5%) for majority3, and a single-pass-substitution rewrite
produced 0% wall change. The bscore cache (&bscoreCache) and the instance-to-tree
cache absorb most of it on small problems. It may matter on larger truth tables,
but it is not a current bottleneck. Documented so it is not re-attempted blindly.

Fix (only if a larger benchmark shows it dominate; ties to Objective 4 KR2):
compile each candidate into a row-evaluable form, or use MeTTa's built-in eval.

### 9. Memory pressure. Status: open, to re-measure.

Observation: about 860 MB peak RSS for a 3-generation, 8-row problem. The growing
&treeSpace and &bscoreCache spaces, plus list rebuilding, create allocation churn
that will scale poorly with more demes and generations.

Fix: re-evaluate after the container work lands; consider bounding or clearing
caches per expansion, and confirm the cons-list reductions lower the allocation
rate.

## Recommendations summary

| Item | Status | Effort | KR | Measured |
|---|---|---|---|---|
| Candidate reconstruction: bottom-up rewrite | Resolved | High | KR2 | ~48% (about 2x) |
| expToMMap: remove eval wrappers (specialization) | Open | Low | KR2/KR3 | ~2-3%, 88% fewer warnings |
| expToMMap: O(n^2) sorted insert to single fold plus sort-once | Open | Low | KR2/KR3 | n/a |
| Native/Prolog-backed ordered-set, multimap, instance | Open | High | KR3 | n/a |
| Replace List.sort (selection sort to merge sort) | Open | Medium | KR3 | n/a |
| Dedup-free neighborhood generation | Open | Medium | KR2 | n/a |
| Gate hot-loop println! behind a verbosity flag | Open | Low | KR2 | ~0% (cleans up logs) |
| demeToTrees: reuse attached scores | Open | Low | KR2 | small (scoring is ~1.5%) |
| Per-row scoring rewrite | Not needed now | High | KR2 | scoring measured ~1.5% |

The single largest opportunity, candidate reconstruction, is resolved. The
remaining items are ordered by expected impact. The guiding lesson for the
follow-on work is to prioritize by measured wall time: the warning-loud expToMMap
was ~2-3%, the statically expensive scoring path was ~1.5%, and the quiet
reconstruction path was ~98%.
