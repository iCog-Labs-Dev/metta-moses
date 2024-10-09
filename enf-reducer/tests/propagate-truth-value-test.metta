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

;; Expression for buildTreeWithRoot = (OR (AND A B) (OR A C))
;; Expected tree node structure = (TreeNode (Value Nil False ROOT) Nil (Cons NilNode (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value A True LITERAL) Nil Nil) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil))) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value A True LITERAL) Nil Nil) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil))) Nil))) Nil)))

;; input expression: (OR (AND A B) (OR A C))
;; Output expression: (OR (AND A B) (OR A C))

;; Test 02

;; input expression: (AND A B)
;; output expression: (AND A B)

;; Test 03

;; input expression: (NOT A)
;; output expression: (NOT A)

;; Test 04

;; input expression: (OR A (AND B C))
;; output expression: (OR A (AND B C))

;; Test 05

;; input expression: (NOT (OR A (AND B C)))
;; output expression: (AND (NOT A) (OR (NOT B) (NOT C)))

;; Test 06

;; input expression: (NOT (AND A (OR B C)))
;; output expression: (OR (NOT A) (AND (NOT B) (NOT C)))

;; Test 7

;; input expression: (AND A (NOT (OR B (AND C D))))
;; output expression: (AND A (AND (NOT B) (OR (NOT C) (NOT D))))

;; Test 8

;; input expression: (NOT (AND A (NOT (OR B (AND C D)))))
;; output expression: (OR (NOT A) (OR B (AND C D)))

;; Test 9
;; input expression: (AND A (OR B (AND C D)))
;; output expression: (AND A (OR B (AND C D)))

;; Test 10

;; input expression: (NOT (NOT (NOT (AND A (AND B (AND C D))))))
;; output expression: (OR (NOT A) (OR (NOT B) (OR (NOT C) (NOT D))))

;; Test 11
;; input expression: (NOT (NOT (NOT (OR A (AND B (OR C D))))))
;; output expression: (AND (NOT A) (OR (NOT B) (AND (NOT C) (NOT D))))

;; Test 12

;; input expression: (NOT (NOT (NOT (NOT (AND A (AND B (AND C D)))))))
;; output expression: (AND A (AND B (AND C D)))

;; Test 13

;; input expression: (NOT (NOT (NOT (NOT (OR A (AND B (OR C D)))))))
;; output expression: (OR A (AND B (OR C D)))

;; Test 14

;; input expression: (NOT (AND (AND I (AND J (NOT (OR K (OR L M))))) (AND B (NOT (AND C (OR D (OR E (NOT (OR F (AND G H))))))))))
;; output expression: (OR (OR (NOT I) (OR (NOT J) (OR K (OR L M)))) (OR (NOT B) (AND C (OR D (OR E (AND (NOT F) (OR (NOT G) (NOT H))))))))

;; Test 15

;; input expression: (NOT (OR (OR I (OR J (AND K (AND L M)))) (OR B (OR C (AND D (AND E (AND F (AND G H))))))))
;; output expression: (AND (AND (NOT I) (AND (NOT J) (OR (NOT K) (OR (NOT L) (NOT M))))) (AND (NOT B) (AND (NOT C) (OR (NOT D) (OR (NOT E) (OR (NOT F) (OR (NOT G) (NOT H))))))))

;; Test 16

;; input expression: (NOT (OR (OR (OR C D) B) A))
;; output expression: (AND (AND (AND (NOT C) (NOT D)) (NOT B)) (NOT A))

;; Test 17

;; input expression: (OR (AND (AND C D) B) (NOT A))
;; output expression: (OR (AND (AND C D) B) (NOT A))

;; !(propagateTruthValue (buildTreeWithRoot (NOT (AND (AND I (AND J (NOT (OR K (OR L M))))) (AND B (NOT (AND C (OR D (OR E (NOT (OR F (AND G H))))))))))) True)
