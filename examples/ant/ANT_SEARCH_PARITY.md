# Santa Fe Ant Search Parity

This note records why the ant search used to plateau near raw score `-78`, what
is now aligned with classic C++ MOSES, and which generic changes remain
deliberately deferred.

## C++ behavior

The reference implementation is the classic C++ MOSES source tree, principally
the files under `moses/optimization`, `moses/metapopulation`, and
`moses/moses/local_moses.cc`.

- `optimization/hill-climbing.cc` chooses a hill-climbing center by composite
  (complexity-penalized) score, but separately updates `best_raw_score` from
  every evaluated candidate. The raw score controls perfect-result termination.
- `metapopulation/metapop_params.h` defaults `discard_dominated` to `false` and
  `revisit` to `0`. Its comments explain that a dominated candidate may still
  produce fitter descendants.
- `metapopulation/metapopulation.cc` excludes exemplars whose visit allowance
  is exhausted, then increments the selected exemplar's visit count.
- `moses/local_moses.cc` increments expansion IDs and evaluation statistics
  from actual new evaluations before merging the resulting deme.
<!-- Previous incorrect description: primitive actions and perceptions both
contribute complexity. -->

- The Santa Fe action vocabulary assigns no complexity to the empty
  `sequential_and` seed. Primitive action nodes and the result constants
  `action_success`/`action_failure` contribute one each; `is_food_ahead`,
  Boolean constants, and structural nodes contribute zero.

The successful seed-10 performance-diary configuration used complexity ratio
`0.16` and a hot metapopulation temperature of `2000`. The newer million-
evaluation regression uses a different ratio and budget; it is not copied
literally because a MeTTa simulator call has substantially different cost and
historical MeTTa/C++ counters have also differed on problems such as mux6.

## Divergences found in MeTTa

The ant pipeline previously:

1. removed dominated candidates unconditionally;
2. repeatedly selected already-expanded exemplars;
3. checked termination using the raw score belonging to the penalized-best
   center instead of the best raw candidate evaluated;
4. stripped and recomputed every accumulated instance score each iteration;
5. used a nominal requested sample count as both population size and evaluation
   count;
<!-- Previous incorrect item 6: prepended crossover offspring, invalidating
previous-range bookkeeping. The shared helper already preserved the population
prefix; only its simplex grouping and sample bounds needed correction. -->

6. kept redundant ant-only crossover helpers even though the shared helper
   already appended offspring after the existing population;
7. counted the empty `and_seq` seed as complexity one; and
8. recursed without incrementing the expansion number and tested the old
   metapopulation after a merge.

Together these make a local optimum sticky: useful stepping stones disappear,
the same source tree is expanded again, and most of the nominal budget is spent
rescoring known programs.

## Ant-only remedy

The normal `moses-run` dispatcher now routes ant to the counted ant loop
`runAntMosesCounted`; Boolean and strategy searches still use generic
`runMoses`. `runAntMoses` remains as a compatibility wrapper for direct callers.

- `antDiscardDominated=False` retains unique, trimmed ant candidates. Setting
  it to `True` restores dominance filtering.
- `antRevisit=0` permits one expansion per tree. A positive value permits that
  many additional visits; a negative value permits unlimited revisits, matching
  C++. An empty eligible pool terminates cleanly.
- Ant hill climbing still optimizes penalized score, while the maximum raw
  score across the whole evaluated deme controls target termination.
- Only instances marked with `worstCscore` are eligible for simulation; prior
  scores remain unchanged, and equal cleaned trees share one batch-local score.
  `hcMaxEvalsAnt=2000` therefore limits actual new simulator calls.
- The shared crossover path appends unique offspring after existing instances,
  derives population indices independently of the evaluation counter, and uses
  the previous center as the base for the previous sample. Its one-, two-, and
  three-simplex operators now stay inside the recorded sample window and match
  the C++ target counts/traversal.
<!-- Previous incorrect description: the empty seed was zero-complexity while
primitive ant actions and is_food_ahead all retained unit complexity. -->

- The empty `and_seq` seed has complexity zero. Primitive action nodes and
  `action_success`/`action_failure` have unit complexity; `is_food_ahead`,
  Boolean constants, and structural nodes have zero complexity.
<!-- Previous imprecise description: termination is checked against the newly
merged metapopulation. -->

