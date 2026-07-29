# Ant Action-Selection Pipeline Compared with Boolean Evolution

## Purpose and scope

This document describes the current MeTTa implementation, not just the ideal
MOSES architecture. It explains where the Santa Fe ant search reuses the
Boolean evolution pipeline, where it deliberately differs, and which ant-only
search corrections should eventually become shared MOSES behavior.

The comparison is important because the ant implementation is not merely a
Boolean scorer with different data. A Boolean candidate is a stateless function
evaluated independently on table rows. An ant candidate is a stateful action
program repeatedly executed against a changing world. That difference requires
domain-specific representation, interpretation, scoring, and complexity rules.
It does **not**, however, require two permanently separate implementations of
the metapopulation lifecycle.

For the history of the C++ parity investigation, fixed defects, diagnostics,
and convergence experiments, see [ANT_SEARCH_PARITY.md](ANT_SEARCH_PARITY.md).

## Executive summary

Both pipelines share the central MOSES idea:

1. select an exemplar;
2. construct one or more representations around it;
3. create knob-vector instances;
4. optimize those instances with hill climbing;
5. turn the instances back into candidate trees;
6. merge candidates into a penalized-score-ordered metapopulation; and
7. return cleaned trees with behavioral scores.

The ant path changes two different layers:

- **Necessary domain specialization:** action-tree representation, stateful
  execution, Santa Fe scoring, action-aware cleanup, and ant complexity.
- **Ant-only MOSES lifecycle improvements:** actual evaluation accounting,
  visit-limited exemplar selection, empty-representation retry, preservation of
  dominated stepping stones, an all-time raw champion, correct expansion
  numbering, and termination against newly evaluated results.

The first group should stay domain-specific. The second group should become a
shared, policy-driven search loop so Boolean, ant, and future domains receive
the same correct lifecycle semantics.

## Pipeline overview

```text
moses-run
   |
   +-- Boolean/table -----------------------------------------------+
   |   resolve ITable -> true seed -> generic runMoses              |
   |          |                                                      |
   |          +-> Boolean representation + optional feature select  |
   |          +-> generic hill climbing and table scoring            |
   |          +-> dominance-filtered merge                           |
   |          +-> penalized top-N final result                       |
   |                                                                 |
   +-- Ant ---------------------------------------------------------+
       AntContext -> scored and_seq seed -> runAntMosesCounted
              |
              +-> visit-filtered exemplar selection
              +-> randomized action representation(s)
              +-> incremental counted hill climbing
              +-> raw champion update before lossy merge
              +-> configurable dominance + penalized merge
              +-> raw-target/global-budget termination
              +-> penalized top-N plus reserved raw champion
```

The metapopulation remains ordered by penalized score in both paths. In the ant
path, the raw champion is deliberately separate: it controls target detection
and final reporting but does not silently become a future roulette candidate.

## Stage-by-stage comparison

