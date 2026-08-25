# Tunable numbers in mixed programs — a contin knob for `prototypes/m1`

**Status: BUILT AND VERIFIED, uncommitted.** Two new suites pass at their written
counts, and all four existing suites are unchanged:

| suite | pass | fail | written |
|---|---|---|---|
| tape (`run`) | 147 | 0 | 147 |
| orchard | 66 | 0 | 66 |
| berries | 29 | 1 | 47 |
| alarm | 39 | 0 | 39 |
| **thermostat** | **48** | **0** | **48** |
| **grove** (mixed) | **54** | **0** | **54** |

Berries' single failure is pre-existing and unrelated — the deliberately emptied
`berryExemplar` committed at `1e4a96e8`. Verified separately against a restored
exemplar: **47/47**. Zero `partial` / `Error` / `%Undefined%` across all six
suites, four demos and both walkthroughs.

> **This document is a design note written before the work, with corrections
> bolted on. Where it disagrees with the code, the code is right.** Two things
> in particular landed after it was written and are not described below: a
> switched-off candidate (`mkNullVex`) is now treated as a DISABLED knob rather
> than the absence of one, so knobs inside it own their slots; and `mkASK` lost
> its `perms` field, making it structurally identical to `mkLSK`. See
> `knobs/builder.metta` and `knobs/decode.metta`.

**Three things came out differently from this design.** They are corrected in
place below, but named here so the diff is not a surprise:

1. **A new knob kind WAS needed** — `mkCTK`, in `knobs/knob.metta` with clauses
   in `getCandidateRec`, `knobSpecs` and `knobKindIdx`. (An earlier draft of
   this note claimed the opposite, that `mkASK` was reused. That was wrong;
   check `knobs/decode.metta` rather than this line.) What *is* true is that the
   ASK decode had to start recursing into its controlled subtree, because a
   knob nested inside a candidate would otherwise claim instance slots decode
   never reads — a well-formed program silently not the one the vector asked
   for.
2. **`isFillable` turned out to be mandatory, not optional.** `numGt` is declared
   in `core/`, so every domain sees it in `opsOfType Bool`. Any domain without
   numeric primitives then reaches `fillAt`'s `(% k 0)` and the run **dies** —
   `%` is a direct goal outside `reduce`'s catch. One guard in `permittedOpsFor`
   is what makes the whole integration possible.
3. **Two tests changed meaning, with approval.** `t-types.metta:42-43` pinned the
   declared Bool vocabulary as `(AND OR NOT)`; it is now `(AND OR NOT numGt)`.
   Nothing else moved, because `permittedOpsFor` filters `numGt` back out of every
   domain that has no numbers.

Also learned, and worth knowing for every future run: **PeTTa's `test` calls
`halt(1)` on mismatch** (`metta.pl:200`). So a short tick count *with* a ❌ means
the run stopped there; a short count with *no* ❌ means checks vanished silently.
Two different diagnoses that had previously been conflated.

## What this is for

`prototypes/m1` evolves boolean-condition programs and action programs. Both
search by *swapping subtrees*: an LSK picks among candidate conditions, an ASK
keeps or drops an action. Neither can tune a **number**.

The goal here is narrow and deliberately not a port of classic MOSES's
continuous machinery. We want a number the search can tune, in the three places
a number actually earns its keep inside the programs m1 already builds:

- **a threshold in a condition** — `(numGt ((m1DistToFood ()) (m1Threshold (3))))`
  inside an `action_bool_if`, so a creature learns a distance policy;
- **a magnitude in an action** — `(m1StepN (2))`, so it learns *how far* to move;
- **a threshold on a table column** — `(numGt ((colAt 0) (m1Threshold (5))))`,
  the classic decision-threshold case in a purely boolean-rooted domain.

