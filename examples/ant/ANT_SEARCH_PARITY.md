# Santa Fe Search Parity and Convergence

## Purpose

This note records why the Santa Fe search originally plateaued near raw score
`-78`, how the MeTTa implementation was brought closer to classic C++ MOSES,
and the deterministic perfect-result regression that now protects the unified
pipeline.

Boolean/table and action problems no longer use separate search loops. The
shared architecture is described in
[ANT_VS_BOOLEAN_PIPELINE.md](ANT_VS_BOOLEAN_PIPELINE.md).

## Relevant C++ behavior

The reference implementation is the C++ MOSES source under
`moses/optimization`, `moses/metapopulation`, and
`moses/moses/local_moses.cc`.

The relevant behavior is:

- Hill climbing chooses its center by complexity-penalized score.
- The best raw score is tracked independently from every evaluated candidate
  and controls perfect-result termination.
- Dominated candidates are retained by default because they may induce useful
  descendant neighborhoods.
- The default revisit policy expands a structural exemplar once.
- Exemplar visits, expansion IDs, and evaluation statistics advance only for
  the work that actually occurs.
- Metapopulation selection uses a hot Boltzmann distribution over penalized
  scores.
- The empty sequential-action seed has complexity zero. Primitive actions and
  action-result constants contribute complexity; structural nodes and
  perceptions do not.

These are MOSES lifecycle rules rather than Santa Fe-only rules, so the MeTTa
remedy is implemented in the shared pipeline.

## Why the old MeTTa search stalled

Several effects reinforced the `-78` local optimum:

1. Dominated candidates were removed unconditionally, discarding possible
   stepping stones.
2. Previously expanded trees could be selected repeatedly, limiting outer-loop
   exploration.
3. Termination observed the raw component of the penalized-best archive entry,
   not the best raw candidate that had actually been evaluated.
4. Accumulated candidates were rescored, and nominal sample or population
   counts were treated as evaluation cost.
5. Duplicate vectors and distinct vectors that reduced to the same program
   consumed redundant deterministic simulations.
6. Expansion numbering and the post-merge termination order did not accurately
   describe completed work.
7. The empty action seed was charged structural complexity.
8. Neighborhood dimension, distance clamping, and crossover bookkeeping had
   discrepancies that reduced useful exploration.
9. Boolean representation construction exposed a superposition of singleton
   deme lists, while raw `is-member` predicates exposed multiple domain-
   classification answers. Those choice points multiplied complete searches.

The result was a misleading budget: the search appeared to perform substantial
work while repeatedly scoring known programs and returning to the same local
region.

## Unified parity corrections

The following behavior now applies to Boolean, action, and strategy searches
through the same `runMoses` lifecycle.

### Visit-controlled outer exploration

Eligibility is keyed by structural tree identity. With the shared default
`revisit=0`, a tree is expanded once. Positive values permit additional
visits, and a negative value permits unlimited visits. Exhausting the eligible
pool terminates cleanly.

The selected visit is recorded before representation construction. A shared
field-count filter rejects empty Boolean, strategy, and action representations
before deme assembly. If none exposes an editable knob, the search records one
bounded expansion attempt but no scorer call. This prevents unlimited-revisit
runs from retrying one intrinsically unexpandable tree forever.

### Representation results are data, not search branches

Boolean representation construction now returns the complete selected
representation list directly. It no longer pattern-binds each representation
and exposes a superposition of singleton lists. The shared budget divider
therefore sees one concrete deme collection, just as it does for action
representations.

Domain and structural-action membership predicates wrap PeTTa's nondeterministic
`is-member` with `once`. This commits only a Boolean classification result; it
does not collapse independently randomized representations.

### Raw and penalized score separation

Penalized score still controls hill-climbing centers, archive order, trimming,
and Boltzmann selection. Separately, every optimized deme is inspected before
lossy merge operations. The all-time raw champion controls target termination
and is reserved in final output if penalized top-N trimming would otherwise
omit it.

On a raw-score tie, lower complexity wins; an exact tie preserves the earlier
candidate. The raw champion is not automatically injected into roulette
selection.

### C++-style dominance policy

`discardDominated=False` retains unique candidate stepping stones by default
for every domain. Setting it to `True` explicitly enables dominance removal.

### Actual evaluation accounting

`maxEvals` counts only new scorer invocations:

- existing candidate scores are retained;
- duplicate knob vectors are suppressed;
- equivalent materialized trees share scores;
- a run-wide cache reuses a score for the same context and tree;
- cache hits do not increment the counter.

The run cache is reset at the start of `runMoses`. The Santa Fe seed is
simulated once, cached, and counted once. Boolean and strategy seeds have
synthetic known scores and consume no initial scorer call.

The remaining finite budget is shared fairly among all demes in an expansion.
The sum of their allowances cannot exceed the complete-run remainder. A zero
budget prevents expansion; a negative budget is unlimited.

This distinction matters because requested samples, newly appended vectors,
unique reduced programs, and scorer calls are not the same quantity.

### Neighborhood and crossover behavior

Neighborhood information dimension uses the sum of
`log2(knob multiplicity)`, truncated in the C++ style. Requested Hamming
distance is clamped to that dimension before neighborhood size is estimated.

Sampling appends only unique, previously unseen vectors. Shared crossover
keeps the existing population as a prefix and appends unique one-, two-, then
three-simplex offspring. Population ranges are derived from instance positions,
not evaluation totals.

Incremental scoring uses that prefix invariant directly: old scored rows are
preserved byte-for-byte, and only the appended suffix is materialized and
examined. This avoids rescanning a growing deme on every hill-climbing step.

### Merge and finalization order

