# M1 prototype — evolving a condition inside a program

A self-contained prototype. It imports nothing from the rest of the codebase,
and nothing in the codebase imports it. Delete the folder and everything else
still works.

## Run it

```sh
# the guided walkthrough -- start here, no background needed
( ulimit -v 8000000; timeout 900 \
    sh /home/yab/PeTTaV1/run.sh prototypes/m1/demo.metta -s )

# the checks -- silence means everything passed
( ulimit -v 8000000; timeout 900 \
    sh /home/yab/PeTTaV1/run.sh prototypes/m1/tests/run.metta -s )
```

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
| `core/prelude.metta` | list and tree helpers. Nothing interesting. |
| `core/monad.metta` | how a context (a world, a board, a table row) is threaded |
| `core/evaluator.metta` | running a program |
| `core/operators.metta` | the operators themselves |
| `core/types.metta` | the questions the builder asks instead of naming operators |
| `knobs/knob.metta` | what a knob is |
| `knobs/perms.metta` | what candidates get offered at a boolean node |
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

**Conditions can grow structure, not just flip.** The candidates offered at a
boolean node include *pairs* joined by the opposite connective, so an `AND` can
acquire an `OR` inside it. One build gives one full alternation; feeding an
evolved program back in as the next starting point gives another.

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

- **Only conjunctions of literals and pairs.** A three-level formula like
  `(AND (OR ...) (OR (NOT ...) (AND ...)))` needs a second generation.
- **Primitives take no parameters.** A perception like "is this cell an F?"
  that takes an argument would be admitted to the vocabulary and then called
  with nothing, failing silently. Filling parameter slots needs a vocabulary of
  *values*, which is a separate piece of work.
- **Slot filling offers primitives only.** The machinery to also offer built
  composites is present in `core/types.metta` and works, but is deliberately
  not wired in.
- **No reduction, no complexity penalty, no population.** The search is one
  hill climb from one starting point.
