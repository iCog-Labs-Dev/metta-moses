;; buildLogical => Build logical knobs for a given NodeId and its children
;;params:
;;       $tree: The tree being updated
;;       $nodeId: ID of the node to build logical knobs for.
;;       $MMap: Multimap to store disc_pec and knobs.
;;       $argLabels: list of argument labels (input variables) from the ITable
;; Return: Updated tree and multimap.
;; (: buildLogical (-> (Tree $a) NodeId (MultiMap ($k $v)) Expression ((Tree $a) (MultiMap ($k $v))))) 
;; (= (buildLogical $tree (mkNodeId $nodeId) $MMap $argLabels)
;;   (let $subtree (getNodeById $tree (mkNodeId $nodeId))
;;     (if (== True (isNullVertex $subtree))
;;         (let $x (println! ("reaching Null Vector ")) ($tree $MMap)) 
;;         (let*
;;         (
;;             ;; ($_ (println! (Started building at: (preOrder $subtree))))
;;             ;; ($_ (println! ("****************Building logical knobs for NodeId:**************** " $argLabels $nodeId)))
;;             ((mkTree (mkNode $op) $childrens) $subtree) 
;;             ($swapped (swapAndOr $op))
;;             ;; ($_ (println!("Operator: " $op " swapped to: " $swapped)))
;;             (($t1 $mp1) (addLogicalKnobs $tree (mkNodeId $nodeId) True $MMap $argLabels))
;;             ;; ($_ (println! ("Building logical knobs for NodeId: " $nodeId " with operator: " $op " swapped to: " $swapped)))
;;             ;; ($_ (println! (Adding knobs to (List.length $childrens) childs)))
;;             ;; INFO: An attempt to replicate opencog's behavior but limits the quality drastically
;;             ;; (($sibToIterate $sibToConcat) (if (= $childrens ())
;;             ;;                                   (() ())
;;             ;;                                   (let (mkTree (mkNode $x) $grandChildren) (List.head $childrens) 
;;             ;;                                        (if (and (isAnArgument $x) (= $grandChildren ()))
;;             ;;                                            ((cons (List.head $childrens) ()) (List.tail $childrens))
;;             ;;                                            ($childrens ())))))
;;             ;; ($_ (println! (SibToIterate: $sibToIterate SibToConcat: $sibToConcat)))
;;
;;             (($updatedTree $updatedMMap) (siblingit $t1 $childrens (mkNodeId $nodeId) 1 $swapped $mp1 $argLabels))
;;             ;; (($updatedTree $updatedMMap) (siblingit $t1 $sibToIterate (mkNodeId $nodeId) 1 $swapped $mp1 $argLabels))
;;             ;; (($childrenUpdatedTree $lastNewId) (eval (List.foldl (|-> ($childToAppend ($treeAcc $newId)) (appendChild $treeAcc (mkNodeId $nodeId) $childToAppend)) ($updatedTree (mkNodeId $nodeId))  $sibToConcat)))
;;             ;;$append (appendChild $updatedTree $nodeId (mkNode $filp)))                                 ;; this part will add much complexity to the tree, not worth the cost
;;
;;             (($appendedTree $newId) (appendChild $updatedTree (mkNodeId $nodeId) (mkTree (mkNode $swapped) ())))
;;             ;; (($appendedTree $newId) (appendChild $childrenUpdatedTree (mkNodeId $nodeId) (mkTree (mkNode $swapped) ())))
;;             (($lastUpdatedTree $lastMp1) (addLogicalKnobs $appendedTree $newId True $updatedMMap $argLabels))
;;         )
;;             ($lastUpdatedTree $lastMp1)))))

;; Compute the absolute NodeId for a child during the buildLogical foldl-atom
;; recursion. Per the design: knob wrappers don't advance the path (they're
;; transparent metadata), so the recursion forwards the parent's NodeId. For
;; non-knob children, find their position in the original $children list and
;; concatenate that 1-indexed position onto $currentNodeId.
(= (computeChildNodeId $currentNodeId $children $ch)
   (case $ch
      (
        ((mkKnob $subtree $lsk $i) $currentNodeId)
        ($other (let $idx (List.index $children $ch)
                   (if (== $idx -1)
                       $currentNodeId
                       (childNodeId $currentNodeId (+ $idx 1))))))))

;; --- knob-wrapper clauses (mkNullVex) ---
(= (buildLogical (mkKnob (mkNullVex $children) $lsk $i) $parentOp $MMap $argLabels)
   (buildLogical (mkKnob (mkNullVex $children) $lsk $i) $parentOp $MMap $argLabels True (mkKnob (mkNullVex $children) $lsk $i) (mkNodeId (0))))
