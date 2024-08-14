! (register-module! ../../metta-moses-reduction)
! (import! &self metta-moses-reduction:types)
! (import! &self metta-moses-reduction:utilities:list-helpers)
! (import! &self metta-moses-reduction:utilities:tree-helpers)

(: gatherJunctors (-> Tree Tree Tree))
(= (gatherJunctors $currentNode $centerNode)
      (let* (
              ($currentNodeType (getNodeType $currentNode))
              ($centerNodeType (getNodeType $centerNode))
              ($currentLeft (getChild $currentNode L))
              ($currentRight (getChild $currentNode R))
              ((TreeNode (Value $valueName $constraint $currentNodeType) $guardSet $children) $currentNode)
            )
            (if (and (== $currentNodeType ROOT) (not (== $currentRight NilNode)))
                  (let* 
                      (
                        ($updatedCurrent (changeType $currentNode AND))
                        ($removedChildCurrent (replaceChildren $updatedCurrent Nil))
                        ($finalUpdatedCurrent (gatherJunctors $currentRight $removedChildCurrent))
                      )
                      $finalUpdatedCurrent
                  )
                  (if (or (== $currentNodeType AND) (== $currentNodeType OR))
                      (if  (== $currentNodeType $centerNodeType)
                            (let* 
                              (
                                ($leftUpdatedCenter (gatherJunctors $currentLeft $centerNode))
                                ($rightUpdatedCenter (gatherJunctors $currentRight $leftUpdatedCenter))
                              )
                              $rightUpdatedCenter
                            )
                          (let* 
                              (
                                  ($removedChildCurrent (replaceChildren $currentNode Nil))
                                  ($leftUpdatedCenter (gatherJunctors $currentLeft $removedChildCurrent))
                                  ($rightUpdatedCenter (gatherJunctors $currentRight $leftUpdatedCenter))
                                  ($updatedChildrenCenter (prependChild $centerNode $rightUpdatedCenter))
                              )
                              $updatedChildrenCenter
                          )
                      )
                      (if (== $currentNodeType LITERAL)
                          (if (== $centerNodeType AND)
                              (prependToGuardSet $centerNode $currentNode)
                              (prependChild $centerNode (TreeNode (Value Nil $constraint AND) (Cons $currentNode Nil) $children))
                          )
                          NilNode
                      )
                  )
            )
         )
 )


;; (=(gatherJunctorRunner $treeNode)
;;     (gatherJunctors $treeNode NilNode)
;; )
;; (= (checker $treeNode)
;;     (if (== (getNodeType $treeNode) ROOT) True False)
;; )
;; !(checker (TreeNode (Value Nil False ROOT) Nil (Cons NilNode (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value a True LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value b True LITERAL) Nil Nil) (Cons (TreeNode (Value c True LITERAL) Nil Nil) Nil))) Nil))) Nil))))



;;;Gather Junctor check
 ;         (TreeNode (Value NilNode False AND)
 ;             (TreeNode (Value Nil False AND)
 ;             (TreeNode (Value NilNode False AND) NilNode NilNode (ConsTree (TreeNode (Value x False LITERAL) NilNode NilNode NilList NilList) NilList ) NilList) ;this node fulfills the condition
 ;             (TreeNode (Value NilNode False AND) NilNode NilNode NilList NilList)
 ;                 NilList
 ;                 NilList
 ;             )
 ;             NilNode NilList NilList)

;;!(gatherJunctors (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value a True LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value b True LITERAL) Nil Nil) (Cons (TreeNode (Value c True LITERAL) Nil Nil) Nil))) Nil))))
;!(buildTreeWithRoot (OR A (AND Y (OR B (AND C D)))))
;;(propagate-truth-value (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value A False LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value Y False LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value B False LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value C False LITERAL) Nil Nil) (Cons (TreeNode (Value D False LITERAL) Nil Nil) Nil))) Nil))) Nil))) Nil))))
;;!(gatherJunctors (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value A False LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value Y False LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value B False LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value C False LITERAL) Nil Nil) (Cons (TreeNode (Value D False LITERAL) Nil Nil) Nil))) Nil))) Nil))) Nil))))
!(gatherJunctors (TreeNode (Value Nil False ROOT) Nil (Cons NilNode (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value A False LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value Y False LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value B False LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value C False LITERAL) Nil Nil) (Cons (TreeNode (Value D False LITERAL) Nil Nil) Nil))) Nil))) Nil))) Nil))) Nil))) NilNode)

;; !(gatherJunctors (TreeNode (Value Nil False ROOT) Nil (Cons NilNode (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value A True LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value B True LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value C True LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value D True LITERAL) Nil Nil) (Cons (TreeNode (Value E False LITERAL) Nil Nil) Nil))) Nil))) Nil))) Nil))) Nil))) NilNode)
