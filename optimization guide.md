# Optimization Guide

## Goal

This note summarizes which `metta-moses` functions appear least suitable for PeTTa's current fast/native execution model and are therefore good candidates for optimization or native reimplementation.

It is based on:

- the current PeTTa execution model in `/home/yab/PeTTaV1`
- the hot paths observed in the MOSES profiler output
- the structure of the `metta-moses` MeTTa sources

## PeTTa Fast Path vs Slow Path

### PeTTa is strongest when

- a MeTTa function becomes a direct compiled Prolog predicate
- higher-order calls can be specialized with a concrete function argument
- pseudo-native helpers such as `'map-atom'`, `'foldl-atom'`, and `'filter-atom'` are used

Relevant implementation points in PeTTa:

- `src/translator.pl:49-64`
- `src/translator.pl:216-234`
- `src/specializer.pl:13-58`
- `src/metta.pl:557-565`

### PeTTa is weaker when

- execution goes through generic `reduce([F|Args], Out)` dispatch
- lambdas and `partial(...)` closures are created dynamically
- `eval(...)` is used to execute dynamically assembled code
- generic recursive MeTTa list combinators are used heavily
- recursive control combinators repeatedly invoke dynamic predicates/functions

Relevant implementation points in PeTTa:

- `src/translator.pl:49-64`
- `src/translator.pl:235-252`
- `src/translator.pl:284`

## Main Profiling Interpretation

The MOSES runtime is dominated less by the top-level wrappers like `runMoses` and more by repeated transformation, reduction, and tree-construction work underneath them.

One important detail about the profiler output used here:

- the flat table is ordered from colder functions to hotter ones
- the top of `output.log` is therefore mostly noise and tiny specialized helpers
- the expensive functions are near the bottom of the flat table and in the nested call tree

The main expensive region is roughly:

```text
runMoses
-> getCandidate
-> getCandidateRec
-> cleanTree
-> reduce-to
-> reduceToElegance
-> applyAndTransformations / applyOrTransformations
-> until ... loops
```

This is important because many of these functions use exactly the kinds of generic recursive and higher-order patterns that are not ideal for PeTTa's current fast path.

## Profile-Verified Hotspots From `output.log`

The following list reflects the measured hotspots from the current run in `output.log`, cross-checked against the earlier structural analysis of what PeTTa handles poorly.

These are not just the highest raw totals. They are the functions that are both:

- materially expensive in the current profile
- plausible optimization targets given PeTTa's internals

## 1. `getCandidate/3`

- `output.log:916`
- measured time: `11.586 s`

Why it matters:

- this is the main hot pipeline entry under the real workload
- it drives `getCandidateRec`, `cleanTree`, and repeated tree operations

PeTTa cross-check:

- consistent with the earlier recommendation
- expensive because it forces deeper slow-shape recursion and tree rebuilding

## 2. `cleanTree/2`

- `output.log:972`
- measured time: `8.089 s`

Why it matters:

- one of the biggest costs in the current run
- forces tree -> expression -> reduction -> tree conversion

PeTTa cross-check:

- consistent with earlier recommendation
- repeated representation conversion is not ideal for PeTTa's fast path

## 3. `reduce-to/2`

- `output.log:980`
- measured time: `8.076 s`

Why it matters:

- it is the direct reduction driver inside `cleanTree`
- it pushes execution into repeated transformation passes

PeTTa cross-check:

- structurally aligned with earlier `reduceToElegance` / `until` concerns
- this run shows it deserves explicit priority as well

## 4. `getCandidateRec/7`

- `output.log:922`
- measured time: `3.497 s`

Why it matters:

- recursive candidate builder in the hot path
- heavy tree-copy / tree-update logic

PeTTa cross-check:

- strongly consistent with earlier recommendation
- deep recursive structural manipulation is a weak spot for current execution

## 5. `List.foldl_Spec_[applyGetCandidateRec]/4`

- `output.log:968`
- measured time: `3.168 s`

Why it matters:

- significant time is going through a higher-order fold over candidate construction
- even specialized, this still represents expensive recursive list/state threading

PeTTa cross-check:

- directly confirms the earlier warning about generic `List.foldl`

## 6. `applyReduce/2`

