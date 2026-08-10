;; ============================================================================
;; tests/t-knobs.metta -- building the space of programs.
;;
;; Programs are written out in the form the evaluator actually receives --
;; (op (children)), leaves included as (op ()) -- because that is the only form
;; the prototype renders. There is no prettier printing to compare against.
;;
;; `quote` on the expected side is not decoration. A written-out program is a
;; tuple headed by a live operator, so without it the expected value is CALLED,
;; produces no answer, and the check quietly does not run at all -- it neither
;; passes nor fails, it simply never prints. Anything inert (mkTree, mkLSK, a
;; type name, a number) needs no quote.
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


;; ============================================================================
;; What gets OFFERED at a position: primitives, plus operators with every
;; argument filled.
;; ============================================================================

;; --- filling an operator ----------------------------------------------------
;; A slot is filled from the things that produce the type that slot asks for.
!(test (slotTypesOf action_bool_if) (Bool Act Act))
!(test (slotTypesOf and_seq)        (Act Act))    ;; any-number-of -> sample two
!(test (map-atom (fillersOfType Act) $f (preOrderExp $f))
       (quote ((m1Grab ()) (m1Step ()))))
;; a test slot offers both polarities: there is no knob INSIDE a candidate to
;; flip one later
!(test (map-atom (fillersOfType Bool) $f (preOrderExp $f))
       (quote ((m1FoodHere ()) (m1FoodAhead ())
               (NOT ((m1FoodHere ()))) (NOT ((m1FoodAhead ()))))))

;; the odometer over those vocabularies -- last slot turns fastest
!(test (map-atom (fillAt (vocabsOf action_bool_if) 1) $f (preOrderExp $f))
       (quote ((m1FoodHere ()) (m1Grab ()) (m1Step ()))))
!(test (map-atom (fillAt (vocabsOf action_bool_if) 0) $f (preOrderExp $f))
       (quote ((m1FoodHere ()) (m1Grab ()) (m1Grab ()))))
;; ...and that one is thrown away, because two slots hold the same thing
!(test (usableFilling action_bool_if (fillAt (vocabsOf action_bool_if) 0)) False)
!(test (usableFilling action_bool_if (fillAt (vocabsOf action_bool_if) 1)) True)
;; same test, same base, opposite polarity: (OR p (NOT p)) is always true
!(test (usableFilling OR ((mkTree (mkNode m1FoodHere) ())
                          (mkTree (mkNode NOT) ((mkTree (mkNode m1FoodHere) ())))))
       False)
;; and an argument is never headed by the operator it sits under, which is what
;; keeps (NOT (NOT p)) from being offered as though it were something new
!(test (usableFilling NOT ((mkTree (mkNode NOT) ((mkTree (mkNode m1FoodHere) ())))))
       False)
!(test (usableFilling NOT ((mkTree (mkNode m1FoodHere) ()))) True)

;; --- the candidates for a test position -------------------------------------
;; Every perception, plus operators over them. The AND/OR alternation is not a
;; special case: a candidate is simply never headed by the operator it will sit
;; under, so inside an AND the pairs are ORs. NOT is offered too -- negation
;; being available as a knob SETTING does not make a negated CANDIDATE
;; redundant, and the production tree offers both as well.
!(test (permittedOpsFor AND Bool) (quote (OR NOT)))
!(test (permittedOpsFor OR  Bool) (quote (AND NOT)))
!(test (map-atom (sampleLogicalPerms AND) $p (preOrderExp $p))
       (quote ((m1FoodHere ())
               (m1FoodAhead ())
               (NOT ((m1FoodHere ())))
               (OR  ((m1FoodHere ()) (m1FoodAhead ())))
               (NOT ((m1FoodAhead ())))
               (OR  ((m1FoodHere ()) (NOT ((m1FoodAhead ())))))
               (OR  ((m1FoodAhead ()) (m1FoodHere ())))
               (OR  ((m1FoodAhead ()) (NOT ((m1FoodHere ()))))))))
;; inside an OR the pairs are ANDs
!(test (nodeSymOf (index-atom (sampleLogicalPerms OR) 3)) AND)

