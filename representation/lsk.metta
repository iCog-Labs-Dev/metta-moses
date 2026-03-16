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
;; (:logicalSubtreeKnob (-> (Tree $a) NodeId (Tree $a) (Tree $a LogicalSubtreeKnob)))
(= (logicalSubtreeKnob $tree (mkNodeId $target) $subtree)
   (let*
   (
    ($negatedSubtree (insertAbove $subtree (mkNode NOT)))
    ;; ($_ (println! (NegatedSubtree----------------- : $negatedSubtree)))
    ($reducedSubtree (cleanTree $negatedSubtree)  )
    ;; ($_ (println! (ReducedSubtree---------------: $reducedSubtree))) 
    ($childrenOfTarget (getChildrenById $tree (mkNodeId $target)))
   )
   (if (== True (List.contains $subtree $childrenOfTarget))
       (let $idOfSubtree (getSubtreeId $tree (mkNodeId $target) $subtree 0)
           ($tree (mkLSK (mkDiscKnob (mkKnob (updateID $idOfSubtree)) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) Nil)))
       )
       (if (== True (List.contains $reducedSubtree $childrenOfTarget))
           (let $idOfReducedSubtree (getSubtreeId $tree (mkNodeId $target) $reducedSubtree 0)
                ($tree (mkLSK (mkDiscKnob (mkKnob (updateID $idOfReducedSubtree)) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) Nil))))
           (let*
           (
            (($nullVexAppendedTree $nullVexId) (appendChild $tree (mkNodeId $target) (mkNullVex Nil)))
            (($subtreeAppendedTree $subtreeId) (appendChild $nullVexAppendedTree $nullVexId $subtree))
           )
           ($subtreeAppendedTree (mkLSK (mkDiscKnob (mkKnob (updateID $nullVexId)) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil)))
           )
       )
   )
   )
)


;; Retrieves the node ID from a Logical Subtree Knob (LSK).
; ;; (:getNodeId (-> LogicalSubtreeKnob NodeId))
(= (getNodeId (mkLSK (mkDiscKnob (mkKnob $nodeId) $multi $default $current $discSpecList)))
   $nodeId)

;; Retrieves the current and default disc specifications from an LSK.
;; (:getDiscSpec (-> LogicalSubtreeKnob (DiscSpec DiscSpec)))
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
; (: appendTo (-> (Tree $a) LogicalSubtreeKnob (Tree $a) NodeId Number (Tree $a)))
(= (appendTo $updatedTree $lsk $tree $parentId $d)
    (let*
       (
        ; ($_ (println! (lsk: $lsk)))
        ;; ($_ (println! (ParentId: $parentId)))
        ;; ($_ (println! (D: $d)))
        ((mkNodeId $targetId) (getNodeId $lsk))
        ;; ($newPosition (index-atom $targetId (- (length $targetId) 1)))
        ((mkNodeId $dstId) (if (= (mkNodeId (0)) $parentId) (mkNodeId ()) $parentId))
        ($targetTree (getNodeById  $updatedTree (mkNodeId $targetId)))
        ($newPosition (+ (List.length (getChildren (getNodeById  $tree $parentId))) 1))
        ;; ($_ (println! (newPosition: $newPosition)))
        ;; ($_ (println! (if (== $targetId (1 1 1)) $targetTree NotPrinting)))
        (($subtree $newSrcId) (if (== True (isNullVertex $targetTree))
                        (let (mkNullVex (Cons $child Nil)) $targetTree ($child (mkNodeId (union-atom $targetId (1)))))
                        ($targetTree (mkNodeId $targetId))
                    ))        
        ;; ($_ (println! ("subtree ": $subtree $targetTree)))
        ;; ($_ (println! (CandidateSoFar: (preOrder $tree))))
        ;; ($_ (println! ("subtree ": (getNodeValue $subtree) parentId(OldDstId): $parentId srcId: $newSrcId targetId: $targetId)))
      )
      (if (> $d 2)
          (Error $d "Invalid disc specification:- cannot exceed 2.")
          ;; TODO: Skip multiplicity 0, we don't want to convert the subtree into a null vertex. That will bring weird behavior like nested NullVertex and the like.
          ;;       In addition, this tree is a new candidate tree needed only to be evaluated, why do we need to process null vertexes here? We want to avoid adding any.
          (let ($treeToAppend $newDstId)
                            (case $d
                                (
                                  (2  ((mkTree (mkNode NOT) (Cons (mkTree (getNodeValue $subtree) Nil) Nil)) (mkNodeId (union-atom $dstId ($newPosition 1))))) ;; If negated
                                  (1  ((mkTree (getNodeValue $subtree) Nil) (mkNodeId (union-atom $dstId ($newPosition))))) ;; If present
                                  (0  ((mkNullVex (Cons $subtree Nil)) $parentId)))) ;; If absent

                            (if (isNullVertex $treeToAppend)
                                ($tree $parentId $parentId)
                                (chain (appendChild $tree $parentId $treeToAppend) $treeChIdPair
                                        ((first $treeChIdPair) $newSrcId (if (== $parentId $newDstId) (second $treeChIdPair) $newDstId)))))))) ;; INFO: Just incase if the append fails and stores the result somewhere else, we need to add a test case here to cmpare between targetNode and appendChild node.