- `output.log:985`
- also appears as a larger expanded subtree at `output.log:1144`

Why it matters:

- central reducer that feeds directly into `reduceToElegance`
- large practical share of the hot reduction pipeline

PeTTa cross-check:

- matches earlier suspicion that the reduction kernels are worth native work

## 7. `reduceToElegance/5`

- `output.log:1002`
- measured time: `2.455 s`

Why it matters:

- core structural transformation kernel
- repeatedly re-entered through cycles and `until` loops

PeTTa cross-check:

- one of the clearest matches with the earlier analysis

## 8. `until_Spec_[reduceNotApplied,applyReduce]/4`

- `output.log:983`
- measured time: `2.499 s`

Why it matters:

- confirms that the generic `until` pattern is materially expensive in practice

PeTTa cross-check:

- directly validates the earlier recommendation to optimize `until` first

## 9. `applyAndTransformations/2`

- `output.log:1076`
- measured time: `1.478 s`

Why it matters:

- one of the main transformation kernels in the hot reduction chain
- repeatedly traverses and rewrites structure

PeTTa cross-check:

- consistent with earlier recommendation

## 10. `applyOrTransformations/2`

- `output.log:1051`
- measured time: `0.929 s`

Why it matters:

- paired with `applyAndTransformations`
- structurally similar and repeatedly used

PeTTa cross-check:

- also consistent with earlier recommendation

## Strong Honorable Mentions

These are also worth attention and reinforce the same conclusions:

- `scoreTree/4` at `output.log:903`
- `preOrder/2` at `output.log:907`, `979`
- `buildTree/2` at `output.log:974`
- `until_Spec_[transformationsNotApplied,applyAndTransformations]/4` at `output.log:1074`
- `until_Spec_[hasNoNextChild,applyReduceToEleganceToOr]/4` at `output.log:1123`
- `until_Spec_[hasNoNextChild,applyReduceToEleganceToAnd]/4` at `output.log:1067`

These were already suspicious structurally, and the current profile output supports that suspicion.

## Top Candidates For Optimization

## 1. `until`

File:

- `utilities/general-helpers.metta:147-159`

Why it is a poor fit:

- uses `eval ($predicate $x)`
- uses `eval (until ...)` recursively
- behaves like a dynamic fixpoint loop rather than a static compiled call

Why it matters:

- many hot functions in the profile are `until_Spec_[...]`
- this helper amplifies the cost of transformation and reduction passes

Optimization idea:

- replace with a native loop/fixpoint primitive on the PeTTa side
- or compile a dedicated Prolog helper for fixpoint iteration

## 2. `applyAndTransformations`

File:

- `reduct/boolean-reduct/reduce-to-elegance.metta:133-209`

Why it is a poor fit:

- nested tree traversals
- repeated `until` usage
- repeated structural updates and child iteration

Why it matters:

- one of the strongest computational hotspots in the profile
- drives a large fraction of total runtime

Optimization idea:

- native implementation of the transformation loop
- reduce repeated recomputation of guard sets / children / replacements

## 3. `applyOrTransformations`

File:

- `reduct/boolean-reduct/reduce-to-elegance.metta:253-293`

Why it is a poor fit:

- same issues as `applyAndTransformations`
- repeated `until`, recursive structural transforms, child-wise reprocessing

Optimization idea:

- same style as above: native loop + fewer repeated passes

## 4. `reduceToElegance`

File:

- `reduct/boolean-reduct/reduce-to-elegance.metta:23-124`

Why it is a poor fit:

- large control-heavy dispatcher
- repeated structural decomposition and reconstruction
- repeatedly re-enters the transformation loops

Why it matters:

- central orchestrator in the hottest reduction pipeline

Optimization idea:

- candidate for a dedicated native implementation
- or at minimum split into smaller specialized native helpers for AND/OR cases

## 5. `getCandidateRec`

File:

- `representation/representation.metta:180-259`

Why it is a poor fit:

- deep recursive tree copy/build logic
- uses `List.foldl`, `getNodeById`, `appendChild`, repeated child traversal
- significant recursive structural manipulation

Why it matters:

- major hotspot in the profile
- central to candidate generation

Optimization idea:

- native tree-copy/build helper
- avoid repeated path-based node lookup and reconstruction where possible

