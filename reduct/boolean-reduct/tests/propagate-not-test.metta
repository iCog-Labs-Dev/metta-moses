! (register-module! ../../../../metta-moses)

! (import! &self metta-moses:reduct:boolean-reduct:propagate-not)

;; Test 01
!(assertEqual
    (propagateNot (OR (AND A B) (OR A C)))
    (OR (AND A B) (OR A C))
)

;; Test 02
!(assertEqual
    (propagateNot (AND A B))
    (AND A B)
)

;; Test 03
!(assertEqual
    (propagateNot (NOT A))
    (NOT A)
)

;; Test 04
!(assertEqual
    (propagateNot (OR A (AND B C)))
    (OR A (AND B C))
)

;; Test 05
!(assertEqual
    (propagateNot (NOT (OR A (AND B C))))
    (AND (NOT A) (OR (NOT B) (NOT C)))
)

;; Test 06
!(assertEqual
    (propagateNot (NOT (AND A (OR B C))))
    (OR (NOT A) (AND (NOT B) (NOT C)))
)

;; Test 07
!(assertEqual
    (propagateNot (AND A (NOT (OR B (AND C D)))))
    (AND A (AND (NOT B) (OR (NOT C) (NOT D))))
)

;; Test 08
!(assertEqual
    (propagateNot (NOT (AND A (NOT (OR B (AND C D))))))
    (OR (NOT A) (OR B (AND C D)))
)

;; Test 09
!(assertEqual
    (propagateNot (AND A (OR B (AND C D))))
    (AND A (OR B (AND C D)))
)

;; Test 10
!(assertEqual
    (propagateNot (NOT (NOT (NOT (AND A (AND B (AND C D)))))))
    (OR (NOT A) (OR (NOT B) (OR (NOT C) (NOT D))))
)

;; Test 11
!(assertEqual
    (propagateNot (NOT (NOT (NOT (OR A (AND B (OR C D)))))))
    (AND (NOT A) (OR (NOT B) (AND (NOT C) (NOT D))))
)

;; Test 12
!(assertEqual
    (propagateNot (NOT (NOT (NOT (NOT (AND A (AND B (AND C D))))))))
    (AND A (AND B (AND C D)))
)

;; Test 13
!(assertEqual
    (propagateNot (NOT (NOT (NOT (NOT (OR A (AND B (OR C D))))))))
    (OR A (AND B (OR C D)))
)

;; Test 14
!(assertEqual
    (propagateNot (NOT (AND (AND I (AND J (NOT (OR K (OR L M))))) (AND B (NOT (AND C (OR D (OR E (NOT (OR F (AND G H)))))))))))
    (OR (OR (NOT I) (OR (NOT J) (OR K (OR L M)))) (OR (NOT B) (AND C (OR D (OR E (AND (NOT F) (OR (NOT G) (NOT H))))))))
)

;; Test 15
!(assertEqual
    (propagateNot (NOT (OR (OR I (OR J (AND K (AND L M)))) (OR B (OR C (AND D (AND E (AND F (AND G H)))))))))
    (AND (AND (NOT I) (AND (NOT J) (OR (NOT K) (OR (NOT L) (NOT M))))) (AND (NOT B) (AND (NOT C) (OR (NOT D) (OR (NOT E) (OR (NOT F) (OR (NOT G) (NOT H))))))))
)

;; Test 16
!(assertEqual
    (propagateNot (NOT (OR (OR (OR C D) B) A)))
    (AND (AND (AND (NOT C) (NOT D)) (NOT B)) (NOT A))
)

;; Test 17
!(assertEqual
    (propagateNot (OR (AND (AND C D) B) (NOT A)))
    (OR (AND (AND C D) B) (NOT A))
)
