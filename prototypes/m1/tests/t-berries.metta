;; ============================================================================
;; tests/t-berries.metta -- the world whose answer is not on the menu.
;;
;; Programs are written in the form the evaluator receives, and every expected
;; value that is a program is wrapped in `quote` -- unquoted it would be a CALL,
;; yield nothing, and the check would silently not run at all.
;; ============================================================================

(= (patch5 $cells) (mkPatch $cells 0 0 0 5))
(= (start) (exemplarInst (berryRep)))

;; --- what a pick is worth ---------------------------------------------------
!(test (berryWorth RC)  2)
!(test (berryWorth RS)  2)
!(test (berryWorth RW) -3)
!(test (berryWorth U)  -2)
!(test (berryWorth E)  -1)

;; picking a sound ripe berry: eaten goes up, the cell is emptied, one fuel
!(test (evalProgram (quote (berryPick ())) (patch5 (RC U)))
       (mkRes True (mkPatch (E U) 0 2 0 4)))
;; a wormy one costs, and is still taken off the bush
!(test (evalProgram (quote (berryPick ())) (patch5 (RW U)))
       (mkRes True (mkPatch (E U) 0 0 3 4)))
!(test (evalProgram (quote (berryPick ())) (patch5 (U RC)))
       (mkRes True (mkPatch (E RC) 0 0 2 4)))
;; picking at an emptied cell changes NOTHING but the fuel -- which is why a
;; program that does it stands still until the fuel runs out
!(test (evalProgram (quote (berryPick ())) (patch5 (E U)))
       (mkRes True (mkPatch (E U) 0 0 1 4)))

!(test (evalProgram (quote (berryWalk ())) (patch5 (RC U)))
       (mkRes True (mkPatch (RC U) 1 0 0 4)))
;; ...and the ring wraps
!(test (evalProgram (quote (berryWalk ())) (mkPatch (RC U) 1 0 0 5))
       (mkRes True (mkPatch (RC U) 0 0 0 4)))

;; out of fuel, an action fails and changes nothing
!(test (evalProgram (quote (berryPick ())) (mkPatch (RC U) 0 0 0 0))
       (mkRes False (mkPatch (RC U) 0 0 0 0)))

;; THE INVARIANT: an action reports success whatever it found, so success can
;; never be used as a perception.
!(test (resValOf (evalProgram (quote (berryPick ())) (patch5 (RC U)))) True)
!(test (resValOf (evalProgram (quote (berryPick ())) (patch5 (RW U)))) True)
!(test (resValOf (evalProgram (quote (berryPick ())) (patch5 (U  U)))) True)
!(test (resValOf (evalProgram (quote (berryPick ())) (patch5 (E  U)))) True)

;; --- what it can see --------------------------------------------------------
;; the truth table, and a perception hands the world back untouched
!(test (evalProgram (quote (berryWormy ())) (patch5 (RW U))) (mkRes True  (mkPatch (RW U) 0 0 0 5)))
!(test (evalProgram (quote (berryWormy ())) (patch5 (RC U))) (mkRes False (mkPatch (RC U) 0 0 0 5)))
!(test (resValOf (evalProgram (quote (berryRed ()))   (patch5 (RC U)))) True)
!(test (resValOf (evalProgram (quote (berryRed ()))   (patch5 (RW U)))) True)
!(test (resValOf (evalProgram (quote (berryRed ()))   (patch5 (RS U)))) False)
!(test (resValOf (evalProgram (quote (berrySweet ())) (patch5 (RS U)))) True)
!(test (resValOf (evalProgram (quote (berrySweet ())) (patch5 (RC U)))) False)
!(test (resValOf (evalProgram (quote (berrySweet ())) (patch5 (RW U)))) False)

;; --- the rings --------------------------------------------------------------
!(test (size-atom (berryRingA)) 8)
!(test (size-atom (berryRingB)) 8)
!(test (berryFuel) 14)
;; both hold the same berries in a different order, so no fixed rhythm carries
!(test (== (berryRingA) (berryRingB)) False)

