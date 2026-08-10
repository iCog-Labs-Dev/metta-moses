;; ============================================================================
;; tests/t-orchard.metta -- the orchard, and the claim that ONE test is never
;; enough.
;;
;; The claim is not "we tried it and the conjunction won". It is a case
;; analysis, and it is short enough to write out:
;;
;;   there are three kinds of cell, and picking is right at exactly one of them
;;   (FS). Each perception is true at two of the three -- fruitHere at FS and
;;   FX, freshHere at FS and E -- and so is each negation. No single test, and
;;   no single negated test, is true at FS and nowhere else. So every program
;;   whose condition is one test either picks the spoiled fruit or picks at
;;   empty cells; and picking at an empty cell leaves the cell empty and the
;;   creature where it was, so it does that for the rest of its fuel.
;;
;; Only (AND fruitHere freshHere) is true at FS alone. The tests below check the
;; facts that case analysis rests on, and then the scores it predicts.
;;
;; The upper bound is arithmetic: three fresh fruits at 2 each is 6 a ring, and
;; wasted never goes below 0, so 12 over the two episodes cannot be beaten.
;;
;; NOTE on `quote`: `test` EVALUATES its expected side, so a program written out
;; longhand there is a CALL -- it yields no answer and the check silently does
;; not run, printing neither pass nor fail. Count the ticks against the number
;; of `!(test` lines; do not just look for failures.
;; ============================================================================

;; --- the two rings ----------------------------------------------------------
;; The fresh fruit sits in the same three places in both, so both rings have the
;; same ceiling. The spoiled fruit does not: ring A puts it just after each
;; fresh one, ring B just before.
(= (orchCellsAt $cells $what)
   (filter-atom (rangeTo (size-atom $cells)) $i (== (index-atom $cells $i) $what)))

!(test (size-atom (orchRingA)) 9)
!(test (size-atom (orchRingB)) 9)
!(test (orchFreshCount (orchRingA)) 3)
!(test (orchFreshCount (orchRingB)) 3)
!(test (orchSpoiledCount (orchRingA)) 3)
!(test (orchSpoiledCount (orchRingB)) 3)
!(test (orchCellsAt (orchRingA) FS) (0 3 6))
!(test (orchCellsAt (orchRingB) FS) (0 3 6))
!(test (orchCellsAt (orchRingA) FX) (1 4 7))
!(test (orchCellsAt (orchRingB) FX) (2 5 8))
!(test (orchFuel) 14)
!(test (orchBestScore) 12)

;; --- what the actions do ----------------------------------------------------
;; Fresh fruit pays 2 and the cell is emptied; spoiled fruit costs 3 and the
;; cell is emptied; picking at nothing costs 1 and NOTHING CHANGES -- which is
;; why a program that picks at empty cells is stuck there until its fuel runs
;; out.
!(test (evalProgram (quote (orchPick ())) (mkOrchard (FS FX E) 0 0 0 5))
       (mkRes True (mkOrchard (E FX E) 0 2 0 4)))
!(test (evalProgram (quote (orchPick ())) (mkOrchard (FS FX E) 1 0 0 5))
       (mkRes True (mkOrchard (FS E E) 1 0 3 4)))
!(test (evalProgram (quote (orchPick ())) (mkOrchard (FS FX E) 2 0 0 5))
       (mkRes True (mkOrchard (FS FX E) 2 0 1 4)))
!(test (evalProgram (quote (orchWalk ())) (mkOrchard (FS FX E) 0 0 0 5))
       (mkRes True (mkOrchard (FS FX E) 1 0 0 4)))
!(test (evalProgram (quote (orchWalk ())) (mkOrchard (FS FX E) 2 0 0 5))
       (mkRes True (mkOrchard (FS FX E) 0 0 0 4)))

;; --- success says nothing about the cell -------------------------------------
;; An action reports the same thing whatever it found. If a wasted pick reported
;; failure, a program could tell FS from FX by watching whether its actions
;; succeeded -- seeing without looking -- and the case analysis above would stop
;; being about perceptions at all.
!(test (resValOf (evalProgram (quote (orchPick ())) (mkOrchard (FS FX E) 0 0 0 5))) True)
!(test (resValOf (evalProgram (quote (orchPick ())) (mkOrchard (FS FX E) 1 0 0 5))) True)
!(test (resValOf (evalProgram (quote (orchPick ())) (mkOrchard (FS FX E) 2 0 0 5))) True)
!(test (resValOf (evalProgram (quote (orchWalk ())) (mkOrchard (FS FX E) 2 0 0 5))) True)
!(test (resValOf (evalProgram (quote (orchPick ())) (mkOrchard (FS FX E) 0 0 0 0))) False)
!(test (resValOf (evalProgram (quote (orchWalk ())) (mkOrchard (FS FX E) 0 0 0 0))) False)

