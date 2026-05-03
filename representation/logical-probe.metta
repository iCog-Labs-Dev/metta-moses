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
(= (logicalProbe $exemplar $targetId $perms $addIfInExemplar $knobs)
   (logicalProbeAt $exemplar $targetId $targetId $perms $addIfInExemplar $knobs))

;; logicalProbeAt carries the logical root used for disc-probe complexity checks
;; separately from the node controlled by the knob.
(= (logicalProbeAt $exemplar $probeRootId (mkNodeId $targetId) () $addIfInExemplar $knobs) ($knobs $exemplar))
(= (logicalProbeAt $exemplar $probeRootId (mkNodeId $targetId) $perms $addIfInExemplar $knobs)
(let*
(
    (($headPerms $tailPerms) (decons-atom $perms))
    (($updatedTree $lsk) (logicalSubtreeKnob $exemplar (mkNodeId $targetId) $headPerms))
    ($probedLsk (discProbe $updatedTree $probeRootId $lsk))
    ($discKnob (getDiscKnob $probedLsk))
)
(if (and (not (allDisallowed $probedLsk)) (or $addIfInExemplar (not (inExemplar $discKnob)))) 
    (let $updatedKnobs (concatT $knobs ($probedLsk))
	    (logicalProbeAt $updatedTree $probeRootId (mkNodeId $targetId) $tailPerms $addIfInExemplar $updatedKnobs))
	    (logicalProbeAt $exemplar $probeRootId (mkNodeId $targetId) $tailPerms $addIfInExemplar $knobs))))

;; strategyProbe -> builds SSKs by processing game move permutations
;; Params:
;;      $exemplar: Reference tree containing the target node
;;      $targetId: ID of the target node in the exemplar
;;      $perms: Tuple of game strategy trees
;;      $addIfInExemplar: If true, include knobs even if in exemplar
;;      $knobs: the list of knobs at each iteration, () at the start
;; Return: a tuple containing a tuple of SSKs and the final updated tree
;; (: strategyProbe (-> (Tree $a) NodeId Expression Bool Expression Expression))
(= (strategyProbe $exemplar (mkNodeId $targetId) () $addIfInExemplar $knobs) ($knobs $exemplar))
(= (strategyProbe $exemplar (mkNodeId $targetId) $perms $addIfInExemplar $knobs)
   (let*
   (
       (($headPerms $tailPerms) (decons-atom $perms))
       ;; CHANGE: Call strategySubtreeKnob instead of logicalSubtreeKnob
       (($updatedTree $ssk) (strategySubtreeKnob $exemplar (mkNodeId $targetId) $headPerms))
       ($discKnob (getDiscKnob $ssk))
   )
   (if (or $addIfInExemplar (not (inExemplar $discKnob) ))
       (let* (
           ($updatedKnobs (concatT $knobs ($ssk)))
       )
       (strategyProbe $updatedTree (mkNodeId $targetId) $tailPerms $addIfInExemplar $updatedKnobs)
       )
       (strategyProbe $exemplar (mkNodeId $targetId) $tailPerms $addIfInExemplar $knobs))))
