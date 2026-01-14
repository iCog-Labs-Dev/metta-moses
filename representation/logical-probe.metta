;;;;;;;;;; Logical Probe ;;;;;;;;;;;
;; logicalProbe builds LSKs by processing the sampleLogicalPerms 
;; Params:
;;      $exemplar: Reference tree containing the target node.
;;      (mkNodeId $targetId): ID of the target node in the exemplar.
;;      $perms: Tuple of trees
;;      $addIfInExemplar: If true, include knobs even if in exemplar.
;;      $knobs: the list of knobs at each iteration, () at the start
;; Return: a tuple containing a tuple of LSKs and the final updated tree

;; logicalProbe
;; (: logicalProbe (-> (Tree $a) NodeId Expression Bool Expression Expression))
(= (logicalProbe $exemplar (mkNodeId $targetId) () $addIfInExemplar $knobs) ($knobs $exemplar))
(= (logicalProbe $exemplar (mkNodeId $targetId) $perms $addIfInExemplar $knobs)
(let*
(
    (($headPerms $tailPerms) (decons-atom $perms))
    (($updatedTree $lsk) (eval (logicalSubtreeKnob $exemplar (mkNodeId $targetId) $headPerms)))
    ($discKnob (eval (getDiscKnob $lsk)))
)
(if (or $addIfInExemplar (not (eval (inExemplar $discKnob)) )) 
    (let* 
    (
        ($updatedKnobs (eval (concatT $knobs ($lsk))))
    )
    (eval (logicalProbe $updatedTree (mkNodeId $targetId) $tailPerms $addIfInExemplar $updatedKnobs))
    )
    (eval (logicalProbe $exemplar (mkNodeId $targetId) $tailPerms $addIfInExemplar $knobs)))))