(= (buildLogical (mkKnob (mkNullVex $children) $lsk $i) $parentOp $MMap $argLabels $disable-discprobe)
   (buildLogical (mkKnob (mkNullVex $children) $lsk $i) $parentOp $MMap $argLabels $disable-discprobe (mkKnob (mkNullVex $children) $lsk $i) (mkNodeId (0))))
(= (buildLogical (mkKnob (mkNullVex $children) $lsk $i) $parentOp $MMap $argLabels $disable-discprobe $globalTree $currentNodeId)
   ;; (let $x (println! ("Reaching knob")) ((mkKnob $tree $lsk $i) $MMap)))
   ((mkKnob (mkNullVex $children) $lsk $i) $MMap))

;; --- knob-wrapper clauses (mkTree) ---
(= (buildLogical (mkKnob (mkTree $node $children) $lsk $i) $parentOp $MMap $argLabels)
   (buildLogical (mkKnob (mkTree $node $children) $lsk $i) $parentOp $MMap $argLabels True (mkKnob (mkTree $node $children) $lsk $i) (mkNodeId (0))))
(= (buildLogical (mkKnob (mkTree $node $children) $lsk $i) $parentOp $MMap $argLabels $disable-discprobe)
   (buildLogical (mkKnob (mkTree $node $children) $lsk $i) $parentOp $MMap $argLabels $disable-discprobe (mkKnob (mkTree $node $children) $lsk $i) (mkNodeId (0))))
;; Knob wrappers forward $globalTree and $currentNodeId unchanged into the
;; inner subtree's recursion — the wrapper does not advance the path.
(= (buildLogical (mkKnob (mkTree $node $children) $lsk $i) $parentOp $MMap $argLabels $disable-discprobe $globalTree $currentNodeId)
   (let ($uTree $uMMap) (buildLogical (mkTree $node $children) $parentOp $MMap $argLabels $disable-discprobe $globalTree $currentNodeId) ((mkKnob $uTree $lsk $i) $uMMap)))

;; --- main mkTree clauses ---
(= (buildLogical (mkTree (mkNode $node) $children) $MMap $argLabels)
   (buildLogical (mkTree (mkNode $node) $children) $node $MMap $argLabels True (mkTree (mkNode $node) $children) (mkNodeId (0))))
(= (buildLogical (mkTree (mkNode $node) $children) $parentOp $MMap $argLabels)
   (buildLogical (mkTree (mkNode $node) $children) $parentOp $MMap $argLabels True (mkTree (mkNode $node) $children) (mkNodeId (0))))

(= (buildLogical (mkTree (mkNode $node) $children) $parentOp $MMap $argLabels $disable-discprobe)
   (buildLogical (mkTree (mkNode $node) $children) $parentOp $MMap $argLabels $disable-discprobe (mkTree (mkNode $node) $children) (mkNodeId (0))))

(= (buildLogical (mkTree (mkNode $node) $children) $parentOp $MMap $argLabels $disable-discprobe $globalTree $currentNodeId)
   (if (once (is-member $node (quote (AND OR))))
       (let*
           (
             ;; ($_ (println! (BuildLogical 0)))
             ($swapped (swapAndOr $parentOp))
             ;; ($_ (println! (BulidLogical 1)))
             (($t1 $mp1) (addLogicalKnobsFast (mkTree (mkNode $node) $children) True $MMap $argLabels $disable-discprobe $globalTree $currentNodeId))
             ((mkTree (mkNode $node) $newChildren) $t1)
             ;; ($_ (println! (BulidLogical 2)))
             ;; ($_ (println! (newChildren: $newChildren)))
             (($updatedChildren $updatedMMap) (foldl-atom $newChildren (() $mp1) $acc $ch
                                                          (let*
                                                              (
                                                                (($prevTrees $prevMap) $acc)
                                                                ;; Compute child's absolute NodeId: knob wrappers inherit
                                                                ;; $currentNodeId; non-knob children use their original
                                                                ;; position in $children to extend the path.
                                                                ($childNodeId (computeChildNodeId $currentNodeId $children $ch))
                                                                (($tree $map) (buildLogical $ch $node $prevMap $argLabels $disable-discprobe $globalTree $childNodeId))
                                                              )
                                                              ((cons $tree $prevTrees) $map))))
             ;; ($_ (println! (BulidLogical 3)))
             (($lastUpdatedTree $lastMp1) (addLogicalKnobsFast (mkTree (mkNode (swapAndOr $node)) ()) True $updatedMMap $argLabels $disable-discprobe $globalTree $currentNodeId))
             ;; ($_ (println! (BulidLogical 4)))
           )
           ((mkTree (mkNode $node) (append (reverse $updatedChildren) ($lastUpdatedTree))) $lastMp1))
       (addLogicalKnobsFast (mkTree (mkNode (swapAndOr $parentOp)) ((mkTree (mkNode $node) $children))) (not (isAnArgument $node)) $MMap $argLabels $disable-discprobe $globalTree $currentNodeId)))
