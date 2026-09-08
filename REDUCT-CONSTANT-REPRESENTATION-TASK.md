# Task: replace the empty-junctor constants with TRUE / FALSE emitted at the point of detection

You are picking up reduct work in `metta-moses`. A previous session fixed five defects in the
boolean reducer and, in doing so, built a constant-propagation design that the repo owner has
decided to replace. **That design has been reverted.** The other four fixes are still in place
and are not yours to redo.

Read this whole file before touching anything. It contains the harness recipes, because the
previous session's scratchpad was wiped between sessions and every verification tool had to be
rebuilt from scratch. Do not let that happen to you: keep anything reusable in the repo or in
this file, not in `/tmp`.

---

## 1. The mission

Today a contradiction or tautology is signalled by **emptying a junctor** — `(OR)` means false,
`(AND)` means true — and a later pass notices the empty junctor and propagates it.

You are replacing that with: **the rule that detects the condition emits the constant directly.**

- a rule that finds a contradiction replaces that subtree with `FALSE`
- a rule that finds a tautology replaces that subtree with `TRUE`
- one absorption rule handles the rest:

  | parent | child | action |
  |---|---|---|
  | `AND` | `FALSE` | whole AND becomes `FALSE` |
  | `OR`  | `TRUE`  | whole OR becomes `TRUE` |
  | `AND` | `TRUE`  | drop the child (identity) |
  | `OR`  | `FALSE` | drop the child (identity) |

Why this is better than what was there:

- **No conversion step.** Under the old design a junctor gets emptied in ~7 different places and
  something later has to recognise it. Here the constant is born as a constant.
- **No ambiguity with knob placeholders.** Knob building emits childless `(AND)`/`(OR)` in input
  trees. Under the old design those are *syntactically identical* to the constants, which forced
  an ordering discipline to keep them apart. With distinct symbols, `gatherJunctors` can delete
  placeholders freely and never touch a constant.
- **Probably cheaper.** Absorption can be local to the node being rebuilt instead of a separate
  whole-tree pass per round. See §6 for the measurement you must take.

---

## 2. Where things stand

