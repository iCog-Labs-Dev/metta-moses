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
(let (mkTree (mkNode $op) $children) (GetByID $exemplar $nodeId)
       (let  $lengthOfArgs (len (ARGS))
       ;; for the sake of simplicity the sampleLogicalPerms method isn't called here
       ;; because it generates a number of perms which will increate the number of knobs and iterations
       ;; for the time being we are just passing 2 Arguments A and B
          (let  $perms (A B) ;(sampleLogicalPerms $op $lengthOfArgs)
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