!(bind! &knobCount (new-state 0))

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
;; (= (logicalProbe $exemplar (mkNodeId $targetId) () $addIfInExemplar $knobs) ($knobs $exemplar))
;; (= (logicalProbe $exemplar (mkNodeId $targetId) $perms $addIfInExemplar $knobs)
;; (let*
;; (
;;     (($headPerms $tailPerms) (decons-atom $perms))
;;     (($updatedTree $lsk) (logicalSubtreeKnob $exemplar (mkNodeId $targetId) $headPerms))
;;     ($discKnob (getDiscKnob $lsk))
;;     ;; ((mkDiscKnob (mkKnob $posId) $multipKnob $spec1 $spec2 $something) $discKnob)
;;     ;; ($_ (println! (Adding: (getNodeById $updatedTree $posId) isInexemplar: (inExemplar $discKnob))))
;; )
;; (if (or $addIfInExemplar (not (inExemplar $discKnob) )) 
;;     (let* 
;;     (
;;         ($updatedKnobs (concatT $knobs ($lsk)))
;;     )
;;     (logicalProbe $updatedTree (mkNodeId $targetId) $tailPerms $addIfInExemplar $updatedKnobs)
;;     )
;;     (logicalProbe $exemplar (mkNodeId $targetId) $tailPerms $addIfInExemplar $knobs))))
    ;; (trace! (skipping $discKnob because addInExemplar: $addIfInExemplar inExemplar: (inExemplar $discKnob)) (logicalProbe $exemplar (mkNodeId $targetId) $tailPerms $addIfInExemplar $knobs)))))

(= (knobId $subtree $id) (mkKnob $subtree $id))

(= (logicalProbe (mkTree $node $children) $perms $addIfInExemplar)
   (let*
     (
      ;; ($_ (println! (LogicalProbe 1)))
      ($exemplar (mkTree $node $children))
      ;; ($_ (println! (LogicalProbe 2)))
      ($updatedChldLskPair (map-atom $perms $perm (logicalSubtreeKnob $exemplar $perm)))
      ;; ($_ (println! (LogicalProbe 3)))
      ($filteredChildrenLskPair (filter-atom $updatedChldLskPair $pair (or $addIfInExemplar (not (inExemplar (getDiscKnob (second $pair)))))))
      ;; ($_ (println! (LogicalProbe 4)))
      ($updatedChildren (map-atom $filteredChildrenLskPair $ch (first $ch)))
      ;; ($_ (println! (LogicalProbe 5)))
      ($newLskPair (map-atom $filteredChildrenLskPair $ch (second $ch)))
      ;; ($_ (println! (LogicalProbe 6)))
      ($index (map-atom (genList (- (size-atom $updatedChildren) 1)) $i (+ $i (get-state &knobCount))))
      ($temp (incrementState &knobCount (size-atom $index)))
      ;; ($_ (println! (LogicalProbe 7)))
      ($updatedKnobChildren (zipWith knobId $updatedChildren $index))
      ;; ($_ (println! (LogicalProbe 8)))
     )
     ($newLskPair (mkTree $node (append (subtraction-atom $children $updatedChildren) $updatedKnobChildren)))))

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
