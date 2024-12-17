! (register-module! ../../../../metta-moses) 

! (import! &self metta-moses:reduct:boolean-reduct:rte-helpers)
! (import! &self metta-moses:utilities:general-helpers)

! (import! &self metta-moses:reduct:boolean-reduct:one-constraint-complement-subtraction)

;; Test 01
!(assertEqual 
    (oneCcSub (OR (AND D) (AND B C)) (AND B C) ((NOT B) C))
    (OR (AND D) (AND C))
)

;; Test 02
!(assertEqual 
    (oneCcSub (AND (AND B A) (AND B (NOT C))) (AND B A) ((NOT B) C))
    (AND (AND A) (AND B (NOT C)))
)

;; Test 03
!(assertEqual 
    (oneCcSub (AND A (AND B A) (NOT D) (AND B (NOT C))) (AND B A) ((NOT B) C))
    (AND A (AND A) (NOT D) (AND B (NOT C)))
)

;; Test 04
! (assertEqual 
    (oneCcSub (AND (AND D C) (NOT B) A (AND B C)) (AND B C) ((NOT B) C))
    (AND (AND D C) (NOT B) A (AND C))
)
;; Test 05
! (assertEqual 
    (oneCcSub (OR (AND (NOT A) C) (OR A B (AND B C))) (AND (NOT A) C) (A B C))
    (OR (AND C) (OR A B (AND B C)))
)

;; No reduction

;; Test 06
! (assertEqual 
    (oneCcSub (AND (AND D C) (NOT B) A (AND B C)) (AND A C) ((NOT B) C))
    (AND (AND D C) (NOT B) A (AND B C))
)

;; Test 07
! (assertEqual 
    (oneCcSub (OR (AND (NOT A) C) (AND A B (AND B C))) (AND (NOT A) C) ((NOT A) B C))
    (OR (AND (NOT A) C) (AND A B (AND B C)))
)

;; Test for helper function ===
! (assertEqual (=== A B) False)
! (assertEqual (=== A A) True)
! (assertEqual (=== () (A)) False)
! (assertEqual (=== (A) () ) False)
! (assertEqual (=== (A B) (A)) False)
! (assertEqual (=== (A B) (A B)) True)
! (assertEqual (=== (B A) (A B)) True)
! (assertEqual (=== (B C D E A) (B C D E A)) True)
! (assertEqual (=== (B C D E A) (C D A E B)) True)
! (assertEqual (=== (B F D E A) (B C D E A)) False)
