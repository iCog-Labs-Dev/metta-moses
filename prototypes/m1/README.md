# M1 prototype — evolving a condition inside a program

A self-contained prototype. It imports nothing from the rest of the codebase,
and nothing in the codebase imports it. Delete the folder and everything else
still works.

## Run it

```sh
# Every demo is ONE call -- (m1Moses <name> <exemplar> <scorer> <best>) -- and
# search/moses.metta is the only place the pieces are assembled. Each run also
# repeats itself from an EMPTY program and prints both, so a result that only
# works because the exemplar was already half the answer says so.

# a creature on a tape: is it worth LOOKING before you grab?
( ulimit -v 8000000; timeout 900 \
    sh /home/yab/PeTTaV1/run.sh prototypes/m1/demo.metta -s )

# a second world, where ONE test is not enough
( ulimit -v 8000000; timeout 900 \
    sh /home/yab/PeTTaV1/run.sh prototypes/m1/demo-orchard.metta -s )

# a third, where the answer is not among the candidates at all
( ulimit -v 8000000; timeout 900 \
    sh /home/yab/PeTTaV1/run.sh prototypes/m1/demo-berries.metta -s )

# no actions at all -- an input table and a boolean formula to find
( ulimit -v 8000000; timeout 900 \
    sh /home/yab/PeTTaV1/run.sh prototypes/m1/demo-alarm.metta -s )

# a NUMBER, not a subtree -- the exemplar's structure is right and its
# threshold is wrong, and no rearrangement of subtrees can fix that
( ulimit -v 8000000; timeout 900 \
    sh /home/yab/PeTTaV1/run.sh prototypes/m1/demo-grove.metta -s )

# the checks -- every line should end in a green tick
( ulimit -v 8000000; timeout 900 \
    sh /home/yab/PeTTaV1/run.sh prototypes/m1/tests/run.metta -s ) | grep -c ✅
( ulimit -v 8000000; timeout 900 \
    sh /home/yab/PeTTaV1/run.sh prototypes/m1/tests/run-orchard.metta -s ) | grep -c ✅
( ulimit -v 8000000; timeout 900 \
    sh /home/yab/PeTTaV1/run.sh prototypes/m1/tests/run-berries.metta -s ) | grep -c ✅
( ulimit -v 8000000; timeout 900 \
    sh /home/yab/PeTTaV1/run.sh prototypes/m1/tests/run-alarm.metta -s ) | grep -c ✅
( ulimit -v 8000000; timeout 900 \
    sh /home/yab/PeTTaV1/run.sh prototypes/m1/tests/run-contin.metta -s ) | grep -c ✅
( ulimit -v 8000000; timeout 900 \
    sh /home/yab/PeTTaV1/run.sh prototypes/m1/tests/run-grove.metta -s ) | grep -c ✅
```

Each count must equal the number of checks written down for that suite:

```sh
cat prototypes/m1/tests/t-{operators,types,knobs,decode,domain,search}.metta \
    | grep -c '^!(test'                                    # 147, the tape suite
grep -c '^!(test' prototypes/m1/tests/t-orchard.metta       #  66, the orchard suite
grep -c '^!(test' prototypes/m1/tests/t-berries.metta       #  47, the berry suite
grep -c '^!(test' prototypes/m1/tests/t-alarm.metta         #  39, the boolean suite
grep -c '^!(test' prototypes/m1/tests/t-contin.metta        #  80, tunable numbers
grep -c '^!(test' prototypes/m1/tests/t-grove.metta         #  27, the mixed suite
``` Compare them; do not just look for failures, and note that the two ways of
coming up short mean different things.

A check whose expected value is a program written out longhand is a *call*, and
unless it is wrapped in `quote` it produces no answer and the check never runs —
printing nothing at all, neither pass nor fail. Eleven checks were silently
missing this way before the counts were compared. **That is a short count with no
failure.**

A short count *with* a failure means something else: `test` calls `halt(1)` on
mismatch (`metta.pl:200`), so the run stopped at the first red tick and every
check after it never ran. Berries reports 29 + 1 for exactly this reason — its
exemplar is deliberately emptied, and 17 checks sit behind the failure.

