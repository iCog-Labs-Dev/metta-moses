;; ============================================================================
;; tests/t-decode.metta -- vector -> tree -> tidy tree -> runnable.
;; ============================================================================

;; a switched-off knob removes its position entirely
!(test (showTree (candidateOf (m1Rep) (0 0 0 0 0 0 0 0 0 0 0 0 0 1 1)))
       (and_seq ((action_bool_if ((AND ()) m1Step m1Grab)))))
;; ...and an empty condition means "no test", which is True, so the THEN
;; branch always runs. It must not be treated as a broken program.
!(test (evalProgram (compileTree (candidateOf (m1Rep) (0 0 0 0 0 0 0 0 0 0 0 0 0 1 1)))
                    (mkW (F E) 0 0 0 5))
       (mkRes True (mkW (F E) 1 0 0 4)))

;; setting 2 negates whatever the knob controls
!(test (showTree (candidateOf (m1Rep) (0 2 0 0 0 1 0 0 0 0 0 0 0 1 1)))
       (and_seq ((action_bool_if ((AND ((NOT ((OR (m1FoodHere)))))) m1Step m1Grab)))))
;; and the negation is real, not just structural: with it, food present takes
;; the ELSE branch
!(test (evalProgram (compileTree (candidateOf (m1Rep) (0 2 0 0 0 1 0 0 0 0 0 0 0 1 1)))
                    (mkW (F E) 0 0 0 5))
       (mkRes True (mkW (E E) 0 1 0 4)))

;; the growth slot: switching knob 0 on appends a child to the sequence
!(test (showTree (candidateOf (m1Rep) (1 1 0 0 0 1 0 0 0 0 0 0 0 1 1)))
       (and_seq ((action_bool_if ((AND ((OR (m1FoodHere)))) m1Step m1Grab)) m1Grab)))

;; dropping a branch leaves the conditional short of a child, which is a
;; malformed program -- it scores worst rather than crashing
!(test (showTree (candidateOf (m1Rep) (0 1 0 0 0 1 0 0 0 0 0 0 0 0 1)))
       (and_seq ((action_bool_if ((AND ((OR (m1FoodHere)))) m1Grab)))))
!(test (m1Score (m1Rep) (0 1 0 0 0 1 0 0 0 0 0 0 0 0 0)) 0)

;; tidying: an unused empty boolean node is scaffolding and comes out...
!(test (showTree (cleanupTree
         (mkTree (mkNode AND) ((mkTree (mkNode m1FoodHere) ())
                               (mkTree (mkNode OR) ())))))
       (AND (m1FoodHere)))
;; ...but an empty condition at the top is a real statement -- "no test" -- and
;; stays, or the search would be punished for turning a condition off
!(test (showTree (cleanupTree (mkTree (mkNode AND) ()))) AND)

;; compiling: every node gets the same shape, leaves included
!(test (compileTree (mkTree (mkNode m1Grab) ())) (quote (m1Grab ())))
!(test (compileTree (mkTree (mkNode AND) ((mkTree (mkNode m1FoodHere) ()))))
       (quote (AND ((m1FoodHere ())))))