- Expansion numbers advance, producing distinct deme IDs. Each generation's
  raw best updates the separate all-time champion before merge, and target
  termination checks that champion after the merge completes.

Additional parity and accounting corrections now in place are:

- Neighborhood size uses the sum of `log2(multiplicity)` and truncates it as
  C++ does, rather than summing raw knob multiplicities. Requested Hamming
  distance is then clamped to that dimension before the estimate is computed;
  the previous code incorrectly returned an empty neighborhood for an
  over-wide request.
- Ant merge conversion derives the behavioral score from each stored composite
  score. It no longer runs the ant simulator again merely to materialize the
  metapopulation.
- `antMaxEvals=100000` caps the complete ant run using the one initial scorer
  call plus actual newly scored instances. The outer loop threads the
  cumulative total and divides each expansion's remaining allowance fairly
  across its demes, subject to `hcMaxEvalsAnt` per deme; a negative value means
  unlimited. The dispatcher must score its initial exemplar, so a configured
  value below one has an effective minimum cost of that single call.
- Before penalized top-N/temperature trimming, the ant loop records one
  raw-best, shortest-on-tie scored instance in a separate accumulator. Merge
  and resize remain purely penalized, so that champion cannot change later
  roulette selection or exceed the archive cap. It is used only for diagnostics,
  termination, and one reserved final-output slot. This is analogous to C++
  `_best_candidates`, but MeTTa deliberately tracks one representative and sees
  every evaluated row before trim rather than retaining every exact tie.
- Initial instance coordinates are read through the ordered multimap API. Tests
  verify insertion order, repeated action-spec coordinates, their defaults, and
  semantic round-trip reconstruction through a randomized representation.
- Crossover now compares instance payloads, not complete scored rows, before
  appending offspring. Rediscovering an existing vector with `worstCscore` can
  no longer hide its equality to the already-scored row.
- Within each new scoring batch, distinct knob vectors that action-reduce to
  the same tree share one deterministic ant simulation and one Cscore. The
  actual-evaluation counter advances only for the first reduced-tree result.
- Initialization now derives the seed exemplar's composite score from its
  already measured behavioral score. The old path simulated that tree twice
  while counting neither call; the new path performs it once and seeds the
  complete-run evaluation counter with that call.
- The first `log2(multiplicity)` implementation used a `chain`/`foldr` result
  that was correct at top level but did not compose inside PeTTa's neighborhood
  estimator. The estimator now consumes a native fold result and uses grounded
  nonnegative truncation; the end-to-end test guards this real ASK-knob path.
- Random action-representation construction can legitimately produce no knob
  fields for a selected exemplar. Those representations are now filtered
  before hill climbing. If every representation is empty, the exemplar remains
  marked visited and, with the normal finite revisit setting, the ant loop
  selects another eligible tree at the same expansion ID without consuming a
  generation or evaluator call. This matches the retry in C++ `create_demes`;
  diagnostics report `AntRepresentationSkipped`. As in C++, the explicit
  negative/unlimited revisit mode can select the same failed tree again, so it
  is unsuitable as a convergence setting unless an external stop is used.
- `nDeme<=0` or `hcMaxEvalsAnt<=0` now terminates before expansion instead of
  entering a zero-work retry. The legacy `runAntMoses` wrapper counts only new
  expansion scores; complete-run callers use `runAntMosesCounted` and seed it
  with the cost of their already-scored input population.

## Diagnostics

Set `antDiagnostics=True` to emit:

<!-- Previous imprecise diagnostic descriptions referred to newly scored
instances and to the information dimension itself. -->

- `AntHillClimbingEvaluations`: actual simulator calls and cumulative local
  simulator calls; equal reduced trees can share one call;
- `AntHillClimbingNeighborhoodEstimate`: the estimated neighbor count computed
  from the C++-style truncated information dimension and current distance;
- `AntHillClimbingBest`: independent raw and penalized maxima;
- `AntGenerationDiagnostics`: selected tree, visit count, expansion number,
  actual local evaluations, unique materialized programs, retained candidate
  count, the all-time raw accumulator, and the selectable metapopulation's
  penalized maximum.

