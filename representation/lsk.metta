;;;;;;;;;;;;;;;;; LSK Constructor ;;;;;;;;;;;;;;;;;;;;;;;;

;; Creates a Logical Subtree Knob (LSK) for a given tree, target node, and subtree.
;; Params:
;;  $tree: The tree structure where the logical subtree knob will be applied.
;;  $target: The parent node to which the LSK's place holder (null vertex) 
;;           will be added is pointed by the target node.
;;  $subtree: The subtree to be appended.
;; Returns:
;;  $tree 
;;  A LogicalSubtreeKnob (LSK) configured based on the subtree's presence or its appended state.
(: logicalSubtreeKnob (-> (Tree $a) NodeId (Tree $a) (Tree $a LogicalSubtreeKnob)))
(= (logicalSubtreeKnob $tree (mkNodeId $target) $subtree)
   (let*
   (
    ($negatedSubtree (insertAbove $subtree (mkNode NOT)))
    (() (println! (NegatedSubtree : $negatedSubtree)))
    ($reducedSubtree (cleanTree $negatedSubtree))  ;;;after the reduct integration, the reduction step will be applied here 
    (() (println! (ReducedSubtree: $reducedSubtree)))
    ;; ($reducedSubtree $negatedSubtree)  ;;;after the reduct integration, the reduction step will be applied here 
    ($childrenOfTarget (getChildrenById $tree (mkNodeId $target)))
   )
   (if (List.contains $subtree $childrenOfTarget) 
       (let $idOfSubtree (getSubtreeId $tree (mkNodeId $target) $subtree 0)
           ($tree (mkLSK (mkDiscKnob (mkKnob $idOfSubtree) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) Nil)))
       )
       (if (List.contains $reducedSubtree $childrenOfTarget)
           (let $idOfReducedSubtree (getSubtreeId $tree (mkNodeId $target) $reducedSubtree 0)
                ($tree (mkLSK (mkDiscKnob (mkKnob $idOfReducedSubtree) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) Nil))))
           (let*
           (
            (($nullVexAppendedTree $nullVexId) (appendChild $tree (mkNodeId $target) (mkNullVex Nil)))
            (($subtreeAppendedTree $subtreeId) (appendChild $nullVexAppendedTree $nullVexId $subtree))
           )
           ($subtreeAppendedTree (mkLSK (mkDiscKnob (mkKnob $nullVexId) (mkMultip 3))))
           )
       )
   )
   )
)


;; Retrieves the node ID from a Logical Subtree Knob (LSK).
(: getNodeId (-> LogicalSubtreeKnob NodeId))
(= (getNodeId (mkLSK (mkDiscKnob (mkKnob $nodeId) $multi $default $current $discSpecList)))
   $nodeId)

;; Retrieves the current and default disc specifications from an LSK.
(: getDiscSpec (-> LogicalSubtreeKnob (DiscSpec DiscSpec)))
(= (getDiscSpec (mkLSK (mkDiscKnob (mkKnob $nodeId) $multi $default $current $discSpecList)))
    (let ((mkDiscSpec $def) (mkDiscSpec $cur)) ($default $current) ($def $cur)))


;; Appends a subtree or a null vertex in place of a logical subtree 
;;  using information from the LSK and a knob setting specified.
;; Params:
;;  $lsk: The logical subtree knob containing information on how the subtree is appended to the original tree.
;;  $tree: An incomplete tree. It will be built using the tree with knobs as a
;;            reference and it may also contain knobs if $d is 0
;;  $parentId: The location where the new node will be added.
;;  $d: The current setting of the knob.
(: appendTo (-> (Tree $a) LogicalSubtreeKnob (Tree $a) NodeId Number (Tree $a)))
(= (appendTo $updatedTree $lsk $tree $parentId $d)
    (let*
       (
        (() (println! (lsk: $lsk)))
        ($targetId (getNodeId $lsk))
        ($targetTree (getNodeById  $updatedTree $targetId))
        ($subtree (if (isNullVertex $targetTree) 
                        (let (mkNullVex (Cons $child Nil)) $targetTree $child)
                        $targetTree
                    ))        
      )
      (if (> $d 2)
          (Error $d "Invalid disc specification:- cannot exceed 2.")
          (if (isEmpty $tree)
              $subtree

              ;; The c++ version takes the child of the null vertex from the 
              ;;   location of the tree but we don't have access to the knob 
              ;;   decorated tree in this function. It is possible to pass 
              ;;   that tree as well but instead of increasing the function 
              ;;   parameter size, why not simply use the $subtree we already 
              ;;   have stored in the lsk? It seems to be doing the exact same thing.
              (let $treeToAppend
                   (case $d
                       (
                         (2 (insertAbove $subtree (mkNode NOT))) ;; If negated
                         (1  $subtree) ;; If present
                         (0  (mkNullVex (Cons $subtree Nil))))) ;; If absent

                   (chain (appendChild $tree $parentId $treeToAppend) $treeChIdPair
                       (first $treeChIdPair))))))) ;; INFO: Just incase if the append fails and stores the result somewhere else, we need to add a test case here to cmpare between targetNode and appendChild node.
