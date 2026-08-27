;; ============================================================================
;; tests/t-contin.metta -- tunable numbers, with no domain in sight.
;;
;; Two things are checked here and nothing else: the WALK that turns a string of
;; trits into a number, and the GUARD that decides which numbers are allowed to
;; have a walk attached. Both are domain-independent, so this suite loads
;; prototypes/m1/all and stops -- which is also what keeps the four existing
;; suites at exactly the counts they had before tunable numbers existed.
;;
;; Every expected value below was computed BY HAND from classic MOSES's
;; contin_stepper (field_set.h), not read off a run. That is deliberate: the
;; two-phase step size is easy to implement plausibly and wrongly, and a wrong
;; `expansion` factor in the bisection phase is invisible to a smoke test while
;; halving the reachable range.
;; ============================================================================

;; ---------------------------------------------------------------------------
;; THE WALK.  0 = Stop, 1 = Left, 2 = Right.
;;
;; Start at `mean`. While every step so far has gone the SAME way, move by
;; `step` and multiply `step` by `expansion` -- the expansion phase, which is
;; how few trits reach far from the mean. The first time the direction reverses,
;; undo the last expansion (`step / (expansion * 2)`) and halve from then on --
;; the bisection phase, which is how the walk lands precisely.
;;
;; Mean 0, step 1, expansion 2 throughout this block.
;; ---------------------------------------------------------------------------

;; No trits at all, and a walk that stops immediately, are both the mean. This
;; is what makes an all-Stop instance decode back to the program that was built.
!(test (continWalk ()    0 1 2) 0)
!(test (continWalk (0)   0 1 2) 0)

;; --- the expansion phase ----------------------------------------------------
;; Pure Right: 1, 3, 7, 15, 31. The step doubles every move, so five trits
;; already reach 31 -- an evenly spaced grid of five values could not.
!(test (continWalk (2)         0 1 2) 1)
!(test (continWalk (2 2)       0 1 2) 3)
!(test (continWalk (2 2 2)     0 1 2) 7)
!(test (continWalk (2 2 2 2)   0 1 2) 15)
!(test (continWalk (2 2 2 2 2) 0 1 2) 31)

;; Pure Left is the mirror image. Note that a Left does NOT clear all_left --
;; only all_right -- so a second Left is still in the expansion phase.
!(test (continWalk (1)     0 1 2) -1)
!(test (continWalk (1 1)   0 1 2) -3)
!(test (continWalk (1 1 1) 0 1 2) -7)

;; --- crossing into the bisection phase --------------------------------------
;; Right then Left is the case worth doing by hand, because it is the crossing:
;;   R  all_right, so v = 0 + 1 = 1, step = 1 * 2 = 2, all_left := False
;;   L  not all_left, and all_right still holds, so undo the expansion --
;;      step = 2 / (2 * 2) = 0.5 -- then v = 1 - 0.5 = 0.5, step = 0.25
;; Get the expansion factor into the wrong phase and this reads 0 or -1.
!(test (continWalk (2 1) 0 1 2) 0.5)
!(test (continWalk (1 2) 0 1 2) -0.5)

;; ...and once in the bisection phase it stays there, halving each time.
!(test (continWalk (2 1 2) 0 1 2) 0.75)
!(test (continWalk (2 1 1) 0 1 2) 0.25)
!(test (continWalk (2 2 1) 0 1 2) 2)

;; --- the first Stop ends the walk -------------------------------------------
;; classic breaks out of its loop; a fold cannot break, so a distinct shape
;; absorbs every later trit. Every one of these must equal the walk with the
;; trailing trits removed -- not something else that happens to be close.
!(test (continWalk (0 2)   0 1 2) 0)
!(test (continWalk (0 2 2) 0 1 2) 0)
!(test (continWalk (2 0 2) 0 1 2) 1)
!(test (continWalk (2 0 1) 0 1 2) 1)
!(test (continWalk (2 2 0) 0 1 2) 3)

;; --- a mean and a step that are not 0 and 1 ---------------------------------
;; The shape a real domain uses: a threshold starting at 16 with room to move
;; by 8. Nothing about the walk depends on the mean being zero.
!(test (continWalk (0 0 0) 16 8 2) 16)
!(test (continWalk (2 0 0) 16 8 2) 24)
!(test (continWalk (1 0 0) 16 8 2) 8)
!(test (continWalk (1 1 0) 16 8 2) -8)
!(test (continWalk (1 2 0) 16 8 2) 12)

