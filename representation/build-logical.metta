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
(: siblingit (-> (Tree $a) (List (Tree $a)) NodeId Number Symbol (MultiMap ($k $v)) Expression ((Tree $a) (MultiMap ($k $v)))))
(= (siblingit $tree Nil (mkNodeId $parentId) $childNum $swapedOp $MMap $argLabels) ($tree $MMap))
(= (siblingit $tree (Cons $head $tail) (mkNodeId $parentId) $childNum $swapedOp $MMap $argLabels)
        (let*
             (
                ;; (() (println! "siblingit called"))
                ($curId (concatT $parentId ($childNum)))
                ((mkTree (mkNode $node) $childern) $head)
                ;; (() (println!( "curId: " $curId "node :" $node)))
                ;; (() (println!( "head: " $head "tail :" $tail)))
                (($tNew  $mNew) (if (isMember $node (AND OR NOT));;
                                (buildLogical $tree (mkNodeId $curId) $MMap $argLabels)
                                (let  $itree (insertNodeAtPosition $tree (mkNodeId $curId) (mkNode $swapedOp))  (addLogicalKnobs $itree (mkNodeId $curId) True $MMap $argLabels))
                            ))
                ;;(() (println! $tNew))
                (($tailT $tailM) (siblingit $tNew $tail (mkNodeId $parentId )(+ $childNum 1) $swapedOp $mNew $argLabels))
                
             )
             ($tailT $tailM)))

;; buildLogical => Build logical knobs for a given NodeId and its children
;;params:
;;       $tree: The tree being updated
;;       $nodeId: ID of the node to build logical knobs for.
;;       $MMap: Multimap to store disc_pec and knobs.
;;       $argLabels: list of argument labels (input variables) from the ITable
;; Return: Updated tree and multimap.
(: buildLogical (-> (Tree $a) NodeId (MultiMap ($k $v)) Expression ((Tree $a) (MultiMap ($k $v))))) 
(= (buildLogical $tree (mkNodeId $nodeId) $MMap $argLabels)
  (let $subtree (getNodeById $tree (mkNodeId $nodeId)) 
    (if (isNullVertex $subtree)
        (let $x (println! ("reaching Null Vector ")) ($tree $MMap)) 
        (let*
        (
            ((mkTree (mkNode $op) $childrens) $subtree) 
            ($swapped (swapAndOr $op))
            (($t1 $mp1) (addLogicalKnobs $tree (mkNodeId $nodeId) True $MMap $argLabels))
            (($updatedTree $updatedMMap) (siblingit $t1 $childrens (mkNodeId $nodeId) 1 $swapped $mp1 $argLabels))
            ;;$append (appendChild $updatedTree $nodeId (mkNode $filp)))                                 ;; this part will add much complexity to the tree, not worth the cost
        )
            ($updatedTree $updatedMMap)
        )
    )
  )
)