Explicitly **out of scope**: classic's `contin_canonize`, its
`c1 + (c2 * p1) / p2` canonical form, its planted `*(0 $i)` linear combinations,
and the ~43 reduction rules those require. That is where classic's real power
lives and it is inseparable from contin reduct, which the repo's own roadmap
already marks as *"the largest single item"* and research-grade.

## The division of labour, which m1 already enforces

**Representation building may create contin knobs. Search may only tune them.**

This is classic's rule (`build_knobs` runs once per deme against an immutable
`field_set`; the optimizer only sets values), and m1 already gets it for free:
`buildKnobs` returns a representation, `knobSpecs`/`knobMultiplicities` are
derived from it once, and `hillClimbing` varies settings inside a fixed-length
instance vector. There is no mechanism by which search could add a knob.

Worth being precise about one thing, because it is easy to misread: **candidate
sampling is representation building.** `samplePerms` → `sampleCandidates` →
`candidateAt` all run inside `buildKnobs`. So the builder placing a threshold
into a numeric slot is *not* the search inventing one.

Consequence with no fix here: m1 has no deme loop, so placement happens once, at
the start, against the vocabulary available then. A threshold appearing around an
*evolved* program requires feeding the winner back as the next exemplar and
rebuilding — a path `knobs/knob.metta:49-54` already says is deliberate.

## The core idea: a tunable number is a primitive's parameter

In m1 every primitive is called `(op (params))`, and `colAt`'s column index
already lives in exactly that parameter slot. So a tunable constant needs no new
kind of tree node — it is a primitive whose parameter is *continuous* rather than
*enumerated*:

```metta
(: m1Threshold (-> Params $ctx Number))
(= (m1Threshold ($n) $world) (mkRes $n $world))

(= (paramsOf colAt)       (map-atom (rangeTo (inputCount)) $i ($i)))  ;; today
(= (continOf m1Threshold) (mkContin 0 1.0 2.0 3))     ;; mean step expansion depth
```

Two answers to one question — *what goes in this primitive's parameter slot?* —
and a primitive picks one. `paramsOf` yields N discrete leaves; `continOf` yields
one leaf plus a contin knob on it.

This framing buys three things. It avoids the trap in classic's flat
"knob every numeric constant" scan, which would happily tune `colAt`'s column
index as though it were a real number. It makes `m1Threshold` a declared
`Number`-returning primitive, so `primsOfType Number` finds it and it is a legal
filling for any numeric slot — the builder can *place* thresholds, not just tune
written ones. And the parameter slot already carries numbers through decode:
`preOrderExp` renders a numeric-symboled leaf as a bare number
(`knobs/decode.metta:69`), so `(m1Threshold (4.5))` needs no special handling.

## The knob

One tunable number occupies **`depth` consecutive slots** of the instance
vector, each a 3-setting trit — `0 = Stop`, `1 = Left`, `2 = Right`. Because they
are ordinary 3-setting knobs, **`search/hillclimb.metta` needs no change at
all**; it just sees more knobs.

```metta
;; One tunable number. $index is the FIRST of its `depth` consecutive trits.
(mkCTK $mean $step $expansion $depth)
```

Index allocation generalises the existing counter rather than adding a second
one:

```metta
(= (nextIdxN $count)
   (let* (($first    (get-state &knobCount))
          ($ignored  (change-state! &knobCount (+ $first $count))))
     $first))

(= (nextIdx) (nextIdxN 1))          ;; knob.metta:31-36, now one line
```

```metta
;; A CTK's subtree is a number, so unlike LSK/ASK there is nothing to recurse
;; into -- the trit specs ARE the whole contribution.
(= (knobSpecs (mkKnob $leaf (mkCTK $mean $step $expansion $depth) $index))
   (map-atom (rangeTo $depth) $i ((+ $index $i) 3 0)))

(= (knobKindIdx (mkKnob $leaf (mkCTK $mean $step $expansion $depth) $index))
   (map-atom (rangeTo $depth) $i ((+ $index $i) CTK)))
```