;; --- the perceptions, and the overlap that is the whole point ---------------
;; Each is true at two of the three cells; neither is true at FS alone. Every
;; world below is handed back byte-identical, fuel included -- looking is free
;; and changes nothing.
!(test (evalProgram (quote (orchFruitHere ())) (mkOrchard (FS FX E) 0 3 4 5))
       (mkRes True  (mkOrchard (FS FX E) 0 3 4 5)))
!(test (evalProgram (quote (orchFruitHere ())) (mkOrchard (FS FX E) 1 3 4 5))
       (mkRes True  (mkOrchard (FS FX E) 1 3 4 5)))
!(test (evalProgram (quote (orchFruitHere ())) (mkOrchard (FS FX E) 2 3 4 5))
       (mkRes False (mkOrchard (FS FX E) 2 3 4 5)))
!(test (evalProgram (quote (orchFreshHere ())) (mkOrchard (FS FX E) 0 3 4 5))
       (mkRes True  (mkOrchard (FS FX E) 0 3 4 5)))
!(test (evalProgram (quote (orchFreshHere ())) (mkOrchard (FS FX E) 1 3 4 5))
       (mkRes False (mkOrchard (FS FX E) 1 3 4 5)))
!(test (evalProgram (quote (orchFreshHere ())) (mkOrchard (FS FX E) 2 3 4 5))
       (mkRes True  (mkOrchard (FS FX E) 2 3 4 5)))

;; and the conjunction is true at FS and nowhere else -- the one thing neither
;; perception can say on its own
!(test (resValOf (evalProgram (quote (AND ((orchFruitHere ()) (orchFreshHere ()))))
                              (mkOrchard (FS FX E) 0 0 0 5))) True)
!(test (resValOf (evalProgram (quote (AND ((orchFruitHere ()) (orchFreshHere ()))))
                              (mkOrchard (FS FX E) 1 0 0 5))) False)
!(test (resValOf (evalProgram (quote (AND ((orchFruitHere ()) (orchFreshHere ()))))
                              (mkOrchard (FS FX E) 2 0 0 5))) False)

;; --- the starting program ---------------------------------------------------
;; "If there is fruit here, pick it." The obvious thing to write, and wrong on
;; both rings for the same reason: three spoiled fruits eaten at -3 each against
;; three fresh ones at +2.
!(test (orchFitness (quote (and_seq ((action_bool_if ((orchFruitHere ()) (orchPick ()) (orchWalk ()))))))  0) -3)
!(test (orchFitness (quote (and_seq ((action_bool_if ((orchFruitHere ()) (orchPick ()) (orchWalk ()))))))  1) -3)
!(test (orchScoreExp (quote (and_seq ((action_bool_if ((orchFruitHere ()) (orchPick ()) (orchWalk ())))))))  -6)

;; --- the program that is right ----------------------------------------------
;; Six a ring, which is every fresh fruit with nothing wasted, which is the
;; arithmetic ceiling.
!(test (orchFitness (quote (and_seq ((action_bool_if ((AND ((orchFruitHere ()) (orchFreshHere ()))) (orchPick ()) (orchWalk ()))))))  0) 6)
!(test (orchFitness (quote (and_seq ((action_bool_if ((AND ((orchFruitHere ()) (orchFreshHere ()))) (orchPick ()) (orchWalk ()))))))  1) 6)
!(test (orchScoreExp (quote (and_seq ((action_bool_if ((AND ((orchFruitHere ()) (orchFreshHere ()))) (orchPick ()) (orchWalk ())))))))  12)
!(test (orchScoreExp (quote (and_seq ((action_bool_if ((AND ((orchFruitHere ()) (orchFreshHere ()))) (orchPick ()) (orchWalk ())))))))  (orchBestScore))

;; --- doing nothing ----------------------------------------------------------
;; The bar every single-test program has to clear, and none of them does.
!(test (orchScoreExp (quote (and_seq ())))                              0)
!(test (orchScoreExp (quote (and_seq ((orchWalk ())))))                 0)
!(test (orchScoreExp (quote (and_seq ((orchPick ())))))                 -22)
!(test (orchScoreExp (quote (and_seq ((orchPick ()) (orchWalk ())))))   -4)

