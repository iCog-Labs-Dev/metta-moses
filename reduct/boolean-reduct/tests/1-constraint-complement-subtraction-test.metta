! (register-module! ../../../../metta-moses) 

! (import! &self metta-moses:reduct:boolean-reduct:rte-helpers)
! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:1-constraint-complement-subtraction)



;; Test 01
!(assertEqual 
    (oneCcSub (OR (AND D) (AND B C)) (AND B C) ((NOT B) C))
    (OR (AND D) (AND C))
)

;; Test 02
! (assertEqual 
    (oneCcSub (AND (AND D C) (NOT B) A (AND B C)) (AND B C) ((NOT B) C))
    (AND (AND D C) (NOT B) A (AND C))
)
;; Test 03
! (assertEqual 
    (oneCcSub (OR (AND (NOT A) C) (OR A B (AND B C))) (AND (NOT A) C) (A B C))
    (OR (AND C) (OR A B (AND B C)))
)

;; No reduction

;; Test 04
! (assertEqual 
    (oneCcSub (AND (AND D C) (NOT B) A (AND B C)) (AND A C) ((NOT B) C))
    (AND (AND D C) (NOT B) A (AND B C))
)

;; Test 05
! (assertEqual 
    (oneCcSub (OR (AND (NOT A) C) (AND A B (AND B C))) (AND (NOT A) C) ((NOT A) B C))
    (OR (AND (NOT A) C) (AND A B (AND B C)))
)
