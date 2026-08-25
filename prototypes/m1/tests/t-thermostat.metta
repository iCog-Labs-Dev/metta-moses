;; ============================================================================
;; tests/t-thermostat.metta -- a tunable number, in the shape classic MOSES uses.
;;
;; The thing being checked is that the search can find a value that is NOWHERE in
;; the problem: not in the table, not in the vocabulary, not in the exemplar. The
;; answer is 16 and the data only ever says which readings should sound an alarm.
;;
;; Three groups, and the second is why this file exists:
;;
;;   1. the walk. A contin knob stores directions, not a value -- Left, Right,
;;      Stop over `depth` slots -- and the arithmetic is classic's contin_stepper
;;      (field_set.h). Every value below was computed BY HAND from that
;;      definition before the code was run.
;;   2. the search tunes it. The trajectory is -3 -2 -1 0 and the thresholds it
;;      passes through are 0, 8, 24, 16 -- it OVERSHOOTS in the expansion phase
;;      and bisects back. Nothing asked it to do that; it is what one-knob-at-a-
;;      time hill climbing does to a walk encoding.
;;   3. the mixture is safe. numGt is declared in core, so every other domain
;;      sees it in `opsOfType Bool`; it is `isFillable` that keeps it out of a
;;      domain with no numbers. If that filter breaks, tape/orchard/berries/alarm
;;      die with a zero-divisor rather than failing a check.
;;
;; NOTE on `quote`: `test` EVALUATES its expected side, so a program written out
;; longhand is a CALL and the check silently does not run. Count ticks against
;; `grep -c '^!(test'`; a short count with NO failure means checks vanished, and a
;; short count WITH a failure means the run halted there (test calls halt/1).
;; ============================================================================

;; --- the problem -------------------------------------------------------------
!(test (thermInputCount) 1)
!(test (size-atom (thermRowsOf (thermTable))) 6)
!(test (map-atom (thermRowsOf (thermTable)) $row (thermOutputOf $row))
       (False False False True True True))
!(test (thermBestScore) 0)

;; The answer is not in the data. 16 separates the rows and appears in no row.
!(test (containsIn (map-atom (thermRowsOf (thermTable)) $row (car-atom $row)) 16) False)

;; --- two kinds of parameter --------------------------------------------------
;; The same question -- what goes in this primitive's parameter slot? -- answered
;; two ways. A discrete set for a column index; a walk for a number to tune.
!(test (paramsOf numColAt) ((0)))
!(test (continOf numThreshold) (mkContin 0 8 2 3))
!(test (collapse (continOf numColAt)) ())
!(test (collapse (paramsOf numThreshold)) ())

;; A contin primitive is ONE candidate, holding the declared mean -- not a family.
!(test (map-atom (instancesOf numThreshold) $l (preOrderExp $l))
       (quote ((numThreshold (0)))))

;; --- the vocabulary ----------------------------------------------------------
!(test (map-atom (literalsOfType Number) $l (preOrderExp $l))
       (quote ((numColAt (0)) (numThreshold (0)))))
!(test (literalsOfType Bool) ())

;; isFillable at work: AND, OR and NOT all produce Bool, but this domain has no
;; Bool primitives to fill their slots, so only numGt may head a candidate. This
;; is the check that stands between the numGt declaration and a zero-divisor.
!(test (permittedOpsFor AND Bool) (quote (numGt)))
!(test (isFillable numGt) True)
!(test (isFillable OR) False)

!(test (size-atom (sampleLogicalPerms AND)) 2)
!(test (map-atom (sampleLogicalPerms AND) $c (preOrderExp $c))
       (quote ((numGt ((numColAt (0)) (numThreshold (0))))
               (numGt ((numThreshold (0)) (numColAt (0)))))))

;; --- the walk ----------------------------------------------------------------
;; mean 0, step 8, expansion 2. Hand-computed from classic's contin_stepper:
;; while every move goes the same way the step GROWS by expansion; the first
;; reversal undoes that expansion and halves from then on.
!(test (continWalk (0 0 0) 0 8 2) 0)      ;; all Stop = the mean
!(test (continWalk (2 0 0) 0 8 2) 8)      ;; R: 0+8, step becomes 16
!(test (continWalk (2 2 0) 0 8 2) 24)     ;; RR: 8+16, still expanding
!(test (continWalk (2 2 1) 0 8 2) 16)     ;; RRL: reversal, 24 - 32/(2*2)
!(test (continWalk (1 0 0) 0 8 2) -8)     ;; L is the mirror of R

;; THE FIRST Stop ENDS THE WALK. Everything after it is dead, exactly as classic's
;; decoder `break`s -- which is what makes all-Stop mean "the value it was built
;; with", and what makes hill climbing extend the walk left to right.
!(test (continWalk (0 2 2) 0 8 2) 0)
!(test (continWalk (2 0 2) 0 8 2) 8)

