# Backlog: known bugs

The cleanup of `dev` (branch `chore/dev-cleanup`, October 2026) found these bugs. The cleanup kept the behaviour, so each bug is still in the code. A fix changes behaviour. Give each fix its own branch, a regression test, and the lead's approval.

Line numbers are from `chore/dev-cleanup`. "Probe" means a bounded PeTTaV1 run that shows the effect.

## High: wrong results in a supported mode

### B1. `instanceFs>=` is always false

- **Where:** `representation/instance.metta:173`.
- **What:** the body calls `=>`. No file and no PeTTa built-in defines `=>`. The call stays unreduced, and `if` treats it as false.
- **Probe:** `!(instanceFs>= (mkSInst (mkPair a 0.9)) (mkSInst (mkPair b 0.1)))` gives `(=> 0.9 0.1)`.
- **Effect:** `crossTopOneFs` (`optimization/hillclimbing/crossover.metta`) sorts with it. With `--fsAlgo=hc`, the "top" reference row is not the best row.
- **Likely fix:** `(>= $score1 $score2)`. Feature-selection results will change.

### B2. `--fsAlgo=inc` and `--fsAlgo=smd` do not run

- **Where:** `feature-selection/feature-selection-main.metta:78-79`.
- **What:** the dispatch calls `incremental-feature-selection` and `smd-feature-selection`. `moses-imports.metta` loads `incremental.metta` and `smd.metta`, which define other names (`incrementalSelection`, `stochasticMaxDependency`). The dispatched files are not loaded.
- **Probe:** in the production load context, `(featureSelection smd ...)` and `(featureSelection inc ...)` return the unreduced call.
- **Also:** `parameters/defaults.metta` lists `mi` as an fsAlgo value, but `featureSelection` has no `mi` branch, so it gives zero solutions.
- **Decision first:** each algorithm has two implementations with different MI code. The lead chooses one of each pair. Then delete the other file and fix the dispatch.

### B3. `isActionSeqOp` is false for `and_seq` and `or_seq`

- **Where:** `reduct/action-reduct/reduce-action-properties.metta:23-24`.
- **What:** the literal list `(and_seq or_seq exec_seq)` is a live-head site in production. After `scoring/action-ops` loads, `and_seq` and `or_seq` are function heads.
- **Probe:** with `moses-imports`, `(isActionSeqOp and_seq)` and `(isActionSeqOp or_seq)` give `False`. `(isActionSeqOp exec_seq)` gives `True`.
- **Effect:** `reduceIdempotent` and `reduceAdditive` never fire for `and_seq` and `or_seq` nodes in a real run.
- **Likely fix:** `quote` the list, or compare with `==`. Check `actionTreeToExpression` (`reduct/action-reduct/action-reduction.metta`), which has the same kind of list.

### B4. `sampleEnforcedFts` returns `(Empty)` values

- **Where:** `feature-selection/select-top-features.metta:80`.
- **What:** it writes `(Empty)`, not `(empty)`. `(Empty)` is data, not "no solution".
- **Probe:** `(sampleEnforcedFts ((A 0.0) (B 1.0)))` gives `((Empty) B)`.
- **Effect:** only when `$enforced-fts` is not `()` (`representation/representation.metta`).

## Medium: silent failure or hidden duplicate work

### B5. `optimizerFor` matches only `hc`

- **Where:** `moses/demo-problems.metta:334`.
- **What:** the head is `(optimizerFor hc)`, and the body does `case` on the unbound `$optimizer`. Any other value gives zero solutions. The error branch never runs.
- **Probe:** `(collapse (optimizerFor sa))` gives `()`.
- **Fix:** head `(optimizerFor $optimizer)`. Then `--optAlgo=sa` prints the documented error and halts.

### B6. Overlapping clauses give duplicate solutions

Each item gives each result two or more times. A `(cut)` or a `once` hides most of them today, but the work runs.

