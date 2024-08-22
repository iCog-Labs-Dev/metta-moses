! (register-module! ../../metta-moses-reduction)
! (import! &self metta-moses-reduction:types) 
! (import! &self metta-moses-reduction:utilities:list-helpers)
! (import! &self metta-moses-reduction:utilities:tree-helpers)
! (import! &self metta-moses-reduction:enf-reducer:RTEHelpers)
! (import! &self metta-moses-reduction:enf-reducer:propagate_truth_value)
! (import! &self metta-moses-reduction:enf-reducer:reduce_to_elegance)

! (import! &self metta-moses-reduction:enf-reducer:postProcessing)
! (import! &self metta-moses-reduction:enf-reducer:reduct)
! (import! &self metta-moses-reduction:enf-reducer:gather-junctors)

; Test 01

; expression for builtreewithroot = (OR (AND A B) (OR A C))
; Expected tree node structure = (TreeNode (Value Nil False ROOT) Nil (Cons NilNode (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value A True LITERAL) Nil Nil) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil))) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value A True LITERAL) Nil Nil) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil))) Nil))) Nil)))

! (assertEqual (propagateTruthValue (buildTreeWithRoot (OR (AND A B) (OR A C))) True) (TreeNode (Value Nil False ROOT) Nil (Cons NilNode (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value A True LITERAL) Nil Nil) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil))) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value A True LITERAL) Nil Nil) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil))) Nil))) Nil))))

; Test 02

; expression for builtreewithroot = (AND A B)
; ! (propagateTruthValue (buildTreeWithRoot (AND A B) ) True) 

! (assertEqual (propagateTruthValue (buildTreeWithRoot (AND A B) ) True) (TreeNode (Value Nil False ROOT) Nil (Cons NilNode (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value A True LITERAL) Nil Nil) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil))) Nil))))
; Test 03

; expression for builtreewithroot = (NOT A)
; ! (propagateTruthValue (buildTreeWithRoot (NOT A) ) True) 
! (assertEqual (propagateTruthValue (buildTreeWithRoot (NOT A)) True) (TreeNode (Value Nil False ROOT) Nil (Cons NilNode (Cons (TreeNode (Value A False LITERAL) Nil Nil) Nil))))