## 6. `getCandidate`

File:

- `representation/representation.metta:126-149`

Why it is a poor fit:

- not expensive by itself, but it forces expensive downstream work:
  - `getCandidateRec`
  - `preOrder`
  - `buildTree`
  - `cleanTree`

Optimization idea:

- optimize together with `getCandidateRec`
- avoid unnecessary conversion or cleanup passes when possible

## 7. `cleanTree`

File:

- `utilities/tree.metta:90-100`

Why it is a poor fit:

- does a full tree -> expression -> reduced expression -> tree pipeline
- depends on `preOrder`, `reduce-to`, and `buildTree`

Why it matters:

- one of the biggest hotspots in the measured run

Optimization idea:

- avoid repeated conversion between tree and expression forms
- provide a native tree-normalization path if possible

## 8. `preOrder`

File:

- `utilities/tree.metta:28-39`

Why it is a poor fit:

- recursive traversal using:
  - `List.map`
  - `List.filter`
  - `List.listToExpr`

Why it matters:

- appears repeatedly inside hot code
- contributes to tree-expression conversion overhead

Optimization idea:

- replace with a native traversal helper
- or rewrite the hot path to avoid needing a full preorder rebuild so often

## 9. `buildTree`

File:

- `utilities/tree.metta:68-85`

Why it is a poor fit:

- recursive expression-to-tree reconstruction
- repeatedly paired with `preOrder`

Optimization idea:

- native expression-to-tree constructor
- avoid full rebuilds after every transform if a more local update is possible

## 10. `scoreTree`

File:

- `scoring/bscore.metta:62-81`

Why it is a poor fit:

- combines generic higher-order features heavily:
  - `List.map`
  - `compose`
  - `curry`
  - `evaluate`
  - `eval`
  - `List.flatten`

Why it matters:

- this is exactly the type of dynamic higher-order workload that tends to bypass PeTTa's best execution path

Optimization idea:

- replace the scoring map/eval pipeline with a native batch evaluator
- or specialize the `replaceVarsWithTruth` + `evaluate` pipeline more aggressively

## Foundational Helpers That Likely Amplify Cost

These helpers are not necessarily the biggest standalone hotspots, but they are repeatedly used inside hot functions and are currently written as generic recursive MeTTa definitions.

## `List.map`

File:

- `utilities/list-methods.metta:90-91`

Risk:

- generic higher-order recursion
- often called with composed or curried functions

## `List.foldl`

File:

- `utilities/list-methods.metta:14-15`

Risk:

- generic higher-order recursion
- used in hot recursive/state-threading code such as candidate construction

## `List.filter`

File:

- `utilities/list-methods.metta:108-109`

Risk:

- dynamic predicate/function argument

## `List.zipWith`

File:

- `utilities/list-methods.metta:219-221`

Risk:

- generic higher-order recursion over two lists

## `List.getByIdx`

File:

- `utilities/list-methods.metta:50-51`

Risk:

- linear recursive lookup
- heavily repeated in tree/path navigation

## `List.replaceAt`

File:

- `utilities/list-methods.metta:146-148`

Risk:

- linear recursive reconstruction
- expensive when repeatedly used in tree updates

## Why These Are Likely Not Ideal For PeTTa Native Execution

The key issue is that many hot MOSES functions are built from:

- generic list recursion
- dynamic higher-order calls
- `compose`, `curry`, and lambda-like closures
- repeated `eval`
- repeated tree rebuilding and node path traversal

These patterns are much less friendly to PeTTa than direct first-order predicate-style execution.

By contrast, PeTTa's strongest current paths are:

- direct compiled calls
- selectively specialized higher-order calls
- special pseudo-native combinators like `'map-atom'`, `'foldl-atom'`, `'filter-atom'`

`metta-moses` often uses its own generic `List.*` recursion instead of these pseudo-native forms in the hottest code.

## Suggested Priority Order

If the goal is highest likely payoff first, this is the recommended order after incorporating the measured `output.log` results:

1. `until`
2. `getCandidateRec`
3. `cleanTree`
4. `reduce-to`
5. `reduceToElegance`
6. `applyAndTransformations`
7. `applyOrTransformations`
8. `List.foldl`
9. `preOrder`
10. `buildTree`

