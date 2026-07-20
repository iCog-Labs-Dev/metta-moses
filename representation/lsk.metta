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
;; (= (logicalSubtreeKnob $tree (mkNodeId $target) $subtree)
;;    (let*
;;    (
;;     ($negatedSubtree (insertAbove $subtree (mkNode NOT)))
;;     ;; ($_ (println! (NegatedSubtree----------------- : $negatedSubtree)))
;;     ($reducedSubtree (cleanTree $negatedSubtree)  )
;;     ;; ($_ (println! (ReducedSubtree---------------: $reducedSubtree))) 
;;     ($childrenOfTarget (getChildrenById $tree (mkNodeId $target)))
;;    )
;;    (if (== True (List.contains $subtree $childrenOfTarget))
;;        (let $idOfSubtree (getSubtreeId $tree (mkNodeId $target) $subtree 0)
;;            ($tree (mkLSK (mkDiscKnob (mkKnob (updateID $idOfSubtree)) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ())))
;;        )
;;        (if (== True (List.contains $reducedSubtree $childrenOfTarget))
;;            (let $idOfReducedSubtree (getSubtreeId $tree (mkNodeId $target) $reducedSubtree 0)
;;                 ($tree (mkLSK (mkDiscKnob (mkKnob (updateID $idOfReducedSubtree)) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ()))))
;;            (let*
;;            (
;;             (($nullVexAppendedTree $nullVexId) (appendChild $tree (mkNodeId $target) (mkNullVex ())))
;;             (($subtreeAppendedTree $subtreeId) (appendChild $nullVexAppendedTree $nullVexId $subtree))
;;            )
;;            ($subtreeAppendedTree (mkLSK (mkDiscKnob (mkKnob (updateID $nullVexId)) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())))
;;            )
;;        )
;;    )
;;    )
;; )

(= (logicalSubtreeKnob (mkTree $node $children ) $subtree)
   (let*
     (
       ($negatedSubtree (insertAbove $subtree (mkNode NOT)))
       ;; ($_ (println! (NegatedSubtree----------------- : $negatedSubtree)))
       ($reducedSubtree (cleanTree $negatedSubtree)  )
       ;; ($_ (println! (ReducedSubtree---------------: $reducedSubtree))) 
     )
     ;; TODO: Replace this with a robust check for subtree, one that is in accordance to the way the classic checks for subtrees.
     (if (List.contains $subtree $children)
         ($subtree (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ())))
         (if (List.contains $reducedSubtree $children)
             ($reducedSubtree (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ())))
             ((mkNullVex ($subtree)) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())))))))

;; Action subtree knobs store all selectable action permutations in the knob.
;; The two-argument form follows the current embedded-knob representation.
(= (actionSubtreeKnob $perms)
   ((mkNullVex $perms)
    (mkASK (mkDiscKnob (mkMultip (+ (length $perms) 1))
                       (mkDiscSpec 0)
                       (mkDiscSpec 0)
                       ())
           $perms)))

(= (simpleActionSubtreeKnob $subtree)
   ($subtree
    (mkASK (mkDiscKnob (mkMultip 2)
                       (mkDiscSpec 1)
                       (mkDiscSpec 1)
                       ())
           (cons $subtree ()))))

;; Compatibility form for node-id based callers.
(= (actionSubtreeKnob $tree (mkNodeId $target) $perms)
   (let*
     (
       (($nullVexTree $nullVexId) (appendChild $tree (mkNodeId $target) (mkNullVex ())))
       ($multip (+ (length $perms) 1))
     )
     ($nullVexTree
      (mkASK (mkDiscKnob (mkKnob (updateID $nullVexId))
                         (mkMultip $multip)
                         (mkDiscSpec 0)
                         (mkDiscSpec 0)
                         ())
             $perms))))

(= (simpleActionSubtreeKnob $tree (mkNodeId $target))
   (let $subtree (getNodeById $tree (mkNodeId $target))
     ($tree
      (mkASK (mkDiscKnob (mkKnob (updateID (mkNodeId $target)))
                         (mkMultip 2)
                         (mkDiscSpec 1)
                         (mkDiscSpec 1)
                         ())
             (cons $subtree ())))))

;; Retrieves the node ID from a Logical Subtree Knob (LSK) or Action Subtree Knob (ASK).
;; (: getNodeId (-> LogicalSubtreeKnob NodeId))
;; (: getNodeId (-> ActionSubtreeKnob NodeId))
(= (getNodeId (mkLSK (mkDiscKnob (mkKnob $nodeId) $multi $default $current $discSpecList)))
   $nodeId)
(= (getNodeId (mkASK (mkDiscKnob (mkKnob $nodeId) $multi $default $current $discSpecList) $perms))
   $nodeId)

