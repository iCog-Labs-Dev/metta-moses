;;;;;;;; addLogicalKnobs ;;;;;;;;;
;; Creates and adds logical subtree knobs in to a multimap
;; Params:
;;   $exemplar: Reference tree containing the target node.
;;   (mkNodeId $targetId): ID of the target node in the exemplar.
;;   $addIfInExemplar: If true, include knobs even if in exemplar.
;;   $map: a multimap to add the new knobs into
;; Return: a tuple of ($knobSpec $knob) pair and the updated tree

;; helper function to the addLogicalKnobs
;; takes a tuple of knobs and return a tuple of knob and knobSpec pairs
(: mkPair (-> Expression Expression))
(= (mkPair $tuple)
(collapse (let*
(
    ($knob (superpose $tuple))
    ($knobSpec (getKnobSpec $knob))
)
($knobSpec $knob)
)))

;; addLogicalKnobs
(: addLogicalKnobs (-> (Tree $a) NodeId Bool (MultiMap ($k $v)) Expression))
(= (addLogicalKnobs $exemplar (mkNodeId $targetId) $addIfInExemplar $map) 
(let*
(
  ((mkTree (mkNode $op) $children) (getNodeById $exemplar (mkNodeId $targetId)))
  ($lengthOfArgs (len (ARGS)))
  ($perms (sampleLogicalPerms $op $lengthOfArgs))
  ($treePerms (map-atom $perms $perm (buildTree $perm)))
  (($knobs $updatedTree) (logicalProbe $exemplar (mkNodeId $targetId) $treePerms $addIfInExemplar ()))
  ($pairs (mkPair $knobs)) 
  ($mmp (tupleToMMap $pairs NilMMap discSpec<=))  
)
($updatedTree $mmp)
)
)