| Stage | Boolean/table evolution | Ant action-selection evolution | Reason for the difference |
|---|---|---|---|
| Dispatch | `moses-run` sends all non-ant problems to `moses-table-run`. | `problem=ant` is sent to `moses-ant-run`. | The ant needs a simulator and action-domain context rather than an input table. |
| Search context | Carries pruning, feature-selection algorithm, truth-table scorer, and `ITable`. | Carries `steps`, complexity ratio, action vocabulary, and perception vocabulary in `mkAntContext`. | These are irreducibly domain-specific inputs. |
| Initial exemplar | Starts from Boolean `true` with a synthetic worst score. | Starts from empty `and_seq`, simulates it once, and derives its Cscore from that stored BScore. | The ant seed is an executable action program. Counting the real initial simulation avoids a hidden duplicate evaluation. |
| Representation | May select features, prune the exemplar, enforce features, and build logical knobs. | Attempts one independently randomized action representation per requested deme, using the ant actions and perceptions; empty representations are subsequently filtered. | Boolean structure varies logical expressions over inputs; ant structure varies stateful action programs. |
| Empty representation | No special retry exists in the generic outer loop. | Representations with an empty knob map are filtered. If every representation is empty, the selected exemplar stays visited and another eligible exemplar is tried without consuming a generation, expansion ID, or evaluation. | An action representation can randomly expose no editable field; sending it to the sampler is invalid and produces no search. |
| Initial knob vector | Uses shared representation defaults to create the center instance. | Uses the same shared coordinate/default machinery. | This part is representation-independent and is intentionally shared. |
| Candidate reconstruction | Uses `getCandidate`, then logical `cleanTree`. | Uses `getCandidate`, then `cleanActionTree`. | Action reduction has sequencing and action-result semantics that Boolean cleanup does not. |
| Behavioral score | Evaluates the tree independently for every row of an `ITable`; each row contributes `0` or `-1`. | Runs one stateful 32x32 toroidal Santa Fe simulation for up to 600 primitive actions; raw score is pellets eaten minus 89, in `[-89, 0]`. | An ant program changes position, heading, remaining food, and elapsed actions as it executes. |
| Complexity | Uses generic `treeComplexity`. | Structural nodes and perceptions cost zero; primitive actions and action result constants cost one. Empty `and_seq` therefore has complexity zero. | This matches the intended Santa Fe C++ vocabulary cost rather than Boolean syntax size. |
| Hill-climbing objective | Chooses centers by complexity-penalized score. | Also chooses centers by complexity-penalized score. | This is shared MOSES behavior and was intentionally preserved. |
| Neighborhood geometry | Uses shared knob multiplicities, information dimension, distance clamping, sampling, and crossover, with Boolean distance/evaluation parameters. | Uses the same corrected geometry and crossover, with ant parameters. It wraps sampling to append only unique, previously unseen vectors. | The geometry is general; duplicate suppression matters more for the expensive stateful simulator. |
| Scoring during hill climbing | Generic `transform` removes every stored score and scores the complete instance list again. | `transformAntIncremental` scores only entries still marked with `worstCscore`; existing scores are retained. Equal cleaned trees within a batch share one simulation. | Ant evaluation accounting must represent real simulator calls, not population length or nominal samples. |
| Per-deme limit | `hcMaxEvals` defaults to 500 and is used by the generic loop. | `hcMaxEvalsAnt` defaults to 2,000; the outer allowance may reduce it. | Ant uses a larger local search while still respecting a complete-run budget. |
| Evaluation count | The generic outer loop does not thread or enforce an actual global evaluation total. | The counted expansion returns actual new simulator calls. `antMaxEvals` caps the whole run, including the initial simulation, and remaining work is divided fairly across demes. | Nominal sample requests, unique vectors, reduced trees, and real simulations are different quantities. |
| Exemplar pool | `selectExemplar` applies hot Boltzmann selection to the current penalized archive. It has no visit state. | The pool is first filtered by structural-tree visit count, then the same Boltzmann selector is called once. | `antRevisit=0` means one expansion per tree; positive values allow that many extra visits; negative means unlimited, as in C++. |
| Deme IDs | The generic recursive call currently reuses its expansion number. | Successful ant generations increment the expansion number and therefore produce distinct deme IDs. Empty-representation retries keep the same ID because no expansion happened. | Deme identity should describe a real expansion, not a recursive-loop call. |
| Raw best | No independent all-time raw accumulator exists. | Every optimized deme is inspected before trimming, and its best raw candidate updates a separate all-time champion. Shorter complexity wins a raw-score tie; an exact tie keeps the earlier candidate. | A raw-perfect tree can have a worse penalized score and otherwise disappear during merge. |
| Dominance | Dominated candidates are always removed. | `antDiscardDominated=False` retains unique trimmed candidates by default; setting it to `True` restores dominance removal. | A currently dominated action tree can be a useful representation seed for a better descendant. |
| Merge ordering | Candidates are deduplicated and retained in penalized-score order. | The same shared merge machinery and penalized ordering are used. | The selectable archive must continue to reflect the hill-climbing objective. |
| Termination | Checks generation count, then compares the raw component of the old archive head. The generic code has no complete-run evaluation-budget stop. | Checks generation count, initial/current all-time raw best, whether expansion is possible, global actual-evaluation budget, eligible-pool exhaustion, and the raw champion after each optimized generation. | A perfect candidate must stop the run even when complexity prevents it from becoming the penalized archive head. |
| Final result | Returns the penalized top `maxCandOutput` candidates. | Returns the penalized top candidates while reserving a tree-deduplicated slot for the all-time raw champion when needed. | Final output should not lose the candidate that actually achieved the best task behavior. |
| Diagnostics | Generic progress output mainly reports generation and optimized-deme size. | Optional ant diagnostics report selected exemplar, visits, eligible count, actual/cumulative evaluations, raw and penalized bests, materialized programs, and retained candidates. | These measurements distinguish search failure from accounting, representation, or merge failure. |