;; ---------------------------------------------------------------------------
;; THE KNOB.  One tunable number occupies `depth` CONSECUTIVE slots of the
;; instance vector, each an ordinary 3-setting knob -- which is why
;; search/hillclimb.metta needs no change at all: it just sees more knobs.
;;
;; Each test resets the counter first, so the indices below are absolute rather
;; than "whatever the previous check left behind".
;; ---------------------------------------------------------------------------

(= (aKnobOn $mean) (let $ignored (resetIdx) (continKnobFor (leafOf $mean))))

;; The MEAN COMES FROM THE TREE -- whatever number sits in the slot when the
;; representation is built. classic does the same: contin_knob's spec takes
;; combo::get_contin(*tgt). Nothing declares a mean anywhere.
!(test (aKnobOn 5)  (quote (mkKnob (mkTree (mkNode 5) ())  (mkCTK 5 8 2 3) 0)))
!(test (aKnobOn 16) (quote (mkKnob (mkTree (mkNode 16) ()) (mkCTK 16 8 2 3) 0)))

;; It claims `depth` consecutive slots and answers the FIRST. Most knobs want
;; one; this is the only kind that wants more, and nextIdxN is the one counter
;; generalised rather than a second counter beside it -- two counters collide
;; silently and decode reads someone else's setting.
!(test (let $ignored (resetIdx) (nextIdxN 3)) 0)
!(test (let* (($i (resetIdx)) ($a (nextIdxN 3))) (nextIdxN 1)) 3)
!(test (let* (($i (resetIdx)) ($a (nextIdx)) ($b (nextIdxN 3))) (nextIdx)) 4)

;; --- what it contributes to the vector --------------------------------------
;; `depth` specs, not one: a 3-setting trit each, EVERY ONE defaulting to 0
;; (Stop). That default is what makes the exemplar instance decode back to the
;; number the representation was built with.
!(test (knobSpecs   (aKnobOn 5)) ((0 3 0) (1 3 0) (2 3 0)))
!(test (knobKindIdx (aKnobOn 5)) ((0 CTK) (1 CTK) (2 CTK)))
!(test (knobCountOf (aKnobOn 5)) 3)
!(test (exemplarInst (aKnobOn 5)) (0 0 0))
!(test (knobMultiplicities (aKnobOn 5)) (3 3 3))

;; --- decoding ---------------------------------------------------------------
;; It is the one knob that can never answer () -- there is no absent setting,
;; because all-Stop already means "the number it was built with" rather than
;; "no number". classic says the same thing as
;; contin_knob::in_exemplar() { return true; }.
!(test (getCandidateRec (0 0 0) (aKnobOn 5)) (quote (mkTree (mkNode 5) ())))
!(test (getCandidateRec (2 0 0) (aKnobOn 5)) (quote (mkTree (mkNode 13) ())))
!(test (getCandidateRec (1 0 0) (aKnobOn 5)) (quote (mkTree (mkNode -3) ())))
!(test (getCandidateRec (2 1 0) (aKnobOn 5)) (quote (mkTree (mkNode 9) ())))

;; the round trip that matters: the exemplar instance reproduces the number the
;; representation was built with
!(test (getCandidate (aKnobOn 16) (exemplarInst (aKnobOn 16)))
       (quote (mkTree (mkNode 16) ())))

;; and a decoded number renders as a bare number, not as (16 ()) -- preOrderExp
;; already treats a ground literal as a leaf, so nothing downstream changes
!(test (preOrderExp (getCandidate (aKnobOn 16) (2 0 0))) 24)

;; ---------------------------------------------------------------------------
;; THE GUARD.  Which numbers are allowed a walk, and which are not.
;;
;; classic never has to ask. There, `is_contin` is a VERTEX-TYPE test and an
;; argument $1 is `is_argument` -- a different vertex type -- so build_contin's
;; flat scan structurally cannot see a column index as a number. Here the 0 in
;; (tCol (0)) is a bare number leaf, indistinguishable from a threshold by
;; inspection, so the distinction has to be put back:
;;
;;     A NUMBER IS TUNABLE EXACTLY WHEN IT IS REACHED THROUGH A SLOT WHOSE
;;     DECLARED TYPE IS Number. A SLOT DECLARED Params IS NEVER ENTERED.
;;
;; The fixtures below are the two shapes that matter, and nothing else: a
;; parametrised leaf whose parameter happens to be a number (colAt, exactly),
;; and an operator with genuine Number slots.
;; ---------------------------------------------------------------------------

