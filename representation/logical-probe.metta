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

(= (knobId $subtree $lsk $id) (mkKnob $subtree $lsk $id))

(= (childNodeId (mkNodeId $parentId) $childIndex)
   (mkNodeId (if (== $parentId (0))
                 ($childIndex)
                 (concatT $parentId ($childIndex)))))

(= (probeTreeForControlledSubtree $tree $targetId $children $controlledSubtree)
   (let $idx (List.index $children $controlledSubtree)
      (if (== $idx -1)
          (appendChild $tree $targetId $controlledSubtree)
          ($tree (childNodeId $targetId (+ $idx 1))))))

;; Extracts the controlled subtree from a possibly-knob-wrapped child for
;; membership testing against the original $children list. The case dispatches
;; in declaration order, with the catch-all $other handling non-knob children
;; (which are already controlled subtrees themselves).
(= (findControlledSubtree $ch)
   (case $ch
      (
        ((mkKnob (mkNullVex ($s)) $lsk $i) $s)
        ((mkKnob (mkTree $node $children) $lsk $i) (mkTree $node $children))
        ($other $other))))

;; $tree is now the global exemplar tree (read-only). $probeRootId stays as
;; the disc-probe scope's root (kept (mkNodeId (0)) by callers; reserved for
;; future tighter scopes), $targetId is the absolute path to the current node
;; where the knob is being appended.
(= (probeLogicalPair $tree $probeRootId $targetId $children $disable-discprobe ($controlledSubtree $lsk))
   (let*
      (
        (($probeTree $probeTargetId) (probeTreeForControlledSubtree $tree $targetId $children $controlledSubtree))
        ($probedLsk (if $disable-discprobe $lsk (discProbe $probeTree $probeRootId $probeTargetId $lsk)))
      )
      ($controlledSubtree $probedLsk)))

(= (logicalProbe (mkTree $node $children) $perms $addIfInExemplar)
   (logicalProbe (mkTree $node $children) $perms $addIfInExemplar True))

;; 4-arg wrapper: defaults $globalTree to the local tree and both NodeId
;; positions to root. Used by tests that don't care about the global context.
(= (logicalProbe (mkTree $node $children) $perms $addIfInExemplar $disable-discprobe)
   (logicalProbe (mkTree $node $children) (mkTree $node $children) (mkNodeId (0)) (mkNodeId (0)) $perms $addIfInExemplar $disable-discprobe))

;; 6-arg wrapper: defaults $globalTree to the local tree. Used by direct test
;; invocations that supply NodeIds but not a separate global tree.
(= (logicalProbe $tree $probeRootId $targetId $perms $addIfInExemplar $disable-discprobe)
   (logicalProbe $tree $tree $probeRootId $targetId $perms $addIfInExemplar $disable-discprobe))

(= (logicalProbe (mkTree $node $children) $globalTree $probeRootId $targetId $perms $addIfInExemplar $discProbeDisabled)
   (let*
     (
      ($exemplar (mkTree $node $children))
      ($updatedChldLskPair (map-atom $perms $perm (logicalSubtreeKnob $exemplar $perm)))
      ($probedChldLskPair (if $discProbeDisabled
                              $updatedChldLskPair 
                              (map-atom $updatedChldLskPair $pair (probeLogicalPair $globalTree $probeRootId $targetId $children False $pair))))
      ($filteredChildrenLskPair (filter-atom $probedChldLskPair $pair (and (not (allDisallowed (second $pair))) (or $addIfInExemplar (not (inExemplar (getDiscKnob (second $pair))))))))
      ($updatedChildren (map-atom $filteredChildrenLskPair $ch (first $ch)))
      ($newLskPair (map-atom $filteredChildrenLskPair $ch (second $ch)))
      ($index (map-atom (genList (- (size-atom $updatedChildren) 1)) $i (+ $i (get-state &knobCount))))
      ($temp (incrementState &knobCount (size-atom $index)))
      ;; Same embed-LSK design as the fast clause above.
      ($updatedKnobChildren (zipWith3 knobId $updatedChildren $newLskPair $index))
	     )
	     ($newLskPair (mkTree $node (append (subtraction-atom $children $updatedChildren) $updatedKnobChildren)))))

;; Action probe builds one ASK containing all supplied action permutations.
;; It intentionally skips disc probing, matching the original action path.
(= (actionProbe $exemplar (mkNodeId $targetId) $perms $addIfInExemplar $knobs)
   (actionProbe $exemplar (mkNodeId $targetId) $perms $addIfInExemplar $knobs 0))

(= (actionProbe $exemplar (mkNodeId $targetId) $perms $addIfInExemplar $knobs $idx)
   (if (== $perms ())
       ($knobs $exemplar)
       (let*
         (
           (($controlledSubtree $ask) (actionSubtreeKnob $perms))
           ($discKnob (getDiscKnob $ask))
         )
         (if (or $addIfInExemplar (not (inExemplar $discKnob)))
             (let*
               (
                 (($updatedTree $_) (appendChild $exemplar (mkNodeId $targetId) (mkKnob $controlledSubtree $ask $idx)))
                 ($updatedKnobs (concatT $knobs ($ask)))
               )
               ($updatedKnobs $updatedTree))
             ($knobs $exemplar)))))

(= (simpleActionProbe $exemplar (mkNodeId $targetId) $addIfInExemplar $knobs)
   (simpleActionProbe $exemplar (mkNodeId $targetId) $addIfInExemplar $knobs 0))

(= (simpleActionProbe $exemplar (mkNodeId $targetId) $addIfInExemplar $knobs $idx)
   (let*
     (
       ($targetSubtree (getNodeById $exemplar (mkNodeId $targetId)))
       (($controlledSubtree $ask) (simpleActionSubtreeKnob $targetSubtree))
       ($discKnob (getDiscKnob $ask))
     )
     (if (or $addIfInExemplar (not (inExemplar $discKnob)))
         (let*
           (
             ($updatedTree (replaceNodeById $exemplar (mkNodeId $targetId) (mkKnob $controlledSubtree $ask $idx)))
             ($updatedKnobs (concatT $knobs ($ask)))
           )
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
