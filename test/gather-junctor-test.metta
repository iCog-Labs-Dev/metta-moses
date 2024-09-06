! (register-module! ../../metta-moses-reduction)
! (import! &self metta-moses-reduction:types) 
! (import! &self metta-moses-reduction:utilities:list-helpers)
! (import! &self metta-moses-reduction:utilities:tree-helpers)
! (import! &self metta-moses-reduction:enf-reducer:rte-helpers)
! (import! &self metta-moses-reduction:enf-reducer:propagate-truth-value)
! (import! &self metta-moses-reduction:enf-reducer:reduce-to-elegance)

! (import! &self metta-moses-reduction:enf-reducer:post-processing)
! (import! &self metta-moses-reduction:enf-reducer:reduct)
! (import! &self metta-moses-reduction:enf-reducer:gather-junctors)

; Test 01

; expression for builtreewithroot = (OR A B)

! (assertEqual (gatherJunctors (buildTreeWithRoot (OR A B)) NilNode) (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value B False LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value A False LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)))

; Test 02

; expression for builtreewithroot = (AND (OR A B) C) 

! (assertEqual (gatherJunctors (buildTreeWithRoot (AND (OR A B) C) ) NilNode) (TreeNode (Value Nil False AND) (Cons (TreeNode (Value C False LITERAL) Nil Nil) Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value B False LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value A False LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)))
; Test 03

; expression for builtreewithroot = (AND (AND A B) (OR C D))
! (assertEqual (gatherJunctors (buildTreeWithRoot (AND (AND A B) (OR C D))) NilNode) (TreeNode (Value Nil False AND) (Cons (TreeNode (Value B False LITERAL) Nil Nil) (Cons (TreeNode (Value A False LITERAL) Nil Nil) Nil)) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value D False LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value C False LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)))
