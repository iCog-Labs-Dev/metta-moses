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

;;!(isTreeWellFormed (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value a False LITERAL) Nil Nil) (Cons (TreeNode (Value b False LITERAL) Nil Nil) Nil))))

;!(assertEqual
;(isTreeWellFormed (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value a False LITERAL) Nil Nil) (Cons (TreeNode (Value b False LITERAL) Nil Nil) Nil))))
;True )

;; !(propagateTruthValue (buildTree (OR a (AND b c))) True)

;!(assertEqual
;(propagateTruthValue (buildTree (OR a (AND b c))) True) 
;(TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value a True LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value b True LITERAL) Nil Nil) (Cons (TreeNode (Value c True LITERAL) Nil Nil) Nil))) Nil)))
;)

;; !(propagateTruthValue (buildTreeWithRoot (OR a (AND b c))) True)

;!(assertEqual
 ;(propagateTruthValue (buildTreeWithRoot (OR a (AND b c))) True)
 ;(TreeNode (Value Nil False ROOT) Nil (Cons NilNode (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value a True LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value b True LITERAL) Nil Nil) (Cons (TreeNode (Value c True LITERAL) Nil Nil) Nil))) Nil))) Nil)))
 ;)

;; !(propagateTruthValue (buildTreeWithRoot (OR a (AND b c))) False)

;!(assertEqual
 ;(propagateTruthValue (buildTreeWithRoot (OR a (AND b c))) False)
;(TreeNode (Value Nil False ROOT) Nil (Cons NilNode (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value a False LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value b False LITERAL) Nil Nil) (Cons (TreeNode (Value c False LITERAL) Nil Nil) Nil))) Nil))) Nil)))
; )
 

;; !(propagateTruthValue (buildTreeWithRoot (NOT (OR a (AND b c)))) False)

 ;!(assertEqual
 ;(propagateTruthValue (buildTreeWithRoot (NOT (OR a (AND b c)))) False)
 ;(TreeNode (Value Nil False ROOT) Nil (Cons NilNode (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value a True LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value b True LITERAL) Nil Nil) (Cons (TreeNode (Value c True LITERAL) Nil Nil) Nil))) Nil))) Nil)))
 ;)

;; !(propagateTruthValue (buildTreeWithRoot (NOT (OR a (AND b c)))) True)

;!(assertEqual
;(propagateTruthValue (buildTreeWithRoot (NOT (OR a (AND b c)))) True)
;(TreeNode (Value Nil False ROOT) Nil (Cons NilNode (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value a False LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value b False LITERAL) Nil Nil) (Cons (TreeNode (Value c False LITERAL) Nil Nil) Nil))) Nil))) Nil)))
;)

;; !(propagateTruthValue (buildTreeWithRoot (AND a (OR b c))) False)

;!(assertEqual
;(propagateTruthValue (buildTreeWithRoot (AND a (OR b c))) False)
;(TreeNode (Value Nil False ROOT) Nil (Cons NilNode (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value a False LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value b False LITERAL) Nil Nil) (Cons (TreeNode (Value c False LITERAL) Nil Nil) Nil))) Nil))) Nil)))
;)

;; !(propagateTruthValue (buildTreeWithRoot (AND a (OR b c))) True)

;!(assertEqual
;(propagateTruthValue (buildTreeWithRoot (AND a (OR b c))) True)
;(TreeNode (Value Nil False ROOT) Nil (Cons NilNode (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value a True LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value b True LITERAL) Nil Nil) (Cons (TreeNode (Value c True LITERAL) Nil Nil) Nil))) Nil))) Nil)))
;)

;; !(propagateTruthValue (buildTreeWithRoot (NOT (AND a (OR b c)))) True)

;!(assertEqual
;(propagateTruthValue (buildTreeWithRoot (NOT (AND a (OR b c)))) True)
;(TreeNode (Value Nil False ROOT) Nil (Cons NilNode (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value a False LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value b False LITERAL) Nil Nil) (Cons (TreeNode (Value c False LITERAL) Nil Nil) Nil))) Nil))) Nil)))
;)

;; !(propagateTruthValue (buildTreeWithRoot (NOT (AND a (OR b c)))) False)