;; --- every conditional with ONE test in it ----------------------------------
;; The two perceptions and their negations, each way round: eight programs,
;; which is all of them. The best is -6; doing nothing is 0.
(= (orchSingles)
   (quote ((action_bool_if ((orchFruitHere ()) (orchPick ()) (orchWalk ())))
           (action_bool_if ((orchFruitHere ()) (orchWalk ()) (orchPick ())))
           (action_bool_if ((NOT ((orchFruitHere ()))) (orchPick ()) (orchWalk ())))
           (action_bool_if ((NOT ((orchFruitHere ()))) (orchWalk ()) (orchPick ())))
           (action_bool_if ((orchFreshHere ()) (orchPick ()) (orchWalk ())))
           (action_bool_if ((orchFreshHere ()) (orchWalk ()) (orchPick ())))
           (action_bool_if ((NOT ((orchFreshHere ()))) (orchPick ()) (orchWalk ())))
           (action_bool_if ((NOT ((orchFreshHere ()))) (orchWalk ()) (orchPick ()))))))

(= (orchSingleScores) (map-atom (orchSingles) $p (orchScoreExp $p)))

!(test (size-atom (orchSingles)) 8)
!(test (orchSingleScores) (-6 -25 -25 -6 -22 -18 -18 -22))
!(test (maxOf (orchSingleScores)) -6)
!(test (< (maxOf (orchSingleScores)) 0) True)
!(test (< (maxOf (orchSingleScores)) (orchScoreExp (quote (and_seq ())))) True)

;; --- the representation -----------------------------------------------------
;; Eight growth knobs of 2, then twenty-four test knobs of 3, then the
;; conditional's two branches at 2.
!(test (knobCountOf (orchRep)) 34)
!(test (knobMultiplicities (orchRep))
       (2 2 2 2 2 2 2 2 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 2 2))
!(test (kindAt (orchRep) 0)  ASK)
!(test (kindAt (orchRep) 8)  LSK)
!(test (kindAt (orchRep) 33) ASK)

;; the starting instance decodes back to the program we started from. The AND
;; over ORs around the condition is the builder's scaffolding, present in every
;; representation and empty of meaning; what matters is that it behaves the same
;; and scores the same.
!(test (exemplarInst (orchRep))
       (0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1))
!(test (preOrderExp (getCandidate (orchRep) (exemplarInst (orchRep))))
       (quote (and_seq ((action_bool_if ((AND ((OR ((orchFruitHere ())))))
                                         (orchPick ()) (orchWalk ())))))))
!(test (orchScore (orchRep) (exemplarInst (orchRep))) -6)
!(test (orchScore (orchRep) (exemplarInst (orchRep)))
       (orchScoreExp (preOrderExp (orchExemplar))))

;; --- the search -------------------------------------------------------------
(= (orchSearchPair)  (hillClimbing orchScoreExp (orchRep)))
(= (orchSearchInst)  (let ($inst $score) (orchSearchPair) $inst))
(= (orchSearchScore) (let ($inst $score) (orchSearchPair) $score))

;; how many knob settings differ between two instances
(= (orchKnobsChanged $a $b)
   (foldl-atom (rangeTo (size-atom $a)) 0 $n $i
     (if (== (index-atom $a $i) (index-atom $b $i)) $n (+ $n 1))))

;; does $term mention $symbol anywhere?
(= (orchMentions $term $symbol)
   (if (isExpr $term)
       (foldl-atom $term False $found $part (or $found (orchMentions $part $symbol)))
       (== $term $symbol)))

!(test (orchSearchScore) 12)
!(test (orchSearchScore) (orchBestScore))
!(test (- (orchSearchScore) (orchScore (orchRep) (exemplarInst (orchRep)))) 18)
;; ONE knob move: the climb changes exactly one setting and then nothing else
;; improves. The move is knob 9, the second candidate offered at the condition.
!(test (orchKnobsChanged (exemplarInst (orchRep)) (orchSearchInst)) 1)
!(test (orchSearchInst)
       (0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1))

;; and what it found is the conjunction -- both perceptions, in one condition
!(test (orchMentions (preOrderExp (getCandidate (orchRep) (orchSearchInst))) orchFruitHere) True)
!(test (orchMentions (preOrderExp (getCandidate (orchRep) (orchSearchInst))) orchFreshHere) True)
!(test (preOrderExp (getCandidate (orchRep) (orchSearchInst)))
       (quote (and_seq ((action_bool_if ((AND ((OR ((orchFruitHere ()))) (orchFreshHere ())))
                                         (orchPick ()) (orchWalk ())))))))
;; drop either conjunct and it is back among the single-test programs, all of
;; which are worse than doing nothing
!(test (> (orchSearchScore) (maxOf (orchSingleScores))) True)