Every trit defaults to `0` (`Stop`), which decodes to the mean — so **an all-zero
instance reproduces exactly the program that was built.** That keeps the
`exemplarInst` round-trip pin (`tests/t-alarm.metta:112-115`) meaningful, which
is the check that catches decode bugs.

### The mean, in one rule

**The mean is whatever number sits in the parameter slot when `buildKnobs`
finishes.** If the author wrote `(m1Threshold (5))`, it is 5. If the builder
placed the candidate, it is the declared default. The declaration says how far
and how finely to search; the tree says where to start.

```metta
(= (wrapContinKnob $leaf (mkContin $defaultMean $step $expansion $depth))
   (let* (($sym   (nodeSymOf $leaf))
          ($mean  (if (isGroundLiteral $sym) $sym $defaultMean))
          ($first (nextIdxN $depth)))
     (mkKnob $leaf (mkCTK $mean $step $expansion $depth) $first)))
```

## The stepper

Copied deliberately from classic's `contin_stepper` (`field_set.h`), because the
two-phase behaviour is subtle and reinventing it gets the reach wrong:

- **Expansion phase** — while every move so far went the *same* direction, move
  by `step`, then `step *= expansion`. This is how few trits reach far from the
  mean.
- **Bisection phase** — on the *first* direction change, `step /= (expansion*2)`
  (undoing the last expansion), and every later move does `step /= 2`.
- **The first `Stop` ends the walk.** Later trits are dead.

```metta
(= (continLeft $expansion (mkWalk $value $step $allLeft $allRight $stopped))
   (if $allLeft
       (mkWalk (- $value $step) (* $step $expansion) True False False)
       (let $adjusted (if $allRight (/ $step (* $expansion 2)) $step)
         (mkWalk (- $value $adjusted) (/ $adjusted 2) False False False))))

(= (continRight $expansion (mkWalk $value $step $allLeft $allRight $stopped))
   (if $allRight
       (mkWalk (+ $value $step) (* $step $expansion) False True False)
       (let $adjusted (if $allLeft (/ $step (* $expansion 2)) $step)
         (mkWalk (+ $value $adjusted) (/ $adjusted 2) False False False))))

;; A Stop ends the walk. classic `break`s; a fold cannot, so the flag makes every
;; later trit a no-op -- the same thing. Clauses are disjoint on the flag.
(= (continMove $expansion (mkWalk $v $s $l $r True)  $trit) (mkWalk $v $s $l $r True))
(= (continMove $expansion (mkWalk $v $s $l $r False) 0)     (mkWalk $v $s $l $r True))
(= (continMove $expansion (mkWalk $v $s $l $r False) 1)
   (continLeft  $expansion (mkWalk $v $s $l $r False)))
(= (continMove $expansion (mkWalk $v $s $l $r False) 2)
   (continRight $expansion (mkWalk $v $s $l $r False)))

(= (continWalk $trits $mean $step $expansion)
   (let (mkWalk $value $s $l $r $stopped)
        (foldl-atom $trits (mkWalk $mean $step True True False) $walk $trit
                    (continMove $expansion $walk $trit))
     $value))
```

Sanity check, mean 0 / step 1 / expansion 2. `RRRRR` stays in the expansion
phase throughout — 1, 3, 7, 15, 31.

`RL` is the interesting one, because it crosses phases:

| move | branch taken | value | step | allLeft | allRight |
|---|---|---|---|---|---|
| start | — | 0 | 1 | True | True |
| `R` | `allRight` true → expansion | **1** | 1·2 = 2 | False | True |
| `L` | `allLeft` false → bisection, and `allRight` still true so undo the expansion: `adjusted = 2/(2·2) = 0.5` | **0.5** | 0.25 | False | False |

`RL → 0.5`, matching classic. **Recompute this table by hand for whatever
defaults get chosen, before trusting the implementation** — getting the
`expansion` factor into the wrong phase is invisible to a smoke test but halves
the reachable range.

