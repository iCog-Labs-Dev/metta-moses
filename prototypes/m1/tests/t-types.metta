;; ============================================================================
;; tests/t-types.metta -- the questions the builder asks instead of naming
;; operators. Change a declaration and the builder changes behaviour; that
;; cascade is what shows these are wired in rather than decorative.
;; ============================================================================

!(test (argTypeOf action_bool_if) (Bool Act Act))
!(test (argTypeOf and_seq)        (Seq Act))
!(test (argTypeOf m1Grab)         Params)
!(test (retTypeOf action_bool_if) Act)
!(test (retTypeOf m1FoodHere)     Bool)

!(test (slotType action_bool_if 0) Bool)
!(test (slotType action_bool_if 1) Act)
!(test (slotType action_bool_if 2) Act)
!(test (slotType and_seq 0) Act)
!(test (slotType and_seq 7) Act)      ;; any number of children -- same answer
!(test (slotType AND 0)     Bool)     ;; from the fallback: AND cannot be declared
!(test (slotType AND 5)     Bool)

!(test (isPrimitive m1Grab)         True)
!(test (isPrimitive and_seq)        False)
!(test (isPrimitive action_bool_if) False)
!(test (isVariadic and_seq)         True)
!(test (isVariadic action_bool_if)  False)

!(test (isJunctor AND)     True)
!(test (isJunctor OR)      True)
!(test (isJunctor and_seq) False)
!(test (swapAndOr AND) OR)
!(test (swapAndOr OR)  AND)

;; the vocabulary, read straight out of the declarations. Delete a declaration
;; and the corresponding knob stops being built.
!(test (primsOfType Bool) (quote (m1FoodHere m1FoodAhead)))
!(test (primsOfType Act)  (quote (m1Grab m1Step)))

;; ...and the same question asked of the things that take CHILDREN. This is
;; what lets a candidate be an operator with its arguments filled in, rather
;; than only a bare primitive.
;; numGt is here even though the tape world has no numbers: these two read the
;; DECLARATIONS, and numGt is declared in core/types.metta once for every domain.
;; What keeps it harmless is a later filter, not this list -- knobs/perms.metta's
;; isFillable drops an operator whose slots have no vocabulary, so
;; `permittedOpsFor AND Bool` is still (OR NOT) here and no candidate list, knob
;; count or score anywhere moves. tests/t-knobs.metta:72 is what pins that, and
;; it is the test to watch if this one is ever changed again.
!(test (declaredOpsOfType Act)  (quote (action_bool_if and_seq or_seq action_not)))
!(test (declaredOpsOfType Bool) (quote (AND OR NOT numGt)))
!(test (opsOfType Bool) (quote (AND OR NOT numGt)))
!(test (opsOfType Act)  (quote (action_bool_if and_seq or_seq action_not)))

;; A declared operator can no longer be called from a source call site -- only
;; through the evaluator's reduce, which does not consult declarations. This is
;; the entire price of declaring AND/OR/NOT, and it is pinned here so it is a
;; documented property rather than a surprise. The arity checks at the top of
;; t-operators prove the reduce path is unaffected.
!(test (collapse (AND (True True))) ())
!(test (collapse (OR (True False))) ())
;; the same was already true of every other declared operator
!(test (collapse (and_seq () w0)) ())
