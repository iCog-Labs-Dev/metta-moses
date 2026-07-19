# Santa Fe Ant Search Parity

This note records why the ant search used to plateau near raw score `-78`, what
is now aligned with classic C++ MOSES, and which generic changes remain
deliberately deferred.

## C++ behavior

The reference implementation is in
`/Users/bitseat/KiraFiles/iCogLabs/moses-main/main-repo/moses`.

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
- The Santa Fe action vocabulary assigns no complexity to the empty
  `sequential_and` seed; primitive actions and perceptions contribute
  complexity.

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
6. prepended crossover offspring, invalidating previous-range bookkeeping;
7. counted the empty `and_seq` seed as complexity one; and
8. recursed without incrementing the expansion number and tested the old
   metapopulation after a merge.

Together these make a local optimum sticky: useful stepping stones disappear,
the same source tree is expanded again, and most of the nominal budget is spent
rescoring known programs.

## Ant-only remedy

The normal `moses-run` dispatcher now routes ant to `runAntMoses`; Boolean and
strategy searches still use generic `runMoses`.

- `antDiscardDominated=False` retains unique, trimmed ant candidates. Setting
  it to `True` restores dominance filtering.
- `antRevisit=0` permits one expansion per tree. A positive value permits that
  many additional visits. An empty eligible pool terminates cleanly.
- Ant hill climbing still optimizes penalized score, while the maximum raw
  score across the whole evaluated deme controls target termination.
- Only instances marked with `worstCscore` invoke `antBasedScorer`; prior scores
  remain unchanged. `hcMaxEvalsAnt=2000` therefore means actual new scorer
  calls.
- Ant crossover appends unique offspring after existing instances and derives
  population indices independently of the evaluation counter.
- The empty `and_seq` seed has complexity zero. Primitive ant actions and
  `is_food_ahead` retain unit complexity.
- Expansion numbers advance, producing distinct deme IDs, and termination is
  checked against the newly merged metapopulation.

## Diagnostics

Set `antDiagnostics=True` to emit:

- `AntHillClimbingEvaluations`: newly scored instances and cumulative local
  scorer calls;
- `AntHillClimbingBest`: independent raw and penalized maxima;
- `AntGenerationDiagnostics`: selected tree, visit count, expansion number,
  actual local evaluations, unique materialized programs, retained candidate
  count, and metapopulation raw/penalized maxima.

A rising raw maximum with a stable penalized maximum is expected when a more
complex trail follower is found but is not selected as the local center. A
repeated selected tree at `antRevisit=0`, a decreasing expansion number, or a
new-evaluation count that includes previously scored entries indicates a
regression.

## Verified seed-10 trajectories

Two independent 25-generation runs produced identical generation diagnostics,
selected trees, evaluation counts, and final output. Expansion IDs ran from
`0` through `24`, every selected tree reported `visitCount 1`, and the best raw
score improved from the old `-78` plateau to `-28` (61 of 89 pellets):

```text
(and_seq
  (action_bool_if is_food_ahead action_success
    (and_seq turn_right move_forward turn_left))
  move_forward move_forward move_forward move_forward)
```

This is a search-health regression, not a perfect-convergence regression; no
89-pellet program was found under the deliberately smaller MeTTa budget.

The improved breadth configuration uses two independently randomized demes per
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

A 50-generation verification found no improvement after expansion 23, while
the retained metapopulation grew from roughly 5,500 candidates at discovery to
12,876 candidates. The checked-in regression therefore stops after 25
generations. Ant finalization reserves one output slot for this raw-best
exemplar; previously the penalized top-N conversion could retain it internally
but omit it from `FinalResult`.

## Deferred generic parity work

The generic Boolean/strategy path still needs a separately reviewed change for
visited-exemplar state, configurable dominance retention, actual evaluation
accounting, expansion-number progression, post-merge termination, and generic
crossover ordering. Those changes are intentionally not hidden inside the ant
fix because they can alter established search trajectories and tests for every
domain.