### Hill-climbing behaviour: the right neighbourhood, with waste

Because the default is all-`Stop` and the first `Stop` kills the rest of the
string, **only trit 0 is live at the start.** Varying trit 1 changes nothing. So
`hillClimbingStep`, varying one knob at a time, extends the trit string left to
right — one trit per accepted move, each a finer bisection chosen by fitness.

**Checked against classic (`neighborhood_sampling.cc`), and the reachable set
matches.** Classic's `generate_contin_neighbor` anchors its move to `length`, the
live trit count, and offers exactly four: extend-Left, extend-Right,
truncate-the-last, flip-the-last. Its own header states them:

> if the contin is encoded with depth = 4, as `[L R S S]`, then the neighbors
> worth considering are `[L S S S]` (a decrease of significant bits),
> `[L L S S]` (same number of bits, but direction changed), `[L R L S]`, and
> `[L R R S]` (increase the number of significant bits).

Varying each trit through 3 settings reaches all four: the frontier trit gives
the two extensions, a live trit gives the flip and (because decode breaks at the
first `Stop`) the truncation. `information_theoretic_bits` prices a contin
variable at `log2(5)` — four neighbours plus itself — which agrees.

**What we do NOT get is classic's efficiency.** Classic skips dead trits
explicitly — *"Assume that this is the first stop encountered for this contin
field. Skip straight to the next contin field."* A naive per-trit scan instead
evaluates `(depth − length − 1) × 3` neighbours per step that are bit-identical
to the current program. At depth 3 with a short string that is ~6 wasted
evaluations per contin knob per step; it grows linearly in depth and shrinks as
the string lengthens. Acceptable to start with, and the fix is a later
optimisation in neighbourhood generation, not a correctness matter.

Two further notes from classic worth not rediscovering:

- **`contin_knob` has no `complexity_bound()`** — contin knobs contribute nothing
  to complexity penalties there. If m1 ever adds a complexity term, decide this
  deliberately rather than inheriting it.
- **Adaptive step size was tried and abandoned.** `representation.cc` carries a
  `#if 0` block that adjusted each contin's step to the precision it last used,
  with the verdict *"experiments seem to discredit this idea: it often slows down
  the search, and rarely/never seems to provide better answers."* Don't build it.

## Decoding

```metta
(= (getCandidateRec $inst (mkKnob $leaf (mkCTK $mean $step $expansion $depth) $index))
   (let $trits (map-atom (rangeTo $depth) $i (index-atom $inst (+ $index $i)))
     (leafOf (continWalk $trits $mean $step $expansion))))
```

`cleanTree` is safe without change: `cleanTreeNode` drops a node only when it is
an *empty junctor inside a boolean*, and a numeric leaf is neither.

## Where the builder hangs them

Two touch points, and only the second is a real change.

**(a) A primitive's parameter slot.** `addSimpleActionKnobs`
(`knobs/builder.metta:87-90`) already tests `isPrimitive (nodeSymOf $child)`, so
it already reaches primitive leaves. It needs to ask `continOf` before hanging
the usual keep/drop knob. This covers *magnitude in an action* nearly free.

**(b) Inside a non-junctor `Bool` node.** This is the blocker. `buildLogical`
(`knobs/builder.metta:53-56`) keys on `isJunctor`, which is literally
`== AND` / `== OR`, so a `(numGt …)` child is wrapped in an `OR` and treated as
an opaque literal — nothing ever descends to find the constant inside it.

Classic hit exactly this and solved it in `build_logical`:

```cpp
else if (is_predicate(sib)) {
    add_logical_knobs(subtree, _exemplar.insert_above(sib, flip), false);
    contin_canonize(cit);
    build_contin(pit.begin());     // <- contin knobs INSIDE the predicate
}
```