;!(assertEqual
;(propagateTruthValue (buildTreeWithRoot (NOT (AND a (OR b c)))) False)
;(TreeNode (Value Nil False ROOT) Nil (Cons NilNode (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value a True LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value b True LITERAL) Nil Nil) (Cons (TreeNode (Value c True LITERAL) Nil Nil) Nil))) Nil))) Nil)))
;)

; !(reduceToElegance (TreeNode (Value Nil False AND) (Cons (TreeNode (Value a True AND) Nil Nil) Nil) (Cons (TreeNode (Value b True AND) Nil Nil) Nil)) Nil Nil)

;!(assertEqual
;(reduceToElegance (TreeNode (Value Nil False AND) (Cons (TreeNode (Value a True AND) Nil Nil) Nil) (Cons (TreeNode (Value b True AND) Nil Nil) Nil)) Nil Nil)
;((TreeNode (Value Nil False AND) (Cons (TreeNode (Value a True AND) Nil Nil) Nil) Nil) KEEP)
;)

; !(reduceToElegance (TreeNode (Value Nil False OR) (Cons (TreeNode (Value a True AND) Nil Nil) Nil) (Cons (TreeNode (Value b True AND) Nil Nil) Nil)) Nil Nil)


!(assertEqual
(reduceToElegance (TreeNode (Value Nil False OR) (Cons (TreeNode (Value a True AND) Nil Nil) Nil) (Cons (TreeNode (Value b True AND) Nil Nil) Nil)) Nil Nil)
(empty))

;; !(gatherJunctors (buildTreeWithRoot (AND A (AND B (AND C (OR D E))))) NilNode)

;!(assertEqual
;(gatherJunctors (buildTreeWithRoot (AND A (AND B (AND C (OR D E))))) NilNode)
;(TreeNode (Value Nil False AND) (Cons (TreeNode (Value C False LITERAL) Nil Nil) (Cons (TreeNode (Value B False LITERAL) Nil Nil) (Cons (TreeNode (Value A False LITERAL) Nil Nil) Nil))) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value E False LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value D False LITERAL) Nil Nil) Nil) Nil) Nil))) Nil))
;)

;; !(gatherJunctors (buildTreeWithRoot (OR A (OR B (OR C (AND D E))))) NilNode)

;!(assertEqual
;(gatherJunctors (buildTreeWithRoot (OR A (OR B (OR C (AND D E))))) NilNode)
;(TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value E False LITERAL) Nil Nil) (Cons (TreeNode (Value D False LITERAL) Nil Nil) Nil)) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value C False LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value B False LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value A False LITERAL) Nil Nil) Nil) Nil) Nil))))) Nil))
;)

;; !(gatherJunctors (buildTreeWithRoot (OR A (OR B (AND C (AND D (OR E F)))))) NilNode)

;!(assertEqual
;(gatherJunctors (buildTreeWithRoot (OR A (OR B (AND C (AND D (OR E F)))))) NilNode)
;(TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value D False LITERAL) Nil Nil) (Cons (TreeNode (Value C False LITERAL) Nil Nil) Nil)) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value F False LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value E False LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value B False LITERAL) Nil Nil) Nil) 
;Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value A False LITERAL) Nil Nil) Nil) Nil) Nil)))) Nil))
;)

;;!(gatherJunctors (TreeNode (Value Nil False ROOT) Nil (Cons NilNode (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value A True LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value B True LITERAL) Nil Nil) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil))) Nil))) Nil))) NilNode)


;!(assertEqual
;(gatherJunctors (TreeNode (Value Nil False ROOT) Nil (Cons NilNode (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value A True LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value B True LITERAL) Nil Nil) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil))) Nil))) Nil))) NilNode)
;(TreeNode (Value Nil False AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) (Cons (TreeNode (Value B True LITERAL) Nil Nil) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil))) Nil)
;)

;; !(reduceToElegance (TreeNode (Value Nil False AND) (Cons (TreeNode (Value a True AND) Nil Nil) Nil) (Cons (TreeNode (Value b True AND) Nil Nil) Nil)) Nil Nil)