(: tCol (-> Params $ctx Number))
(= (paramsOf tCol) ((0) (1)))

(= (aColumn $index) (mkTree (mkNode tCol) ((leafOf $index))))
(= (aCompare $left $right) (mkTree (mkNode numGt) ($left $right)))

(= (built $tree) (let $ignored (resetIdx) (buildInner $tree)))

;; --- the parent side: never look inside a Params-taking function ------------
;; tCol's parameter slot is declared Params, so the walk stops at tCol and its
;; index is not visited at all. This is the check to watch: switch the guard off
;; and (tCol (0)) comes back with a knob on its column index, which decodes to
;; a different column -- a perfectly well-formed program reading the wrong data.
!(test (built (aColumn 0)) (quote (mkTree (mkNode tCol) ((mkTree (mkNode 0) ())))))
!(test (knobCountOf (built (aColumn 0))) 0)
!(test (knobCountOf (built (aColumn 1))) 0)

;; --- the child side: a Number slot IS entered -------------------------------
!(test (built (leafOf 5)) (quote (mkTree (mkNode 5) ())))
!(test (knobCountOf (buildNumberSlot (leafOf 5))) 3)

;; --- both at once, which is the whole point ---------------------------------
;; One comparison holding a column index and a threshold. The threshold is
;; tuned; the column index is not; and the knob count says so -- 3, not 6.
!(test (built (aCompare (aColumn 0) (leafOf 5)))
       (quote (mkTree (mkNode numGt)
                      ((mkTree (mkNode tCol) ((mkTree (mkNode 0) ())))
                       (mkKnob (mkTree (mkNode 5) ()) (mkCTK 5 8 2 3) 0)))))
!(test (knobCountOf (built (aCompare (aColumn 0) (leafOf 5)))) 3)

;; a comparison of two columns has nothing to tune at all
!(test (knobCountOf (built (aCompare (aColumn 0) (aColumn 1)))) 0)

;; ...and two written numbers are two knobs, six slots, non-overlapping
!(test (knobCountOf (built (aCompare (leafOf 5) (leafOf 9)))) 6)
!(test (knobSpecs   (built (aCompare (leafOf 5) (leafOf 9))))
       ((0 3 0) (1 3 0) (2 3 0) (3 3 0) (4 3 0) (5 3 0)))

;; and each tunes independently -- the second number's trits start at slot 3
!(test (preOrderExp (getCandidate (built (aCompare (leafOf 5) (leafOf 9)))
                                  (2 0 0  0 0 0)))
       (quote (numGt (13 9))))
!(test (preOrderExp (getCandidate (built (aCompare (leafOf 5) (leafOf 9)))
                                  (0 0 0  1 0 0)))
       (quote (numGt (5 1))))

;; --- a ground literal is not the same thing as a number ---------------------
;; isGroundLiteral admits Bool and String as well as Number
;; (core/evaluator.metta:42). That is right for RENDERING a leaf -- True and
;; "8" print bare, same as 5 -- and wrong for deciding what may be tuned: a walk
;; starting from True adds a step size to a boolean. Only a Number gets a knob;
;; every other literal is left exactly as the author wrote it.
!(test (isNumberLiteral 5)     True)
!(test (isNumberLiteral -3)    True)
!(test (isNumberLiteral 0.5)   True)
!(test (isNumberLiteral True)  False)
!(test (isNumberLiteral False) False)
!(test (isNumberLiteral "8")   False)
;; and a function that RETURNS a Number is not a number -- its type is an arrow,
;; not Number, which is the reading that matters if this is ever rewritten
!(test (isNumberLiteral tCol)  False)

;; so a Bool or a String in a Number slot comes back untouched, with no knob
!(test (built (aCompare (leafOf True) (leafOf "8")))
       (quote (mkTree (mkNode numGt)
                      ((mkTree (mkNode True) ()) (mkTree (mkNode "8") ())))))
