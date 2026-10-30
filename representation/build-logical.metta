;; buildLogical => Build logical knobs for a tree and its children
;; Params:
;;       $tree: The tree being updated (a tree or a knob wrapper)
;;       $parentOp: The operator of the parent node
;;       $MMap: Multimap to store disc_spec and knobs.
;;       $argLabels: list of argument labels (input variables) from the ITable
;;       $globalTree, $currentNodeId: the exemplar and the absolute id of $tree in it
;; Return: Updated tree and multimap.

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
   (buildLogical (mkKnob (mkNullVex $children) $lsk $i) $parentOp $MMap $argLabels True (mkKnob (mkNullVex $children) $lsk $i) (mkNodeId (0)) (param ignoreOps)))
(= (buildLogical (mkKnob (mkNullVex $children) $lsk $i) $parentOp $MMap $argLabels $disable-discprobe)
   (buildLogical (mkKnob (mkNullVex $children) $lsk $i) $parentOp $MMap $argLabels $disable-discprobe (mkKnob (mkNullVex $children) $lsk $i) (mkNodeId (0)) (param ignoreOps)))

(= (buildLogical (mkKnob (mkNullVex $children) $lsk $i) $parentOp $MMap $argLabels $disable-discprobe $globalTree $currentNodeId $ignoreOps)
   ;; (let $x (println! ("Reaching knob")) ((mkKnob $tree $lsk $i) $MMap)))
   ((mkKnob (mkNullVex $children) $lsk $i) $MMap))

;; --- knob-wrapper clauses (mkTree) ---
(= (buildLogical (mkKnob (mkTree $node $children) $lsk $i) $parentOp $MMap $argLabels)
   (buildLogical (mkKnob (mkTree $node $children) $lsk $i) $parentOp $MMap $argLabels True (mkKnob (mkTree $node $children) $lsk $i) (mkNodeId (0)) (param ignoreOps)))
(= (buildLogical (mkKnob (mkTree $node $children) $lsk $i) $parentOp $MMap $argLabels $disable-discprobe)
   (buildLogical (mkKnob (mkTree $node $children) $lsk $i) $parentOp $MMap $argLabels $disable-discprobe (mkKnob (mkTree $node $children) $lsk $i) (mkNodeId (0)) (param ignoreOps)))
;; Knob wrappers forward $globalTree and $currentNodeId unchanged into the
;; inner subtree's recursion — the wrapper does not advance the path.
(= (buildLogical (mkKnob (mkTree $node $children) $lsk $i) $parentOp $MMap $argLabels $disable-discprobe $globalTree $currentNodeId $ignoreOps)
   (let ($uTree $uMMap) (buildLogical (mkTree $node $children) $parentOp $MMap $argLabels $disable-discprobe $globalTree $currentNodeId $ignoreOps) ((mkKnob $uTree $lsk $i) $uMMap)))

;; --- main mkTree clauses ---
(= (buildLogical (mkTree (mkNode $node) $children) $MMap $argLabels)
   (buildLogical (mkTree (mkNode $node) $children) $node $MMap $argLabels True (mkTree (mkNode $node) $children) (mkNodeId (0)) (param ignoreOps)))
(= (buildLogical (mkTree (mkNode $node) $children) $parentOp $MMap $argLabels)
   (buildLogical (mkTree (mkNode $node) $children) $parentOp $MMap $argLabels True (mkTree (mkNode $node) $children) (mkNodeId (0)) (param ignoreOps)))

(= (buildLogical (mkTree (mkNode $node) $children) $parentOp $MMap $argLabels $disable-discprobe)
   (buildLogical (mkTree (mkNode $node) $children) $parentOp $MMap $argLabels $disable-discprobe (mkTree (mkNode $node) $children) (mkNodeId (0)) (param ignoreOps)))

(= (buildLogical (mkTree (mkNode $node) $children) $parentOp $MMap $argLabels $disable-discprobe $globalTree $currentNodeId $ignoreOps)
   (if (once (is-member $node (quote (AND OR))))
       (let*
           (
             ;; ($_ (println! (BuildLogical 0)))
             ($swapped (swapAndOr $parentOp))
             ;; ($_ (println! (BulidLogical 1)))
             (($t1 $mp1) (addLogicalKnobsFast (mkTree (mkNode $node) $children) True $MMap $argLabels $disable-discprobe $globalTree $currentNodeId $ignoreOps))
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
                                                                (($tree $map) (buildLogical $ch $node $prevMap $argLabels $disable-discprobe $globalTree $childNodeId $ignoreOps))
                                                              )
                                                              ((cons $tree $prevTrees) $map))))

            (($childrenWithCandidate $lastMp1)
                (if (operatorAllowed (swapAndOr $node) $ignoreOps)
                    (let* ((($lastUpdatedTree $lastMp1) (addLogicalKnobsFast (mkTree (mkNode (swapAndOr $node)) ()) True $updatedMMap $argLabels $disable-discprobe $globalTree $currentNodeId $ignoreOps)))
                         ((append (reverse $updatedChildren) ($lastUpdatedTree)) $lastMp1))
                    ((reverse $updatedChildren) $updatedMMap)))
             ;; ($_ (println! (BulidLogical 4)))
           )

          ((mkTree (mkNode $node) $childrenWithCandidate) $lastMp1))

          (if (operatorAllowed (swapAndOr $parentOp) $ignoreOps)
              (addLogicalKnobsFast(mkTree (mkNode (swapAndOr $parentOp)) ((mkTree (mkNode $node) $children))) (not (isAnArgument $node)) $MMap $argLabels $disable-discprobe $globalTree $currentNodeId $ignoreOps)
             ((mkTree (mkNode $node) $children) $MMap))))