A rising raw maximum with a stable penalized maximum is expected when a more
complex trail follower is found but is not selected as the local center. A
repeated selected tree at `antRevisit=0`, a decreasing expansion number, or a
new-evaluation count that includes previously scored entries indicates a
regression.

## Current deterministic perfect-convergence regression

The finalized implementation now has a reproducible, ordinary-suite regression
that evolves a perfect tree from the empty `and_seq` seed. It is
`tests/ant-pipeline-test.metta`, with these search settings:

- seed `1`, `maxGen=1000`, and two independently randomized demes;
- 600 ant steps, complexity ratio `0.5`, and temperature `2000`;
- dominated-candidate retention, zero revisits, crossover enabled, and widening
  disabled;
- a 2,000-evaluation per-deme limit and a 30,000 actual-evaluation complete-run
  ceiling.

The large generation and evaluation values are safety ceilings, not expected
costs. Two independent command-line runs and the checked-in test produced the
same first perfect tree. The diagnostic run followed `-78@expansion 0 / 15
evaluations`, `-37@expansion 1 / 177`, and `0@expansion 2 / 520`, then stopped on
the raw target with 997 future expansions and 29,480 evaluations still available.
Routine test runs take about ten seconds on the development machine.

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

The tree has complexity 8, raw score `0`, and penalized score `-16`. Independent
600-step simulation confirms that it eats all 89 pellets. The test intentionally
asserts the behavior and independent rescore rather than this exact syntax,
because the same final result contains several semantically perfect trees.

This `0.5` ratio is a practical convergence setting, not a claim about the C++
performance-diary default. `getComplexityCoef` is the inverse of the ratio, so
raising it from `0.16` to `0.5` lowers the primitive-action charge from `6.25`
to `2`. Hill climbing still optimizes a complexity-penalized score, but useful
control structure can survive long enough to become a complete trail follower.
The production default remains `0.16` for C++-configuration parity; the pipeline
regression overrides it locally.

For comparison, two current finalized runs at ratio `0.16` were identical: they
first reached `-2` (87 pellets) at expansion 40 / 14,107 evaluations and
exhausted the 20,000-evaluation ceiling at expansion 57 without reaching zero.
This confirms that extending `maxGen` alone is ineffective when the actual-
evaluation budget or complexity pressure is still limiting the run.

## Historical 25-generation seed-10 verification

Two independent runs of the then-current 25-generation parity configuration
produced identical exemplar selections and generation diagnostics. A later
clean-snapshot run after separating the all-time raw champion from the
selectable archive again reproduced the same final score and tree. These runs
predate the final correction that preserves one-, two-, then three-simplex
crossover group order, so their exact trajectory is historical evidence rather
than a current regression contract. It improved from `-78` at expansion 0, to
`-40` at expansion 5, to `-27` at expansion 12, and to `-22` at expansion 18,
where it remained through expansion 24.

<!-- Previous expansion-only accounting:
The final result ate 67 of 89 pellets (`-22`) after 5,559 actual ant simulator
calls and retained 5,146 candidates.
-->
The final result ate 67 of 89 pellets (`-22`) after 5,560 complete-run ant
simulator calls and retained 5,146 candidates. Of those calls, 5,559 evaluated
expansion-generated instances and one evaluated the initial exemplar:

```text
(and_seq
  (action_bool_if is_food_ahead
    (and_seq
      turn_left
      (action_bool_if is_food_ahead (and_seq move_forward) (and_seq turn_left))
      turn_right turn_right move_forward turn_left
      (action_bool_if is_food_ahead (and_seq turn_left) (and_seq turn_right))
      (action_bool_if is_food_ahead move_forward turn_right))
    (and_seq
      turn_right move_forward
      (action_bool_if is_food_ahead
        (and_seq move_forward)
        (and_seq turn_left
          (action_bool_if is_food_ahead
            (and_seq turn_left turn_right)
            (and_seq move_forward))))
      move_forward)))
```

This is stronger than the historical 65-pellet breadth run below, but it is
still a search-health result rather than a perfect-convergence regression.

## Historical perfect seed-1 search and permanent fixture

