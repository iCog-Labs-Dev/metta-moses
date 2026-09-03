# Unified MOSES Pipeline: Boolean and Action Problems

## Purpose

Boolean/table problems and the Santa Fe action problem now use one MOSES
search lifecycle. They enter through different setup functions because their
data, representations, and scorers are genuinely different, but both setup
functions call the same `runMoses` implementation.

The shared implementation owns:

1. exemplar visit eligibility and Boltzmann selection;
2. expansion numbering and deme ID creation;
3. fair division of the remaining evaluation budget among demes;
4. incremental scoring and duplicate-score reuse;
5. actual scorer-call accounting;
6. raw-best tracking independently of penalized optimization;
7. configurable dominance handling;
8. metapopulation merge, termination, and finalization.

The Santa Fe implementation therefore no longer has a parallel outer search
loop. Ant-specific names are reserved for trail state, action interpretation,
action-tree representation, and ant scoring.

For the C++ parity investigation and convergence history, see
[ANT_SEARCH_PARITY.md](ANT_SEARCH_PARITY.md).

## Architecture

```text
moses-run
   |
   +-- moses-table-run
   |      table + Boolean representation/scorer + true seed
   |                         |
   +-- moses-ant-run         |
          AntContext + action representation/scorer + and_seq seed
                             |
                             v
                         runMoses
                             |
          eligible exemplars -> select -> create demes
                             -> share remaining budget
                             -> optimize and score incrementally
                             -> capture raw best before trimming
                             -> merge with shared dominance policy
                             -> terminate or advance expansion ID
                             -> finishMetapop
```

The scoring context enters through `deme/expand-deme.metta`. The shared module
selects the appropriate representation constructor, optimizer scorer, merge
conversion, cache reset, and seed accounting. `expand-deme.metta` consequently
contains no action-specific constructors or scorer names. Once the adapter has
constructed demes, the lifecycle is identical for every problem family.

## Shared lifecycle

### Selection and visits

`eligibleExemplars` filters the current penalized-score-ordered
metapopulation by structural tree identity:

- `revisit=0` permits one expansion of each tree;
- a positive value permits the first expansion plus that many revisits;
- a negative value permits unlimited revisits.

The eligible pool is computed once per search transition. `selectExemplar`
then makes one hot Boltzmann roulette selection using
`complexityTemperature`. Recording the visit before expansion prevents the
same tree from evading the policy through a different deme ID.

### Expansion and deme budgets

A successful transition increments the expansion number exactly once, so
every generated deme receives a distinct ID derived from its expansion and
deme index.

`maxEvals` is the complete-run allowance for actual new scorer calls:

- `0` prevents expansion;
- a positive value is a hard upper bound;
- a negative value is unlimited.

The loop subtracts the cumulative actual count, divides the remaining finite
allowance evenly among the demes, and gives any remainder to the earliest
demes. The assigned shares cannot sum to more than the remaining allowance.

A representation may contain no editable knobs. Before deme assembly, the
shared `expandableRepresentations` filter rejects that fieldless result for
Boolean, strategy, and action representations alike, matching the generic C++
deme-expander check. If every representation for a selected exemplar is empty,
the loop keeps the recorded visit and consumes one bounded
generation/expansion attempt, but no scorer call. This guarantees termination
even when `revisit` is negative.

Boolean representation construction returns one concrete list of selected
representations. Scalar domain predicates use `once(is-member(...))`, so
membership comparisons cannot turn one expansion into a superposition of
whole search branches. Neither correction collapses the intended list of
independently generated demes.

### Incremental scoring and caches

Hill climbing preserves every real score already attached to a candidate.
Sampling and crossover append unique new rows after that scored prefix,
including the feature-selection variants, so the hot path traverses only the
appended suffix. Only rows still carrying the explicit `worstCscore` sentinel
are considered for new scoring.

Before invoking a scorer, the implementation materializes the candidate tree
and checks:

1. scores already present in the current deme;
2. equivalent materialized trees seen in the current scoring batch; and
3. the run-wide candidate score cache, keyed by scoring context and tree.

A cache hit supplies the existing score and consumes no evaluation. Only a
cache miss that actually calls the domain scorer increments the evaluation
count. The run-wide candidate cache is reset at the start of `runMoses`, so
scores cannot leak between runs with different data or settings.

Boolean subtree caching remains an additional optimization. It can reduce the
work performed inside one Boolean scorer invocation, but it does not turn a
candidate-cache hit into a new evaluation.

The Santa Fe seed is simulated once during setup, placed in the candidate
cache, and contributes one to the initial evaluation total. Boolean and
strategy seeds use known synthetic scores, so they contribute zero scorer
calls.

### Penalized optimization and raw termination

Hill climbing, archive ordering, trimming, and exemplar roulette continue to
use penalized score. This preserves the intended pressure toward simpler
programs.

The loop separately captures the best raw candidate from every optimized deme
before merge can deduplicate, trim, remove dominated candidates, or resize the
archive. Higher raw score wins; on a raw tie, lower complexity wins; an exact
tie keeps the earlier candidate.

The independent raw champion is used for:

- checking the target score after newly evaluated demes;
- progress diagnostics; and
- reserving a tree-deduplicated slot in the final output.

It is not inserted into the selectable archive merely because it is the raw
champion. This keeps penalized selection and raw task completion as separate
responsibilities.

### Merge, dominance, and finalization

