! (register-module! ../../../metta-moses-reduction)
! (import! &self metta-moses-reduction:types) 
! (import! &self metta-moses-reduction:utilities:list-helpers)
! (import! &self metta-moses-reduction:utilities:tree-helpers)
! (import! &self metta-moses-reduction:enf-reducer:rte-helpers)
! (import! &self metta-moses-reduction:enf-reducer:propagate-truth-value)
! (import! &self metta-moses-reduction:enf-reducer:reduce-to-elegance)

! (import! &self metta-moses-reduction:enf-reducer:post-processing)
! (import! &self metta-moses-reduction:enf-reducer:reduct)
! (import! &self metta-moses-reduction:enf-reducer:gather-junctors)

;; Test 01

;; input expression: (OR A B)
;; output expression: (OR A B)

;; Test 02

;; input expression: (OR A (OR B (OR C D)))
;; output expression: (OR A B C D)

;; Test 03

;; input expression: (OR (OR (OR C D) B) A)
;; output expression: (OR C D B A) | (OR A B C D). The order doesn't matter.

;; Test 04

;; input expression: (OR (OR B (OR C D)) A)
;; output expression: (OR B C D A) | (OR A B C D). The order doesn't matter.

;; Test 05

;; input expression: (AND A (AND B (AND C D)))
;; output expression: (AND A B C D)

;; Test 06

;; input expression: (AND (AND (AND C D) B) A)
;; output expression: (AND C D B A) | (AND A B C D). The order doesn't matter.

;; Test 07

;; input expression: (AND (AND B (AND C D)) A)
;; output expression: (AND B C D A) | (AND A B C D). The order doesn't matter.

;; Test 08

;; input expression: (AND A (AND B (OR C (OR D (AND E (AND F G))))))
;; output expression: (AND A B (OR C D (AND E F G)))

;; Test 09

;; input expression: (AND A (OR B (OR C (AND D (OR E F)))))
;; output expression: (AND A (OR B C (AND D (OR E F))))

;; Test 10

;; input expression: (OR A (OR B (AND C (AND D (OR E (OR F G))))))
;; output expression: (OR A B (AND C D (OR E F G)))

;; Test 11

;; input expression: (OR A (AND B (AND C (OR D (AND E F)))))
;; output expression: (OR A (AND B C (OR D (AND E F))))

;; Test 12

;; input expression: (AND A (AND B (AND C (OR D (OR E (OR F (AND G H)))))))
;; output expression: (AND A B C (OR D E F (AND G H)))

;; Test 13

;; input expression: (AND (AND I (AND J (OR K (OR L M)))) (AND B (AND C (OR D (OR E (OR F (AND G H)))))))
;; output expression: (AND I J (OR K L M) B C (OR D E F (AND G H))) | (AND B C I J (OR D E F (AND G H)) (OR K L M)). The order doesn't matter.

;; Test 14

;; input expression: (OR (OR I (OR J (AND K (AND L M)))) (OR B (OR C (AND D (AND E (AND F (AND G H)))))))
;; output expression: (OR I J (AND K L M) B C (AND D E F G H)) | (OR B C I J (AND D E F G H) (AND K L M)). The order doesn't matter.

;; Test 15

;; input expression: (AND (AND B (AND (OR D (OR E (OR (AND G H) F))) C)) A)
;; output expression: (AND B (OR D E (AND G H) F) C A) | (AND A B C (OR D E F (AND G H)))
