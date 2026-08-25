;; ============================================================================
;; tests/t-grove.metta -- THE MIXED CASE: an action program whose condition is a
;; numeric comparison, with two tuned numbers in different roles.
;;
;; thermostat proves a contin knob works. This file proves it works WHERE IT HAS
;; TO -- inside the kind of program the other three domains already build, next to
;; the subtree knobs, without either kind disturbing the other.
;;
;; One tree carries four types at once:
;;
;;     (and_seq ((action_bool_if ((numGt ((groveRipeHere ()) (groveThresh (0))))
;;                                (grovePick ())
;;                                (groveStepN (2))))))
;;      ^Act        ^Act              ^Bool     ^Number         ^Act w/ tuned count
;;
;; and the representation ends up holding ASK, LSK and CTK knobs in ONE instance
;; vector, which is the claim being tested. Classic MOSES cannot do the mirror of
;; this: its build_contin never calls build_logical, so a numeric-rooted program
;; there has its boolean structure frozen.
;;
;; TWO CONTIN KNOBS, TWO ROUTES INTO THE BUILDER. The threshold is found by
;; scanning inside a boolean candidate; the magnitude by scanning an action
;; primitive's own parameter. Both must be found, and both start wrong.
;;
;; NOTE on `quote`: `test` EVALUATES its expected side. Count ticks against
;; `grep -c '^!(test'` -- short with no failure means checks vanished, short WITH
;; a failure means the run halted there, because `test` calls halt/1 on mismatch.
;; ============================================================================

;; --- the world ---------------------------------------------------------------
!(test (groveCells) (5 9 0 12 0 5))
!(test (groveFuel) 6)
!(test (groveRipeFloor) 8)
!(test (groveBestScore) 4)

;; two berries worth eating, on cells 1 and 3 -- both ODD, which is why a stride
;; of two can never reach them
!(test (size-atom (filter-atom (groveCells) $r (> $r (groveRipeFloor)))) 2)

;; reading past the end is bare ground, not an error
!(test (groveRipeAt (groveCells) 1) 9)
!(test (groveRipeAt (groveCells) 99) 0)
!(test (groveClearAt (5 9 0) 1) (5 0 0))

;; --- the pieces --------------------------------------------------------------
;; A numeric perception looks without changing anything, exactly as a boolean one
;; does; only its declared type differs.
!(test (evalProgram (quote (groveRipeHere ())) (mkGrove (5 9) 1 0 0 3))
       (mkRes 9 (mkGrove (5 9) 1 0 0 3)))

;; A tunable constant ignores the world and IS its parameter.
!(test (evalProgram (quote (groveThresh (8))) (mkGrove (5 9) 1 0 0 3))
       (mkRes 8 (mkGrove (5 9) 1 0 0 3)))

;; picking a ripe berry earns; picking an unripe one costs more than not picking
!(test (evalProgram (quote (grovePick ())) (mkGrove (5 9) 1 0 0 3))
       (mkRes True (mkGrove (5 0) 1 2 0 2)))
!(test (evalProgram (quote (grovePick ())) (mkGrove (5 9) 0 0 0 3))
       (mkRes True (mkGrove (0 9) 0 0 3 2)))

;; a tuned magnitude moves that far, and rounds in the DOMAIN -- classic keeps
;; contin values as doubles, so a whole-number count rounds at the point of use
!(test (evalProgram (quote (groveStepN (1))) (mkGrove (5 9) 0 0 0 3))
       (mkRes True (mkGrove (5 9) 1 0 0 2)))
!(test (evalProgram (quote (groveStepN (1.6))) (mkGrove (5 9) 0 0 0 3))
       (mkRes True (mkGrove (5 9) 2 0 0 2)))

;; --- the vocabulary, which is genuinely mixed --------------------------------
!(test (map-atom (literalsOfType Number) $l (preOrderExp $l))
       (quote ((groveRipeHere ()) (groveThresh (0)))))
!(test (map-atom (literalsOfType Act) $l (preOrderExp $l))
       (quote ((grovePick ()) (groveStepN (2)))))

;; No boolean primitive exists here -- every condition has to be BUILT out of a
;; comparison. So numGt is the only operator that may head a Bool candidate, and
;; AND/OR/NOT are dropped as unfillable. Without isFillable this is where the run
;; would die with a zero-divisor instead of failing a check.
!(test (literalsOfType Bool) ())
!(test (permittedOpsFor and_seq Bool) (quote (numGt)))
!(test (isFillable numGt) True)
!(test (isFillable AND) False)

;; two contin primitives, two different specs -- which is the argument for
;; continOf being per-primitive rather than one global setting as in classic
!(test (continOf groveThresh) (mkContin 0 8 2 1))
!(test (continOf groveStepN)  (mkContin 2 1 2 1))
!(test (collapse (continOf grovePick)) ())

;; depth 1, so each number is ONE trit: Stop keeps it, Left and Right move it
!(test (continWalk (0) 0 8 2) 0)
!(test (continWalk (2) 0 8 2) 8)
!(test (continWalk (1) 0 8 2) -8)
!(test (continWalk (0) 2 1 2) 2)
!(test (continWalk (1) 2 1 2) 1)
!(test (continWalk (2) 2 1 2) 3)

;; --- the landscape, computed directly ----------------------------------------
;; Both numbers matter, and neither alone is enough. Fixing only the threshold
;; leaves the creature striding past every ripe berry; fixing only the stride
;; leaves it eating the unripe ones.
!(test (groveScoreExp (quote (and_seq ((action_bool_if
         ((numGt ((groveRipeHere ()) (groveThresh (0)))) (grovePick ()) (groveStepN (2)))))))) -3)