`mergeDemes` performs the same sequence for all domains: order instances,
retain top unique candidates, trim, materialize trees, reject trees already in
the metapopulation, apply the configured dominance policy, merge, and resize.

`discardDominated=False` is the shared C++-style default. Dominated candidates
may still induce useful neighborhoods when used as future exemplars. Setting
it to `True` explicitly enables dominance removal.

`finishMetapop` returns the penalized top `maxCandOutput` candidates while
reserving one slot for the all-time raw champion when it is otherwise absent.
The output remains tree-deduplicated.

The shared loop terminates on any of these conditions:

- generation allowance exhausted;
- raw target reached;
- no demes requested;
- actual-evaluation budget exhausted;
- no visit-eligible exemplar remains; or
- the newly optimized and merged population reaches the target.

## Domain-specific differences

| Concern | Boolean/table | Santa Fe action |
| --- | --- | --- |
| Setup context | Input table, truth-table behavioral scorer, pruning and feature-selection settings | `mkAntContext` with execution horizon, action vocabulary, perception vocabulary, and complexity ratio |
| Initial tree | Boolean `true` with a known synthetic worst score | Empty `and_seq`, evaluated once against the trail |
| Representation | Logical knobs over selected table features | Randomized action/perception knobs around an action tree |
| Materialization cleanup | Boolean `cleanTree` rules | `cleanActionTree` sequencing and action-result rules |
| Evaluation | Stateless classification over table rows | Repeated stateful execution on the 32x32 toroidal trail |
| Raw score | Sum of row errors, with `0` as the clean-table target | Pellets eaten minus 89, in `[-89, 0]` |
| Complexity | Generic logical tree complexity | Santa Fe action cost: primitive actions and action-result constants cost one; structural nodes and perceptions cost zero |
| Execution horizon | Unused | `steps`, normally 600 primitive actions |

These are domain adapters, not alternative MOSES lifecycles.

## Neutral configuration

All problem families read the same registry keys:

| Parameter | Default | Meaning |
| --- | ---: | --- |
| `maxEvals` | `25000` | Complete-run budget of actual new scorer calls |
| `maxDist` | `4` | Maximum hill-climbing neighborhood distance |
| `minXoverNeighbors` | `400` | Neighborhood-size threshold for crossover |
| `steps` | `600` | Stateful evaluator horizon; unused by Boolean scoring |
| `complexityRatio` | `3.5` | Shared complexity-penalty ratio |
| `complexityTemperature` | `6` | Temperature used by Boltzmann selection and merge trimming |
| `revisit` | `0` | Number of revisits permitted after a tree's first expansion |
| `discardDominated` | `False` | Whether merge removes dominated candidates |
| `diagnostics` | `False` | Whether shared selection, hill-climbing, and generation telemetry is printed |

Problem runners do not silently replace these values. A Santa Fe experiment
sets its desired values explicitly, just as a Boolean experiment may.

`nEval` is not an evaluation budget. Its historical name currently refers to
a merge-retention limit and must not be conflated with `maxEvals`.

## Diagnostics

With `diagnostics=True`, the shared pipeline reports:

- selected tree, raw score, penalized score, eligible-pool size, and visit;
- estimated neighborhood size and hill-climbing progress;
- actual new and cumulative scorer calls;
- materialized unique candidates and retained metapopulation size;
- all-time raw best and current penalized best; and
- empty-representation retries.

The labels are domain-neutral because the measurements have identical meaning
for Boolean and action searches.

## Tests that protect the boundary

The regression suite checks, across the applicable problem families:

- neutral registry keys and CLI overrides;
- visit limits, unlimited revisits, and empty-pool termination;
- actual-evaluation counting and score reuse;
- finite, zero, unlimited, and fairly shared budgets;
- distinct expansion IDs;
- raw-target termination even when the penalized best differs;
- optional dominance removal;
- crossover ordering and duplicate suppression;
- final raw-champion retention; and
- deterministic Boolean and seed-1 perfect Santa Fe end-to-end results.

## Code map

- Dispatch and domain initialization: `moses/demo-problems.metta`
- Domain-context translation for representation creation, optimizer calls,
  merging, cache reset, and seed accounting: `deme/expand-deme.metta`
- Shared lifecycle, counted expansion, budgeting, diagnostics, and finalization:
  `deme/expand-deme.metta`
- Visit filtering and Boltzmann selection:
  `metapopulation/exemplar-selection.metta`
- Incremental scoring and hill climbing:
  `optimization/hillclimbing/hill-climbing-helpers.metta`
- Candidate cache: `scoring/cacheSpace.metta`
- Shared neighborhood sampling and crossover:
  `moses/neighborhood-sampling.metta` and
  `optimization/hillclimbing/crossover.metta`
- Shared merge and dominance policy: `deme/merge-demes.metta`
- Boolean representation and scoring: `representation/` and `scoring/`
- Santa Fe representation, execution, scoring, and complexity:
  `representation/build-action.metta` and `examples/ant/ant-domain.metta`
- Neutral defaults: `parameters/defaults.metta`

## Future cleanup

The lifecycle and its domain boundary are now separated. For compatibility,
the adapter still recognizes the historical untagged Boolean and strategy
tuples alongside `mkAntContext`. Future work can normalize those public inputs
once into an explicitly tagged `mkMosesContext` record containing deme,
optimizer, merge, reset, and seed specifications. That would make adding a new
domain safer without changing or duplicating the search engine.

The important boundary should remain unchanged: one MOSES lifecycle, with a
small adapter for genuinely different representations and evaluators.