## Detailed control flow

### Boolean/table path

`moses-table-run` performs the following operations:

1. Resolve the built-in problem or CSV input as an `ITable`.
2. Construct a truth-table behavioral scorer and the scalar target score `0`.
3. Seed the metapopulation with the tree `true` and a worst-possible score.
4. Enter generic `runMoses`.
5. In each iteration, `expandDeme` selects an exemplar, creates Boolean
   representations, initializes their center vectors, and applies the chosen
   optimizer.
6. Hill climbing reconstructs a logical tree for each vector and evaluates it
   over the table. Penalized Cscore determines the next center.
7. `mergeDemes` materializes trees, removes duplicates and dominated
   candidates, applies the archive limits, and returns a penalized ordered set.
8. `runMoses` continues until its generation condition or target check, then
   `cleanedExemplar` converts each retained exemplar to `(tree, raw-score)`.

This path is adequate for the existing Boolean tests, but it is not yet the
reference implementation of the corrected lifecycle. In particular, generic
`transform` re-scores the full deme, and generic `runMoses` does not carry
visits, an actual global evaluation count, or an all-time raw champion.

### Ant path

`moses-ant-run` performs a richer sequence:

1. Build `mkAntContext` from the step limit, ant complexity ratio, action
   symbols, and perception symbols.
2. Install the ant-specific hot metapopulation temperature.
3. Seed with `and_seq`, simulate it exactly once, and construct its Cscore from
   the resulting BScore without simulating it again.
4. Enter `runAntMosesCounted` with an empty visit table, cumulative evaluation
   count `1`, and the initial raw champion.
5. At each generation, reject already exhausted exemplars according to
   `antRevisit`, make one penalized Boltzmann selection, and record that visit.
6. Create the requested randomized action representations. Discard only those
   representations that contain no editable knob.
7. If every representation is empty, retry selection without charging work.
   Otherwise allocate the remaining global evaluator allowance across the
   created demes.
8. Hill climb each deme. Center movement still follows penalized score, but new
   action programs are simulated incrementally and the returned work count is
   the number of actual simulations.
9. Inspect all evaluated instances to update the raw champion **before** merge
   can discard, trim, or resize anything.
10. Merge candidates using the shared penalized archive machinery and the
    configured ant dominance policy.
11. Stop on raw target, global budget, generation limit, disabled expansion, or
    exhausted eligible pool. Otherwise increment the expansion ID and continue.
12. Produce a final metapopulation that includes the raw champion without
    changing which candidates were eligible during evolution.

## What is shared already

The ant work did not replace the complete Boolean pipeline. The following
mechanisms are intentionally common:

- the `Exemplar`, `Deme`, `Representation`, `Instance`, `Cscore`, and `BScore`
  data forms;
- initial knob-vector construction from representation defaults;
- neighborhood size estimation based on knob multiplicities;
- distance clamping and the one-, two-, and three-simplex crossover helpers;
- penalized-score center selection within hill climbing;
- ordered metapopulation storage, duplicate removal, cap/merge trimming, and
  maximum candidate/output parameters;
- Boltzmann exemplar selection once the eligible pool is known; and
- final `(preOrder tree, sum BScore)` result shape.

This shared core is valuable. Reconciliation should extend it, not duplicate
the shared pieces under more `ant...` names.

## Why the ant-only lifecycle changes were necessary

### Raw score and penalized score answer different questions

Penalized score answers, “Which candidate is the best center for continued
search after charging complexity?” Raw score answers, “Has the task target
been solved?” A perfect ant can have raw score `0` but a substantially negative
penalized score. Looking only at the penalized archive head can therefore miss
a solved candidate. The ant loop keeps these responsibilities separate:

- penalized score controls hill-climbing centers, archive ordering, trimming,
  and roulette selection;
- the all-time raw champion controls target termination, diagnostics, and its
  reserved final-output slot.

The same distinction is logically valid for Boolean problems, even if their
current small searches often hide the defect.

### Population growth is not evaluation cost

One requested sample can duplicate an existing vector. Multiple vectors can
also reduce to the same cleaned action tree. Neither case needs another
deterministic ant simulation. Consequently the ant pipeline distinguishes:

