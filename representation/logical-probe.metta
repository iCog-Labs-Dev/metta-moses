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
   (logicalProbe $exemplar $targetId $perms $addIfInExemplar $knobs True))

(= (logicalProbe $exemplar $targetId $perms $addIfInExemplar $knobs $disable-discprobe)
   (logicalProbeAt $exemplar $targetId $targetId $perms $addIfInExemplar $knobs $disable-discprobe))

;; logicalProbeAt carries the logical root used for discprobe complexity checks
;; separately from the node controlled by the knob.
(= (logicalProbeAt $exemplar $probeRootId (mkNodeId $targetId) () $addIfInExemplar $knobs $disable-discprobe) ($knobs $exemplar))
(= (logicalProbeAt $exemplar $probeRootId (mkNodeId $targetId) $perms $addIfInExemplar $knobs $disable-discprobe)
(let*
(
    (($headPerms $tailPerms) (decons-atom $perms))
    (($updatedTree $lsk) (logicalSubtreeKnob $exemplar (mkNodeId $targetId) $headPerms))
    ($probedLsk (if $disable-discprobe $lsk (discProbe $updatedTree $probeRootId $lsk)))
    ($discKnob (getDiscKnob $probedLsk))
    ;; ((mkDiscKnob (mkKnob $posId) $multipKnob $spec1 $spec2 $something) $discKnob)
    ;; ($_ (println! (Adding: (getNodeById $updatedTree $posId) isInexemplar: (inExemplar $discKnob))))
)
(if (and (not (allDisallowed $probedLsk)) (or $addIfInExemplar (not (inExemplar $discKnob))))
    (let* 
    (
        ($updatedKnobs (concatT $knobs ($probedLsk)))
    )
    (logicalProbeAt $updatedTree $probeRootId (mkNodeId $targetId) $tailPerms $addIfInExemplar $updatedKnobs $disable-discprobe)
    )
    (logicalProbeAt $exemplar $probeRootId (mkNodeId $targetId) $tailPerms $addIfInExemplar $knobs $disable-discprobe))))
    ;; (trace! (skipping $discKnob because addInExemplar: $addIfInExemplar inExemplar: (inExemplar $discKnob)) (logicalProbe $exemplar (mkNodeId $targetId) $tailPerms $addIfInExemplar $knobs)))))

;; actionProbe - creates one ActionSubtreeKnob for all action permutations at the target position.
;; Mirrors C++ action_probe which constructs a single action_subtree_knob with all perms.
;; Unlike logicalProbe which creates one LSK per perm, actionProbe creates ONE ASK for ALL perms.
;; (: actionProbe (-> (Tree $a) NodeId (List Tree) Bool Expression (Expression (Tree $a))))
(= (actionProbe $exemplar (mkNodeId $targetId) $perms $addIfInExemplar $knobs)
   (if (== $perms ())
       ($knobs $exemplar)
       (let*
       (
        (($updatedTree $ask) (actionSubtreeKnob $exemplar (mkNodeId $targetId) $perms))
        ($discKnob (getDiscKnob $ask))
       )
       (if (or $addIfInExemplar (not (inExemplar $discKnob)))
           (let $updatedKnobs (concatT $knobs ($ask))
                ($updatedKnobs $updatedTree))
           ($knobs $exemplar)))))

;; simpleActionProbe - creates one SimpleActionSubtreeKnob for a single action node.
;; Mirrors C++ simple_action_probe which constructs a single simple_action_subtree_knob.
;; (: simpleActionProbe (-> (Tree $a) NodeId (Tree $a) Bool Expression (Expression (Tree $a))))
(= (simpleActionProbe $exemplar (mkNodeId $targetId) $subtree $addIfInExemplar $knobs)
   (let*
   (
    (($updatedTree $sask) (simpleActionSubtreeKnob $exemplar (mkNodeId $targetId) $subtree))
    ($discKnob (getDiscKnob $sask))
   )
   (if (or $addIfInExemplar (not (inExemplar $discKnob)))
       (let $updatedKnobs (concatT $knobs ($sask))
            ($updatedKnobs $updatedTree))
       ($knobs $exemplar))))

;; Game-specific probe that uses strategySubtreeKnob instead of logicalSubtreeKnob
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

;; discreteProbe - creates ONE GeneralDiscreteKnob covering all atoms in $domain.
;; Unlike logicalProbe (one LSK per perm), this creates a single GDK for the entire domain list.
;; (: discreteProbe (-> (Tree $a) NodeId (List Atom) Bool Expression (Expression (Tree $a))))
(= (discreteProbe $exemplar (mkNodeId $targetId) $domain $addIfInExemplar $knobs)
   (if (== $domain ())
       ($knobs $exemplar)
       (let*
       (
        (($updatedTree $gdk) (generalDiscreteKnob $exemplar (mkNodeId $targetId) $domain))
        ($discKnob (getDiscKnob $gdk))
       )
       (if (or $addIfInExemplar (not (inExemplar $discKnob)))
           (let $updatedKnobs (concatT $knobs ($gdk))
                ($updatedKnobs $updatedTree))
           ($knobs $exemplar)))))