;; --- reading a threshold -----------------------------------------------------
;; A tunable constant ignores the row: it IS its parameter.
!(test (evalProgram (quote (numThreshold (16))) (20 True)) (mkRes 16 (20 True)))
!(test (evalProgram (quote (numColAt (0))) (20 True)) (mkRes 20 (20 True)))
!(test (resValOf (evalProgram (quote (numGt ((numColAt (0)) (numThreshold (16))))) (20 True))) True)
!(test (resValOf (evalProgram (quote (numGt ((numColAt (0)) (numThreshold (16))))) (12 False))) False)

;; --- which thresholds are right ----------------------------------------------
;; Any level in (12, 20] reproduces the table. The three the search walks through
;; bracket it: 8 is too low, 24 too high, 16 exactly right.
!(test (thermScoreExp (quote (AND ((numGt ((numColAt (0)) (numThreshold (16)))))))) 0)
!(test (thermScoreExp (quote (AND ((numGt ((numColAt (0)) (numThreshold (16)))))))) (thermBestScore))
!(test (thermScoreExp (quote (AND ((numGt ((numColAt (0)) (numThreshold (8)))))))) -2)
!(test (thermScoreExp (quote (AND ((numGt ((numColAt (0)) (numThreshold (24)))))))) -1)
!(test (thermScoreExp (preOrderExp (thermExemplar))) -3)

;; --- the representation ------------------------------------------------------
;; Twenty-one knobs: six ordinary subtree knobs, and FIFTEEN that are numbers --
;; the contin knob spends one 3-setting slot per step of its walk, which is why
;; search/hillclimb.metta needs no notion of a number at all.
;;
;; Five contin knobs at depth 3. One is the exemplar's own threshold; the other
;; four sit inside CANDIDATES that start switched off. A placeholder is a
;; DISABLED knob, not the absence of one, so the numbers inside it own their
;; slots like any other knob -- they simply have no effect until the candidate
;; above them is switched on. That is what makes a threshold reachable in a
;; condition the exemplar never contained; before it, such a number was frozen
;; at its declared mean forever. The cost is the dimensions those knobs occupy
;; while switched off, which is the trade classic MOSES makes too by allocating
;; its whole field set up front.
!(test (knobCountOf (thermRep)) 21)
!(test (knobMultiplicities (thermRep)) (3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3))
!(test (map-atom (rangeTo (knobCountOf (thermRep))) $i (kindAt (thermRep) $i))
       (LSK LSK LSK LSK CTK CTK CTK CTK CTK CTK CTK CTK CTK LSK LSK CTK CTK CTK CTK CTK CTK))
!(test (size-atom (filter-atom (map-atom (rangeTo (knobCountOf (thermRep))) $i
                                        (kindAt (thermRep) $i))
                              $k (== $k CTK))) 15)

;; THE ROUND TRIP. Every trit defaults to Stop, so the starting instance decodes
;; back to the threshold the exemplar was written with. This is the check that
;; catches a decode bug: if the trits were read from the wrong slots, or the mean
;; came from the declaration instead of the tree, this is what would move.
!(test (exemplarInst (thermRep)) (1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0))
!(test (preOrderExp (getCandidate (thermRep) (exemplarInst (thermRep))))
       (quote (AND ((OR ((numGt ((numColAt (0)) (numThreshold (0))))))))))
!(test (thermScore (thermRep) (exemplarInst (thermRep))) -3)
!(test (thermScore (thermRep) (exemplarInst (thermRep)))
       (thermScoreExp (preOrderExp (thermExemplar))))

;; --- the search --------------------------------------------------------------
(= (thermSearchPair)  (hillClimbing thermScoreExp (thermRep)))
(= (thermSearchInst)  (let ($inst $score) (thermSearchPair) $inst))
(= (thermSearchScore) (let ($inst $score) (thermSearchPair) $score))

(= (thermTrail $rep $mults $inst $score $fuel)
   (if (<= $fuel 0)
       ($score)
       (let ($nextInst $nextScore) (hillClimbingStep thermScoreExp $rep $mults $inst $score)
         (if (== $nextScore $score)
             ($score)
             (cons-atom $score (thermTrail $rep $mults $nextInst $nextScore (- $fuel 1)))))))

(= (thermSteps)
   (let* (($rep   (thermRep))
          ($mults (knobMultiplicities $rep))
          ($start (exemplarInst $rep)))
     (thermTrail $rep $mults $start (thermScore $rep $start) 20)))

!(test (thermSearchScore) 0)
!(test (thermSearchScore) (thermBestScore))

;; Three moves, and all three are trits of the SAME number -- the search changed
;; no structure at all, only a value. That is the whole point of the file.
!(test (thermSteps) (-3 -2 -1 0))
!(test (thermSearchInst) (1 0 1 0 2 2 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0))
!(test (preOrderExp (getCandidate (thermRep) (thermSearchInst)))
       (quote (AND ((OR ((numGt ((numColAt (0)) (numThreshold (16))))))))))

;; and the trits it settled on are Right, Right, Left -- overshoot, overshoot,
;; bisect back. The expansion phase carried it past the answer and the bisection
;; phase brought it home, driven by nothing but the score.
!(test (map-atom (4 5 6) $i (index-atom (thermSearchInst) $i)) (2 2 1))
!(test (continWalk (map-atom (4 5 6) $i (index-atom (thermSearchInst) $i)) 0 8 2) 16)