Branch `fix/reduct-classic-alignment-followups`, **PR #509**
(https://github.com/iCog-Labs-Dev/metta-moses/pull/509), based on `origin/dev`.

That PR is deliberately the whole story: it contains the superseded constant-law
implementation **and** the commit reverting it. Read both — the reverted commits carry the
measurements, and several traps in §5 were found there.

**Landed and staying — do not redo, do not revert:**

| commit | what |
|---|---|
| `e1bf6a99` | child command set: issues #502, #503, plus an AND de-pollution neither issue mentions. Also moves `invertLiterals` into `rte-helpers.metta` and rewrites it as a structural head check. |
| `77d9f058` | `dedupSiblings` — erase duplicate conjuncts/disjuncts, as classic does at the top of every `reduce()` |
| `6c0c639e` | `promoteCommonConstraints` counts bare-literal alternatives in the intersection |

**Reverted — this is your job to replace:**

| was | what it did |
|---|---|
| `062acbbf` | `applyConstantLaws` (the four laws over `(AND)`/`(OR)`), dangling-placeholder deletion folded into `nary-gather-junctors`, `zeroConstraintSubsume` rewritten to apply the laws, and the ordering discipline that kept placeholders and constants apart |
| `96a8e0df` | a doc commit explaining an asymmetry in `zeroConstraintSubsume'` that only exists in the reverted design |

The full superseded implementation is preserved on branch
`fix/reduct-classic-alignment-followups` and in **PR #509**
(https://github.com/iCog-Labs-Dev/metta-moses/pull/509). Read those commits — they contain the
measurements and the reasoning, and several of the traps in §5 were discovered there.

---

## 3. What the reverted design achieved, so you know the bar

Measured against the classic C++ reducer over **1128 trees** (508 harvested from every boolean
tree in the reduct test suite, 320 random, 300 generated over 2–3 variables so contradictions and
tautologies are dense):

| | dev | with the reverted design |
|---|---|---|
| semantically identical to classic | 1111 / 1128 | **1128 / 1128** |
| syntactically identical to classic's normal form | 876 / 1128 | 1098 / 1128 |

Suite: 85/85. mux6: `+3.0%, paired t = 1.31` — not significant against a ~9.3% floor.

**Your implementation has to reach 1128/1128 semantic parity too.** Anything less is a
regression against a state that was already verified. If it also buys back the extra traversal,
that is the win; if it does not, say so plainly rather than quietly shipping it.

The specific bug the reverted design fixed, which you must also fix: `(OR (AND A B (NOT B)))` —
an unsatisfiable formula — reduced to **`true`**. Of the four laws in §1, only `OR`+`(AND)`
existed; the missing `AND`+`(OR)` row meant a FALSE was dropped as though it were the identity.

---

## 4. Design notes you need before you start

### 4.1 `TRUE`/`FALSE` must be Symbols, not `true`/`false`

Measured in this runtime:

```
(get-metatype true)            -> Grounded      ;; it is the Bool True, not a symbol
(== true True)                 -> true
(getLiterals (AND A false B))  -> (A B)         ;; the constant is SILENTLY DROPPED
(get-metatype TRUE)            -> Symbol
```

Using `true`/`false` puts a Grounded Bool in the tree and `getLiterals` filters it straight out.
That is the same "constant destroyed" failure class the whole task is about. **Use `TRUE` and
`FALSE`.**

### 4.2 Classify them as CHILDREN, not literals

`isLiterals TRUE` is `true` by default, which would put constants into guard sets, dominant sets
and command sets, and `invertLiterals` would negate them. Instead make `isChildren` accept them
and `isLiterals` reject them. This mirrors what `(AND)`/`(OR)` got for free by being Expressions,
and it means constants ride through `concatTuple $guardSet $children` untouched.

This was already built and unit-tested in the previous session (11/11 assertions), including:

```metta
(= (isConstant $exp) (or (== $exp TRUE) (== $exp FALSE)))
;; isLiterals: Symbol branch -> (and (not (or (== $exp AND) (== $exp OR))) (not (isConstant $exp)))
;; isChildren: Symbol branch -> (isConstant $exp)
;; filterLiterals / filterChildren: same treatment
```

### 4.3 The native Prolog overrides must match

`moses/tests/rte-helpers-fast.pl` is consulted from `moses.metta:58` and overrides `getLiterals`,
`getChildrenExp`, `setDifference`, `getGuardSet`, `isConsistentExp`, `removeEmptyAND` and others.
**A MeTTa-only edit to any of these is inert in the full pipeline.** You must patch
`collect_lits` (exclude `TRUE`/`FALSE`) and `collect_kids` (include them). Verified working.

### 4.4 Scoring needs one small change, and no new evaluation logic

`scoring/boolean-ops.metta:preOrderExp` turns a tree into the eval shape. A `TRUE`/`FALSE` leaf
would otherwise be looked up as a column label. Emit the matching junctor identity instead:

```metta
(= (preOrderExp (mkTree (mkNode TRUE) ()))  (quote (AND ())))
(= (preOrderExp (mkTree (mkNode FALSE) ())) (quote (OR ())))
```

`(AND ())` is `(all ())` = True and `(OR ())` is `(any ())` = False, so the existing operator
clauses evaluate constants correctly with nothing else added. Verified.

### 4.5 The sites that must emit a constant

These are the places a junctor can be emptied today. Each needs to emit `TRUE`/`FALSE` at the
point of detection instead:

| file | what happens there |
|---|---|
| `delete-inconsistent-handle.metta` | inconsistent handle set. **Already** returns `((OR) () True)` when the POA is a conjunct; the other branch removes the POA from an OR and can empty it |
| `promote-common-constraints.metta` | a branch emptied by promotion is a tautology |
| `one-constraint-subsumption.metta` | removes a subsumed branch; can empty the OR |
| `zero-constraint-subsumption.metta` | 0-subsumption: an alternative with no constraints is TRUE |
| `cut-unnecessary-and.metta` | `andCut`, and the native `removeEmptyAND` which turns `(AND)` into `Nothing` |
| `cut-unnecessary-or.metta` | `orCut` |
| `reduce-to-elegance.metta` | `$finalCurrent'` when the current node was deleted; the `(== $current (OR))` guard in `applyReduce` |

`grep -rn "removeElement\|subtraction-atom\|filter-atom" reduct/boolean-reduct/*.metta` finds them.

---

## 5. What NOT to do

Every item here cost real debugging time. Several are silent failures.

1. **Do not use `unify` with a live-head pattern.** `(unify $literal (NOT $x) $x (NOT $literal))`
   breaks once `scoring/boolean-ops` is loaded, because that makes `NOT` a DEFINED head.
   Measured: `(unify A (NOT $x) $x SAFE)` returns **two** solutions; `(unify (NOT B) (NOT $x) $x SAFE)`
   returns **none**. Zero solutions then propagate silently until `reduce-to` returns nothing,
   `cleanTree` fails, `buildKnobs` fails and `createRepresentation` quietly yields no deme — the
   visible symptom is a test with FEWER ✅ than asserts, NO ❌, and exit 0. Use a structural head
   check. See memory `petta-live-head-unify-hazard`.

2. **Do not build a live-head term bare.** `(NOT $literal)` in an evaluated position is a call.
   Use `quote` (substitutes bindings, strips once) and comment the hazard.

3. **Do not add an `import!` header to a reduct module.** `import!` does not dedupe and has caused
   OOM kills. Put shared helpers in `rte-helpers.metta`, which every consumer imports first.

4. **Do not put dedup before `addAND`.** `addAND`'s wrapping is what creates most duplicates —
   `(OR (AND B) B ...)` normalises to `(OR (AND B) (AND B) ...)` — and a duplicate alternative
   desynchronises the OR walker. It must run after.

5. **Do not collapse `$parent` inside `zeroConstraintSubsume'`.** It only receives
   `($parent $current)`, so rewriting `$parent` discards whatever it was nested inside, and the
   RTE walkers do not always pass a genuine parent/child pair. Measured: it turned
   `(OR !C B (AND (OR !C B) (OR B !C)))` into `false` instead of `!C v B`. If your design needs to
   propagate upward from here, that is a signal it wants classic's `Delete`/`Disconnect` return
   value rather than tree rewriting — see §9.

6. **Do not compare against classic syntactically.** Classic's effort-2 normal form is not always
   minimal and this reducer sometimes returns a smaller equivalent tree. A shape comparison
   overstates divergence. Compare truth tables, and report syntactic agreement separately.

7. **Do not trust a green suite.** Six expectations passed while asserting `A ^ B` reduces to
   `true`. See §7.3.

8. **Do not run the suite from inside `.claude/worktrees/`.** Relative imports resolve against the
   CWD first and silently load the main checkout's files. Copy to a standalone directory named
   `metta-moses` outside the repo. See memory `run-tests-worktree-dirname`.

9. **Bound every PeTTa run, including probes:** `( ulimit -v 8000000; timeout N ... )`. An
   unbounded run can OOM-kill the session.

10. **Do not accumulate gate copies.** The previous session filled the 7.5G tmpfs with 16 repo
    copies and a mid-rsync quota failure then broke an unrelated `git push`. Exclude
    `moses/demo-problems-test/logs` from copies and delete each gate when done.

11. **Do not benchmark carelessly.** Check the CPU governor and AC/battery first (battery is ~40%
    slower). Alternate A/B pairs, never blocks. mux6 needs pooling — two independent n=5 blocks
    have given +2.4% and −5.6%, both non-significant and opposite in sign.

12. **`true`/`false` are not symbols.** See §4.1. This is the single most likely way to waste a day.

---

## 6. How to verify

### 6.1 The classic oracle

Classic MOSES is at `/home/yab/Documents/Projects/iCog/HyperonRelated/MOSES/OpenCog/Moses`.
Libraries are prebuilt; only the harness needs compiling:

```sh
cd <Moses>/build/tests/comboreduct/reduct && make test_reduct
```

If it dies with `libboost_*.so.1.91.0: cannot open shared object file`, boost was upgraded
underneath it. Extract the matching libs and point `LD_LIBRARY_PATH` at them — do **not** symlink
across the ABI or rebuild the world:

```sh
mkdir -p <scratch>/boost191 && cd <scratch>/boost191
tar --use-compress-program=unzstd -xf /var/cache/pacman/pkg/boost-libs-1.91.0-2-x86_64.pkg.tar.zst usr/lib
```

Wrapper (the second argument is the reduction **effort** 0–3, NOT an arity; run all three, and if
they agree the answer is not an artifact of effort 3's truth-table pruning):

```sh
#!/bin/sh
BIN=<Moses>/build/tests/comboreduct/reduct/test_reduct
export LD_LIBRARY_PATH=<scratch>/boost191/usr/lib
printf '%-58s' "$1"
for e in 1 2 3; do
  printf ' | e%s: %s' "$e" "$("$BIN" "$1" "$e" 2>&1 | grep 'Simplified tree' | sed 's/.*: //')"
done
echo
```

Combo syntax: `$1`, `!$1` or `not($1)`, `and(...)`, `or(...)`. `true`/`false` are real vertices;
childless `and()`/`or()` are **dangling placeholders deleted by classic's pre-pass**, NOT the
constants. Confirm with `and($1 or())` -> `$1` but `and($1 false)` -> `false`.

**Always re-verify the oracle on a case with a known answer before trusting it on a new one.**
The binary was silently wiped mid-session once by something outside the session, and every call
returned an empty string.

### 6.2 The 1128-tree differential

Build three corpora and compare each tree's `reduce-to` output against classic **by truth table**:

- **harvested (508)** — every distinct boolean tree appearing anywhere in
  `reduct/boolean-reduct/tests/*.metta` and `utilities/tests/tree-test.metta`, inputs *and*
  expected values, regardless of which function the assertion calls. Wrap each in `reduce-to`.
- **random (320)** — depth 1–3, 3–5 variables.
- **adversarial (300)** — depth 1–3 over only **2–3 variables**, ~50% negation, so contradictions
  and tautologies are dense. **This one earns its keep**: the other 828 trees all passed while it
  found three real defects, including a regression the previous session had introduced.

Harness notes that cost time to get right:

- Treat a childless `(AND)`/`(OR)` in an **input** as a placeholder to delete, but in an
  **output** as a constant. Mixing the two lenses produces false positives.
- Deduplicate children **before** collapsing a single-child junctor, or `(AND C C)` canonicalises
  to a 1-tuple and prints as `and(C)`.
- Map literals back through the `$n` numbering you sent to classic; do not assume an alphabet.

### 6.3 The suite

```sh
rsync -a --exclude '.git' --exclude '.claude' --exclude 'moses/demo-problems-test/logs' ./ <scratch>/gate/metta-moses/
cd <scratch>/gate/metta-moses && ( ulimit -v 16000000; timeout 3000 python3 -u scripts/run-tests.py )
```

Baseline on dev is **85 files / 0 failed**. `run.sh` must be on PATH (it resolves to
`/home/yab/PeTTaV1`). A failing `assertEqual` halts that file, so the first failure hides every
later one — see §7.3.

### 6.4 The benchmark

```sh
sh /home/yab/PeTTaV1/run.sh moses.metta -s --problem=mux6 --nEval=1000 --maxGen=10
```

Governor `performance`, on AC, alternating A/B pairs, n>=6 each, paired t-test. Expect a
resolution floor around 4–9%. **You are claiming this design buys back a traversal — measure it
against both `origin/dev` and PR #509's head**, or do not make the claim.

Note: the mux6 `FinalResult` md5 was historically `29a0a867` and the reverted design changed it to
`0565b097`. Both solve mux6 perfectly (10 candidates, all score 0, 8 of 10 identical) — a reducer
change moves the search trajectory. Do not treat a hash change as a regression; check the scores.

---

## 7. How we work here

### 7.1 Root cause before fix

No fix without a confirmed root cause, and no expectation edit without a classic-side verdict.
When a hypothesis is stated, label it as a hypothesis and then go and measure it. The previous
session reported a blocker that turned out to be an artifact of testing a weaker variant of the
design — do not repeat that: make sure the thing you measured is the thing being proposed.

### 7.2 Test expectations need explicit approval

**Never remove, disable or semantically modify a test without asking.** Bring the owner each
changed expectation with: the input, the old value, the new value, and classic's verdict, grouped
by cause. They will approve or reject per group. This is a hard rule in this repo.

### 7.3 Unmask before editing expectations

A failing `assertEqual` halts the file. Comment out the blocker **in a scratch copy** and re-run
until green, so you see every failure rather than just the first. Never rewrite an expected value
to whatever came out. Locate assertions by their expected text, not by counting ✅ — some
assertions emit several.

### 7.4 Audit every changed expectation two ways

This is the step the previous session skipped and had to come back for. For each changed
expectation check **both**:

1. Is it meaning-preserving with respect to **its own input**? Embed the call's dominant and
   command sets: `C v (D ^ parent_in)` must equal `C v (D ^ parent_out)`.
2. Does it agree with **classic** on that same embedding?

Six expectations passed the suite while failing both — they asserted things like "`A ^ B` reduces
to `true`" — because their inputs contain a knob placeholder and a unit call into the internals
bypasses the pass that deletes placeholders. Classic agreed with the pre-change values every time.

### 7.5 Subagents

Use them for independent, parallelisable work: running a corpus against classic, sweeping a
battery, auditing a file's expectations. Give each one a self-contained brief and have it report
conclusions, not file dumps. Do not use them to make design decisions or to edit expectations —
those come back to the owner.

### 7.6 Reporting

State measurements, not impressions. If something is not significant, say so with the number. If
you changed your mind, say what changed it. Correct your own earlier claims explicitly when new
evidence lands.

---

## 8. Step-by-step plan

Gate each step; do not batch them.

1. **Read** the reverted implementation on `fix/reduct-classic-alignment-followups` (commits
   `062acbbf` and `96a8e0df`) and the memory notes in §10. Rebuild the oracle (§6.1) and confirm
   it is faithful on two known answers.
2. **Baseline.** Build the three corpora (§6.2) and score the current branch against classic.
   Record the number. It will be short of 1128/1128 — the false-propagation defect is back.
   Confirm `(reduce-to (OR (AND A B (NOT B))))` gives `true` today.
3. **Classification.** Add `isConstant`, and teach `isLiterals`/`isChildren`/`filterLiterals`/
   `filterChildren` plus the two native Prolog predicates (§4.2, §4.3). Unit-test that a constant
   survives `getLiterals`/`getChildrenExp`/`getGuardSet` in the right slot. No behaviour change yet.
4. **Scoring.** Add the two `preOrderExp` clauses (§4.4) and check a constant leaf scores.
5. **Emission.** Convert the sites in §4.5 one at a time, running the corpus after each. This is
   the substance of the task and where the previous attempt stopped.
6. **Absorption.** Add the four laws. Try making it local to node rebuild rather than a
   whole-tree pass — that is the compute win. If local turns out not to work, say so and measure
   the pass version instead.
7. **Corpus to 1128/1128.** Iterate until semantic parity with classic is total.
8. **Suite**, then §7.3 unmasking, then §7.4 auditing, then bring the expectation changes to the
   owner in groups.
9. **Benchmark** (§6.4) against dev and PR #509.
10. **Commit** per logical fix. Note that the previous session could only make the tip green,
    because the fixes are entangled and later commits revised test lines earlier ones touched; if
    you want green-at-every-commit you must gate each with a suite run.

---

## 9. The thing to decide early

The previous session hit this and it is worth confronting on day one rather than day three.

Classic keeps **three** things separate:

- `logical_true` / `logical_false` — real vertices
- childless `and()` / `or()` — dangling placeholders, deleted by a pre-pass
- `Result { Delete, Disconnect, Keep }` — a **signal returned up the recursion**, never a node

This repo has no signal channel: PR #501 deliberately removed `Delete`/`Disconnect` and made the
RTE tuple `($parent $current $applied)`. Every propagation is therefore a tree rewrite, which is
exactly why `zeroConstraintSubsume'` cannot collapse safely (§5.5).

Distinct constant vertices want the signal channel too. If, partway through §8 step 5, you find
yourself unable to propagate a constant upward without losing enclosing context, **stop and raise
it** — the answer may be to restore the three-valued return rather than to keep rewriting trees.
That is a larger change and it is the owner's call, not yours.

---

## 10. Where to look

**Source**

| file | role |
|---|---|
| `reduct/boolean-reduct/reduce-to-elegance.metta` | the RTE walk, `applyReduce`, `reduce-to` |
| `reduct/boolean-reduct/rte-helpers.metta` | shared helpers; `invertLiterals`, `dedupSiblings`, the literal/children classifiers |
| `reduct/boolean-reduct/zero-constraint-subsumption.metta` | 0-subsumption |
| `reduct/boolean-reduct/delete-inconsistent-handle.metta` | contradiction detection |
| `reduct/boolean-reduct/promote-common-constraints.metta` | promotion and tautology detection |
| `reduct/boolean-reduct/n-ary-gather-junctors.metta` | flattening, `addAND` |
| `moses/tests/rte-helpers-fast.pl` | native overrides, consulted at `moses.metta:58` |
| `scoring/boolean-ops.metta` | `preOrderExp` and the AND/OR/NOT clauses |
| `utilities/tree.metta` | `cleanTree` -> `reduce-to` |

**Classic**: `OpenCog/Moses/moses/comboreduct/reduct/logical_rules.{h,cc}` —
`subtree_to_enf::reduce_to_enf`. Key lines: `:181` the Result enum, `:462` root handling,
`:642` complement erasure against the negated command set, `:652` 0-subsume, `:658` 1-subsume,
`:715` `reduce_and` child handling, `:806`/`:817` `reduce_or`.

**Memory** (`~/.claude/projects/-home-yab-...-metta-moses/memory/`): `reduct-constant-laws`,
`reduct-and-or-constants-vs-placeholders`, `classic-reduct-differential-harness`,
`petta-live-head-unify-hazard`, `petta-call-semantics`, `native-prolog-override-conventions`,
`run-tests-worktree-dirname`, `mux6-perf-baselines`, `feedback-bound-petta-runs`,
`feedback-unmask-before-editing-expectations`, `feedback_never_remove_tests`.

**Issues / PRs**: #502 and #503 (fixed, on this branch), #501 (merged, introduced the
`(AND)`/`(OR)` constant convention), #509 (the superseded design, kept as the reference).

---

## 11. Done means

- `(reduce-to (OR (AND A B (NOT B))))` is `FALSE`, and every unsatisfiable input reduces to false
- **1128 / 1128** semantic parity with classic across the three corpora
- suite back to **85 / 85**, every changed expectation audited per §7.4 and approved per §7.2
- mux6 measured against dev and #509, with the traversal claim either demonstrated or withdrawn
- constants never reach a guard set, a dominant set or a command set
- no `import!` added to a reduct module, no `unify` on a live head, no scratch files left behind