During parity experimentation, the predecessor implementation evolved a
perfect tree twice with identical non-timing output. A third run after moving
the raw champion into a separate accumulator reproduced the same trajectory,
score, tree, evaluation count, and retained count. Each reached raw score `0`
at expansion 50 after 13,947 complete-run evaluator calls and retained 13,042
candidates. The raw trajectory was `-78@0`, `-20@4`, `-10@39`, and `0@50`;
the first two runs had all 6,168 non-timing log lines byte-identical. These runs
predate the final correction to crossover group order, so the trajectory is not
claimed as reproducible by the current implementation. The tree itself remains
a permanent direct scoring/complexity regression.

The winning tree has complexity 8 and composite score
`(mkCscore 0 8 50.0 0.0 -50.0)`:

```text
(and_seq
  (action_bool_if is_food_ahead
    (and_seq move_forward move_forward)
    (and_seq
      turn_left
      turn_left
      (action_bool_if is_food_ahead
        (and_seq move_forward)
        (and_seq turn_right))
      move_forward))
  turn_right)
```

Independent simulation eats 68 pellets in 400 actions and all 89 in the
configured 600 actions. The 600-step setting is therefore part of this
convergence result, not merely additional unused runtime.

The historical experiment command was (replace both paths for the local
checkouts, and run from the PeTTa directory so its script can find `src/main.pl`):

```text
cd /path/to/PeTTa
sh run.sh /path/to/metta-moses/moses.metta -s \
  --problem=ant --seed=1 --maxGen=1000 --nDeme=2 --optAlgo=hc \
  --antSteps=600 --antComplexityRatio=0.16 \
  --antComplexityTemperature=2000 --antMaxEvals=20000 \
  --antDiscardDominated=False --antRevisit=0 \
  --antDiagnostics=True --hcWidenSearch=False --hcCrossover=True \
  --maxCandPerDeme=-1
```

<!-- Previous status before the ratio-0.5 convergence experiment:
A current convergence rerun remained opt-in because the historical runs took
roughly nine minutes, while the ordinary pipeline test checked only a six-
expansion seed-10 prefix.
-->

The current auto-discovered pipeline test instead uses the practical ratio-0.5
configuration documented above and requires a perfect independently rescored
result. This historical ratio-0.16 section remains useful for distinguishing the
old crossover-order trajectory from the finalized implementation.

The historical control experiments below were stopped once the perfect seed-1
result was reproduced. Evaluation counts refer to their latest completed
expansion and are not current regression expectations.

| Configuration | Evaluations | Best raw | Pellets | Outcome |
| --- | ---: | ---: | ---: | --- |
| ratio `0.16`, seed 1, pure Boltzmann | 13,947 | `0` | 89 | Perfect in three confirmations |
| ratio `0.16`, seed 10, pure Boltzmann | 21,448 | `-4` | 85 | Interrupted at expansion 66 |
| ratio `0.06`, seed 10, pure Boltzmann | 14,196 | `-5` | 84 | Interrupted at expansion 145 |
| ratio `0.08`, seed 10, pure Boltzmann | 10,141 | `-27` | 62 | Interrupted during expansion 95 |
| ratio `0.16`, seed 10, raw elite plus one revisit | 10,270 | `-34` | 55 | Stopped as inferior |

The controls show that the modern C++ ratio `0.06` is viable but was not the
best small-budget MeTTa setting in this sweep. They also confirm that forcing
the current raw champion is not automatically useful: the successful run used
ordinary complexity-penalized Boltzmann selection with no revisits.

<!-- Previous heading: "Verified seed-10 trajectories". Those observations
predate the complexity, information-bit, crossover, merge, and global-budget
parity corrections and are not current regression expectations. -->
## Historical seed-10 trajectories (before the current parity fixes)

Before the corrections listed above, two independent 25-generation runs
produced identical generation diagnostics, selected trees, evaluation counts,
and final output. Expansion IDs ran from `0` through `24`, every selected tree
reported `visitCount 1`, and the best raw score improved from the old `-78`
plateau to `-28` (61 of 89 pellets):

```text
(and_seq
  (action_bool_if is_food_ahead action_success
    (and_seq turn_right move_forward turn_left))
  move_forward move_forward move_forward move_forward)
```

This was a search-health observation, not a perfect-convergence regression; no
89-pellet program was found under that deliberately smaller MeTTa budget. It is
retained as history and must not be used as the expected post-fix trajectory.

