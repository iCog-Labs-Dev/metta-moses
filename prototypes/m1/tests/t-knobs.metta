;; ============================================================================
;; tests/t-knobs.metta -- building the space of programs.
;; ============================================================================

;; --- which candidate a knob takes over, and whether it starts switched on ---
;; already there -> take it over, start ON
!(test (logicalSubtreeKnob ((mkTree (mkNode m1FoodHere) ())) (mkTree (mkNode m1FoodHere) ()))
       ((mkTree (mkNode m1FoodHere) ()) (mkLSK 3 1)))
;; its NEGATION is there -> take THAT over, start ON.
;; This is the case that keeps an already-evolved condition alive when the
;; program it came from is used as the next starting point. Deciding this by
;; the candidate's head symbol instead would silently discard it.
!(test (logicalSubtreeKnob ((mkTree (mkNode NOT) ((mkTree (mkNode m1FoodHere) ()))))
                           (mkTree (mkNode m1FoodHere) ()))
       ((mkTree (mkNode NOT) ((mkTree (mkNode m1FoodHere) ()))) (mkLSK 3 1)))
;; neither -> a switched-off placeholder
!(test (logicalSubtreeKnob () (mkTree (mkNode m1FoodHere) ()))
       ((mkNullVex ((mkTree (mkNode m1FoodHere) ()))) (mkLSK 3 0)))

;; --- what gets offered at a boolean node ------------------------------------
;; every label, plus pairs built with the OPPOSITE operator. The pairs are
;; where nesting comes from.
;; NOTE the labels come from (primsOfType Bool), not written out by hand: a
;; hand-written (m1FoodHere m1FoodAhead) is a two-element term headed by a live
;; operator, i.e. a CALL, and would quietly evaluate to nothing.
!(test (logicalPerms AND (primsOfType Bool))
       ((mkTree (mkNode m1FoodHere) ())
        (mkTree (mkNode m1FoodAhead) ())
        (mkTree (mkNode OR) ((mkTree (mkNode NOT) ((mkTree (mkNode m1FoodHere) ())))
                             (mkTree (mkNode m1FoodAhead) ())))
        (mkTree (mkNode OR) ((mkTree (mkNode m1FoodHere) ())
                             (mkTree (mkNode m1FoodAhead) ())))))
;; inside an OR the pairs are ANDs -- the alternation
!(test (nodeSymOf (index-atom (logicalPerms OR (primsOfType Bool)) 2)) AND)

;; --- the representation as a whole ------------------------------------------
!(test (knobCountOf (m1Rep)) 15)
!(test (multsOf (m1Rep))     (3 3 3 3 3 3 3 3 3 3 3 3 3 2 2))
!(test (kindAt (m1Rep) 0)  ASK)     ;; the appended growth slot
!(test (kindAt (m1Rep) 1)  LSK)     ;; boolean knobs
!(test (kindAt (m1Rep) 13) ASK)     ;; the two branches
!(test (kindAt (m1Rep) 14) ASK)

;; ONE counter hands out every index, boolean and action alike. With two
;; counters the indices collide and decode silently reads the wrong setting.
!(test (idxOfIn (multsOf (m1Rep)) 2) 13)

;; --- the starting point is preserved ----------------------------------------
;; The whole point of a starting program is to be where the search starts.
!(test (defaultInstance (m1Rep)) (0 1 0 0 0 1 0 0 0 0 0 0 0 1 1))
!(test (showTree (candidateOf (m1Rep) (defaultInstance (m1Rep))))
       (and_seq ((action_bool_if ((AND ((OR (m1FoodHere)))) m1Step m1Grab)))))
!(test (m1Score (m1Rep) (defaultInstance (m1Rep))) -25)

;; ...including when the starting condition is COMPOUND rather than a single
;; perception. This is the case the containment rule above exists for; it is
;; also exactly what happens when an evolved program is fed back in.
(= (compoundExemplar)
   (mkTree (mkNode and_seq)
     ((mkTree (mkNode action_bool_if)
        ((mkTree (mkNode NOT) ((mkTree (mkNode m1FoodHere) ())))
         (mkTree (mkNode m1Step) ())
         (mkTree (mkNode m1Grab) ()))))))
(= (cRep) (buildRep (compoundExemplar)))

!(test (showTree (candidateOf (cRep) (defaultInstance (cRep))))
       (and_seq ((action_bool_if ((AND ((OR ((NOT (m1FoodHere)))))) m1Step m1Grab)))))
;; and it behaves identically to the program it came from
!(test (m1Score (cRep) (defaultInstance (cRep))) 10)
!(test (m1ScoreExp (compileTree (compoundExemplar))) 10)

;; --- nesting is genuinely reachable -----------------------------------------
;; Switching on one pair-candidate puts an OR inside the AND -- structure that
;; could not be reached by turning single literals on and off.
!(test (showTree (candidateOf (m1Rep) (0 1 0 1 0 1 0 0 0 0 0 0 0 1 1)))
       (and_seq ((action_bool_if ((AND ((OR (m1FoodHere))
                                        (OR ((NOT (m1FoodHere)) m1FoodAhead))))
                                  m1Step m1Grab)))))
