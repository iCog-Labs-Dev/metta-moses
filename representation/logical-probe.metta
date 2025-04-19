;;;;;;;;;; Logical Probe ;;;;;;;;;;;
;; logicalProbe builds LSKs by processing the sampleLogicalPerms 
;; Params:
;;      $exemplar: Reference tree containing the target node.
;;      (mkNodeId $targetId): ID of the target node in the exemplar.
;;      $perms: Tuple of trees
;;      $addIfInExemplar: If true, include knobs even if in exemplar.
;;      $knobs: the list of knobs at each iteration, () at the start
;; Return: a tuple containing a tuple of LSKs and the final updated tree


;; a helper to logicalProbe
;; Param:
;;   $perms: a tuple of Expressions (output of sampleLogicalPerms) 
;; Return: a tuple of Trees
(: permsToTree (-> Expression Expression))
(= (permsToTree $perms)
(collapse
   (let*
    (
      ($perm (superpose $perms))
      ($permToTree (buildTree $perm))
    )
    $permToTree)))

;; logicalProbe
(: logicalProbe (-> (Tree $a) NodeId Expression Bool Expression Expression))
(= (logicalProbe $exemplar (mkNodeId $targetId) () $addIfInExemplar $knobs) ($knobs $exemplar))
(= (logicalProbe $exemplar (mkNodeId $targetId) $perms $addIfInExemplar $knobs)
(let*
(
    (($headPerms $tailPerms) (decons-atom $perms))
    ($lsk (logicalSubtreeKnob $exemplar (mkNodeId $targetId) $headPerms))
    ($discKnob (getDiscKnob $lsk))
)
(if (or $addIfInExemplar (not (inExemplar $discKnob)))
    (let* 
    (
        ($updatedTree (getTree $lsk))
        ($updatedKnobs (union-atom $knobs ($lsk)))
    )
    (logicalProbe $updatedTree (mkNodeId $targetId) $tailPerms $addIfInExemplar $updatedKnobs)
    )
    (logicalProbe $exemplar (mkNodeId $targetId) $tailPerms $addIfInExemplar $knobs))))