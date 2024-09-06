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
;; Expression for buildTreeWithRoot = (OR A B)
!(assertEqual 
   (gatherJunctors (buildTreeWithRoot (OR A B)) NilNode)
   (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value B False LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value A False LITERAL) Nil Nil) Nil) Nil) Nil))) Nil))
 )

;; Test 02
;; Expression for buildTreeWithRoot = (AND (OR A B) C) 

!(assertEqual 
   (gatherJunctors (buildTreeWithRoot (AND (OR A B) C) ) NilNode)
   (TreeNode (Value Nil False AND) (Cons (TreeNode (Value C False LITERAL) Nil Nil) Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value B False LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value A False LITERAL) Nil Nil) Nil) Nil) Nil))) Nil))
 )

;; Test 03
;; Expression for buildTreeWithRoot = (AND (AND A B) (OR C D))
!(assertEqual 
   (gatherJunctors (buildTreeWithRoot (AND (AND A B) (OR C D))) NilNode)
   (TreeNode (Value Nil False AND) (Cons (TreeNode (Value B False LITERAL) Nil Nil) (Cons (TreeNode (Value A False LITERAL) Nil Nil) Nil)) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value D False LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value C False LITERAL) Nil Nil) Nil) Nil) Nil))) Nil))
 )

;; Test 04
!(assertEqual
   (gatherJunctors (buildTreeWithRoot (AND A (AND B (AND C (OR D E))))) NilNode)
   (TreeNode (Value Nil False AND) (Cons (TreeNode (Value C False LITERAL) Nil Nil) (Cons (TreeNode (Value B False LITERAL) Nil Nil) (Cons (TreeNode (Value A False LITERAL) Nil Nil) Nil))) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value E False LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value D False LITERAL) Nil Nil) Nil) Nil) Nil))) Nil))
)

;; Test 05
!(assertEqual
   (gatherJunctors (buildTreeWithRoot (OR A (OR B (OR C (AND D E))))) NilNode)
   (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value E False LITERAL) Nil Nil) (Cons (TreeNode (Value D False LITERAL) Nil Nil) Nil)) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value C False LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value B False LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value A False LITERAL) Nil Nil) Nil) Nil) Nil))))) Nil))
)

;; Test 06
!(assertEqual
   (gatherJunctors (buildTreeWithRoot (OR A (OR B (AND C (AND D (OR E F)))))) NilNode)
   (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value D False LITERAL) Nil Nil) (Cons (TreeNode (Value C False LITERAL) Nil Nil) Nil)) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value F False LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value E False LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value B False LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value A False LITERAL) Nil Nil) Nil) Nil) Nil)))) Nil))
 )

;; Test 07
!(assertEqual
   (gatherJunctors (TreeNode (Value Nil False ROOT) Nil (Cons NilNode (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value A True LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value B True LITERAL) Nil Nil) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil))) Nil))) Nil))) NilNode)
   (TreeNode (Value Nil False AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) (Cons (TreeNode (Value B True LITERAL) Nil Nil) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil))) Nil)
)