The `ulimit`/`timeout` wrapper is not optional — an unbounded run can exhaust
memory and take the whole session with it.

## What it does

A creature walks a loop of cells, some holding food. It can grab, step, and
look. It starts with a program that is exactly backwards — it walks away from
food and grabs at empty cells — and scores **−25** out of a possible **10**.

The prototype turns that one program into a space of millions, searches it, and
comes back with a program scoring **10**. The interesting part is not that it
improves; it is that **no program which never looks can score above 2**, and
that is a proof rather than an observation: the two test loops agree in one
place and differ everywhere else, and an action reports the same thing whether
or not it found food, so a program with no perception in it runs an identical
course on both. Whatever it gains on one, it loses on the other.

So the search did not just find a better program. It found one that had to
*look* to be that good.

`demo-orchard.metta` is a second world asking a harder question. Cells hold
fresh fruit, spoiled fruit, or nothing; picking is worth +2, −3 and −1. Two
perceptions are available and **neither is any use alone** — every conditional
built from a single one scores between −6 and −25, all of them worse than doing
nothing, because picking wherever nothing is spoiled means picking at empty
cells and an empty pick does not move you. Only `(AND fruitHere freshHere)`
picks out a fresh fruit, and that is worth 12. The search gets there in one
knob: the second candidate at the condition position is the perception that was
missing, and switching it on puts it alongside the one already there.

Same core, same knobs, same search. `domain/orchard.metta` declares four
primitives and says what a program is worth; nothing else changes.

`demo-berries.metta` takes away the thing that made the orchard easy. Berries
are ripe by colour or by smell, and some of the ripe-looking ones are wormy, so
the answer is `(AND (OR berryRed berrySweet) (NOT berryWormy))` — and
**`(OR berryRed berrySweet)` is not one of the candidates**. The sampler works
to a budget, its odometer holds the leading argument steady longest, and
`berryWormy` is declared first, so every pair on offer leads with `berryWormy`
and the one we need is never reached. No single knob can produce the answer:
the best a single setting reaches is 8 out of 16.

It gets there anyway, in **two moves** — `−4 → 8 → 16`. The first switches on
`(NOT berryWormy)`, which *is* on the menu. The second adds `berrySweet` inside
the OR node the builder leaves under every condition, alongside the `berryRed`
already sitting there. That node is the whole reason a shape nobody offered is
still reachable: the candidates are the letters, and the node is where words get
spelled.

It also marks the limit honestly. Both moves had to pay off on their own,
because a single hill climb accepts nothing else. An answer whose first half is
worthless without its second is still out of reach — which is what a population
is for, and there isn't one here.

## Reading order

| | |
|---|---|
| `search/moses.metta` | **the top-level call.** The one place the pieces are assembled — `(m1Moses <name> <exemplar> <scorer> <best>)`. Read this and you have read the pipeline. |
| `demo.metta` | a creature on a tape: is it worth LOOKING before you grab? Start here. |
| `demo-orchard.metta` | two senses, each blind to what the other sees — the case for compound conditions |
| `demo-berries.metta` | the answer is not a candidate at all, and has to be assembled |
| `demo-alarm.metta` | no world: an input table, a row for a context, one parametrised primitive per column |
| `demo-grove.metta` | a tunable NUMBER, alongside action and condition knobs in one instance vector |
| `core/prelude.metta` | list and tree helpers. Nothing interesting. |
| `core/monad.metta` | how a context (a world, a board, a table row) is threaded |
| `core/evaluator.metta` | running a program |
| `core/operators.metta` | the operators themselves |
| `core/types.metta` | the questions the builder asks instead of naming operators |
| `knobs/knob.metta` | what a knob is |
| `knobs/perms.metta` | what candidates get offered at a position, and how they are built |
| `knobs/builder.metta` | turning one program into a space of programs |
| `knobs/decode.metta` | turning a point in that space back into a program |
| `search/hillclimb.metta` | looking for a better point |
| `domain/tape.metta` | the first world — a domain file is the only kind that knows what a context is |
| `domain/orchard.metta` | the second world, drop-in against the same core |
| `domain/berries.metta` | the third — the one the sampler cannot hand over |
| `domain/alarm.metta` | a fourth with no actions at all — the classic boolean path: an `mkITable` of rows, one parametrised `colAt` standing for every column, and a 0/−1 behavioural score |
| `all.metta` | loads everything domain-independent, in the one order that works |

