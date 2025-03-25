! (register-module! ../../../../metta-moses)

! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:gather-junctors)

;; Test 01
!(assertEqual
    (gatherJunctors (OR A B) ())
    (OR A B)
)

;; Test 02
!(assertEqual
    (gatherJunctors (OR A (OR B (OR C D))) ())
    (OR A B C D)
)

;; Test 03
!(assertEqual
    (gatherJunctors (OR (OR (OR C D) B) A) ())
    (OR C D B A)
)

;; Test 04
!(assertEqual
    (gatherJunctors (OR (OR B (OR C D)) A) ())
    (OR B C D A)
)

;; Test 05
!(assertEqual
    (gatherJunctors (AND A (AND B (AND C D))) ())
    (AND A B C D)
)

;; Test 06
!(assertEqual
    (gatherJunctors (AND (AND (AND C D) B) A) ())
    (AND C D B A)
)

;; Test 07
!(assertEqual
    (gatherJunctors (AND (AND B (AND C D)) A) ())
    (AND B C D A)
)

;; Test 08
!(assertEqual
    (gatherJunctors (AND A (AND B (OR C (OR D (AND E (AND F G)))))) ())
    (AND A B (OR C D (AND E F G)))
)

;; Test 09
!(assertEqual
    (gatherJunctors (AND A (OR B (OR C (AND D (OR E F))))) ())
    (AND A (OR B C (AND D (OR E F))))
)

;; Test 10
!(assertEqual
    (gatherJunctors (OR A (OR B (AND C (AND D (OR E (OR F G)))))) ())
    (OR A B (AND C D (OR E F G)))
)

;; Test 11
!(assertEqual
    (gatherJunctors (OR A (AND B (AND C (OR D (AND E F))))) ())
    (OR A (AND B C (OR D (AND E F))))
)

;; Test 12
!(assertEqual
    (gatherJunctors (AND A (AND B (AND C (OR D (OR E (OR F (AND G H))))))) ())
    (AND A B C (OR D E F (AND G H)))
)

;; Test 13
!(assertEqual
    (gatherJunctors (AND (AND I (AND J (OR K (OR L M)))) (AND B (AND C (OR D (OR E (OR F (AND G H))))))) ())
    (AND I J (OR K L M) B C (OR D E F (AND G H)))
)

;; Test 14
!(assertEqual
    (gatherJunctors (OR (OR I (OR J (AND K (AND L M)))) (OR B (OR C (AND D (AND E (AND F (AND G H))))))) ())
    (OR I J (AND K L M) B C (AND D E F G H))
)

;; Test 15
!(assertEqual
    (gatherJunctors (AND (AND B (AND (OR D (OR E (OR (AND G H) F))) C)) A) ())
    (AND B (OR D E (AND G H) F) C A)
)

;; Test 16
! (assertEqual (gatherJunctors (OR (NOT A) B) ())
                 (OR (NOT A) B))

;; Test 17 
! (assertEqual (gatherJunctors (OR (NOT A) (OR B (OR (NOT C) D))) ())
                  (OR (NOT A) B (NOT C) D) )
;; Test 18
! (assertEqual (gatherJunctors (AND (OR (OR C D) (NOT B)) (NOT A)) ())
                 (AND (OR C D (NOT B)) (NOT A)))

;; Test 19
! (assertEqual (gatherJunctors (AND (AND (OR C (NOT D)) (NOT B)) A) ())
                 (AND (OR C (NOT D)) (NOT B) A))

;; Test 20
! (assertEqual (gatherJunctors (AND (NOT A) (AND B (OR C (OR (NOT D) (AND E (AND F (NOT G))))))) ())
                 (AND (NOT A) B (OR C (NOT D) (AND E F (NOT G)))) )