1. nominally requested samples;
2. unique new knob vectors;
3. unique cleaned action programs; and
4. actual scorer invocations.

Only item 4 consumes `antMaxEvals`. Previously scored rows keep their Cscore,
and a batch-local cleaned-tree cache avoids duplicate simulations. This is the
main reason the ant budget now has an interpretable meaning.

### Visit control provides the outer escape mechanism

Hill climbing is allowed to settle at a local optimum. MOSES escapes by using
the resulting candidates as new representation centers. Re-expanding the same
tree forever defeats that mechanism. Visit state is keyed by structural tree,
not deme ID, so the same program cannot bypass `antRevisit` merely by appearing
under another ID.

### Dominated programs can be stepping stones

Dominance describes the candidate's present score/complexity relation; it does
not describe the quality of the neighborhood induced by using that candidate
as an exemplar. The ant default therefore keeps dominated candidates after the
normal uniqueness and size controls. The option remains configurable because
retaining them increases archive diversity and memory pressure.

## Domain specialization versus generic search corrections

The clean architectural boundary is:

### Keep domain-specific

- Boolean table scoring versus stateful ant simulation;
- Boolean feature selection and logical representation versus action/perception
  representation;
- `cleanTree` versus `cleanActionTree`;
- generic logical complexity versus Santa Fe action complexity;
- construction of the initial seed and domain context; and
- optional deterministic score-cache keys, because a stochastic domain may
  require a different policy.

### Generalize from the ant path

- visit-counted eligibility and explicit revisit policy;
- monotonic expansion numbering and distinct deme IDs;
- actual evaluation counts returned by optimization;
- a complete-run evaluation budget;
- raw-best capture over all evaluated candidates before lossy merge;
- termination against the all-time raw champion;
- explicit empty-representation outcome and retry;
- configurable dominance behavior; and
- final inclusion of the raw champion without injecting it into selection.

### Treat as temporary implementation detail

- the ant-specific wrapper functions that mirror generic operations;
- the temporary parameter/state mechanism used to communicate a local ant
  evaluator allowance into hill climbing; and
- context-shape dispatch spread across `case` expressions in creation,
  optimization, merge, and the outer loop.

## Known generic/Boolean lifecycle gaps

These are not claims that current Boolean regression tests fail. They are
differences visible in the present implementation that reconciliation should
characterize and address:

- `runMoses` has no visited-exemplar state, so it may select the same structural
  tree repeatedly.
- Dominance removal is mandatory outside the ant context.
- The generic outer loop does not enforce a budget of actual scorer calls.
- Generic `transform` extracts all instance vectors and re-scores the whole
  deme; it does not retain existing scores incrementally.
- The recursive generic call currently passes the same expansion number,
  rather than incrementing it after a completed expansion.
- Its target check reads the head of the pre-merge metapopulation instead of an
  all-time raw best collected from the just-evaluated demes.
- Its final top-N result is penalized-score ordered and has no reserved raw-best
  result.
- Empty representation is not represented as a first-class retry outcome.

Before changing Boolean defaults, tests must determine which of these behaviors
existing seed trajectories or callers currently rely on.

## Recommended reconciliation

The two paths should be reconciled by sharing a **counted MOSES lifecycle with
domain policies**, not by forcing action evaluation into the Boolean scorer or
by copying more ant-specific functions.

### 1. Define domain operations explicitly

Introduce one internal domain-policy value (or an equivalent set of callable
arguments) supplying operations such as:

```text
initial exemplar and score
create representations(exemplar, deme IDs, context)
score new instances(deme, context) -> (scored deme, actual evaluations)
materialize candidate(instance, representation, context)
clean candidate(tree)
candidate complexity(tree)
best possible raw score(context)
dominance policy(context)
score-cache policy(context)
```

Boolean and ant would implement these operations separately. The outer search
would no longer need to detect a domain by destructuring the shape of its
context at several different layers.

### 2. Return structured optimization results

Make every optimizer/expansion return a result equivalent to:

```text
mkExpansionResult(
  optimized demes,
  actual new evaluations,
  best raw exemplar evaluated,
  status                 ; success, empty-representation, or no-work
)
```

This removes inferred/nominal counters and avoids using temporary global state
to pass the ant allowance into hill climbing. Boolean scoring can first report
its existing behavior accurately, then adopt incremental scoring independently.