`all.metta` loads **no domain**. A demo or a test suite picks one:

```metta
!(import! &self prototypes/m1/all)
!(import! &self prototypes/m1/domain/tape)
```

Loading two at once would merge their vocabularies, which is exactly what the
type queries would then report.

## Three ideas worth the detour

**Operators never mention the context.** `(= (and_seq $children) (allM evalTerm $children))`
— no world, no board, nothing, and no conditional either. So the same operators
work for any domain, and only the file under `domain/` knows what is being
evaluated.

**The context is ambient, and only `core/monad.metta` may name it.** It lives in
a state cell reached through `getCtx` and `putCtx` — Haskell's `MonadState`
`get` and `put` — and those two are the abstraction barrier: they are the seam
to use if it ever has to go back to being a threaded value.

This is the `IO`/`ST` way of hiding state rather than the `State s` way.
`State s a = s -> (a, s)` hides it inside a wrapped function, which needs
closures; `IO` hides it by making it ambient, and `RealWorld` is a fiction
nothing threads. `Control.Monad.Extra`'s `allM` is `Monad m =>` and is written
identically for both, which is why `core/monad.metta`'s two definitions are
character-for-character the Haskell ones.

What does *not* survive is a definable `>>=`. Arguments here are built strictly,
so by the time a function is entered its arguments have already run — a
user-defined bind would receive a value rather than a computation it could
choose whether to run. So `m >>= k` is `let`, `fmap f m` is `(f m)`, `return v`
is `v`, and `ifM` is `if`. `ifM` in particular *must* be `if`, because only a
special form is lazy in its branches; written as a function, `allM`'s recursive
call would run before the test was looked at. A real `>>=` needs some way to
hold an unrun computation, and the three ways to do that — partial application,
a closure, or data — are all things this prototype deliberately does not use.

**The builder never names an operator.** It asks the type declarations: what
does this slot want, and what can produce that? A slot wanting `Bool` gets an
evolved condition — it does not matter which operator the slot belongs to.
Declare a new perception and it joins the vocabulary on its own; nothing else
changes.

**A candidate is a whole operator, not just a symbol.** What gets offered at a
position is either a primitive or an operator with *every* argument filled by
something of the type that argument asks for — `(OR (NOT p) q)`, and equally
`(action_bool_if m1FoodHere m1Grab m1Step)`. A half-filled operator is never
offered. This is what lets structure appear that the search could not have
assembled one piece at a time, and it is the same trick in both directions:
an `AND` can acquire an `OR` inside it, and a program with no conditional can
grow one.

**One candidate is one knob.** A knob's settings are the ways *that* candidate
can be handled — two for an action (out, in), three for a test (out, in,
negated). The number of candidates on offer is the number of *knobs*, never the
width of one. Folding the candidates into a single knob's settings would mean a
position could hold at most one of them, so `(and_seq GRAB STEP)` could never
be built and a conditional could never sit alongside anything else.

## Things that will bite you

**An operator must call `evalTerm`, never `evalProgram`.** `evalProgram` is the
boundary: it writes the cell from its argument, so an operator that called it
would discard the context threaded so far and restart from whatever it was
handed. Nothing errors — the laziness and threading checks in
`tests/t-operators.metta` are what catch it. This replaced eta-expansion as the
thing to get wrong here.

**Import order gates reduction.** A call to a function that has not been
imported yet compiles as *data* rather than failing. `core/types.metta` must
load before `core/evaluator.metta` (`evalNode` asks `isPrimitive`), and the
evaluator before the operators. `all.metta` is the only file that imports, and
its order is the working one.

