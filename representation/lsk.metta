;;;;;;;;;;;;;;;;; LSK Constructor ;;;;;;;;;;;;;;;;;;;;;;;;

(: logicalSubtreeKnob (-> (Tree $a) NodeId (Tree $a) LogicalSubtreeKnob))
(= (logicalSubtreeKnob $tree (mkNodeId $target) $subtree)
   (let*
   (
    ($negatedSubtree (insertAbove $subtree (mkNode NOT)))
    ($reducedSubtree $negatedSubtree)  ;;;after the reduct integration, the reduction step will be applied here 
    ($childrenOfTarget (getChildrenById $tree (mkNodeId $target)))
   )
   (if (List.contains $subtree $childrenOfTarget) 
       (let $idOfSubtree (getSubtreeId $tree (mkNodeId $target) $subtree 0) 
           (mkLSK (mkDiscKnob (mkKnob $tree $idOfSubtree) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) Nil) $subtree))
       (if (List.contains $reducedSubtree $childrenOfTarget)
           (let $idOfReducedSubtree (getSubtreeId $tree (mkNodeId $target) $reducedSubtree 0) 
                (mkLSK (mkDiscKnob (mkKnob $tree $idOfReducedSubtree) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) Nil) $subtree))
           (let*
           (
            (($nullVexAppendedTree $nullVexId) (appendChild $tree (mkNodeId $target) (mkNullVex Nil)))
            (($subtreeAppendedTree $subtreeId) (appendChild $nullVexAppendedTree $nullVexId $subtree))
           )
           (mkLSK (mkDiscKnob (mkKnob $subtreeAppendedTree $nullVexId) (mkMultip 3)) $subtree)
           )
       )
   )
   )
)