### 3. Use one explicit search state

The shared loop should thread a value equivalent to:

```text
mkSearchState(
  generations remaining,
  next expansion ID,
  metapopulation,
  exemplar visits,
  cumulative actual evaluations,
  all-time raw champion
)
```

One transition then has a fixed order: build eligible pool, select once, record
visit, expand, handle no-representation, update counters and raw champion,
merge, test termination, and increment the expansion ID. This order prevents
the old/new-metapopulation and nominal/actual-count ambiguities.

### 4. Separate mechanisms from policies

The shared loop should implement mechanisms; parameters should select policies:

- maximum revisit count, including unlimited;
- discard or retain dominated candidates;
- finite or unlimited global evaluation budget;
- penalized exemplar selection strategy;
- whether a raw champion is reserved in final output; and
- whether deterministic equivalent candidates may share cached scores.

During migration, a Boolean compatibility policy can preserve current defaults
while the corrected policy is tested. Once parity and deterministic regressions
are established, the generic parameter names should replace ant-prefixed names
such as `antRevisit` and `antDiscardDominated`.

### 5. Migrate in behavior-preserving stages

1. **Characterize:** add tests for current Boolean seeds, result ordering,
   scorer-call counts, multiple demes, expansion IDs, and unreachable targets.
2. **Standardize results:** introduce counted expansion/result structures while
   preserving current decisions and output.
3. **Extract the loop:** move the proven ant transition order into one shared
   state machine with Boolean and ant domain policies.
4. **Enable corrected Boolean lifecycle behind parameters:** visit filtering,
   raw champion, post-expansion target checks, actual global budget, and
   configurable dominance.
5. **Promote and simplify:** after trajectory and performance comparison, make
   the shared corrected lifecycle the default and remove compatibility wrappers
   and duplicate context dispatch.

## Reconciliation invariants and acceptance tests

The unified implementation should not be considered complete until the tests
prove all of the following for both Boolean and ant domains:

- the same configuration and random seed produce the same trajectory;
- expansion IDs advance exactly once per successful expansion;
- revisit limits are enforced by structural candidate identity;
- an empty representation consumes no generation or scorer budget and cannot
  crash neighborhood sampling;
- the evaluation total equals actual scorer invocations;
- already scored deterministic candidates are not scored again;
- penalized score remains the optimization and selection objective;
- the best raw candidate is observed before trim, dominance removal, or resize;
- reaching the raw target terminates even if another candidate has the best
  penalized score;
- the raw champion does not enter roulette selection unless a policy explicitly
  requests it;
- final output is tree-deduplicated and contains the all-time raw champion; and
- `nDeme > 1` respects the global remaining budget and assigns distinct IDs.

The existing perfect-ant regression is a useful end-to-end acceptance test.
The Boolean side needs equivalent small, deterministic characterization tests
before its lifecycle defaults change.

## Code map

- Dispatcher and initialization: `moses/demo-problems.metta`
- Outer loops, counted expansion, raw champion, and finalization:
  `deme/expand-deme.metta`
- Boolean and ant representation creation: `deme/create-deme.metta` and
  `representation/representation.metta`
- Exemplar selection and ant visits:
  `metapopulation/exemplar-selection.metta`
- Shared and ant-incremental hill climbing:
  `optimization/hillclimbing/hill-climbing-helpers.metta`
- Shared and ant-deduplicating neighborhood sampling:
  `moses/neighborhood-sampling.metta`
- Candidate conversion, dominance, and archive merge:
  `deme/merge-demes.metta`
- Boolean scoring: `scoring/bscore.metta`, `scoring/cscore.metta`, and
  `scoring/complexity-based-scorer.metta`
- Ant interpreter, simulator, score, and complexity:
  `examples/ant/ant-domain.metta`
- Search defaults: `parameters/defaults.metta`

## Final recommendation

Keep two domain adapters but one search engine. The action interpreter,
representation vocabulary, cleanup, complexity, and simulator belong to the
ant adapter; table evaluation and logical representation belong to the Boolean
adapter. Visit handling, counted expansion, raw-champion tracking, dominance
policy, merge ordering, budgets, termination, and finalization belong to a
single generic MOSES lifecycle.

That boundary preserves what is genuinely different about action selection
while ensuring that correctness improvements discovered through the ant work
benefit Boolean evolution and every future domain instead of becoming another
parallel implementation.