**Mutation is not undone by backtracking.** PeTTa's state is `nb_setval`, and
`collapse` backtracks looking for further solutions — so a second solution would
run the actions *again*. Every `collapse` in `evalNode` has `once` inside it for
that reason. The single-solution discipline elsewhere (`containsIn`'s `once`,
`nub`) is load-bearing in a way it was not when contexts were values: a stray
duplicate used to show up as a doubled number, and now shows up as extra
actions.

**A program that fails partway keeps what it already did.** When contexts were
values, the worst result handed back the context it was *given*. With the
context in a cell that would take a snapshot and a restore, and this prototype
deliberately does not. Nothing reaches it today — the builder only emits
well-formed programs from declared vocabulary — but it is no longer true.

**`tests/t-operators.metta` still opens with arity checks, and they still come
first.** A symbol compiled at the wrong arity fails dispatch silently and
*every* program scores worst while the run looks healthy. If those fail, ignore
every result below them.

**A declared operator cannot be called from source.** Writing `(AND (True False))`
literally in a file yields nothing — the compiler injects a type check at such a
site, and a tuple's type comes back as `(Bool Bool)`, which does not unify with
the declared `(Seq Bool)`. Operators are reached only through the evaluator's
`reduce`, which never consults declarations. This was always true of every
declared operator; it only became visible when `AND` and `OR` were declared,
because they were the only ones anything called directly.

**Only `all.metta` and a domain get imported.** Loading a file twice defines
everything in it twice, and duplicate definitions here do not replace each other
— they pile up and every answer comes back doubled. That is not hypothetical: a
`blindScores` helper defined in two test files turned one assertion into 65537
solutions. No file under `core/`, `knobs/`, `search/` or `domain/` imports
anything.

**A program is never pretty-printed.** There is no `showTree`. A program is
shown by *compiling* it — `preOrderExp`, the same call the scorer makes — so
what a demo prints is exactly the term the evaluator receives, `(op (children))`
with leaves as `(op ())`. It is noisier to read and it cannot drift.

## Where these names come from

Nothing here is invented where MOSES already had a word for it. Read the middle
column if you know the production tree, the right one if you know the C++.

