# Toward General Program Evolution — the M0→M4 roadmap

Status: M0 done, M0.5 (params-based fitness) done (branch
`feat/generic-action-eval`). M1–M3 designed, not started. M4 research-marked.

## Context

The action domain has a generic evaluator, but domains are still
**containerized**: boolean, strategy, and action problems ride three parallel
paths — three `case` arms in `transform`/`optimizeDemes`/`runMoses`, three knob
builders, two complexity functions — that never interact. The goal is gradual
convergence toward **general program evolution**, concretely:

1. boolean *evolved* conditionals inside `action_bool_if` whose inputs are
   perceptions (today the condition slot holds one atomic perception preserved
   verbatim), and
2. contin knobs (classic OpenCog MOSES capability) tuning numbers inside
   action programs.

## What classic MOSES does — and does not — do

Findings from reading classic MOSES (`OpenCog/Moses`) against this branch:

- **Classic is only "semi-connected."** `build_knobs.cc` dispatches ONE
  top-level output type to per-type canonization templates; type bridges are
  hand-inserted wrapper ops (`greater_than_zero` for contin→bool, `impulse`
  for bool→contin). There is no general typed recursion.
- **Classic never evolves action conditions.** `build_action` skips the
  `action_boolean_if` condition child (build_knobs.cc:1109), and
  `sample_action_perms` embeds one atomic random perception per permutation.
  Capability (1) above therefore goes *beyond* classic.
- **Classic's contin encoding is discrete underneath.** One contin knob =
  `depth` ternary trits (Stop/Left/Right) walked by a binary-search stepper
  (field_set.cc:75-125). This maps directly onto metta-moses's flat discrete
  instance vector: each trit is a multiplicity-3 pseudo-knob, so neighborhood
  sampling and crossover work **unchanged**.
- **metta-moses is closer than expected to capability (1).** `buildLogical`
  takes `$argLabels` as an opaque symbol list (no ITable dependency), so it
  can run over perceptions nearly as-is; the evaluator's `action_bool_if`
  clause already evaluates its condition via `evalAction` — only
  world-threading `AND`/`OR`/`NOT` eval clauses are missing (today an
  `(AND ...)` condition hits the unknown-op worst path and is always False).
- **The M1 correctness linchpin is knob indexing.** LSK indices come from the
  global `&knobCount` (representation/logical-probe.metta:1,95-96) while ASK
  indices come from `MultiMap.length` (representation/build-action.metta:71,84)
  — mixing the two builders in one representation collides instance slots.
- **PeTTaV1 call semantics** (probe-verified): a truly-undefined head leaves
  the expression unreduced (so boolean-style `reduce` dispatch works); a
  defined head with wrong arity or a failed head-destructure fails silently.
  Directive: prefer bare heads + `reduce` + the quote convention; do not
  design around stock-PeTTa CI.

## M0 — Bare-head eval refactor + registry slimming (DONE)

Aligned the action evaluator with the boolean path's style — one dispatch
convention repo-wide — and deleted redundant registration.

- **Bare heads.** Every action op and domain primitive is
  `(= (<op> $children $world) (mkARes Bool World'))` — no `actionOp` wrapper
  predicate. The engine (scoring/action-eval.metta) cons-builds
  `(<op> <children> <world>)` and dispatches via `reduce`, with a
  collapse + in-collapse unify-destructure guard: undefined head → unreduced
  (non-mkARes) → defined-worst; defined head with wrong shape → silent fail →
  zero results → defined-worst. The `actionOp` sentinel is gone (reduce
  dispatches late-loaded clauses dynamically, like boolean AND/OR/NOT); the
  `actionDomain*` config sentinels remain (direct call sites need them).
- **The generalized quote rule.** With bare heads, any source literal headed
  by a live op symbol is a call. Two classes: (a) config clauses returning
  op-symbol lists are quote-wrapped —
  `(= (actionDomainActions tttAction) (quote (tttWin ...)))` — and read
  through the shared `configListSafe` unwrap (scoring/action-score.metta);
  (b) hand-written wrapped-shape literals in tests/playgrounds are
  quote-protected: `(evalAction (quote (and_seq (...))) <world>)`. Ops must
  not carry `(: ...)` type declarations.
