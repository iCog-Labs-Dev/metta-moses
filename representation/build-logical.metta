;; siblingit => Iterate over list of Tree children and build logical knobs for each node
;; Extended to support PRIORITIZED-OR for game strategies
;;params:
;;       $tree: The tree being updated
;;       $childrens: List of children to iterate over.
;;       $parentId: ID of the parent node.
;;       $childNum: Current child number.
;;       $swapedOp: Swapped operator symbol.
;;       $MMap: Multimap to store disc_pec and knobs.
;;       $argLabels: list of argument labels (input variables) from the ITable
;; Return: Updated tree and multimap.
;; (: siblingit (-> (Tree $a) (List (Tree $a)) NodeId Number Symbol (MultiMap ($k $v)) Expression ((Tree $a) (MultiMap ($k $v)))))
(= (siblingit $tree () (mkNodeId $parentId) $childNum $swapedOp $MMap $argLabels) ($tree $MMap))
(= (siblingit $tree (cons $head $tail) (mkNodeId $parentId) $childNum $swapedOp $MMap $argLabels)
        (let*
             (
                ;; ($_ (println! "siblingit called"))
                ($curId (if (== $parentId (0))
                            ($childNum)
                           (concatT $parentId ($childNum))))
                ((mkTree (mkNode $node) $childern) $head)
                ;; ($_ (println!( "curId: " $curId "node :" $node)))
                ;; ($_ (println!( "head: " $head "tail :" $tail)))
                (($tNew  $mNew) (if (is-member $node (AND OR PRIORITIZED-OR));; only build logical knobs for AND/OR nodes, creating sampleLogicalPerms
                                    (if (== $node PRIORITIZED-OR)
                                        (buildStrategy $tree (mkNodeId $curId) $MMap $argLabels)
                                        (buildLogical $tree (mkNodeId $curId) $MMap $argLabels))
                                        (if (== $swapedOp PRIORITIZED-OR)
                                            ;; Game move terminals - no transformation needed
                                            ($tree $MMap)
                                            ;; Boolean logic terminals - insert operator and add knobs
                                           (let  $itree (insertNodeAtPosition $tree (mkNodeId $curId) (mkNode $swapedOp))
                                                  (if (isAnArgument $node)
                                                      (addLogicalKnobs $itree (mkNodeId $curId) False $MMap $argLabels) ;; INFO: Due to the structure of the pointer in the classic, after adding a knob here, the iteration terminates and goes to the parent node even though there are still other siblings. For now this seemed to be the correct approach so living it as it is, but needs an investigation for later.
                                                      (addLogicalKnobs $itree (mkNodeId $curId) True $MMap $argLabels))))))
                ;;($_ (println! $tNew))
                (($tailT $tailM) (siblingit $tNew $tail (mkNodeId $parentId) (+ $childNum 1) $swapedOp $mNew $argLabels))
                
             )
             ($tailT $tailM)))

;; buildLogical => Build logical knobs for a given NodeId and its children
;;params:
;;       $tree: The tree being updated
;;       $nodeId: ID of the node to build logical knobs for.
;;       $MMap: Multimap to store disc_pec and knobs.
;;       $argLabels: list of argument labels (input variables) from the ITable
;; Return: Updated tree and multimap.
;; (: buildLogical (-> (Tree $a) NodeId (MultiMap ($k $v)) Expression ((Tree $a) (MultiMap ($k $v))))) 
(= (buildLogical $tree (mkNodeId $nodeId) $MMap $argLabels)
  (let $subtree (getNodeById $tree (mkNodeId $nodeId))
    (if (== True (isNullVertex $subtree))
        (let $x (println! ("reaching Null Vector ")) ($tree $MMap)) 
        (let*
        (
            ;; ($_ (println! (Started building at: (preOrder $subtree))))
            ;; ($_ (println! ("****************Building logical knobs for NodeId:**************** " $argLabels $nodeId)))
            ((mkTree (mkNode $op) $childrens) $subtree) 
            ($swapped (swapAndOr $op))
            ;; ($_ (println! ("Operator: " $op " swapped to: " $swapped)))
            (($t1 $mp1) (addLogicalKnobs $tree (mkNodeId $nodeId) True $MMap $argLabels))
            ;; ($_ (println! ("Building logical knobs for NodeId: " $nodeId " with operator: " $op " swapped to: " $swapped)))
            ;; ($_ (println! (Adding knobs to (List.length $childrens) childs)))
            ;; INFO: An attempt to replicate opencog's behavior but limits the quality drastically
            ;; (($sibToIterate $sibToConcat) (if (= $childrens ())
            ;;                                   (() ())
            ;;                                   (let (mkTree (mkNode $x) $grandChildren) (List.head $childrens) 
            ;;                                        (if (and (isAnArgument $x) (= $grandChildren ()))
            ;;                                            ((cons (List.head $childrens) ()) (List.tail $childrens))
            ;;                                            ($childrens ())))))
            ;; ($_ (println! (SibToIterate: $sibToIterate SibToConcat: $sibToConcat)))

            (($updatedTree $updatedMMap) (siblingit $t1 $childrens (mkNodeId $nodeId) 1 $swapped $mp1 $argLabels))
            ;; (($updatedTree $updatedMMap) (siblingit $t1 $sibToIterate (mkNodeId $nodeId) 1 $swapped $mp1 $argLabels))
            ;; (($childrenUpdatedTree $lastNewId) (eval (List.foldl (|-> ($childToAppend ($treeAcc $newId)) (appendChild $treeAcc (mkNodeId $nodeId) $childToAppend)) ($updatedTree (mkNodeId $nodeId))  $sibToConcat)))
            ;;$append (appendChild $updatedTree $nodeId (mkNode $filp)))                                 ;; this part will add much complexity to the tree, not worth the cost

            (($appendedTree $newId) (appendChild $updatedTree (mkNodeId $nodeId) (mkTree (mkNode $swapped) ())))
            ;; (($appendedTree $newId) (appendChild $childrenUpdatedTree (mkNodeId $nodeId) (mkTree (mkNode $swapped) ())))
            (($lastUpdatedTree $lastMp1) (addLogicalKnobs $appendedTree $newId True $updatedMMap $argLabels))
        )
            ($lastUpdatedTree $lastMp1)))))
;; buildStrategy => Build strategy knobs for PRIORITIZED-OR nodes
;; (: buildStrategy (-> (Tree $a) NodeId (MultiMap ($k $v)) Expression ((Tree $a) (MultiMap ($k $v))))) 
(= (buildStrategy $tree (mkNodeId $nodeId) $MMap $argLabels)
  (let $subtree (getNodeById $tree (mkNodeId $nodeId))
    ;; Safety Check
    (if (== True (isNullVertex $subtree))
        ($tree $MMap) 
        (let*
        (
            ($_ (println! ("****************Building strategy knobs for NodeId:**************** " $argLabels $nodeId)))
            ;; Deconstruct the current node
            ((mkTree (mkNode $op) $children) $subtree) 
            ($_ (println! ("Operator: " $op " (no swapping for game strategies)")))
            ;; Add game knobs to the current PRIORITIZED-OR node
            (($t1 $mp1) (addLogicalKnobs $tree (mkNodeId $nodeId) True $MMap $argLabels))
            ($_ (println! ("Building strategy knobs for NodeId: " $nodeId " with operator: " $op)))
            ;; Process Children using unified sibling iterator with PRIORITIZED-OR (no swapping)
            (($updatedTree $updatedMMap) (siblingit $t1 $children (mkNodeId $nodeId) 1 $op $mp1 $argLabels))
        )
            ($updatedTree $updatedMMap)))))