!(test (knobCountOf (built (aCompare (leafOf True) (leafOf "8")))) 0)

;; ...the same shape holding real numbers is six slots...
!(test (knobCountOf (built (aCompare (leafOf 1) (leafOf 2)))) 6)
;; ...and a mixture knobs the number and only the number
!(test (knobCountOf (built (aCompare (leafOf True) (leafOf 2)))) 3)

;; --- the slot dispatch itself -----------------------------------------------
;; buildSlot is the only type dispatch in the builder, and Params is the branch
;; that hands the child straight back.
!(test (buildSlot Params (leafOf 7)) (quote (mkTree (mkNode 7) ())))
!(test (knobCountOf (buildSlot Params (leafOf 7))) 0)
!(test (knobCountOf (let $i (resetIdx) (buildSlot Number (leafOf 7)))) 3)

;; ---------------------------------------------------------------------------
;; A NUMBER INSIDE A CONDITION, which is where the whole thing has to work.
;;
;; buildLogical keys on isJunctor -- literally == AND / == OR -- so a (numGt ...)
;; child is wrapped in the opposite junctor and treated as an opaque literal.
;; Nothing used to descend into it, so its threshold got no knob, ever. classic
;; hit exactly this and answered it in build_logical: for a predicate child it
;; calls add_logical_knobs and THEN goes inside for the contin knobs. The order
;; is not incidental -- assignKnobs matches candidates against the children a
;; node already has, and a knob-bearing child matches nothing, so knobbing first
;; would drop the exemplar's own condition and re-offer it.
;;
;; This block also pins isFillable. This suite loads no domain, so there are no
;; Bool literals: `vocabsOf OR` is (() ()) and its fillCount is 0, while numGt
;; is fillable from the two tCol columns and lifts permLimit above zero. That
;; mixture is what reaches (% k 0) inside fillAt -- and `%` compiles to a direct
;; goal outside reduce's catch, so the whole run DIES rather than failing a
;; check. One filter in permittedOpsFor is what makes numeric domains possible
;; at all.
;; ---------------------------------------------------------------------------

(= (aCondition) (mkTree (mkNode AND) ((aCompare (aColumn 0) (leafOf 5)))))
(= (aCondRep)   (buildKnobs (aCondition)))
(= (ctkCount $rep) (size-atom (filter-atom (knobKindIdx $rep) $pair (== (lastOf $pair) CTK))))

;; an operator none of whose slots can be filled is not a candidate head at all
!(test (permittedOpsFor AND Bool) (quote (numGt)))
!(test (permittedOpsFor OR  Bool) (quote (numGt)))
!(test (isFillable numGt) True)
!(test (isFillable OR)    False)

;; the comparison is reachable as a candidate, from the column vocabulary
!(test (map-atom (sampleLogicalPerms AND) $p (preOrderExp $p))
       (quote ((numGt ((tCol (0)) (tCol (1))))
               (numGt ((tCol (1)) (tCol (0)))))))

;; --- the threshold gets its walk, the column index does not -----------------
;; Nine knobs: two placeholders at the AND, two at the OR the comparison is
;; wrapped in, three trits for the threshold, and two on the grow-into node.
!(test (knobCountOf (aCondRep)) 9)
!(test (ctkCount    (aCondRep)) 3)
!(test (kindAt (aCondRep) 4) CTK)
!(test (kindAt (aCondRep) 5) CTK)
!(test (kindAt (aCondRep) 6) CTK)

;; the exemplar instance reproduces the condition that was written, threshold
;; and column both
!(test (preOrderExp (getCandidate (aCondRep) (exemplarInst (aCondRep))))
       (quote (AND ((OR ((numGt ((tCol (0)) 5))))))))

;; ...and turning the first trit moves the THRESHOLD, leaving the column and
;; every piece of structure exactly where they were
!(test (preOrderExp (getCandidate (aCondRep) (changeAt (exemplarInst (aCondRep)) 4 2)))
       (quote (AND ((OR ((numGt ((tCol (0)) 13))))))))
!(test (preOrderExp (getCandidate (aCondRep) (changeAt (exemplarInst (aCondRep)) 4 1)))
       (quote (AND ((OR ((numGt ((tCol (0)) -3))))))))