Why this order changed slightly:

- the profiler strongly confirms the importance of `getCandidate`, `cleanTree`, and `reduce-to`
- `List.foldl` is no longer just a theoretical concern: it is visible in the hot path through `List.foldl_Spec_[applyGetCandidateRec]/4`
- `until` remains the most structurally suspicious and is also now directly validated by profile time

## Most Promising Native Rewrite Themes

### 1. Native fixpoint/loop support

Primary target:

- `until`

Likely impact:

- improves all `until_Spec_[...]` hotspots at once

### 2. Native tree navigation and update helpers

Primary targets:

- `getNodeById`
- `appendChild`
- `replaceNodeById`
- `getChildrenExp`
- `getCandidateRec`

Likely impact:

- reduces repeated recursive structural overhead in candidate generation and transformations

### 3. Native normalization/transformation kernels

Primary targets:

- `reduceToElegance`
- `applyAndTransformations`
- `applyOrTransformations`
- `cleanTree`

Likely impact:

- largest total runtime reduction if done well

### 4. Native list/higher-order kernels for hot paths

Primary targets:

- `List.map`
- `List.foldl`
- `List.filter`
- `List.zipWith`

Likely impact:

- broad improvement across tree traversal, scoring, and candidate-generation paths

## Short Conclusion

The functions least suitable for PeTTa's current native/fast execution model are the generic higher-order recursive helpers and the tree-rewrite loops built on top of them.

The clearest native implementation candidates are:

- `until`
- `getCandidateRec`
- `cleanTree`
- `reduceToElegance`
- `applyAndTransformations`
- `applyOrTransformations`
- `scoreTree`

The generic `List.*` helpers are also important because they amplify cost across many of the above hotspots.

The current `output.log` confirms that this is not only a structural suspicion. The measured hot path is dominated by exactly these patterns:

- fixpoint-style `until` loops
- recursive candidate construction
- repeated tree normalization and rebuilding
- reduction pipelines built from generic higher-order recursive helpers

## Implementation Roadmap

This section turns the analysis into a concrete execution plan.

The goal is not just to optimize the hottest functions individually, but to attack the shared execution patterns that PeTTa currently handles less efficiently:

- dynamic fixpoint iteration
- recursive structural tree updates
- repeated tree/expression conversion
- generic higher-order list recursion

## Phase 1: Highest Return, Lowest Conceptual Risk

These changes should produce visible wins quickly while staying fairly local in scope.

### 1. Native `until` / fixpoint helper

Targets:

- `utilities/general-helpers.metta:147-159`
- all `until_Spec_[...]` hotspots in the profile

Why first:

- affects multiple hotspots at once
- validated both structurally and by profile output
- avoids repeated `eval` and recursive dynamic control

Expected impact:

- high
- should reduce overhead in `applyReduce`, `applyAndTransformations`, `applyOrTransformations`, and child-rewrite loops simultaneously

Risk:

- medium
- semantic correctness matters because `until` is a control primitive used widely

Recommended form:

- add a PeTTa/Prolog-side fixpoint helper with explicit predicate/function application
- preserve current MeTTa semantics while removing dynamic `eval` recursion

### 2. Native tree-update kernel for candidate construction

Targets:

- `getCandidateRec`
- supporting helpers such as:
  - `getNodeById`
  - `appendChild`
  - `replaceNodeById`
  - `appendTo`

Why second:

- `getCandidate/3` and `getCandidateRec/7` are major measured hotspots
- the current implementation repeatedly walks and rebuilds trees through recursive path-based updates

Expected impact:

- high
- likely to reduce a large part of candidate generation cost

Risk:

- medium to high
- tree mutation semantics must remain purely functional from the MeTTa perspective

Recommended form:

- implement a native tree-navigation/update API in PeTTa/Prolog
- expose a narrow set of native operations rather than rewriting all tree logic at once

### 3. Native `cleanTree` pipeline reduction

Targets:

- `cleanTree`
- `reduce-to`

Why third:

- `cleanTree` and `reduce-to` are directly confirmed as large costs in the current run
- they also sit between candidate generation and later scoring/optimization

Expected impact:

- high
- likely to reduce end-to-end runtime substantially

Risk:

