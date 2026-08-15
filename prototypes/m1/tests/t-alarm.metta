;; ============================================================================
;; tests/t-alarm.metta -- the classic boolean path: an input table, and ONE
;; parametrised primitive standing for every column.
;;
;; Three things are being checked, and the second is the one this file exists
;; for:
;;
;;   1. the table is the specification -- eight rows, one formula behind them,
;;      and no single column able to reproduce it
;;   2. the VOCABULARY IS GENERATED FROM THE TABLE. One declaration
;;      (: colAt (-> Params $ctx Bool)) plus a parameter slot per input column
;;      yields (colAt (0)) (colAt (1)) (colAt (2)). Widen the table and the
;;      vocabulary widens; nothing in the domain names a column.
;;   3. a BOOLEAN-ROOTED exemplar builds a boolean representation: every knob an
;;      LSK with three settings, not one action knob anywhere.
;;
;; Scores follow scoring/bscore.metta rather than the action domains: 0 for a
;; row the program got right, -1 for one it got wrong, summed. So the BEST
;; score is 0 and everything else is negative.
;;
;; NOTE on `quote`: `test` EVALUATES its expected side, so a program written out
;; longhand there is a CALL -- it yields no answer and the check silently does
;; not run, printing neither pass nor fail. Count the ticks against the number
;; of `!(test` lines; do not just look for failures.
;; ============================================================================

;; --- the table is the problem statement -------------------------------------
!(test (size-atom (rowsOf   (alarmTable))) 8)
!(test (size-atom (labelsOf (alarmTable))) 4)
!(test (lastOf (labelsOf (alarmTable))) Output)
!(test (map-atom (rowsOf (alarmTable)) $row (outputOf $row))
       (False False True False True False True False))
!(test (alarmBestScore) 0)

;; --- the vocabulary comes from the table ------------------------------------
;; Four headings, one of them the target, so three input columns and three
;; parameter slots. Add a column to alarmRows and alarmLabels and every number
;; below follows on its own.
!(test (inputCount) 3)
!(test (paramsOf colAt) ((0) (1) (2)))
!(test (map-atom (literalsOfType Bool) $l (preOrderExp $l))
       (quote ((colAt (0)) (colAt (1)) (colAt (2)))))

;; A primitive that is a single leaf says nothing about families, and expands to
;; exactly one candidate -- which is what keeps every action domain untouched.
!(test (collapse (paramsOf somethingUndeclared)) ())
!(test (map-atom (instancesOf somethingUndeclared) $l (preOrderExp $l))
       (quote ((somethingUndeclared ()))))
!(test (size-atom (instancesOf colAt)) 3)

;; --- reading a column -------------------------------------------------------
;; The index arrives in the node's parameter slot. The row comes back
;; byte-identical -- there is nothing in this domain a program could change.
!(test (evalProgram (quote (colAt (0))) (True False True False))
       (mkRes True  (True False True False)))
!(test (evalProgram (quote (colAt (1))) (True False True False))
       (mkRes False (True False True False)))
!(test (evalProgram (quote (colAt (2))) (True False True False))
       (mkRes True  (True False True False)))

;; --- no single column is the answer -----------------------------------------
;; Three columns and their three negations: six programs, which is all of the
;; one-column ones. The best still gets a row wrong, so the table can only be
;; matched by combining columns -- which is the whole reason there is a search.
(= (alarmSingles)
   (quote ((colAt (0)) (colAt (1)) (colAt (2))
           (NOT ((colAt (0)))) (NOT ((colAt (1)))) (NOT ((colAt (2)))))))

(= (alarmSingleScores) (map-atom (alarmSingles) $program (alarmScoreExp $program)))

!(test (size-atom (alarmSingles)) 6)
!(test (alarmSingleScores) (-3 -3 -7 -5 -5 -1))
!(test (maxOf (alarmSingleScores)) -1)
!(test (< (maxOf (alarmSingleScores)) (alarmBestScore)) True)

;; --- the two programs that bracket the search -------------------------------
!(test (alarmScoreExp (preOrderExp (alarmExemplar))) -3)
!(test (alarmScoreExp (quote (AND ((OR ((colAt (0)) (colAt (1))))
                                   (NOT ((colAt (2)))))))) 0)
!(test (alarmScoreExp (quote (AND ((OR ((colAt (0)) (colAt (1))))
                                   (NOT ((colAt (2)))))))) (alarmBestScore))