;!(assertEqual
;(reduceToElegance (TreeNode (Value Nil False AND) (Cons (TreeNode (Value a True AND) Nil Nil) Nil) (Cons (TreeNode (Value b True AND) Nil Nil) Nil)) Nil Nil)
;((TreeNode (Value Nil False AND) (Cons (TreeNode (Value a True AND) Nil Nil) Nil) Nil) KEEP)
;)

;; !(reduceToElegance (TreeNode (Value Nil False OR) (Cons (TreeNode (Value a True AND) Nil Nil) Nil) (Cons (TreeNode (Value b True AND) Nil Nil) Nil)) Nil Nil)

;!(assertEqual
;(reduceToElegance (TreeNode (Value Nil False OR) (Cons (TreeNode (Value a True AND) Nil Nil) Nil) (Cons (TreeNode (Value b True AND) Nil Nil) Nil)) Nil Nil)
;(empty))

;!(postProcessing (TreeNode (Value Nil False AND) (Cons (TreeNode (Value A False LITERAL) Nil Nil) (Cons (TreeNode (Value B False LITERAL) Nil Nil) (Cons (TreeNode (Value C False LITERAL) Nil Nil) Nil))) (Cons (TreeNode (Value Nil True OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value D False LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value E False LITERAL) Nil Nil) (Cons (TreeNode (Value F False LITERAL) Nil Nil) Nil)) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value G False LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value H False LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value E False LITERAL) Nil Nil) (Cons (TreeNode (Value F False LITERAL) Nil Nil) Nil)) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value G False LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value H False LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) Nil)))) Nil)))

;!(assertEqual
;(postProcessing (TreeNode (Value Nil False AND) (Cons (TreeNode (Value A False LITERAL) Nil Nil) (Cons (TreeNode (Value B False LITERAL) Nil Nil) (Cons (TreeNode (Value C False LITERAL) Nil Nil) Nil))) (Cons (TreeNode (Value Nil True OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value D False LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value E False LITERAL) Nil Nil) (Cons (TreeNode (Value F False LITERAL) Nil Nil) Nil)) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value G False LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value H False LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value E False LITERAL) Nil Nil) (Cons (TreeNode (Value F False LITERAL) Nil Nil) Nil)) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value G False LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value H False LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) Nil)))) Nil)))
;(nAndArr C B A (nOrArr ((nAndArr F E (nOrArr (H G))) (nAndArr F E (nOrArr (H G))) D)))
;)

;!(postProcessing (TreeNode (Value Nil False AND) (Cons (TreeNode (Value A false LITERAL) Nil Nil) (Cons (TreeNode (Value B false LITERAL) Nil Nil) (Cons (TreeNode (Value C false LITERAL) Nil Nil) Nil))) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value A False AND) (Cons (TreeNode (Value A false LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value A false LITERAL) Nil Nil) (Cons (TreeNode (Value B false LITERAL) Nil Nil) Nil)) (Cons (TreeNode (Value Nil True OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value D false LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value E false LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B false LITERAL) Nil Nil) Nil) Nil) Nil)))) Nil)))

;!(assertEqual
;(postProcessing (TreeNode (Value Nil False AND) (Cons (TreeNode (Value A false LITERAL) Nil Nil) (Cons (TreeNode (Value B false LITERAL) Nil Nil) (Cons (TreeNode (Value C false LITERAL) Nil Nil) Nil))) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value A False AND) (Cons (TreeNode (Value A false LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value A false LITERAL) Nil Nil) (Cons (TreeNode (Value B false LITERAL) Nil Nil) Nil)) (Cons (TreeNode (Value Nil True OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value D false LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value E false LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B false LITERAL) Nil Nil) Nil) Nil) Nil)))) Nil)))
;(nAndArr C B A (nOrArr (B (nAndArr B A (nOrArr (E D))) A)))
;)

;;!(reduct (AND A (AND B (AND C (AND (OR A (OR B (OR C A))) (AND B (AND (AND A A) (NOT A))))))))
;;!(reduct (AND A (AND B A)))

!(assertEqual True True)
!(assertEqual False False)
!(assertEqual True False)
!(assertEqualToResult (True) (False))