m1's version is better than classic's, because classic's `is_predicate` is
hardcoded to the literal symbol `greater_than_zero`, whereas m1 can derive the
test: **a declared operator whose return type is `Bool` and which is not a
junctor.** No symbol list.

The scan itself is classic's `build_contin` — a flat walk with no intelligence of
its own, because every placement decision was already made:

```metta
(= (continOf noSuchPrimitive) ())      ;; seed: defines the predicate. Same
                                       ;; reason as paramsOf (perms.metta:69) --
                                       ;; an undefined head comes back
                                       ;; unreduced, and collapse of THAT is a
                                       ;; one-element list, taking the wrong
                                       ;; branch silently.

(= (continSpecOf $op)
   (let $found (collapse (continOf $op)) (if (== $found ()) () (car-atom $found))))

(= (addContinKnobs $tree)
   (let* (($sym  (nodeSymOf $tree))
          ($spec (continSpecOf $sym)))
     (if (== $spec ())
         (mkTree (mkNode $sym) (map-atom (kidsOf $tree) $child (addContinKnobs $child)))
         (mkTree (mkNode $sym) ((wrapContinKnob (car-atom (kidsOf $tree)) $spec))))))
```

## Placement: how a threshold reaches a numeric slot

`instancesOf` (`knobs/perms.metta:71-76`) becomes a three-way answer to the same
question. A contin primitive contributes **exactly one** candidate, holding the
declared default mean:

```metta
(= (instancesOf $op)
   (let* (($params (collapse (paramsOf $op)))
          ($contin (collapse (continOf $op))))
     (if (not (== $params ()))
         (map-atom (car-atom $params) $slot
                   (mkTree (mkNode $op) (map-atom $slot $param (leafOf $param))))
         (if (not (== $contin ()))
             ((mkTree (mkNode $op) ((leafOf (meanOfSpec (car-atom $contin))))))
             ((leafOf $op))))))
```

So `fillersOfType Number` gains `(m1Threshold (0))`, the odometer can place it in
any numeric slot, and `addContinKnobs` then hangs the CTK on its `0`.

## Accepted costs

These are real and should be stated rather than discovered.

- **Dead trits produce duplicate neighbours.** Varying a trit after the first
  `Stop` yields an identical program and an identical score — a wasted
  evaluation. Classic avoids this in its enumerator by skipping to the next
  contin field, and prices a contin variable as one dimension in its sampler; a
  naive per-trit scan in m1 does neither. Depth 3 keeps it to roughly 6 wasted
  evaluations per contin knob per step early on, falling as the string grows.
  Fixable later inside neighbourhood generation without touching the encoding.
- **Decode-only is the right shape, and classic agrees.** m1 never needs to
  encode a real number into trits. Classic's `set_contin` exists but is
  unreachable from hill climbing, the neighbourhood sampler, or crossover — its
  only live caller is the particle-swarm optimizer. Everything on the search path
  reads raw trits and decodes.
- **`permCount = 6` gets tighter** (`knobs/perms.metta:42`). A threshold in the
  numeric vocabulary competes with column-vs-column comparisons for the same six
  sampled candidates; with three columns that is already exactly at budget, so
  adding a threshold *evicts* a comparison. Controlling this is a configuration
  activity in classic too — `_linear_contin` is its escape hatch.
- **No contin reduct**, so two programs computing the same number are not
  recognised as equal. Acceptable only because we are not planting linear
  combinations — the thing that made classic need 43 rules.
- **Action magnitudes round in the domain clause**, e.g. `round-math` inside
  `(= (m1StepN ($n) $world) …)`. Classic uses `contin_t` doubles throughout;
  keeping the rounding domain-side avoids an integer knob kind.
- **Numeric operands of a comparison are still not evolvable.** Per the
  `buildLogical` limitation, a `(numGt …)` candidate is opaque: the search can
  swap in a different pre-sampled comparison and tune its threshold, but cannot
  change *which column* it reads. That needs the type-generic slot work in
  `/home/yab/.claude/plans/calm-whistling-panda.md`, not this design.

