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
(= (pairKnobWithSpec $tuple)   (map-atom $tuple $knob ( (eval (getKnobSpec $knob)) $knob) ))

;; addLogicalKnobs
;; (: addLogicalKnobs (-> (Tree $a) NodeId Bool (MultiMap ($k $v)) Expression Expression))
(= (addLogicalKnobs $exemplar $nodeId $addIfInExemplar $map $argLabels) 
(let (mkTree (mkNode $op) $children) (eval (getNodeById $exemplar $nodeId))
       (let  $lengthOfArgs (size-atom $argLabels)
          (let  $perms (eval (sampleLogicalPerms $op $lengthOfArgs $argLabels))
            (let  $treePerms (map-atom $perms $perm (buildTree $perm))
              (let ($knobs $updatedTree) (eval (logicalProbe $exemplar $nodeId $treePerms $addIfInExemplar ()))
                (let  $pairs (eval (pairKnobWithSpec $knobs))
                    (let $mmp (eval (expToMMap $pairs $map discSpec<=))
                       (let $temp (cut)
                         ($updatedTree $mmp)
                       )
                     )
                )
              )
            )
          )
       )
    )
)