;; an empty condition is True on every row, which is right on the three the
;; alarm should sound and wrong on the five it should not
!(test (alarmScoreExp (quote (AND ()))) -5)

;; --- the candidates on offer ------------------------------------------------
;; Pinned because the order is load-bearing: columns in index order, then
;; operator-headed candidates with the LEADING argument held at column 0.
;; (OR (colAt (1)) (colAt (2))) is NOT among them -- the odometer never gets to
;; it inside the budget -- and the search does not need it, which is the point
;; of pinning this rather than assuming it.
!(test (size-atom (sampleLogicalPerms AND)) 9)
!(test (map-atom (sampleLogicalPerms AND) $candidate (preOrderExp $candidate))
       (quote ((colAt (0)) (colAt (1)) (colAt (2))
               (NOT ((colAt (0))))
               (OR ((colAt (0)) (colAt (1))))
               (NOT ((colAt (1))))
               (OR ((colAt (0)) (colAt (2))))
               (NOT ((colAt (2))))
               (OR ((colAt (0)) (NOT ((colAt (1)))))))))

;; --- the representation -----------------------------------------------------
;; Nine candidates at the root AND, nine inside the OR that took over column 0,
;; nine in the empty OR appended to grow into: twenty-seven knobs, every one of
;; them a three-setting test knob.
!(test (knobCountOf (alarmRep)) 27)
!(test (nub (knobMultiplicities (alarmRep))) (3))
!(test (nub (map-atom (rangeTo (knobCountOf (alarmRep))) $i (kindAt (alarmRep) $i))) (LSK))

;; the starting instance decodes back to the program we started from
!(test (exemplarInst (alarmRep))
       (1 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0))
!(test (preOrderExp (getCandidate (alarmRep) (exemplarInst (alarmRep))))
       (quote (AND ((OR ((colAt (0))))))))
!(test (alarmScore (alarmRep) (exemplarInst (alarmRep))) -3)
!(test (alarmScore (alarmRep) (exemplarInst (alarmRep)))
       (alarmScoreExp (preOrderExp (alarmExemplar))))

;; --- the search -------------------------------------------------------------
(= (alarmSearchPair)  (hillClimbing alarmScoreExp (alarmRep)))
(= (alarmSearchInst)  (let ($inst $score) (alarmSearchPair) $inst))
(= (alarmSearchScore) (let ($inst $score) (alarmSearchPair) $score))

(= (alarmKnobsChanged $a $b)
   (foldl-atom (rangeTo (size-atom $a)) 0 $n $i
     (if (== (index-atom $a $i) (index-atom $b $i)) $n (+ $n 1))))

;; the score after each accepted move
(= (alarmTrajectory $rep $mults $inst $score $fuel)
   (if (<= $fuel 0)
       ($score)
       (let ($nextInst $nextScore) (hillClimbingStep alarmScoreExp $rep $mults $inst $score)
         (if (== $nextScore $score)
             ($score)
             (cons-atom $score (alarmTrajectory $rep $mults $nextInst $nextScore (- $fuel 1)))))))

(= (alarmTrail)
   (let* (($rep   (alarmRep))
          ($mults (knobMultiplicities $rep))
          ($start (exemplarInst $rep)))
     (alarmTrajectory $rep $mults $start (alarmScore $rep $start) 20)))

!(test (alarmSearchScore) 0)
!(test (alarmSearchScore) (alarmBestScore))

;; TWO moves, and they are different KINDS of move -- which is the thing worth
;; seeing. The first adds a conjunct at the root (setting 2 on the candidate
;; for column 2, i.e. negated); the second reaches INSIDE the conjunct that was
;; already there and widens its OR. A representation that only offered
;; root-level choices could make the first move and never the second.
!(test (alarmTrail) (-3 -1 0))
!(test (alarmKnobsChanged (exemplarInst (alarmRep)) (alarmSearchInst)) 2)
!(test (alarmSearchInst)
       (1 0 2 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0))
!(test (preOrderExp (getCandidate (alarmRep) (alarmSearchInst)))
       (quote (AND ((OR ((colAt (0)) (colAt (1)))) (NOT ((colAt (2))))))))

;; and what it found matches the table on every row
!(test (alarmScoreExp (preOrderExp (getCandidate (alarmRep) (alarmSearchInst))))
       (alarmBestScore))
!(test (> (alarmSearchScore) (maxOf (alarmSingleScores))) True)