- **Registry slimming.** scoring/action-registry.metta now holds exactly:
  structural/cleanup operator membership, domain-NAME registration for CLI
  routing (`registerActionDomain`/`isRegisteredActionDomain`), and the config
  sentinels. The per-primitive API (`registerDomainAction`,
  `registerDomainPerception`, the listers, `resetActionDomain`) was deleted;
  per-domain vocabularies live only in the domain's config clauses, and
  `createRepresentation`'s action clause reads them via `configListSafe`.
- A domain package is now: world + primitives + episode runner + one
  registration file with four sections (config clauses, episode runner, best
  score, `registerActionDomain`). See
  examples/tic-tac-toe-action/README.md for the recipe.

## M0.5 — Params-based fitness + context-shape routing (DONE)

Superseded M0's domain concept: the "action domain" no longer exists as a
framework entity. (This section supersedes the M0 notes above on
`actionDomain*` config clauses, `configListSafe`, and `registerActionDomain`
— all deleted.)

- **Binding = global params.** An experiment binds via
  `fitness`/`bestScore` (function SYMBOLS; CLI-carriable; on the TABLE
  route `bestScore` may instead be a plain Number used directly as the
  termination target) and
  `actions`/`perceptions` (quoted tuples, in-script only); see
  parameters/defaults.metta. The scorer calls `($fn $exp $i)` per episode —
  $i is the ordinal 0..n-1; the ordinal→opponent/trail/world mapping is
  PRIVATE to the fitness. Cache keyed by (fitness symbol, compiled exp, n).
  Only Numbers enter the bscore: the episode guard tests
  `(get-type $v) == Number` (a metatype/Grounded test is NOT enough --
  True and strings are Grounded); unset/clauseless/failing/non-Number all
  score the defined-worst -1.0. An action run with `actions` unset
  refuses loudly in `moses-run-action` (a knobless run would otherwise die
  silently); `perceptions` may be () (action-only knobs).
- **Routing = context shape.** `(moses)` decides by configuration (action
  vs table, both → loud error); below the entry point everything dispatches
  on `(mkActionCtx $nGames ...)` shapes exactly as before, minus the domain
  slot. The registry keeps only structural/cleanup operator membership; the
  config sentinels are gone (the var-head `($fn ...)` apply needs none).

## M1 — Evolved boolean conditions in `action_bool_if` (beyond classic)

Mechanism:

- Add world-threading `AND`/`OR`/`NOT` eval clauses to the action engine:
  short-circuit, world threads through each evaluated child; empty `AND` →
  True and empty `OR` → False so an all-knobs-off condition is not
  worst-scored.
- Hook `buildLogical` into the condition slot: replace the
  verbatim-preservation of the perception at
  representation/build-action.metta:150-152 with `logicalCanonize` +
  `buildLogical` over `$perceptions` as argLabels.
- **The knob-index linchpin:** `syncKnobCount` must set
  `&knobCount := (MultiMap.length $MMap)` before entering the logical
  builder, so the LSK counter and the multimap grow in lockstep (verified);
  otherwise LSK and ASK instance slots collide and decode corrupts silently.
  A decode collision-regression pin test is mandatory: a condition-LSK at
  setting 2 must decode to `(NOT <perception>)` AND the ASKs after it must
  still decode their own slots.
- Complexity: `actionTreeComplexity` treats AND/OR/NOT as free — an M1-local
  patch, unified in M2.

Gates:

- Knob-explosion gate: a `(param actionCondKnobProb)` plus a per-rep knob
  cap. Each AND/OR node adds roughly |perceptions| + arity LSKs, and every
  neighbor evaluated costs nGames episodes.
