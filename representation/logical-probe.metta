;;;;;;;;;; Logical Probe ;;;;;;;;;;;
;; Builds a tuple of LSKs by processing the sample logical perms 
;; Params:
;;   $exemplar: Reference tree containing the target node.
;;   (mkNodeId $targetId): ID of the target node in the exemplar.
;;   $perms: Tuple of expressions returns from the sampleLogicalPerms.
;;   $addIfInExemplar: If true, include knobs even if in exemplar.
;;   $knobs: Accumulator tuple of mkLSK values (e.g., ((mkLSK ...) (mkLSK ...))).

;; Return: Accumulated mkLSK values.

(: logicalProbe (-> (Tree $a) NodeId Expression Bool Expression Expression))
(= (logicalProbe $exemplar (mkNodeId $targetId) () $addIfInExemplar $knobs) $knobs)
(= (logicalProbe $exemplar (mkNodeId $targetId) $perms $addIfInExemplar $knobs)
(let*
(
    (($head $tail) (decons-atom $perms))
    ($headToTree (buildTree $head))
    ($lsk (logicalSubtreeKnob $exemplar (mkNodeId $targetId) $headToTree))
    ($discKnob (getDiscKnob $lsk))
)
(if (or $addIfInExemplar (not (inExemplar $discKnob)))
    (if (== $tail ()) 
        (union-atom $knobs ($lsk))
        (let $knobsList (union-atom $knobs ($lsk)) (logicalProbe $exemplar (mkNodeId $targetId) $tail $addIfInExemplar $knobsList))
    )
    (logicalProbe $exemplar (mkNodeId $targetId) $tail $addIfInExemplar $knobs))))
