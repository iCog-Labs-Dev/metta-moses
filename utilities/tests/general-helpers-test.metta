! (register-module! ../../../metta-moses)

! (import! &self metta-moses:utilities:general-helpers)

; Test 01 -- selectByIndex

! (assertEqual (selectByIndex (0 1 2 3 4) 2) 2)
! (assertEqual (selectByIndex (0 1 2 3 4) 3) 3)
! (assertEqual (selectByIndex (0 1 2 3 4) 5) (Error (Index out of range) ()))

;; Test 03 -- unNest

! (assertEqual (collapse (unNest (AND A (AND B C)))) (AND A AND B C))
! (assertEqual (collapse (unNest (1 2 (3 4 (5))))) (1 2 3 4 5))

;; Test 06 -- cleanSpace

! (bind! &__ (new-space))

! (add-reduct &__ (superpose ((A B C) atom 2 4 (2 1))))

! (assertEqual 
        (let () (cleanSpace &__) 
            (collapse (get-atoms &__))) (empty))

;; Test 07 -- repeat

! (assertEqual (repeat 5 4) (5 5 5 5))
! (assertEqual (repeat 1 3) (1 1 1))

;; Test 08 -- update-atom
! (add-atom &__ (A 2 3))
! (let () (collapse (update-atom  &__ (A 2 3) (A 3 4))) (assertEqual (match &__ $x $x) (A 3 4)))