Each successful expansion receives a new expansion number and distinct deme
IDs. The generation raw best is captured before merge. Merge remains ordered
by penalized score and applies shared uniqueness, trimming, dominance, and
resize policies. Target and budget checks then use the newly produced state.

One final-output slot is reserved for the all-time raw champion when it is not
already present. This does not alter the archive used during evolution.

## Santa Fe domain parity

Only the following behavior remains specific to the action domain:

- the 32x32 toroidal Santa Fe trail and its 89 food pellets;
- ant position, heading, elapsed primitive actions, remaining food, and eaten
  count;
- stateful interpretation of action sequences and `is_food_ahead`;
- repeated execution of the candidate tree up to `steps` primitive actions;
- action reduction and action-tree representation;
- behavioral score `pellets eaten - 89`, with target `0`; and
- action complexity, where primitive actions and action-result constants cost
  one and the empty `and_seq` seed costs zero.

`mkAntContext` carries this scorer and representation configuration into the
shared expansion, hill-climbing, merge, and finalization machinery.

## Neutral settings

There is no separate action-search parameter family. Santa Fe experiments set
the same global keys available to Boolean searches:

```text
maxEvals
maxDist
minXoverNeighbors
steps
complexityRatio
complexityTemperature
revisit
discardDominated
diagnostics
```

Other shared controls such as `maxGen`, `nDeme`, crossover, widening, and
archive limits work the same way. Problem runners do not silently substitute
domain-specific values.

The historical `nEval` setting is still a merge-retention control despite its
name; it is not a scorer-call budget.

## Diagnostics

Set `diagnostics=True` to emit shared telemetry:

- selected exemplar, eligible-pool size, and visit count;
- neighborhood estimate and hill-climbing center progress;
- actual new scorer calls and cumulative calls;
- unique materialized candidates and retained archive size;
- independent best raw and best penalized scores; and
- representation retries.

A rising raw maximum alongside a stable penalized maximum is valid: a more
complex trail follower can improve task behavior without becoming the favored
hill-climbing center. A repeated selection with `revisit=0`, a non-monotonic
expansion number, or a new-evaluation count that includes cache hits indicates
a regression.

## Deterministic perfect-result regression

`examples/ant/tests/ant-pipeline-test.metta` runs the normal dispatcher and
therefore covers domain setup plus the complete shared lifecycle. Its explicit
configuration is:

| Setting | Value |
| --- | ---: |
| seed | `1` |
| maximum generations | `1000` |
| demes per expansion | `2` |
| complete-run evaluation ceiling | `30000` |
| neighborhood distance | `4` |
| crossover threshold | `400` |
| execution horizon | `600` |
| complexity ratio | `0.5` |
| complexity temperature | `2000` |
| revisits | `0` |
| discard dominated | `False` |
| widening | `False` |
| crossover | `True` |

The large generation and evaluation values are safety ceilings. Raw-target
termination stops the recorded deterministic trajectory during expansion 2
after finding a program that eats all 89 pellets. The test independently
re-simulates every returned candidate and requires a best raw score of `0`.
It intentionally asserts behavior rather than one exact syntax because
multiple action trees can be semantically perfect.

One recorded perfect tree is:

```text
(and_seq
  (action_bool_if is_food_ahead
    (and_seq move_forward move_forward)
    (and_seq
      turn_right
      turn_right
      (action_bool_if is_food_ahead
        (and_seq move_forward)
        (and_seq turn_right))
      move_forward))
  turn_right)
```

It has raw score `0`, complexity `8`, and penalized score `-16` at ratio
`0.5`. Independent 600-step simulation confirms all 89 pellets are eaten.

The exact actual-evaluation total is intentionally not part of the regression
contract. Improvements to deterministic duplicate suppression or score caching
may reduce scorer calls without changing the selected trajectory or result.
The hard requirements are that the total never exceeds `maxEvals`, cached
results are not counted as evaluations, and the perfect result is reproducible.

## Complexity-ratio observations

The practical regression ratio `0.5` is not a claim about one canonical C++
Santa Fe setting. `getComplexityCoef` uses the inverse of the ratio, so:

- ratio `0.16` charges each unit of action complexity `6.25`;
- ratio `0.5` charges each unit `2`.

The lower penalty at `0.5` lets useful control structure remain competitive
long enough to become a complete trail follower while hill climbing still
optimizes penalized score.

Seed 10 remains a useful, separate convergence experiment rather than the
fast perfect-result fixture. On the corrected unified path at ratio `0.5`, it
reached raw score `-1` (88 pellets) by expansion 8 after 2,853 actual scorer
calls, but did not produce a quick verified perfect result. Historical runs at
ratio `0.16` likewise reached strong but imperfect results, including 87
pellets before exhausting a smaller allowance. Those trajectories are
diagnostic observations, not regression contracts.

The main lesson is that increasing only `maxGen` cannot overcome an exhausted
actual-evaluation budget or excessive complexity pressure. Generation limit,
evaluation budget, representation breadth, and penalty ratio must be considered
together.

## Remaining work

The search lifecycle is unified. Remaining improvements should preserve that
architecture:

- replace the adapter's legacy untagged Boolean and strategy context tuples
  with an explicitly tagged `mkMosesContext` record while retaining
  compatibility at the public boundary;
- pass local deme allowances as optimizer arguments instead of temporary
  process state, improving reentrancy;
- add equally strong actual-evaluation and raw-target end-to-end regressions
  for Boolean and strategy problems;
- compare longer MeTTa and C++ runs using scorer-call counts rather than
  nominal sample counts; and
- experiment with representation diversity and penalty schedules without
  changing the shared lifecycle semantics.

Future action domains should add domain adapters, not another outer MOSES loop.
