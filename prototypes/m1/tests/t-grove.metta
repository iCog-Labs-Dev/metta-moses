;; ============================================================================
;; tests/t-grove.metta -- actions and numbers in one program, end to end.
;;
;; tests/t-contin.metta already pins the walk and the guard against fixtures.
;; This suite is the other half: a real world, a real exemplar, and the question
;; that matters -- does a number the exemplar got wrong actually move, without
;; anything else moving with it?
;; ============================================================================

(= (holdingOutFor $ripeness)
   (quote (and_seq ((action_bool_if ((numGt ((groveRipeHere ()) $ripeness))
                                     (grovePick ())
                                     (groveWalkBy (1))))))))

(= (ctkCount $rep)
   (size-atom (filter-atom (knobKindIdx $rep) $pair (== (lastOf $pair) CTK))))

;; ---------------------------------------------------------------------------
;; THE WORLD.  Nothing here involves knobs -- if these are wrong, every score
;; below is measuring the wrong thing.
;; ---------------------------------------------------------------------------

;; picking a tree above the cutoff gains one; the tree is emptied either way, so
;; the same tree cannot be picked twice for profit
!(test (evalProgram (quote (grovePick ())) (mkG (2 12) 1 0 0 5))
       (mkRes True (mkG (2 0) 1 1 0 4)))
;; ...and picking one below the cutoff spoils it
!(test (evalProgram (quote (grovePick ())) (mkG (2 12) 0 0 0 5))
       (mkRes True (mkG (0 12) 0 0 1 4)))
;; exactly at the cutoff is NOT ripe enough -- the condition is strictly greater
!(test (evalProgram (quote (grovePick ())) (mkG (8) 0 0 0 5))
       (mkRes True (mkG (0) 0 0 1 4)))

;; an action reports success while there is fuel, whether or not the fruit was
;; any good -- otherwise a program could read ripeness without looking
!(test (resValOf (evalProgram (quote (grovePick ())) (mkG (2) 0 0 0 5))) True)
!(test (resValOf (evalProgram (quote (grovePick ())) (mkG (2) 0 0 0 0))) False)

;; walking is an operator with a NUMBER slot, so it reaches the world through
;; the ambient context rather than a $ctx argument -- and still threads it
!(test (evalProgram (quote (groveWalkBy (1))) (mkG (2 5 12) 0 0 0 5))
       (mkRes True (mkG (2 5 12) 1 0 0 4)))
!(test (evalProgram (quote (groveWalkBy (2))) (mkG (2 5 12) 0 0 0 5))
       (mkRes True (mkG (2 5 12) 2 0 0 4)))
;; and it wraps round the end of the row
!(test (evalProgram (quote (groveWalkBy (2))) (mkG (2 5 12) 2 0 0 5))
       (mkRes True (mkG (2 5 12) 1 0 0 4)))

;; a tuned stride arrives from a contin walk, so it can be fractional or
;; negative; rounding lives in the domain, as it does in classic
!(test (groveStepsOf 0.5)  1)
!(test (groveStepsOf 2.5)  2)
!(test (groveStepsOf 3)    3)
!(test (groveStepsOf -7)   1)

;; seeing costs nothing and changes nothing
!(test (evalProgram (quote (groveRipeHere ()))  (mkG (2 5 12) 1 0 0 5))
       (mkRes 5 (mkG (2 5 12) 1 0 0 5)))
!(test (evalProgram (quote (groveRipeAhead ())) (mkG (2 5 12) 1 0 0 5))
       (mkRes 12 (mkG (2 5 12) 1 0 0 5)))
!(test (evalProgram (quote (groveRipeAhead ())) (mkG (2 5 12) 2 0 0 5))
       (mkRes 2 (mkG (2 5 12) 2 0 0 5)))

;; ---------------------------------------------------------------------------
;; WHAT THE NUMBER IS WORTH.  The same program at three thresholds, scored over
;; both groves. This is the whole problem in three lines: the structure never
;; changes, and the score is decided entirely by a number.
;; ---------------------------------------------------------------------------

;; hold out for nothing and it strips both groves bare -- four spoiled, two
;; picked, per pair of groves
!(test (groveScoreExp (holdingOutFor 0)) -4)
;; and that IS the domain's exemplar -- the tree compiles to the same program
!(test (preOrderExp (groveExemplar)) (holdingOutFor 0))

;; hold out for the cutoff and it takes exactly the fruit worth taking
!(test (groveScoreExp (holdingOutFor 8)) 4)
!(test (groveScoreExp (holdingOutFor 8)) (groveBestScore))

;; hold out too long and it picks nothing at all -- no gain, but no waste
!(test (groveScoreExp (holdingOutFor 24)) 0)

;; ---------------------------------------------------------------------------
;; THE REPRESENTATION.  Six trit slots, because the exemplar wrote two numbers.
;; ---------------------------------------------------------------------------

;; two tunable numbers, three consecutive slots each
!(test (ctkCount (groveRep)) 6)

;; The exemplar instance reproduces the program that was written -- threshold,
;; stride and actions all intact. The condition comes back inside the AND-over-OR
;; that logicalCanonize wraps a lone literal in, which is what every domain's
;; exemplar decodes to (tests/t-decode.metta:13 shows the same shape around
;; m1FoodHere). (AND ((OR (x)))) is x, so this is the same program.
!(test (preOrderExp (getCandidate (groveRep) (exemplarInst (groveRep))))
       (quote (and_seq ((action_bool_if ((AND ((OR ((numGt ((groveRipeHere ()) 0))))))
                                         (grovePick ())
                                         (groveWalkBy (1))))))))

;; ...and "the same program" is not a claim about shape -- it scores identically
;; to the exemplar written out by hand, wrapping and all
!(test (groveScore (groveRep) (exemplarInst (groveRep))) (groveScoreExp (holdingOutFor 0)))
!(test (groveScore (groveRep) (exemplarInst (groveRep))) -4)

;; ---------------------------------------------------------------------------
;; THE SEARCH.  One number has to move and one has to stay.
;; ---------------------------------------------------------------------------

;; hillClimbing takes the PROGRAM scorer, not the (rep inst) one -- passing
;; groveScore here is an arity mismatch, which in this runtime fails silently
;; and makes the check vanish rather than fail. That is why the tick count is
;; compared against the written count and not merely scanned for ❌.
(= (bestPair) (hillClimbing groveScoreExp (groveRep)))

;; the number moves, and it moves all the way
!(test (lastOf (bestPair)) 4)
!(test (lastOf (bestPair)) (groveBestScore))

;; and it got there by changing the THRESHOLD and nothing else: the found
;; program still picks, still walks by one, and still has the structure the
;; exemplar had. Only the number is different.
!(test (preOrderExp (getCandidate (groveRep) (car-atom (bestPair))))
       (quote (and_seq ((action_bool_if ((AND ((OR ((numGt ((groveRipeHere ()) 8))))))
                                         (grovePick ())
                                         (groveWalkBy (1))))))))