| this prototype | metta-moses | classic MOSES |
|---|---|---|
| `buildKnobs` | `buildKnobs` | `build_knobs` |
| `buildLogical` | `buildLogical` | `build_knobs::build_logical` |
| `addLogicalKnobs` | `addLogicalKnobs` | `add_logical_knobs` |
| `logicalCanonize` | `logicalCanonize` | `logical_canonize` |
| `addSimpleActionKnobs` | `addSimpleActionKnobs` | `add_simple_action_knobs` |
| `logicalSubtreeKnob` / `mkLSK` | same | `logical_subtree_knob` |
| `simpleActionSubtreeKnob` | `simpleActionSubtreeKnob` | `simple_action_subtree_knob` |
| `actionSubtreeKnob` / `mkASK` | `actionSubtreeKnob` | `action_subtree_knob` |
| `continKnobFor` / `mkCTK` | — | `contin_knob` |
| `continWalk` / `continLeft` / `continRight` | — | `field_set::contin_stepper` |
| `continDefaults` / `mkContin` | — | `field_set::contin_spec` |
| `buildInner` | — | `build_knobs::build_contin` |
| `numGt` | — | `greater_than_zero` |
| `isFillable` | — | — (classic's `permitted_op` filters symbols, not fillability) |
| `sampleLogicalPerms` | `sampleLogicalPerms` | `sample_logical_perms` |
| `samplePerms` | — (`sampleLogicalPerms` + `sampleActionPerms`) | — (`sample_logical_perms` + `sample_action_perms`) |
| `permittedOpsFor` | `swapAndOr` | `swap_and_or` + `permitted_op` |
| `swapAndOr` | `swapAndOr` | `swap_and_or` |
| `getCandidate` | `getCandidate` | `representation::get_candidate` |
| `getCandidateRec` | `getCandidateRec` | `get_candidate_rec` |
| `cleanTree` | `cleanTree` | `clean_combo_tree` / `logical_cleanup` |
| `preOrderExp` | `preOrderExp` | — (`combo_tree` runs directly) |
| `knobMultiplicities` | `getKnobMultip` | `field_set::disc_spec::multy` |
| `exemplarInst` | `initCenterInst` | `representation::exemplar_inst` |
| `changeAt` | `changeAt` | `field_set::set_raw` |
| `varyNKnobs` | `varyNKnobs` | `vary_n_knobs` |
| `generateAllInNeighborhood` | `generateAllInNeighborhood` | `generate_all_in_neighborhood` |
| `hillClimbing` | `hillClimbing` | `hill_climbing::operator()` |
| `isPrimitive` | `isAnArgument` | `is_argument` |

Two entries are worth reading twice. `samplePerms` is **one** function where both
implementations have two, because the type of the slot is an argument rather
than something baked into the function name. And `permittedOpsFor` generalises
`swapAndOr`: rather than "inside an AND, use OR", the rule is "a candidate is
never headed by the operator it will sit under", which produces the AND/OR
alternation as a special case and also keeps `(NOT (NOT p))` from being offered.

Things with no counterpart keep descriptive names: `slotTypesOf`, `fillersOfType`,
`vocabsOf`, `fillAt`, `usableFilling`, `candidateAt`, `sampleCandidates`. They
are the type-driven filling machinery, which is the part that is genuinely new.

## What it does not do

- **One level of structure per candidate.** A candidate's arguments are
  primitives, so a three-level formula like
  `(AND (OR ...) (OR (NOT ...) (AND ...)))` needs a second generation. Raising
  `seqArity` or nesting the fill would go deeper at an exponential cost in
  knobs; `permCount` is the budget that keeps it honest.
- **Primitives take no parameters.** A perception like "is this cell an F?"
  that takes an argument would be admitted to the vocabulary and then called
  with nothing, failing silently. Filling parameter slots needs a vocabulary of
  *values*, which is a separate piece of work.
- **No reduction, no complexity penalty, no population.** The search is one
  hill climb from one starting point.
- **A number is tunable only where the program already has one.** A tunable
  number takes its starting value from the tree, so a number the author wrote
  or an exemplar carried can be moved, and one that exists nowhere cannot be
  invented. Classic gets around this by *planting* constants — `contin_canonize`
  rewrites a term into `c1 + (c2 * p1) / p2` and hangs `*(0 $i)` on every
  argument, so tuning a coefficient off zero switches an input on. That is the
  symbolic-regression half of classic, it is what makes its ~43 arithmetic
  reduction rules necessary, and none of it is here. `demo-grove.metta` reports
  the consequence rather than hiding it: its control run from an empty program
  has nothing to tune and says so.
- **A number inside a switched-off candidate gets no knob.** Its slots would
  not be reported by `knobSpecs`, so the instance vector would come out short.
  Switching a candidate on and tuning it in the same run needs placeholders to
  be treated as disabled knobs rather than as absent ones.
- **One step size for the whole run.** `continDefaults` is a single spec, as
  classic's `_step_size` / `_expansion` / `_depth` are single `build_knobs`
  members. A threshold ranging over tens and a stride ranging over ones cannot
  both be served well by it. Classic tried per-position adaptation and
  abandoned it — the code is still there, `#if 0`'d, with the verdict that it
  "often slows down the search, and rarely/never seems to provide better
  answers".
- **A Number slot's occupant is fixed once built.** The search tunes the numbers
  in a comparison and can swap in a whole different comparison, but cannot
  change which sense one of them reads.

Every demo prints its run from an empty program too, which is where the candidate rule stops being a footnote.
Given an empty program — eight candidates, all switched off, scoring 0 — the
search reaches **10 in a single move**, by saying yes to
`(action_bool_if m1FoodHere m1Grab m1Step)`.

Had only bare primitives been on offer it would have gone nowhere, for two
reasons that have nothing to do with search effort. A **valley**: grab-then-step
is worth 2, but the first addition alone costs −24 and a climb that only accepts
improvements cannot cross that. And a **ceiling** behind it: every program made
of grab and step is capped at 2, because none of them looks, so crossing the
valley would not have helped either.

Offering complete operators goes *around* both. The valley is still there — this
is a single hill climb, and MOSES's answer to valleys is a population, which is
not built here.