;; --- the candidates for an action position ----------------------------------
;; Same machinery, different type -- and this is what lets a CONDITIONAL appear
;; in a program that did not have one. Note it arrives complete, condition and
;; both branches filled: a half-built operator is never a candidate.
!(test (permittedOpsFor and_seq Act) (quote (action_bool_if or_seq action_not)))
!(test (map-atom (samplePerms and_seq Act) $p (preOrderExp $p))
       (quote ((m1Grab ())
               (m1Step ())
               (action_not ((m1Grab ())))
               (action_bool_if ((m1FoodHere ()) (m1Grab ()) (m1Step ())))
               (or_seq ((m1Grab ()) (m1Step ())))
               (action_not ((m1Step ())))
               (action_bool_if ((m1FoodHere ()) (m1Step ()) (m1Grab ())))
               (or_seq ((m1Step ()) (m1Grab ()))))))

;; --- one candidate is one knob ----------------------------------------------
;; The rule that makes the whole thing work: a knob's settings are the ways ONE
;; candidate can be handled, never a menu of candidates. Eight candidates at the
;; growth position means eight knobs of two settings each -- so several can be
;; switched on at once. Were it one knob of nine settings, the sequence could
;; never hold more than one new child.
(= (emptyProgram) (mkTree (mkNode and_seq) ()))
(= (eRep) (buildKnobs (emptyProgram)))
!(test (size-atom (samplePerms and_seq Act)) 8)
!(test (knobCountOf (eRep)) 8)
!(test (knobMultiplicities (eRep)) (2 2 2 2 2 2 2 2))
;; two of them on at once -- the thing a single wide knob could not express
!(test (preOrderExp (getCandidate (eRep) (1 1 0 0 0 0 0 0)))
       (quote (and_seq ((m1Grab ()) (m1Step ())))))
!(test (m1Score (eRep) (1 1 0 0 0 0 0 0)) 2)


;; ============================================================================
;; The representation as a whole.
;; ============================================================================
;; 8 growth knobs of 2, then 24 test knobs of 3, then the conditional's two
;; branches at 2. ONE counter hands out every index, boolean and action alike:
;; with two counters the indices collide and decode silently reads the wrong
;; setting.
!(test (knobCountOf (m1Rep)) 34)
!(test (knobMultiplicities (m1Rep))
       (2 2 2 2 2 2 2 2 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 2 2))
!(test (kindAt (m1Rep) 0)  ASK)     ;; the growth candidates
!(test (kindAt (m1Rep) 8)  LSK)     ;; test knobs
!(test (kindAt (m1Rep) 32) ASK)     ;; the two branches
!(test (kindAt (m1Rep) 33) ASK)

;; --- the starting point is preserved ----------------------------------------
;; The whole point of a starting program is to be where the search starts.
!(test (exemplarInst (m1Rep))
       (0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1))
!(test (preOrderExp (getCandidate (m1Rep) (exemplarInst (m1Rep))))
       (quote (and_seq ((action_bool_if ((AND ((OR ((m1FoodHere ())))))
                                         (m1Step ()) (m1Grab ())))))))
!(test (m1Score (m1Rep) (exemplarInst (m1Rep))) -25)

;; ...including when the starting condition is COMPOUND rather than a single
;; perception. This is the case the containment rule above exists for; it is
;; also exactly what happens when an evolved program is fed back in.
(= (compoundExemplar)
   (mkTree (mkNode and_seq)
     ((mkTree (mkNode action_bool_if)
        ((mkTree (mkNode NOT) ((mkTree (mkNode m1FoodHere) ())))
         (mkTree (mkNode m1Step) ())
         (mkTree (mkNode m1Grab) ()))))))
(= (cRep) (buildKnobs (compoundExemplar)))

!(test (preOrderExp (getCandidate (cRep) (exemplarInst (cRep))))
       (quote (and_seq ((action_bool_if ((AND ((OR ((NOT ((m1FoodHere ())))))))
                                         (m1Step ()) (m1Grab ())))))))
;; and it behaves identically to the program it came from
!(test (m1Score (cRep) (exemplarInst (cRep))) 10)
!(test (m1ScoreExp (preOrderExp (compoundExemplar))) 10)

;; --- nesting is genuinely reachable -----------------------------------------
;; Switching on one pair-candidate puts an OR inside the AND -- structure that
;; could not be reached by turning single perceptions on and off. Knob 11 is the
;; fourth candidate offered at the AND position.
!(test (preOrderExp (getCandidate (m1Rep) (changeAt (exemplarInst (m1Rep)) 11 1)))
       (quote (and_seq ((action_bool_if ((AND ((OR ((m1FoodHere ())))
                                                (OR ((m1FoodHere ()) (m1FoodAhead ())))))
                                         (m1Step ()) (m1Grab ())))))))
