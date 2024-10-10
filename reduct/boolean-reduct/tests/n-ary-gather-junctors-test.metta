 ! (register-module! ../../../../metta-moses)

! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:n-ary-gather-junctors)


;; Test 01
!(assertEqual
    (gatherJunctors (OR A B))
    (OR A B)
)

;; Test 02
!(assertEqual
    (gatherJunctors (OR A F (OR B (OR C D))) )
    (OR A F B C D)
)

;; Test 03
!(assertEqual
    (gatherJunctors (OR (OR (OR C D) B) A (AND F H (AND K L) V)))
    (OR C D B A (AND F H K L V))
)

;; Test 04
!(assertEqual
    (gatherJunctors (OR (OR B K (OR C D J)) A))
    (OR B K C D J A)
)

;; Test 05
!(assertEqual
    (gatherJunctors (AND A F (AND B (AND C D))))
    (AND A F B C D)
)

;; Test 06
!(assertEqual
    (gatherJunctors (AND (OR L U (OR M I J)) (AND (AND C D) B) A))
    (AND (OR L U M I J) C D B A)
)

;; Test 07
!(assertEqual
    (gatherJunctors (AND (AND B (AND C D)) A N))
    (AND B C D A N)
)

;; Test 08
!(assertEqual
    (gatherJunctors (AND A (AND B H (OR C (OR D K (AND E (AND F B G)))))))
    (AND A B H (OR C D K (AND E F B G)))
)

;; Test 09
!(assertEqual
    (gatherJunctors (AND A (OR B (OR C (AND D (OR E F))))))
    (AND A (OR B C (AND D (OR E F))))
)

;; Test 10
!(assertEqual
    (gatherJunctors (OR A (OR B (AND C (AND D (OR E (OR F G)))))))
    (OR A B (AND C D (OR E F G)))
)

;; Test 11
! (assertEqual (gatherJunctors (OR (NOT A) B (NOT B)))
                 (OR (NOT A) B (NOT B)))

;; Test 12
! (assertEqual (gatherJunctors (OR (NOT A) (OR B (NOT C) (OR (NOT C) D))))
                  (OR (NOT A) B (NOT C) (NOT C) D) )
;; Test 13
! (assertEqual (gatherJunctors (AND (OR (OR C D K) (NOT B)) (NOT A)))
                 (AND (OR C D K (NOT B)) (NOT A)))

;; Test 14
! (assertEqual (gatherJunctors (AND (AND (OR C (NOT D)) (NOT B)) A))
                 (AND (OR C (NOT D)) (NOT B) A))

;; Test 15
! (assertEqual (gatherJunctors (AND (NOT A) (AND B (NOT V) (OR C (OR (NOT D) (NOT K) (AND E (AND F (NOT G))))))))
                 (AND (NOT A) B (NOT V) (OR C (NOT D) (NOT K) (AND E F (NOT G)))) )
