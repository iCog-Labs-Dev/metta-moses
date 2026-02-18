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
(= (siblingit $tree Nil (mkNodeId $parentId) $childNum $swapedOp $MMap $argLabels) ($tree $MMap))
(= (siblingit $tree (Cons $head $tail) (mkNodeId $parentId) $childNum $swapedOp $MMap $argLabels)
        (let*
             (
                ($_ (println! "siblingit called"))
                ($curId (if (== $parentId (0))
                            ($childNum)
                           (concatT $parentId ($childNum))))
                ;; Check if head is mkNullVex and extract actual tree if so
                ($actualHead (if (eval (isNullVertex $head))
                                 (let (mkNullVex (Cons $innerTree Nil)) $head $innerTree)
                                 $head))
                ((mkTree (mkNode $node) $childern) $actualHead)
                ;; ($_ (println!( "curId: " $curId "node :" $node)))
                ;; ($_ (println!( "head: " $head "tail :" $tail)))
                (($tNew  $mNew) 
                    (if (is-member $node (AND OR PRIORITIZED-OR))
                        ;; Control nodes - recurse with appropriate builder
                        (if (== $node PRIORITIZED-OR)
                            (eval (buildStrategy $tree (mkNodeId $curId) $MMap $argLabels))
                            (eval (buildLogical $tree (mkNodeId $curId) $MMap $argLabels)))
                        ;; Terminal nodes - for game strategies, just return unchanged
                        (if (== $swapedOp PRIORITIZED-OR)
                            ;; Game move terminals - no transformation needed
                            ($tree $MMap)
                            ;; Boolean logic terminals - insert operator and add knobs
                            (let $itree (eval (insertNodeAtPosition $tree (mkNodeId $curId) (mkNode $swapedOp)))
                                (eval (addLogicalKnobs $itree (mkNodeId $curId) True $MMap $argLabels))))))
                ;;($_ (println! $tNew))
                (($tailT $tailM) (eval (siblingit $tNew $tail (mkNodeId $parentId) (+ $childNum 1) $swapedOp $mNew $argLabels)))
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
  (let $subtree (eval (getNodeById $tree (mkNodeId $nodeId)))
    (if (== True (eval (isNullVertex $subtree)))
        (let $x (println! ("reaching Null Vector ")) ($tree $MMap)) 
        (let*
        (
            ($_ (println! ("****************Building logical knobs for NodeId:**************** " $argLabels $nodeId)))
            ((mkTree (mkNode $op) $childrens) $subtree) 
            ($swapped (eval (swapAndOr $op)))
            ($_ (println! ("Operator: " $op " swapped to: " $swapped)))
            (($t1 $mp1) (eval (addLogicalKnobs $tree (mkNodeId $nodeId) True $MMap $argLabels)))
            ($_ (println! ("Building logical knobs for NodeId: " $nodeId " with operator: " $op " swapped to: " $swapped)))
            (($updatedTree $updatedMMap) (siblingit $t1 $childrens (mkNodeId $nodeId) 1 $swapped $mp1 $argLabels))
        )
            ($updatedTree $updatedMMap)))))

;; buildStrategy => Build strategy knobs for PRIORITIZED-OR nodes
;; (: buildStrategy (-> (Tree $a) NodeId (MultiMap ($k $v)) Expression ((Tree $a) (MultiMap ($k $v))))) 
(= (buildStrategy $tree (mkNodeId $nodeId) $MMap $argLabels)
  (let $subtree (eval (getNodeById $tree (mkNodeId $nodeId)))
    ;; Safety Check
    (if (== True (eval (isNullVertex $subtree)))
        ($tree $MMap) 
        (let*
        (
            ($_ (println! ("****************Building strategy knobs for NodeId:**************** " $argLabels $nodeId)))
            ;; Deconstruct the current node
            ((mkTree (mkNode $op) $children) $subtree) 
            ($_ (println! ("Operator: " $op " (no swapping for game strategies)")))
            ;; Add game knobs to the current PRIORITIZED-OR node
            (($t1 $mp1) (eval (addLogicalKnobs $tree (mkNodeId $nodeId) True $MMap $argLabels)))
            ($_ (println! ("Building strategy knobs for NodeId: " $nodeId " with operator: " $op)))
            ;; Process Children using unified sibling iterator with PRIORITIZED-OR (no swapping)
            (($updatedTree $updatedMMap) (eval (siblingit $t1 $children (mkNodeId $nodeId) 1 $op $mp1 $argLabels)))
        )
            ($updatedTree $updatedMMap)))))