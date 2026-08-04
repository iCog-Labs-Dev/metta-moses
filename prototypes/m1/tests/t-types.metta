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
!(test (flipJunctor AND) OR)
!(test (flipJunctor OR)  AND)

;; the vocabulary, read straight out of the declarations. Delete a declaration
;; and the corresponding knob stops being built.
!(test (primsOfType Bool) (m1FoodHere m1FoodAhead))
!(test (primsOfType Act)  (m1Grab m1Step))