## Risks specific to this runtime

- **`/` on integers.** `'/'(A,B,R) :- R is A / B` (`metta.pl:38`). Under SWI's
  default flags `1 / 2` is `0.5`, but if rationals are ever preferred the trit
  walk starts producing `1 rdiv 2` and every downstream comparison gets strange.
  **Probe this first** — it is one line and it invalidates the stepper if wrong.
- **`foldl-atom` with a compound accumulator.** A nested `foldl-atom` has bound
  incorrectly in this codebase before. `continWalk` is not nested, but the
  `mkWalk` accumulator should be pinned by a direct test before anything is built
  on it.
- **Clause disjointness of `continMove`.** Four clauses discriminating on a flag
  and a literal trit. This is the same shape as `getCandidateRec`'s five clauses,
  so it is idiomatic — but a duplicate or overlapping clause multiplies solutions
  silently, so assert a single solution.

## What the verification actually measured

Bound every run — an unbounded metta run can OOM the machine:
`( ulimit -v 8000000; timeout 600 sh /home/yab/PeTTaV1/run.sh <file> -s )`

**Runtime risks, cleared first.** `(/ 1 2)` = `0.5`, not a rational, so the
halving in the bisection phase is safe. The stepper reproduced all 22
hand-computed values on the first run, including `RRRRR → 31` (pure expansion)
and `(0 2) → 0` (a dead trit after `Stop`), single solution each.

**`domain/thermostat.metta` — a threshold on a numeric table.** Six temperature
readings, alarm above 16. The answer is in no row and no declaration; the
exemplar guesses 0. Nine knobs, three of them one number (`mean 0, step 8,
expansion 2, depth 3`).

```
exemplarInst  (1 0 1 0 0 0 0 0 0)   -> threshold 0, score -3
search        (1 0 1 0 2 2 1 0 0)   -> threshold 16, score 0
trajectory    (-3 -2 -1 0)
thresholds    0 -> 8 -> 24 -> 16
```

The last line is the interesting one and nothing asked for it: the search
**overshoots** through the expansion phase (8, then 24) and then **bisects back**
to 16. That is classic's two-phase stepper being driven purely by fitness, with
one-knob-at-a-time hill climbing and no knowledge that a number is involved.

**`domain/grove.metta` — the mixed case, which is the point.** An action root,
a boolean condition, numeric operands, and *two* contin knobs in different roles:
a threshold inside the condition and a magnitude on an action.

```
16 knobs:  6 ASK, 8 LSK, 2 CTK          all in one instance vector
exemplarInst (0 0 0 0 0 0 1 0 1 0 0 0 0 1 0 1)  -> threshold 0, stride 2, score -3
search       (0 0 0 0 0 0 1 0 1 0 2 0 0 1 1 1)  -> threshold 8, stride 1, score 4
trajectory   (-3 1 4)
```

Both numbers start wrong and both get fixed, in two moves, **changing no
structure at all** — every other knob stays where it was. The two contin knobs
reach the builder by two different routes (scanning inside a boolean candidate
versus scanning an action primitive's own parameter), which is what makes this an
integration test rather than a second copy of the thermostat one.

Worth noting against classic: the mirror of this program is something **classic
cannot do**. Its `build_contin` never calls `build_logical`, so a numeric-rooted
program there has its boolean structure frozen — only the coefficient in front of
an `impulse(...)` can vary.

**Still true, still a limitation.** A `(numGt …)` candidate remains opaque to
`buildLogical`, so the search can swap in a different pre-sampled comparison and
tune its threshold, but cannot change *which column* the comparison reads. And a
threshold sitting in a switched-off candidate is deliberately not knobbed — it
would claim an index `knobSpecs` never reports, leaving a silent gap in the
instance vector. Both need the type-generic slot work in
`/home/yab/.claude/plans/calm-whistling-panda.md`, not this design.