| Function | Where | Overlap |
|---|---|---|
| `removeDupInsts` | `deme/merge-demes.metta:15,17` | Clause 2 and clause 3 both match a one-element list. Probe: two equal solutions. |
| `demeToTrees` | `deme/merge-demes.metta:140,163` | Both match an empty deme with a 1-field `mkActionCtx`. |
| `List.getByIdx` | `utilities/list-methods.metta:38-39` | Both match `()`. Probe: two `(Error () (Index out of range))`. |
| `getNodeById` | `utilities/nodeId.metta:38-40` | Clauses 2 and 3 overlap. `(getNodeById () (mkNodeId (1 2 3)))` gives 3 solutions. |
| `coll.length` and other `coll.*` | `utilities/general-helpers.metta:735-758` | `(coll.length ())` has 4 clauses. |
| `materializeCandidateForContext` | `optimization/hillclimbing/hill-climbing-helpers.metta:239-245` | Clause 3 also matches action contexts, so they get 2 solutions. `seedTreeScoreCache` runs before the `cut`. |

### B7. `reduceToElegance` matches only the literal `(NOT A)`

- **Where:** `reduct/boolean-reduct/reduce-to-elegance.metta:28`.
- **What:** the pattern `(Expression (NOT A))` binds no variable. It matches only the symbol `A`, not any negation. A `(NOT B)` falls into the general arm.
- **Check:** compare with classic MOSES (`docs/agents/classic-oracle.md`) before you change it.

## Low: latent, dead or test-only

| ID | Bug | Where |
|---|---|---|
| B8 | `deleteInconsInGrandchildren` uses one grandchild as the parent of the next one when there are two or more. Not probed. | `reduct/boolean-reduct/delete-inconsistent-handle.metta` |
| B9 | `transform` case arms reuse the bound `$complexityRatio`, so an arm matches only when the context ratio equals the argument. Only tests and the SA/univariate code call `transform`. | `deme/score-deme.metta:47` |
| B10 | `crossTopOneFs` uses `(- $nToMake 1)` and sorts `$nToMakeNew` rows; `crossTopOne` uses `$nToMakeNew` and `+ 1`. No stated reason. | `optimization/hillclimbing/crossover.metta` |
| B11 | `replaceVarWithTruth` builds `(AND OR)` bare. After `boolean-ops` loads, that is a call. Production uses the native override, so only test contexts can see it. | `scoring/bscore.metta:99` |
| B12 | `xmplrInit` uses `(pow-math 10 -37)` (+1e-37) as the worst score. Classic uses `very_worst_score` (-1e37). | `metapopulation/exemplar-type.metta:33` |
| B13 | `mkDemeId` is declared `(-> Number DemeId)`, but production passes strings and expressions. Probe before any edit: type declarations can make static calls fail in silence. | `metapopulation/exemplar-type.metta:4` |
| B14 | `decrementState` computes `int - state`, not `state - int`. No caller. | `utilities/general-helpers.metta:1126` |
| B15 | `profile` calls `(round $avg 3)`, but `round` has only a 1-argument clause. | `utilities/general-helpers.metta:19` |

## Tests that check nothing

| ID | Test | Problem |
|---|---|---|
| T1 | `representation/tests/create-representation-test.metta` | 0 live asserts |
| T2 | `deme/tests/create-deme-test.metta` | All asserts are commented out, so `createDeme` has no direct test. |
| T3 | `metapopulation/tests/exemplar-type-test.metta` | Uses `!(test` only; `run-tests.py` counts nothing. |
| T4 | `utilities/tests/general-helper-functions-test.metta:344` | Calls `cleanSpace`, which no loaded file defines. The assert is vacuous. |
| T5 | `parameters/tests/cli-test.metta:42` | Sets `--steps=700`, a parameter that no longer exists. |

## Tooling

- `scripts/test_moses.py`: its template `moses/tests/demo-problems-test.metta` has a stale import list, and `stopped_generation` is always -1 (it parses `Generation N` lines that no code prints).
- `scripts/run-tests.py`: `rglob` also collects test files under hidden folders such as `.claude/worktrees/`. CI is not affected.
