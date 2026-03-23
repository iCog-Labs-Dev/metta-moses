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
;; strategySubtreeKnob -> Creates Strategy Subtree Knob (SSK) for game moves
;; Params:
;;  $tree: The tree structure where the strategy subtree knob will be applied
;;  $target: The parent node to which the SSK's place holder will be added
;;  $subtree: The subtree to be appended (game move or strategy)
;; Returns: ($tree StrategySubtreeKnob)
;; (: strategySubtreeKnob (-> (Tree $a) NodeId (Tree $a) (Tree $a StrategySubtreeKnob)))
(= (strategySubtreeKnob $tree (mkNodeId $target) $subtree)
   (let $childrenOfTarget (eval (getChildrenById $tree (mkNodeId $target)))
       ;; Case 1: Subtree already exists in children
       (if (== True (eval (List.contains $subtree $childrenOfTarget)))
           (let $idOfSubtree (eval (getSubtreeId $tree (mkNodeId $target) $subtree 0))
               ;; Create Knob: Multiplicity 2 (0=Absent, 1=Present). Default=1 (Present)
               ($tree (mkSSK (mkDiscKnob (mkKnob (updateID $idOfSubtree)) (mkMultip 2) (mkDiscSpec 1) (mkDiscSpec 1) Nil)))
           )
           ;; Case 2: New Subtree (Insert placeholder)
           (let*
               (
                   ;; Insert NullVertex placeholder
                   (($nullVexAppendedTree $nullVexId) (eval (appendChild $tree (mkNodeId $target) (mkNullVex Nil))))
                   ;; Attach the actual subtree to the placeholder
                   (($subtreeAppendedTree $subtreeId) (eval (appendChild $nullVexAppendedTree $nullVexId $subtree)))
               )
               ($subtreeAppendedTree (mkSSK (mkDiscKnob (mkKnob (updateID $nullVexId)) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil)))
           )
       )
   )
)


;; Retrieves the node ID from a Logical Subtree Knob (LSK) or Strategy Subtree Knob (SSK).
;; (: getNodeId (-> LogicalSubtreeKnob NodeId))
;; (: getNodeId (-> StrategySubtreeKnob NodeId))
(= (getNodeId (mkLSK (mkDiscKnob (mkKnob $nodeId) $multi $default $current $discSpecList)))
   $nodeId)
(= (getNodeId (mkSSK (mkDiscKnob (mkKnob $nodeId) $multi $default $current $discSpecList)))
   $nodeId)

;; Retrieves the current and default disc specifications from an LSK.
;; (:getDiscSpec (-> LogicalSubtreeKnob (DiscSpec DiscSpec)))
(= (getDiscSpec (mkLSK (mkDiscKnob (mkKnob $nodeId) $multi $default $current $discSpecList)))
    (let ((mkDiscSpec $def) (mkDiscSpec $cur)) ($default $current) ($def $cur)))


;; appendTo dispatcher - calls the appropriate function based on knob type
;; (: appendTo (-> (Tree $a) LogicalSubtreeKnob (Tree $a) NodeId Number (Tree $a)))
;; (: appendTo (-> (Tree $a) StrategySubtreeKnob (Tree $a) NodeId Number (Tree $a)))
(= (appendTo $updatedTree (mkLSK $discKnob) $tree $parentId $d)
    (appendToLSK $updatedTree (mkLSK $discKnob) $tree $parentId $d))
(= (appendTo $updatedTree (mkSSK $discKnob) $tree $parentId $d)
    (appendToSSK $updatedTree (mkSSK $discKnob) $tree $parentId $d))

    
;; Appends a subtree or a null vertex in place of a logical subtree 
;;  using information from the LSK and a knob setting specified.
;; Params:
;;  $lsk: The logical subtree knob containing information on how the subtree is appended to the original tree.
;;  $tree: An incomplete tree. It will be built using the tree with knobs as a
;;            reference and it may also contain knobs if $d is 0
;;  $parentId: The location where the new node will be added.
;;  $d: The current setting of the knob.
; (: appendToLSK (-> (Tree $a) LogicalSubtreeKnob (Tree $a) NodeId Number (Tree $a)))
(= (appendToLSK $updatedTree $lsk $tree $parentId $d)
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

;; appendTo for Strategy Subtree Knobs (SSK) - No negation for game moves
;; Params:
;;  $ssk: The strategy subtree knob containing information on how the subtree is appended
;;  $tree: An incomplete tree to be built
;;  $parentId: The location where the new node will be added
;;  $d: The current setting of the knob (0=Absent, 1=Present)
;; (: appendToSSK (-> (Tree $a) StrategySubtreeKnob (Tree $a) NodeId Number (Tree $a)))
(= (appendToSSK $updatedTree $ssk $tree $parentId $d)
    (let*
       (
        ($targetId (eval (getNodeId $ssk)))
        ($targetTree (eval (getNodeById $updatedTree $targetId)))
        ($subtree (if (== True (eval (isNullVertex $targetTree)))
                        (let (mkNullVex (Cons $child Nil)) $targetTree $child)
                        $targetTree))
      )
      (if (> $d 1)
          (Error $d "Invalid disc specification for strategy:- cannot exceed 1.")
          (if (== True (isEmpty $tree))
              $subtree
              (let $treeToAppend
                   (case $d
                       (
                         (1 $subtree) ;; If present
                         (0 (mkNullVex (Cons $subtree Nil))))) ;; If absent
                   (chain (eval (appendChild $tree $parentId $treeToAppend)) $treeChIdPair
                      (eval (first $treeChIdPair))))))))
