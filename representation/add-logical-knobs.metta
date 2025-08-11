;;;;;;;; addLogicalKnobs ;;;;;;;;;
;; Creates and adds logical subtree knobs in to a multimap
;; Params:
;;   $exemplar: Reference tree containing the target node.
;;   (mkNodeId $targetId): ID of the target node in the exemplar.
;;   $addIfInExemplar: If true, include knobs even if in exemplar.
;;   $map: a multimap to add the new knobs into
;;   $argLabels: list of argument labels (input variables) from the ITable
;; Return: a multimap of ($knobSpec $knob) and the updated tree

;; helper function to the addLogicalKnobs
;; takes a tuple of knobs and return a tuple of knob and knobSpec pairs
(: pairKnobWithSpec (-> Expression Expression))
(= (pairKnobWithSpec $tuple)
(collapse (let*
(
    ($knob (superpose $tuple))
    ($knobSpec (getKnobSpec $knob))
)
($knobSpec $knob)
)))


;; addLogicalKnobs
(: addLogicalKnobs (-> (Tree $a) NodeId Bool (MultiMap ($k $v)) Expression Expression))
(= (addLogicalKnobs $exemplar $nodeId $addIfInExemplar $map $argLabels) 
(let (mkTree (mkNode $op) $children) (getNodeById $exemplar $nodeId)
       (let  $lengthOfArgs (size-atom $argLabels)
          (let  $perms (sampleLogicalPerms $op $lengthOfArgs $argLabels)
            (let  $treePerms (map-atom $perms $perm (buildTree $perm))
              (let ($knobs $updatedTree) (logicalProbe $exemplar $nodeId $treePerms $addIfInExemplar ())
                (let  $pairs (pairKnobWithSpec $knobs)
                  (chain (expToMMap $pairs $map discSpec<=) $mmp
                    ($updatedTree $mmp))
                )
              )
            )
          )
       )
)
)