The improved breadth configuration used two independently randomized demes per
exemplar and `antComplexityRatio=0.20`. It deterministically reached raw `-24`
(65 pellets) at expansion 23:

```text
(and_seq move_forward move_forward
  (action_bool_if is_food_ahead
    (and_seq move_forward turn_right
      (action_bool_if is_food_ahead move_forward turn_right))
    (and_seq turn_right move_forward
      (action_bool_if is_food_ahead
        (and_seq move_forward)
        (and_seq turn_left move_forward)))))
```

<!-- Previous contradictory wording: the 50-generation experiment therefore
stopped after 25 generations. -->

A 50-generation pre-fix verification found no improvement after expansion 23,
while the retained metapopulation grew from roughly 5,500 candidates at
discovery to 12,876 candidates. That result motivated a subsequent 25-generation
routine cutoff. Ant finalization reserves one output slot for this raw-best
exemplar; previously the penalized top-N conversion could retain it internally
but omit it from `FinalResult`.

## Historical raw-elite exploitation experiment

<!-- Previous wording called this the "next experiment" and said its parameters
remained available for opt-in use.  Both claims became stale when the inferior
overlay was removed; the section now records results only as history. -->

An earlier experimental worktree exposed two ant-only parameters for a
raw-elite selection overlay. The experiment was discarded because the mode does
not match C++ selection and performed worse than pure Boltzmann search:

- `antRawEliteInterval` selected the raw-best visit-eligible exemplar at a
  configured interval instead of using Boltzmann roulette.
- `antRawEliteStartExpansion` delayed the first such selection, allowing an
  unchanged exploration phase before exploitation began.

The removed overlay still filtered through `antEligibleExemplars` and recorded
the visit, so `antRevisit=0` remained effective. Its diagnostics reported the
selection mode and the selected exemplar's raw and penalized scores. It was
never a parity claim: C++ roulette uses penalized score; its independently
tracked raw score is used for termination, not selection.

The following results also predate the current parity fixes. A one-shot seed-10
control used the then-current 25-generation configuration with
`antRawEliteInterval=24`. Expansion 0 selected the same singleton seed without
consuming roulette randomness, and all generated outcomes through expansion 23
reproduced the baseline. Expansion 24 selected the retained raw `-24` /
penalized `-94` tree from 5,428 eligible candidates, and 514 new evaluations
produced no improvement.

The historical follow-up used `maxGen=35`, `antRawEliteInterval=1`, and
`antRawEliteStartExpansion=24`, with all other then-current pipeline settings
unchanged. Expansions 0 through 23 again reproduced the baseline exactly. The
raw-elite phase improved the best score from `-24` to `-19` at expansion 28,
meaning 70 of 89 pellets were eaten:

```text
(and_seq
  move_forward
  move_forward
  (action_bool_if is_food_ahead
    (and_seq
      move_forward
      turn_right
      (action_bool_if is_food_ahead
        (and_seq move_forward move_forward)
        (and_seq turn_left)))
    (and_seq
      turn_right
      move_forward
      (action_bool_if is_food_ahead
        (and_seq move_forward)
        (and_seq turn_left move_forward))))
  move_forward)
```

The score remained `-19` through expansion 34. The final retained pool contained
8,005 candidates. In that pre-fix comparison it beat the shorter breadth run,
but the later corrected pure-Boltzmann search did substantially better and made
the overlay unnecessary.

The overlay is retained here only as experiment history; its removed parameters
are not part of the public ant interface.

The shared `crossover`/`merge3Demes` path retains existing scored instances as
the population prefix and appends unique offspring in one-, two-, then
three-simplex order. The redundant ant-only crossover wrappers were therefore
removed.

The counted optimizer currently communicates its per-deme allowance through
the temporary `&antLocalEvalLimit` state because the generic optimizer function
signature has no budget argument. Sequential successful calls restore the
sentinel and are covered by integration tests. Passing the allowance explicitly
is deferred with the generic optimizer API work; that will also make failure
paths and concurrent/reentrant expansion naturally exception-safe.

## Deferred generic parity work

The generic Boolean/strategy path still needs a separately reviewed change for
visited-exemplar state, configurable dominance retention, actual evaluation
accounting, expansion-number progression, and post-merge termination. Those
changes are intentionally not hidden inside the ant fix because they can alter
established search trajectories and tests for every domain.
