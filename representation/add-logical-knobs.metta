;;;;;;;; addLogicalKnotree knobs in to a multimap
;; Params:
;;   $exemplar: Reference tree containing the target node.
;;   (mkNodeId $targetId): ID of the target node in the exemplar.
;;   $addIfInExemplar: If true, include knobs even if in exemplar.
;;   $map: a multimap to add the new knobs into
;;   $argLabels: list of argument labels (input variables) from the ITable
;; Return: a multimap of ($knobSpec $knob) and the updated tree

;; helper function to the addLogicalKnobs
;; takes a tuple of knobs and return a tuple of knob and knobSpec pairs
;; (: pairKnobWithSpec (-> Expression Expression))
(= (pairKnobWithSpec $tuple)   (map-atom $tuple $knob ( (getKnobSpec $knob) $knob) ))

;; addLogicalKnobs
;; (: addLogicalKnobs (-> (Tree $a) NodeId Bool (MultiMap ($k $v)) Expression Expression))
(= (addLogicalKnobs $exemplar $nodeId $addIfInExemplar $map $argLabels) 
   (let*
     (
      ((mkTree (mkNode $op) $children) (getNodeById $exemplar $nodeId))
      ;; ($_ (println! (Adding knobs to: (preOrder (mkTree (mkNode $op) $children)))))
      ($lengthOfArgs (size-atom $argLabels))
      ($perms (sampleLogicalPerms $op $lengthOfArgs $argLabels))
      ($treePerms (map-atom $perms $perm (buildTree $perm)))
      (($knobs $updatedTree) (logicalProbe $exemplar $nodeId $treePerms $addIfInExemplar ()))

      ;; ($_ (println! (Adding (length $knobs) Knobs)))

      ($pairs (pairKnobWithSpec $knobs))
      ($mmp (expToMMap $pairs $map discSpec<))
      ($_ (cut))
     )
     ($updatedTree $mmp)))
