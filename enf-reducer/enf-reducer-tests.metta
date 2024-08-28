! (register-module! ../../metta-moses-reduction)
! (import! &self metta-moses-reduction:types) 
! (import! &self metta-moses-reduction:utilities:list-helpers)
! (import! &self metta-moses-reduction:utilities:tree-helpers)
! (import! &self metta-moses-reduction:enf-reducer:RTEHelpers)
! (import! &self metta-moses-reduction:enf-reducer:propagate_truth_value)
! (import! &self metta-moses-reduction:enf-reducer:reduce_to_elegance)

! (import! &self metta-moses-reduction:enf-reducer:postProcessing)
! (import! &self metta-moses-reduction:enf-reducer:reduct)
! (import! &self metta-moses-reduction:gather-junctors)

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


;; !(reduceToElegance (TreeNode (Value Nil False AND) (Cons (TreeNode (Value a True AND) Nil Nil) Nil) (Cons (TreeNode (Value b True AND) Nil Nil) Nil)) Nil Nil)
;; !(reduceToElegance (TreeNode (Value Nil False OR) (Cons (TreeNode (Value a True AND) Nil Nil) Nil) (Cons (TreeNode (Value b True AND) Nil Nil) Nil)) Nil Nil)

;; !(gatherJunctors (buildTreeWithRoot (AND A (AND B (AND C (OR D E))))) NilNode)
;; !(gatherJunctors (buildTreeWithRoot (OR A (OR B (OR C (AND D E))))) NilNode)
;; !(gatherJunctors (buildTreeWithRoot (OR A (OR B (AND C (AND D (OR E F)))))) NilNode)
;;!(gatherJunctors (TreeNode (Value Nil False ROOT) Nil (Cons NilNode (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value A True LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value B True LITERAL) Nil Nil) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil))) Nil))) Nil))) NilNode)

;; !(reduceToElegance (TreeNode (Value Nil False AND) (Cons (TreeNode (Value a True AND) Nil Nil) Nil) (Cons (TreeNode (Value b True AND) Nil Nil) Nil)) Nil Nil)
;; !(reduceToElegance (TreeNode (Value Nil False OR) (Cons (TreeNode (Value a True AND) Nil Nil) Nil) (Cons (TreeNode (Value b True AND) Nil Nil) Nil)) Nil Nil)
;;!(reduceToElegance (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value Y True LITERAL) Nil Nil) Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value D True LITERAL) Nil Nil) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil)) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) Nil Nil)

;!(postProcessing (TreeNode (Value Nil False AND) (Cons (TreeNode (Value A False LITERAL) Nil Nil) (Cons (TreeNode (Value B False LITERAL) Nil Nil) (Cons (TreeNode (Value C False LITERAL) Nil Nil) Nil))) (Cons (TreeNode (Value Nil True OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value D False LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value E False LITERAL) Nil Nil) (Cons (TreeNode (Value F False LITERAL) Nil Nil) Nil)) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value G False LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value H False LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value E False LITERAL) Nil Nil) (Cons (TreeNode (Value F False LITERAL) Nil Nil) Nil)) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value G False LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value H False LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) Nil)))) Nil)))

;!(postProcessing (TreeNode (Value Nil False AND) (Cons (TreeNode (Value A false LITERAL) Nil Nil) (Cons (TreeNode (Value B false LITERAL) Nil Nil) (Cons (TreeNode (Value C false LITERAL) Nil Nil) Nil))) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value A False AND) (Cons (TreeNode (Value A false LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value A false LITERAL) Nil Nil) (Cons (TreeNode (Value B false LITERAL) Nil Nil) Nil)) (Cons (TreeNode (Value Nil True OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value D false LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value E false LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B false LITERAL) Nil Nil) Nil) Nil) Nil)))) Nil)))

;;!(reduct (AND A (AND B (AND C (AND (OR A (OR B (OR C A))) (AND B (AND (AND A A) (NOT A))))))))
;;!(reduct (AND A (AND B A)))
;;!(reduct (OR A (AND Y (OR B (AND C D)))))
;;!(reduct (OR A (AND Y (OR B C))))
;; !(and (== (getChildren (head (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil) 
;;             (== (guardSetChecker (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) Nil) Nil)) 1)) 
;; !(== (getNodeType (head (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) Nil) Nil))) AND)

;;!(and (and (== (getChildren (head (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil) (== (guardSetChecker (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) Nil) Nil)) 1)) (== (getNodeType (head (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) Nil) Nil))) AND))
;;!(reduceToElegance (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value Y True LITERAL) Nil Nil) Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value D True LITERAL) Nil Nil) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil)) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) Nil Nil)
;;!(TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value Y True LITERAL) Nil Nil) Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value D True LITERAL) Nil Nil) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil)) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil))
;;!(reduceToElegance (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value Y True LITERAL) Nil Nil) Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) Nil Nil)
;;!(commandSetIterator (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) Nil) Nil) Nil)
;;!(iterator (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value Y True LITERAL) Nil Nil) Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) Nil Nil)
;;!(let (TreeNode $nodeValue $guardSet $children) (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil))) (The head is (head $children) The tail is (tail $children)))
;;dominantSet
;;(Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil)
;;commmandSet
;;(Cons (TreeNode (Value Y True LITERAL) Nil Nil) Nil)
;;head
;;(TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil)
;;Tail
;;(Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil))
;;orNode
;;(TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil)))
;;!(orSubTreeIterator (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil) (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil))) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) (Cons (TreeNode (Value Y True LITERAL) Nil Nil) Nil))

;;!(orSubTreeIterator (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil) (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil))) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) (Cons (TreeNode (Value Y True LITERAL) Nil Nil) Nil))
;;!(iterator (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value Y True LITERAL) Nil Nil) Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) Nil Nil)
;;!(TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value Y True LITERAL) Nil Nil) Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil))
;;!(iterator (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil Nil)
;; !(getChildren (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil))))
;; !(andSubTreeIterator 
;;             (getChildren (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil)))) 
;;                 (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil Nil)
;;(Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil))
;; !(treeIntersection (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil)
!(iterator (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) Nil Nil)
;;!(applyToChildren (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) (getChildren (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil)))