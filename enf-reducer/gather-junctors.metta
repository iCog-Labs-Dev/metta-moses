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

;; !(gatherJunctors (buildTreeWithRoot (AND A (AND B (AND C (OR D E))))) NilNode)
;; !(gatherJunctors (buildTreeWithRoot (OR A (OR B (OR C (AND D E))))) NilNode)
;; !(gatherJunctors (buildTreeWithRoot (OR A (OR B (AND C (AND D (OR E F)))))) NilNode)
