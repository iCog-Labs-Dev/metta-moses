;;;;;;;;;; Logical Probe ;;;;;;;;;;;
;; Builds a tuple of LSKs by processing the sample logical perms 
;; Params:
;;   $exemplar: Reference tree containing the target node.
;;   (mkNodeId $targetId): ID of the target node in the exemplar.
;;   $perms: Tuple of expressions returns from the sampleLogicalPerms.
;;   $addIfInExemplar: If true, include knobs even if in exemplar.

;; Return: LSKs

(: logicalProbe (-> (Tree $a) NodeId Expression Bool Expression))
(= (logicalProbe $exemplar (mkNodeId $targetId) $perms $addIfInExemplar)
(collapse
(let*
(
    ($perm (superpose $perms))
    ($permToTree (buildTree $perm))
    ($lsk (logicalSubtreeKnob $exemplar (mkNodeId $targetId) $permToTree))
    ($discKnob (getDiscKnob $lsk))
)
(if (or $addIfInExemplar (not (inExemplar $discKnob)))
    $lsk
    (empty)))))