;; --- the score tiers --------------------------------------------------------
;; doing nothing is 0; the naive program is WORSE than nothing
!(test (berryScoreExp (quote (and_seq ()))) 0)
!(test (berryScoreExp (preOrderExp (berryExemplar))) -4)
;; stopping the wormy ones helps but leaves the sweet ones on the bush
!(test (berryScoreExp (quote (and_seq ((action_bool_if
          ((AND ((berryRed ()) (NOT ((berryWormy ()))))) (berryPick ()) (berryWalk ())))))))
       8)
;; taking both ripeness cues helps but takes the wormy ones
!(test (berryScoreExp (quote (and_seq ((action_bool_if
          ((OR ((berryRed ()) (berrySweet ()))) (berryPick ()) (berryWalk ())))))))
       4)
;; only both together reach the ceiling: four sound berries per ring at 2 each
!(test (berryScoreExp (quote (and_seq ((action_bool_if
          ((AND ((OR ((berryRed ()) (berrySweet ()))) (NOT ((berryWormy ())))))
           (berryPick ()) (berryWalk ())))))))
       (berryBestScore))
!(test (berryBestScore) 16)

;; --- THE POINT OF THIS DOMAIN ----------------------------------------------
;; The disjunction the answer needs is NOT among the candidates offered at the
;; condition. If this ever starts passing as True, the domain has stopped
;; testing what it was built to test.
!(test (containsIn (sampleLogicalPerms AND)
                   (mkTree (mkNode OR) ((mkTree (mkNode berryRed) ())
                                        (mkTree (mkNode berrySweet) ()))))
       False)
;; ...while each of its two halves is offered on its own, and so is the
;; negation the answer also needs
!(test (containsIn (sampleLogicalPerms AND) (mkTree (mkNode berryRed) ()))   True)
!(test (containsIn (sampleLogicalPerms AND) (mkTree (mkNode berrySweet) ())) True)
!(test (containsIn (sampleLogicalPerms AND)
                   (mkTree (mkNode NOT) ((mkTree (mkNode berryWormy) ()))))
       True)
;; every OR-headed candidate leads with the first perception declared -- that
;; is the odometer, and it is why the pair we want never comes up
!(test (map-atom (filter-atom (sampleLogicalPerms AND) $c (== (nodeSymOf $c) OR))
                 $c (nodeSymOf (car-atom (kidsOf $c))))
       (quote (berryWormy berryWormy berryWormy)))

;; --- the representation -----------------------------------------------------
!(test (knobCountOf (berryRep)) 37)
!(test (preOrderExp (getCandidate (berryRep) (start)))
       (quote (and_seq ((action_bool_if ((AND ((OR ((berryRed ())))))
                                         (berryPick ()) (berryWalk ())))))))
!(test (berryScore (berryRep) (start)) -4)

;; --- the search has to work for it ------------------------------------------
(= (bestPair)  (hillClimbing berryScoreExp (berryRep)))
(= (bestInst)  (let ($i $s) (bestPair) $i))
(= (bestScore) (let ($i $s) (bestPair) $s))
(= (movesMade)
   (size-atom (filter-atom (rangeTo (knobCountOf (berryRep))) $k
                (!= (index-atom (bestInst) $k) (index-atom (start) $k)))))

;; no single move gets there: the best one knob can do is 8, half the answer
!(test (maxOf (map-atom (generateAllInNeighborhood (knobMultiplicities (berryRep)) (start))
                        $n (berryScore (berryRep) $n)))
       8)
;; but two do
!(test (bestScore) (berryBestScore))
!(test (bestScore) 16)
!(test (movesMade) 2)
;; and what it built is the disjunction it was never offered
!(test (preOrderExp (getCandidate (berryRep) (bestInst)))
       (quote (and_seq ((action_bool_if
                          ((AND ((NOT ((berryWormy ())))
                                 (OR ((berryRed ()) (berrySweet ())))))
                           (berryPick ()) (berryWalk ()))))))) 