;; Retrieves the current and default disc specifications from an LSK or ASK.
;; (:getDiscSpec (-> LogicalSubtreeKnob (DiscSpec DiscSpec)))
;; (:getDiscSpec (-> ActionSubtreeKnob (DiscSpec DiscSpec)))
(= (getDiscSpec (mkLSK (mkDiscKnob (mkKnob $nodeId) $multi $default $current $discSpecList)))
    (let ((mkDiscSpec $def) (mkDiscSpec $cur)) ($default $current) ($def $cur)))
(= (getDiscSpec (mkASK (mkDiscKnob (mkKnob $nodeId) $multi $default $current $discSpecList) $perms))
    (let ((mkDiscSpec $def) (mkDiscSpec $cur)) ($default $current) ($def $cur)))


;; appendTo dispatcher - calls the appropriate function based on knob type
;; (: appendTo (-> (Tree $a) LogicalSubtreeKnob (Tree $a) NodeId Number (Tree $a)))
;; (: appendTo (-> (Tree $a) ActionSubtreeKnob (Tree $a) NodeId Number (Tree $a)))
(= (appendTo $updatedTree (mkLSK $discKnob) $tree $parentId $d)
    (appendToLSK $updatedTree (mkLSK $discKnob) $tree $parentId $d))
(= (appendTo $updatedTree (mkASK $discKnob $perms) $tree $parentId $d)
    (appendToASK $updatedTree (mkASK $discKnob $perms) $tree $parentId $d))

    
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
                        (let (mkNullVex (cons $child ())) $targetTree ($child (mkNodeId (union-atom $targetId (1)))))
                        ($targetTree (mkNodeId $targetId))
                    ))        
        ((mkMultip $effectiveMultip) (getKnobMultip $lsk))
        ;; ($_ (println! ("subtree ": $subtree $targetTree)))
        ;; ($_ (println! (CandidateSoFar: (preOrder $tree))))
        ;; ($_ (println! ("subtree ": (getNodeValue $subtree) parentId(OldDstId): $parentId srcId: $newSrcId targetId: $targetId)))
      )
      (if (>= $d $effectiveMultip)
          (Error $d "Invalid effective disc specification for logical knob.")
          ;; TODO: Skip multiplicity 0, we don't want to convert the subtree into a null vertex. That will bring weird behavior like nested NullVertex and the like.
          ;;       In addition, this tree is a new candidate tree needed only to be evaluated, why do we need to process null vertexes here? We want to avoid adding any.
          (let $actualD (mapEffectiveDiscSpec $lsk $d)
          (let ($treeToAppend $newDstId)
                            (case $actualD
                                (
                                  (2  ((mkTree (mkNode NOT) (cons (mkTree (getNodeValue $subtree) ()) ())) (mkNodeId (union-atom $dstId ($newPosition 1))))) ;; If negated
                                  (1  ((mkTree (getNodeValue $subtree) ()) (mkNodeId (union-atom $dstId ($newPosition))))) ;; If present
                                  (0  ((mkNullVex (cons $subtree ())) $parentId)))) ;; If absent

                            (if (isNullVertex $treeToAppend)
                                ($tree $parentId $parentId)
                                (chain (appendChild $tree $parentId $treeToAppend) $treeChIdPair
                                        ((first $treeChIdPair) $newSrcId (if (== $parentId $newDstId) (second $treeChIdPair) $newDstId))))))))) ;; INFO: Just incase if the append fails and stores the result somewhere else, we need to add a test case here to cmpare between targetNode and appendChild node.

;;;; ---------------------------------------------------------------------------
;; appendToASK appends a permutation subtree for an Action Subtree Knob.
;;
;; default 0: action-subtree ASK, append selected perm and stop recursion.
;; default 1: simple-action ASK, append existing subtree and recurse.
;; Returns ($updatedTree $newSrcId $newDstId).
;; ---------------------------------------------------------------------------
(= (appendToASK $updatedTree $ask $tree $parentId $d)
    (let*
       (
        ((mkNodeId $targetId) (getNodeId $ask))
        ((mkNodeId $dstId) (if (= (mkNodeId (0)) $parentId) (mkNodeId ()) $parentId))
        ((mkMultip $effectiveMultip) (getKnobMultip $ask))
        ((mkDiscSpec $defaultSetting) (getKnobDefault $ask))
        ((mkASK $discKnob $perms) $ask)
       )
      (if (>= $d $effectiveMultip)
          (Error $d "Invalid effective disc specification for action knob.")
          (let $actualD (mapEffectiveDiscSpec $ask $d)
            (if (== $actualD 0)
                ($tree $parentId $parentId)
                (let $expressionToAppend (List.getByIdx $perms (- $actualD 1))
                  (let $treeChIdPair (appendChild $tree $parentId $expressionToAppend)
                    (if (== $defaultSetting 0)
                        ((first $treeChIdPair) $parentId $parentId)
                        ((first $treeChIdPair) (mkNodeId $targetId) (second $treeChIdPair))))))))))