!(test (groveScoreExp (quote (and_seq ((action_bool_if
         ((numGt ((groveRipeHere ()) (groveThresh (8)))) (grovePick ()) (groveStepN (2)))))))) 0)
!(test (groveScoreExp (quote (and_seq ((action_bool_if
         ((numGt ((groveRipeHere ()) (groveThresh (0)))) (grovePick ()) (groveStepN (1)))))))) 1)
!(test (groveScoreExp (quote (and_seq ((action_bool_if
         ((numGt ((groveRipeHere ()) (groveThresh (8)))) (grovePick ()) (groveStepN (1)))))))) 4)
!(test (groveScoreExp (quote (and_seq ((action_bool_if
         ((numGt ((groveRipeHere ()) (groveThresh (8)))) (grovePick ()) (groveStepN (1))))))))
       (groveBestScore))
!(test (groveScoreExp (preOrderExp (groveExemplar))) -3)

;; --- the representation: three knob kinds, one instance vector ---------------
!(test (knobCountOf (groveRep)) 24)
!(test (map-atom (rangeTo (knobCountOf (groveRep))) $i (kindAt (groveRep) $i))
       (CTK CTK CTK CTK ASK ASK ASK ASK ASK ASK LSK LSK LSK LSK CTK CTK CTK LSK LSK CTK CTK ASK CTK ASK))
!(test (knobMultiplicities (groveRep)) (3 3 3 3 2 2 2 2 2 2 3 3 3 3 3 3 3 3 3 3 3 2 3 2))

;; TEN contin knobs, all depth 1, sitting among six action knobs and eight test
;; knobs, all indexed by one shared counter. Two of the ten are the exemplar's
;; own numbers -- the threshold at slot 14 and the magnitude at slot 22. The
;; other eight are inside CANDIDATES that start switched off, on both sides:
;; four in boolean candidates offered at the condition, four in action
;; candidates offered at the grow-into slot.
;;
;; A placeholder is a DISABLED knob, not the absence of one: the numbers inside
;; it own their slots like any other knob and simply have no effect until the
;; candidate above them is switched on. That is what makes a number reachable
;; inside structure the exemplar never contained; before it, such a number was
;; frozen at its declared mean forever. The cost is the dimensions those knobs
;; occupy while switched off -- the same trade classic MOSES makes by allocating
;; its whole field set up front.
!(test (size-atom (filter-atom (map-atom (rangeTo (knobCountOf (groveRep))) $i
                                        (kindAt (groveRep) $i))
                              $k (== $k CTK))) 10)
!(test (kindAt (groveRep) 14) CTK)
!(test (kindAt (groveRep) 22) CTK)

;; THE ROUND TRIP. Both trits default to Stop, so the starting instance decodes
;; back to the two numbers the exemplar was written with -- 0 and 2. If a contin
;; knob read the wrong slot, or took its mean from the declaration instead of the
;; tree, this is the check that would move.
!(test (exemplarInst (groveRep)) (0 0 0 0 0 0 0 0 0 0 1 0 1 0 0 0 0 0 0 0 0 1 0 1))
!(test (preOrderExp (getCandidate (groveRep) (exemplarInst (groveRep))))
       (quote (and_seq ((action_bool_if ((AND ((OR ((numGt ((groveRipeHere ()) (groveThresh (0))))))))
                                         (grovePick ()) (groveStepN (2))))))))
!(test (groveScore (groveRep) (exemplarInst (groveRep))) -3)
!(test (groveScore (groveRep) (exemplarInst (groveRep)))
       (groveScoreExp (preOrderExp (groveExemplar))))

;; --- the search --------------------------------------------------------------
(= (groveSearchPair)  (hillClimbing groveScoreExp (groveRep)))
(= (groveSearchInst)  (let ($inst $score) (groveSearchPair) $inst))
(= (groveSearchScore) (let ($inst $score) (groveSearchPair) $score))

(= (groveTrail $rep $mults $inst $score $fuel)
   (if (<= $fuel 0)
       ($score)
       (let ($nextInst $nextScore) (hillClimbingStep groveScoreExp $rep $mults $inst $score)
         (if (== $nextScore $score)
             ($score)
             (cons-atom $score (groveTrail $rep $mults $nextInst $nextScore (- $fuel 1)))))))

(= (groveSteps)
   (let* (($rep   (groveRep))
          ($mults (knobMultiplicities $rep))
          ($start (exemplarInst $rep)))
     (groveTrail $rep $mults $start (groveScore $rep $start) 20)))

!(test (groveSearchScore) 4)
!(test (groveSearchScore) (groveBestScore))

;; TWO moves, and both are contin trits -- the search changed no structure at
;; all. It fixed the stride first (that alone is worth +4 of swing) and then the
;; threshold.
!(test (groveSteps) (-3 1 4))
!(test (groveSearchInst) (0 0 0 0 0 0 0 0 0 0 1 0 1 0 2 0 0 0 0 0 0 1 1 1))
!(test (preOrderExp (getCandidate (groveRep) (groveSearchInst)))
       (quote (and_seq ((action_bool_if ((AND ((OR ((numGt ((groveRipeHere ()) (groveThresh (8))))))))
                                         (grovePick ()) (groveStepN (1))))))))

;; and both trits moved: the threshold Right (0 -> 8), the stride Left (2 -> 1)
!(test (index-atom (groveSearchInst) 14) 2)
!(test (index-atom (groveSearchInst) 22) 1)
!(test (continWalk ((index-atom (groveSearchInst) 14)) 0 8 2) 8)
!(test (continWalk ((index-atom (groveSearchInst) 22)) 2 1 2) 1)
