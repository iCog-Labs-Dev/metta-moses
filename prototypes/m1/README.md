# M1 prototype — evolving a condition inside a program

A self-contained prototype. It imports nothing from the rest of the codebase,
and nothing in the codebase imports it. Delete the folder and everything else
still works.

## Run it

```sh
# the guided walkthrough -- start here, no background needed
( ulimit -v 8000000; timeout 900 \
    sh /home/yab/PeTTaV1/run.sh prototypes/m1/demo.metta -s )

# the same thing starting from an empty program
( ulimit -v 8000000; timeout 900 \
    sh /home/yab/PeTTaV1/run.sh prototypes/m1/demo-from-scratch.metta -s )

# the checks -- every line should end in a green tick
( ulimit -v 8000000; timeout 900 \
    sh /home/yab/PeTTaV1/run.sh prototypes/m1/tests/run.metta -s ) | grep -c ✅
```

That last count must equal the number of checks written down:

```sh
cat prototypes/m1/tests/t-*.metta | grep -c '^!(test'
```

Both are **148**. Compare them; do not just look for failures. A check whose
expected value is a program written out longhand is a *call*, and unless it is
wrapped in `quote` it produces no answer and the check never runs — printing
nothing at all, neither pass nor fail. Eleven checks were silently missing this
way before the counts were compared.

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

## Reading order

| | |
|---|---|
| `demo.metta` | the guided walkthrough. Start here. |
| `demo-from-scratch.metta` | the same machinery with no starting program at all |
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
| `domain/tape.metta` | the toy world — the only file that knows what a context is |
| `all.metta` | loads everything, in the one order that works |

## Three ideas worth the detour

**Operators never mention the context.** `(= (and_seq $children) ...)` — no
world, no board, nothing. Each body ends in a partially applied call and the
compiler supplies the missing argument. So the same operators work for any
domain, and only `domain/tape.metta` knows what is being evaluated.

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

## Two things that will bite you

**Every operator body must end in a call.** A body starting with a bare `if`
does not get the extra argument, compiles one short, and then *every* program
silently scores worst while the run still looks healthy. `ifM` exists for this,
and `tests/t-operators.metta` checks each operator's arity individually. If
those fail, ignore everything below them.

**Only `all.metta` imports.** Loading a file twice defines everything in it
twice, and duplicate definitions here do not replace each other — they pile up
and every answer comes back doubled. `demo.metta` and `tests/run.metta` import
`all.metta` and nothing else; no file under `core/`, `knobs/`, `search/` or
`domain/` imports anything.

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

`demo-from-scratch.metta` is where the candidate rule stops being a footnote.
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
