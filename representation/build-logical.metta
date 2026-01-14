;; siblingit => Itreate over list of Tree childrens and build logical knobs for each node
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
                           (concatT $parentId ($childNum))      
                        ))
                ((mkTree (mkNode $node) $childern) $head)
                ;; ($_ (println!( "curId: " $curId "node :" $node)))
                ;; ($_ (println!( "head: " $head "tail :" $tail)))
                (($tNew  $mNew) (if (is-member $node (AND OR));; only build logical knobs for AND/OR nodes, creating sampleLogicalPerms
                                (eval (buildLogical $tree (mkNodeId $curId) $MMap $argLabels))
                                (let  $itree (eval (insertNodeAtPosition $tree (mkNodeId $curId) (mkNode $swapedOp))) (eval (addLogicalKnobs $itree (mkNodeId $curId) True $MMap $argLabels)))
                            ))
                ;;($_ (println! $tNew))
                (($tailT $tailM) (eval (siblingit $tNew $tail (mkNodeId $parentId )(+ $childNum 1) $swapedOp $mNew $argLabels)))
                
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
            (($updatedTree $updatedMMap) (eval (siblingit $t1 $childrens (mkNodeId $nodeId) 1 $swapped $mp1 $argLabels)))
            ;;$append (appendChild $updatedTree $nodeId (mkNode $filp)))                                 ;; this part will add much complexity to the tree, not worth the cost
        )
            ($updatedTree $updatedMMap)
        )
    )
  )
)
