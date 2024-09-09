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

!(assertEqual 
   (propagateTruthValue (buildTreeWithRoot (OR (AND A B) (OR A C))) True) 
   (TreeNode (Value Nil False ROOT) Nil (Cons NilNode (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value A True LITERAL) Nil Nil) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil))) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value A True LITERAL) Nil Nil) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil))) Nil))) Nil)))
 )

;; Test 02

;; Expression for buildTreeWithRoot = (AND A B)

!(assertEqual 
   (propagateTruthValue (buildTreeWithRoot (AND A B) ) True)
   (TreeNode (Value Nil False ROOT) Nil (Cons NilNode (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value A True LITERAL) Nil Nil) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil))) Nil)))
 )

;; Test 03

;; Expression for buildTreeWithRoot = (NOT A)
!(assertEqual 
   (propagateTruthValue (buildTreeWithRoot (NOT A)) True)
   (TreeNode (Value Nil False ROOT) Nil (Cons NilNode (Cons (TreeNode (Value A False LITERAL) Nil Nil) Nil)))
 )

;; Test 04

!(assertEqual
   (propagateTruthValue (buildTree (OR a (AND b c))) True) 
   (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value a True LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value b True LITERAL) Nil Nil) (Cons (TreeNode (Value c True LITERAL) Nil Nil) Nil))) Nil)))
 )

;; Test 05

!(assertEqual
   (propagateTruthValue (buildTreeWithRoot (OR a (AND b c))) True)
   (TreeNode (Value Nil False ROOT) Nil (Cons NilNode (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value a True LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value b True LITERAL) Nil Nil) (Cons (TreeNode (Value c True LITERAL) Nil Nil) Nil))) Nil))) Nil)))
 )

;; Test 06

!(assertEqual
   (propagateTruthValue (buildTreeWithRoot (OR a (AND b c))) False)
   (TreeNode (Value Nil False ROOT) Nil (Cons NilNode (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value a False LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value b False LITERAL) Nil Nil) (Cons (TreeNode (Value c False LITERAL) Nil Nil) Nil))) Nil))) Nil)))
 )
 
;; Test 07

!(assertEqual
    (propagateTruthValue (buildTreeWithRoot (NOT (OR a (AND b c)))) False)
    (TreeNode (Value Nil False ROOT) Nil (Cons NilNode (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value a True LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value b True LITERAL) Nil Nil) (Cons (TreeNode (Value c True LITERAL) Nil Nil) Nil))) Nil))) Nil)))
 )

;; Test 08

!(assertEqual
    (propagateTruthValue (buildTreeWithRoot (NOT (OR a (AND b c)))) True)
    (TreeNode (Value Nil False ROOT) Nil (Cons NilNode (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value a False LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value b False LITERAL) Nil Nil) (Cons (TreeNode (Value c False LITERAL) Nil Nil) Nil))) Nil))) Nil)))
)

;; Test 09

!(assertEqual
    (propagateTruthValue (buildTreeWithRoot (AND a (OR b c))) False)
    (TreeNode (Value Nil False ROOT) Nil (Cons NilNode (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value a False LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value b False LITERAL) Nil Nil) (Cons (TreeNode (Value c False LITERAL) Nil Nil) Nil))) Nil))) Nil)))
)

;; Test 10

!(assertEqual
    (propagateTruthValue (buildTreeWithRoot (AND a (OR b c))) True)
    (TreeNode (Value Nil False ROOT) Nil (Cons NilNode (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value a True LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value b True LITERAL) Nil Nil) (Cons (TreeNode (Value c True LITERAL) Nil Nil) Nil))) Nil))) Nil)))
)

;; Test 11

!(assertEqual
    (propagateTruthValue (buildTreeWithRoot (NOT (AND a (OR b c)))) True)
    (TreeNode (Value Nil False ROOT) Nil (Cons NilNode (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value a False LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value b False LITERAL) Nil Nil) (Cons (TreeNode (Value c False LITERAL) Nil Nil) Nil))) Nil))) Nil)))
)

;; Test 12

!(assertEqual
    (propagateTruthValue (buildTreeWithRoot (NOT (AND a (OR b c)))) False)
    (TreeNode (Value Nil False ROOT) Nil (Cons NilNode (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value a True LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value b True LITERAL) Nil Nil) (Cons (TreeNode (Value c True LITERAL) Nil Nil) Nil))) Nil))) Nil)))
)
