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
    ($negatedSubtree (eval (insertAbove $subtree (mkNode NOT))))
    ($_ (println! (NegatedSubtree----------------- : $negatedSubtree)))
    ($reducedSubtree (eval (cleanTree $negatedSubtree))  )
    ($_ (println! (ReducedSubtree---------------: $reducedSubtree))) 
    ($childrenOfTarget (eval (getChildrenById $tree (mkNodeId $target))))
   )
   (if (== True (eval (List.contains $subtree $childrenOfTarget) ))
       (let $idOfSubtree (eval (getSubtreeId $tree (mkNodeId $target) $subtree 0))
           ($tree (mkLSK (mkDiscKnob (mkKnob (updateID $idOfSubtree)) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) Nil)))
       )
       (if (== True (eval (List.contains $reducedSubtree $childrenOfTarget)))
           (let $idOfReducedSubtree (eval (getSubtreeId $tree (mkNodeId $target) $reducedSubtree 0))
                ($tree (mkLSK (mkDiscKnob (mkKnob (updateID $idOfReducedSubtree)) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) Nil))))
           (let*
           (
            (($nullVexAppendedTree $nullVexId) (eval (appendChild $tree (mkNodeId $target) (mkNullVex Nil))))
            (($subtreeAppendedTree $subtreeId) (eval (appendChild $nullVexAppendedTree $nullVexId $subtree)))
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
               ;; Create Knob: Multiplicity 2. Default=0 (Absent/NullVertex)
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
        ($targetId (eval (getNodeId $lsk)))
        ($targetTree (eval (getNodeById  $updatedTree $targetId)))
        ($subtree (if (== True (eval (isNullVertex $targetTree) ))
                        (let (mkNullVex (Cons $child Nil)) $targetTree $child)
                        $targetTree
                    ))        
        ($_ (println! ("subtree ": $subtree $targetTree)))
      )
      (if (> $d 2)
          (Error $d "Invalid disc specification:- cannot exceed 2.")
          (if (== True (isEmpty $tree))
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
                         (2 (eval (insertAbove $subtree (mkNode NOT)))) ;; If negated
                         (1  $subtree) ;; If present
                         (0  (mkNullVex (Cons $subtree Nil))))) ;; If absent

                   (chain (eval (appendChild $tree $parentId $treeToAppend)) $treeChIdPair
                      (eval (first $treeChIdPair)))))))) ;; INFO: Just incase if the append fails and stores the result somewhere else, we need to add a test case here to cmpare between targetNode and appendChild node.



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
        ($_ (println! ("strategy subtree:": $subtree $targetTree)))
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