- medium
- reduction semantics must be preserved exactly

Recommended form:

- start by keeping the external interface identical
- internally reduce the number of conversions and fixpoint passes

## Phase 2: Core Reduction Kernel Optimization

These changes target the deepest recurring transformation costs.

### 4. Native `reduceToElegance`

Targets:

- `reduceToElegance`

Why here:

- central structural kernel
- already measured as hot
- likely to benefit from more deterministic lower-level execution

Expected impact:

- high

Risk:

- high
- this is semantically rich code with many transformation branches

Recommended form:

- first split native work by AND-case and OR-case helpers
- avoid a full monolithic rewrite immediately

### 5. Native `applyAndTransformations`

Targets:

- `applyAndTransformations`

Expected impact:

- medium to high

Risk:

- medium to high

Recommended form:

- optimize after `until` and basic tree operations are native
- otherwise much of the loop overhead remains

### 6. Native `applyOrTransformations`

Targets:

- `applyOrTransformations`

Expected impact:

- medium

Risk:

- medium to high

Recommended form:

- similar treatment to `applyAndTransformations`
- likely best implemented with shared lower-level native helpers

## Phase 3: Structural Conversion Cleanup

These changes reduce recurring overhead across many hot paths.

### 7. Native `preOrder`

Targets:

- `preOrder`

Why:

- repeatedly appears in the hot call chain
- depends on generic `List.map` and `List.filter`

Expected impact:

- medium

Risk:

- medium

### 8. Native `buildTree`

Targets:

- `buildTree`

Why:

- directly paired with `preOrder`
- part of the expensive cleanup/normalization pipeline

Expected impact:

- medium

Risk:

- medium

### 9. Reduce tree <-> expression churn

Targets:

- `cleanTree`
- `preOrder`
- `buildTree`

Why:

- even if individual helpers are optimized, repeated conversion may still dominate

Expected impact:

- medium to high

Risk:

- medium

Recommended form:

- evaluate whether some reductions can operate directly on tree form
- or cache intermediate representations where semantically safe

## Phase 4: Higher-Order Collection Primitives

These changes are broader and can improve many smaller hotspots.

### 10. Native or pseudo-native hot list combinators

Targets:

- `List.foldl`
- `List.map`
- `List.filter`
- `List.zipWith`
- `List.getByIdx`
- `List.replaceAt`

Why:

- the profile already confirms `List.foldl` in the hot path
- the others appear frequently inside tree and scoring logic

Expected impact:

- medium
- potentially high when combined with the earlier phases

Risk:

- low to medium for collection primitives
- depends on whether semantics are purely structural or rely on dynamic function arguments

Recommended form:

- prioritize `List.foldl`, `List.getByIdx`, and `List.replaceAt` first
- these are directly implicated in the `getCandidateRec` path

## Optional Later Target

### 11. Native batch scoring path for `scoreTree`

Targets:

- `scoreTree`
- `replaceVarsWithTruth`
- the `List.map (compose evaluate (curry ...))` scoring pipeline

Why later:

- hot, but not as dominant as the candidate/reduction path in the current run
- still likely to become more important after the main tree/reduction bottlenecks are improved

Expected impact:

- medium

Risk:

- medium

Recommended form:

- batch-evaluate truth-table rows in a native helper
- avoid repeated dynamic composition/eval where possible

## Recommended Execution Order

If only a few changes can be done first, this is the strongest order:

1. native `until`
2. native tree-update primitives used by `getCandidateRec`
3. optimize/native `getCandidateRec`
4. optimize/native `cleanTree` + `reduce-to`
5. optimize/native `reduceToElegance`
6. optimize/native `applyAndTransformations`
7. optimize/native `applyOrTransformations`
8. native `List.foldl`, `List.getByIdx`, `List.replaceAt`
9. native `preOrder`
10. native `buildTree`
11. native/batched `scoreTree`

## Quick Win Summary

If the aim is fastest visible payoff, the three most promising milestones are:

1. replace `until` with a native fixpoint primitive
2. native tree operations for `getCandidateRec`
3. reduce or eliminate repeated tree/expression/tree rebuilding inside `cleanTree`

These three changes together should attack the broadest and most expensive execution patterns confirmed by the current profile.