- Approval gate: M1 changes semantics pinned by
  representation/tests/build-action-test.metta (37 asserts, "perception
  preserved verbatim") — needs explicit sign-off at that point.
- ASK perms still contain atomic-condition `action_bool_if` templates. This
  is fine: evolved conditions live in the exemplar, and the build recursion
  picks them up next generation.

## M2 — Typed operator-signature registry (the "three questions")

One registry of `(opSignature <op> (-> argTypes ret))` atoms plus per-problem
declarations answers the three questions every layer keeps re-asking:

- **Membership** = type queries. `isActionOperator` ≡ signature-returns-Act;
  `isArgument` and ONE unified `treeComplexity` (structural ops free,
  primitives cost 1) replace the two disagreeing complexity functions and the
  hardcoded `(AND OR NOT PRIORITIZED-OR)` quote-lists. The load-order blocker
  is fixed by moving `treeComplexity`/`isArgument` out of utilities/tree.metta
  into a new `scoring/complexity.metta` loaded after the registry (consumers
  cscore/bscore/disc-probe already load later — verified).
- **Enumeration** = vocabulary at a typed slot:
  `(primitivesOfType $problem T)` ∪ ops-returning-T, gated by a
  `permittedOps` param (classic's permitted_op analog). Kills
  `getAllGameMoves` and the PRIORITIZED-OR special cases inside the "generic"
  logical builder.
- **Existence** = a `problemSignature` clause. Declaration sketches:

  ```metta
  (= (problemSignature tttAction) (-> WorldT Act))
  ;; plus problemPrimitives / problemEpisode / problemOpponents /
  ;; problemBestScore clauses for the domain

  (= (problemSignature parity3) (-> (BoolArgs 3) Bool))
  ;; plus problemTable — boolean table problems use the same grammar
  ```

  The columnar boolean fast path is selected by return type and stays
  byte-for-byte identical.

- Collapse the boolean/strategy/action context triple-arms (`transform`,
  `optimizeDemes`, `runMoses`, `mergeDemes`, and the hillClimbing
  slot-packing hack at
  optimization/hillclimbing/hill-climbing-helpers.metta:257-340) into one
  `(mkProblemCtx ...)`.

## M3 — Contin knobs via classic's trit encoding

Mechanism:

- One contin knob = `depth` consecutive multiplicity-3 pseudo-knobs (`mkCTK`)
  in the existing MMap + flat instance vector → **zero changes to
  neighborhood sampling and crossover**. `biasedRandomInt`'s 0-bias becomes a
  Stop-bias, i.e. values near the mean — the right prior for free.
- Decode: a ~15-line MeTTa port of classic's `contin_stepper`
  (field_set.cc:75-125). First-Stop-ends-walk canonicalizes redundant trit
  strings, so different dead-trit instances compile to identical expressions
  and the score cache absorbs them.
- Scope: knob only structural numeric literals (`repeat_n` counts) and
  problem-declared tunables (`problemContinConsts`) — NOT classic's full
  linear-combination canonization (that is regression machinery, wrong
  scope). Params: continStepSize 1.0 / continExpansion 1.0 / continDepth 4
  (classic's defaults).

Known losses vs classic (acceptable for v1):

- Exhaustive neighborhood enumeration counts dead-trit duplicates (they
  cache-hit rather than re-run, but they still occupy evaluation slots).
- Uniform trit sampling vs classic's significance-targeted perturbation.

Real risk: stochastic fitness × fine step sizes → a random walk on the fine
trits. Mitigate with shallow depth, wider steps, and a
deterministic-optimum test problem before trusting tttAction results.

## M4 — Type-directed unified knob building (research-marked)

One `buildKnobs` recursion dispatching per typed slot: a Cond slot gets the
logical builder over Cond-typed primitives everywhere (not just
`action_bool_if`), a Num slot gets contin knobs; the bridges
`greaterThanZero`/`impulse` become ordinary registered ops with eval clauses
(requires an `mkNRes Number World` numeric protocol beside `mkARes`);
per-problem reduct selection.

Honest marks — mechanical given M2+M3: typed-slot dispatch, the bridge ops.
**Research-grade**: numeric reduction rules in MeTTa (the largest single
item); bridge-induced enumeration explosion (permitted-ops tuning);
cross-representation crossover (classic punts on this too); and never
unifying boolean's columnar fast path into generic eval without profiling
first.

## Challenges register (condensed)

- **M1**: knob-index unification (silent decode corruption — the pin test is
  mandatory); knob-count explosion; test-semantic changes needing approval;
  ASK perms retaining atomic-condition templates (accepted — see M1 gates).
- **M2**: load-order re-audit for every moved predicate; slot-packing removal
  touches the engine's positional destructuring; decide freeze-vs-port for
  the legacy PRIORITIZED-OR strategy path; ~20-file test churn, gated by a
  no-behavior-change benchmark.
- **M3**: noise vs step size; no numeric reduct (decode-clamp instead;
  `repeat_n` is already safe on n≤0); LRU-cap `&actionScoreCache` once keys
  live on a continuum.
- **M4**: see the research marks above.
