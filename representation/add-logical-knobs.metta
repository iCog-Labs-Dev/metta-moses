;;;;;;;; addLogicalKnobs ;;;;;;;;;
;; Creates and adds logical subtree knobs in to a multimap
;; Params:
;;   $exemplar: Reference tree containing the target node.
;;   (mkNodeId $targetId): ID of the target node in the exemplar.
;;   $addIfInExemplar: If true, include knobs even if in exemplar.
;;   $map: a multimap to add the new knobs into
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
(: addLogicalKnobs (-> (Tree $a) NodeId Bool (MultiMap ($k $v)) Expression))
(= (addLogicalKnobs $exemplar $nodeId $addIfInExemplar $map) 
(let*
(
  ((mkTree (mkNode $op) $children) (getNodeById $exemplar $nodeId))
  ($lengthOfArgs (len (ARGS)))
  ($perms (sampleLogicalPerms $op $lengthOfArgs))
  ($treePerms (map-atom $perms $perm (buildTree $perm)))
  (($knobs $updatedTree) (logicalProbe $exemplar $nodeId $treePerms $addIfInExemplar ()))
  ($pairs (pairKnobWithSpec $knobs)) 
  ($mmp (expToMMap $pairs NilMMap discSpec<=))  
)
($updatedTree $mmp)
)
)
