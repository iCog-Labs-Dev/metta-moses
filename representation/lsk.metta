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


;; get node id from lsk
(: getNodeId (-> LogicalSubtreeKnob NodeId))
(= (getNodeId (mkLSK (mkDiscKnob (mkKnob $tree $nodeId) $multi $default $current $discSpecList) $subtree))
   $nodeId)

;; get current and default disc spec
(: getDiscSpec (-> LogicalSubtreeKnob (DiscSpec DiscSpec)))
(= (getDiscSpec (mkLSK (mkDiscKnob (mkKnob $tree $nodeId) $multi $default $current $discSpecList) $subtree))
    (let ((mkDiscSpec $def) (mkDiscSpec $cur)) ($default $current) ($def $cur)))

;; get subtree from lsk
(: getSubtree (-> LogicalSubtreeKnob (Tree $a)))
(= (getSubtree (mkLSK $disknob $subtree))
    $subtree)

;; appendTo -- appends a subtree in place of a logical subtree using information from the lsk 
;;          -- $tree is an tree decorated with logica subtree knobs
;;          -- $lsk is a the knob containing information of how the subtree is appeneded to the original tree 

(: appendTo (-> (Tree $a) LogicalSubtreeKnob (Tree $a)))
(= (appendTo $tree $lsk)
    (let* (($nodeId (getNodeId $lsk))
            (($current $default) (getDiscSpec $lsk))
            ($subtree (getSubtree $lsk)))

            (if (> $current 2)
              (Error $current "Invalid disc specification:- cannot exceed 2.")
              (if (isEmpty $tree)
                $subtree
                (let $treeToAppend 
                   (case ($current $default)
                        (((2 1) (insertAbove $subtree (mkNode NOT))) ;; If negated but present in the tree
                         ((2 0) (let $child (getChildrenByIdx $subtree 0) (insertAbove $child (mkNode NOT)))) ;; If negated but not present in the tree
                         ($else (if (and (not (== $current 0)) (== $default 1)) ;; If not absent and is present
                                $subtree
                                (getChildrenByIdx $subtree 0))))) ;; If not absent and not present
                    (replaceNodeById $tree $nodeId $treeToAppend))))))
