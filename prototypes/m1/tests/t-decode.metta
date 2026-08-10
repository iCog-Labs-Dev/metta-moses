;; ============================================================================
;; tests/t-decode.metta -- vector -> tree -> tidy tree -> runnable.
;;
;; Instances are written as one change to the starting instance, so what is
;; being tested stays visible. Knob 8 holds the test; knob 0 is the first
;; growth candidate; knobs 32 and 33 are the conditional's two branches.
;; ============================================================================

(= (start) (exemplarInst (m1Rep)))

;; a switched-off knob removes its position entirely. With the only switched-on
;; test gone the condition is an empty AND -- "no test".
!(test (preOrderExp (getCandidate (m1Rep) (changeAt (start) 8 0)))
       (quote (and_seq ((action_bool_if ((AND ()) (m1Step ()) (m1Grab ())))))))
;; ...and an empty condition means "no test", which is True, so the THEN
;; branch always runs. It must not be treated as a broken program.
!(test (evalProgram (preOrderExp (getCandidate (m1Rep) (changeAt (start) 8 0)))
                    (mkW (F E) 0 0 0 5))
       (mkRes True (mkW (F E) 1 0 0 4)))

;; setting 2 negates whatever the knob controls
!(test (preOrderExp (getCandidate (m1Rep) (changeAt (start) 8 2)))
       (quote (and_seq ((action_bool_if ((AND ((NOT ((OR ((m1FoodHere ())))))))
                                         (m1Step ()) (m1Grab ())))))))
;; and the negation is real, not just structural: with it, food present takes
;; the ELSE branch
!(test (evalProgram (preOrderExp (getCandidate (m1Rep) (changeAt (start) 8 2)))
                    (mkW (F E) 0 0 0 5))
       (mkRes True (mkW (E E) 0 1 0 4)))

;; the growth candidates: switching one on appends that child to the sequence.
;; Candidate 0 is a bare action; candidate 3 is a whole conditional, which
;; arrives in one piece because a candidate is only ever offered complete.
!(test (preOrderExp (getCandidate (m1Rep) (changeAt (start) 0 1)))
       (quote (and_seq ((action_bool_if ((AND ((OR ((m1FoodHere ())))))
                                         (m1Step ()) (m1Grab ())))
                        (m1Grab ())))))
!(test (preOrderExp (getCandidate (m1Rep) (changeAt (start) 3 1)))
       (quote (and_seq ((action_bool_if ((AND ((OR ((m1FoodHere ())))))
                                         (m1Step ()) (m1Grab ())))
                        (action_bool_if ((m1FoodHere ()) (m1Grab ()) (m1Step ())))))))
;; two growth knobs at once -- they are independent knobs, not settings of one
!(test (preOrderExp (getCandidate (m1Rep) (changeAt (changeAt (start) 0 1) 1 1)))
       (quote (and_seq ((action_bool_if ((AND ((OR ((m1FoodHere ())))))
                                         (m1Step ()) (m1Grab ())))
                        (m1Grab ()) (m1Step ())))))

;; dropping a branch leaves the conditional short of a child, which is a
;; malformed program -- it scores worst rather than crashing
!(test (preOrderExp (getCandidate (m1Rep) (changeAt (start) 32 0)))
       (quote (and_seq ((action_bool_if ((AND ((OR ((m1FoodHere ()))))) (m1Grab ())))))))
!(test (m1Score (m1Rep) (changeAt (changeAt (start) 32 0) 33 0)) 0)

;; tidying: an unused empty boolean node is scaffolding and comes out...
!(test (preOrderExp (cleanTree
         (mkTree (mkNode AND) ((mkTree (mkNode m1FoodHere) ())
                               (mkTree (mkNode OR) ())))))
       (quote (AND ((m1FoodHere ())))))
;; ...but an empty condition at the top is a real statement -- "no test" -- and
;; stays, or the search would be punished for turning a condition off
!(test (preOrderExp (cleanTree (mkTree (mkNode AND) ()))) (quote (AND ())))

;; compiling: every node gets the same shape, leaves included
!(test (preOrderExp (mkTree (mkNode m1Grab) ())) (quote (m1Grab ())))
!(test (preOrderExp (mkTree (mkNode AND) ((mkTree (mkNode m1FoodHere) ()))))
       (quote (AND ((m1FoodHere ())))))
