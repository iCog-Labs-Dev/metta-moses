! (register-module! ../../metta-moses-reduction)
! (import! &self metta-moses-reduction:utilities:list-helpers)
! (import! &self metta-moses-reduction:utilities:tree-helpers)
! (import! &self metta-moses-reduction:enf-reducer:RTEHelpers)
! (import! &self metta-moses-reduction:enf-reducer:propagate_truth_value)
! (import! &self metta-moses-reduction:enf-reducer:gather-junctors)
! (import! &self metta-moses-reduction:enf-reducer:reduce_to_elegance)
! (import! &self metta-moses-reduction:enf-reducer:postProcessing)

;;!(isTreeWellFormed (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value a False LITERAL) Nil Nil) (Cons (TreeNode (Value b False LITERAL) Nil Nil) Nil))))

;; !(propagateTruthValue (buildTree (OR a (AND b c))) True)
;; !(propagateTruthValue (buildTreeWithRoot (OR a (AND b c))) True)
;; !(propagateTruthValue (buildTreeWithRoot (OR a (AND b c))) False)
;; !(propagateTruthValue (buildTreeWithRoot (NOT (OR a (AND b c)))) False)
;; !(propagateTruthValue (buildTreeWithRoot (NOT (OR a (AND b c)))) True)
;; !(propagateTruthValue (buildTreeWithRoot (AND a (OR b c))) False)
;; !(propagateTruthValue (buildTreeWithRoot (AND a (OR b c))) True)
;; !(propagateTruthValue (buildTreeWithRoot (NOT (AND a (OR b c)))) True)
;; !(propagateTruthValue (buildTreeWithRoot (NOT (AND a (OR b c)))) False)

;; !(gatherJunctors (buildTreeWithRoot (AND A (AND B (AND C (OR D E))))) NilNode)
;; !(gatherJunctors (buildTreeWithRoot (OR A (OR B (OR C (AND D E))))) NilNode)
;; !(gatherJunctors (buildTreeWithRoot (OR A (OR B (AND C (AND D (OR E F)))))) NilNode)

;; !(reduceToElegance (TreeNode (Value Nil False AND) (Cons (TreeNode (Value a True AND) Nil Nil) Nil) (Cons (TreeNode (Value b True AND) Nil Nil) Nil)) Nil Nil)
;; !(reduceToElegance (TreeNode (Value Nil False OR) (Cons (TreeNode (Value a True AND) Nil Nil) Nil) (Cons (TreeNode (Value b True AND) Nil Nil) Nil)) Nil Nil)

; !(postProcessing (TreeNode (Value Nil False AND) (Cons (TreeNode (Value A False LITERAL) Nil Nil) (Cons (TreeNode (Value B False LITERAL) Nil Nil) (Cons (TreeNode (Value C False LITERAL) Nil Nil) Nil))) (Cons (TreeNode (Value Nil True OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value D False LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value E False LITERAL) Nil Nil) (Cons (TreeNode (Value F False LITERAL) Nil Nil) Nil)) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value G False LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value H False LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value E False LITERAL) Nil Nil) (Cons (TreeNode (Value F False LITERAL) Nil Nil) Nil)) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value G False LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value H False LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) Nil)))) Nil)))

; !(postProcessing (TreeNode (Value Nil False AND) (Cons (TreeNode (Value A false LITERAL) Nil Nil) (Cons (TreeNode (Value B false LITERAL) Nil Nil) (Cons (TreeNode (Value C false LITERAL) Nil Nil) Nil))) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value A False AND) (Cons (TreeNode (Value A false LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value A false LITERAL) Nil Nil) (Cons (TreeNode (Value B false LITERAL) Nil Nil) Nil)) (Cons (TreeNode (Value Nil True OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value D false LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value E false LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B false LITERAL) Nil Nil) Nil) Nil) Nil)))) Nil)))

!(assertEqual True True)
!(assertEqual False False)
!(assertEqual True False)
!(assertEqualToResult (True) (False))