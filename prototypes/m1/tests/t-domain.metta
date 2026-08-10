;; ============================================================================
;; tests/t-domain.metta -- the toy world, and the claim that looking pays off.
;;
;; The claim is not "we tried it and looking won". It is a bound:
;;
;;   the two tapes agree at position 0 and differ everywhere else, and an
;;   action reports the same thing whether or not it found food, so a program
;;   with no perception in it runs an IDENTICAL course on both tapes. Whatever
;;   it gains on one it loses on the other. Across the two episodes it cannot
;;   score more than 2, whatever it does.
;;
;; The tests below check the facts that bound rests on, so that changing the
;; world by accident fails loudly instead of quietly making the claim false.
;; ============================================================================

!(test (m1FoodCount (m1TapeA)) 5)
!(test (m1FoodCount (m1TapeB)) 5)
!(test (size-atom (m1TapeA)) 9)
!(test (size-atom (m1TapeB)) 9)
!(test (m1Fuel) 14)
!(test (m1BestScore) 10)

(= (tapesAgreeAt0) (== (index-atom (m1TapeA) 0) (index-atom (m1TapeB) 0)))
(= (tapesDifferAfter0)
   (let $idxs (rangeTo (size-atom (m1TapeA)))
     (foldl-atom $idxs True $a $k
       (if (== $k 0) $a
           (and $a (not (== (index-atom (m1TapeA) $k) (index-atom (m1TapeB) $k))))))))
!(test (tapesAgreeAt0)     True)
!(test (tapesDifferAfter0) True)

;; An action reports the same thing regardless of what it found. If this ever
;; became false, a program could tell food from empty by watching whether its
;; actions succeeded -- seeing without looking -- and the bound would collapse.
!(test (resValOf (evalProgram (quote (m1Grab ())) (mkW (F E) 0 0 0 5))) True)
!(test (resValOf (evalProgram (quote (m1Grab ())) (mkW (E E) 0 0 0 5))) True)
!(test (resValOf (evalProgram (quote (m1Step ())) (mkW (E E) 0 0 0 5))) True)
!(test (resValOf (evalProgram (quote (m1Grab ())) (mkW (F E) 0 0 0 0))) False)

;; --- what particular programs score, per episode so the totals are checkable
!(test (m1Fitness (quote (action_bool_if ((m1FoodHere ()) (m1Grab ()) (m1Step ())))) 0) 5)
!(test (m1Fitness (quote (action_bool_if ((m1FoodHere ()) (m1Grab ()) (m1Step ())))) 1) 5)
!(test (m1Fitness (quote (action_bool_if ((m1FoodHere ()) (m1Step ()) (m1Grab ())))) 0) -12)
!(test (m1Fitness (quote (action_bool_if ((m1FoodHere ()) (m1Step ()) (m1Grab ())))) 1) -13)
!(test (m1Fitness (quote (and_seq ((m1Grab ()) (m1Step ())))) 0) 1)
!(test (m1Fitness (quote (and_seq ((m1Grab ()) (m1Step ())))) 1) 1)

;; doing nothing scores 0 -- so "do nothing" is not accidentally a good answer
!(test (m1ScoreExp (quote (and_seq ())))            0)
!(test (m1ScoreExp (quote (and_seq ((m1Step ()))))) 0)
!(test (m1ScoreExp (quote (and_seq ((m1Grab ()))))) -24)

;; the three tiers
!(test (m1ScoreExp (quote (action_bool_if ((m1FoodHere ()) (m1Grab ()) (m1Step ()))))) 10)
!(test (m1ScoreExp (quote (and_seq ((m1Grab ()) (m1Step ())))))                        2)
!(test (m1ScoreExp (quote (action_bool_if ((m1FoodHere ()) (m1Step ()) (m1Grab ()))))) -25)

;; --- the bound itself, checked over every program that never looks ----------
(= (m1Acts) ((mkTree (mkNode m1Grab) ()) (mkTree (mkNode m1Step) ())))

;; all sequences of length $n. ONE clause with a test inside -- two clauses
;; would both apply at 0 and every answer would come back doubled.
(= (m1Seqs $n)
   (if (<= $n 0)
       (())
       (let $tails (m1Seqs (- $n 1))
         (foldl-atom (m1Acts) () $acc $a
           (union-atom $acc (map-atom $tails $t (cons-atom $a $t)))))))

(= (blindScores)
   (let $all (union-atom (m1Seqs 1) (union-atom (m1Seqs 2) (m1Seqs 3)))
     (map-atom $all $kids (m1ScoreExp (preOrderExp (mkTree (mkNode and_seq) $kids))))))

!(test (size-atom (blindScores)) 14)    ;; 2 + 4 + 8
!(test (maxOf (blindScores))      2)    ;; and not one of them beats the bound
