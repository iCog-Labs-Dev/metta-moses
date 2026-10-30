!(bind! &knobCount (new-state 0))

;;;;;;;;;; Logical Probe ;;;;;;;;;;;
;; logicalProbe builds LSKs for the trees from sampleLogicalPerms.
;; Params:
;;      (mkTree $node $children): The local tree that gets the knobs.
;;      $globalTree: The exemplar tree, read-only context for disc probing.
;;      $probeRootId: Root of the disc-probe scope (callers pass (mkNodeId (0))).
;;      $targetId: Absolute id of the local tree in $globalTree.
;;      $perms: Tuple of trees
;;      $addIfInExemplar: If true, include knobs even if in exemplar.
;;      $discProbeDisabled: If true, skip disc probing.
;; Return: (lsks updatedTree); the new knobs are embedded in updatedTree.

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

;; $tree is the global exemplar tree (read-only). $targetId is the absolute
;; id of the node that gets the knob.
(= (probeLogicalPair $tree $probeRootId $targetId $children ($controlledSubtree $lsk))
   (let*
      (
        (($probeTree $probeTargetId) (probeTreeForControlledSubtree $tree $targetId $children $controlledSubtree))
        ($probedLsk (discProbe $probeTree $probeRootId $probeTargetId $lsk))
      )
      ($controlledSubtree $probedLsk)))

(= (logicalProbe (mkTree $node $children) $perms $addIfInExemplar)
   (logicalProbe (mkTree $node $children) $perms $addIfInExemplar True))

;; Test entry: $globalTree is the local tree and both NodeIds are the root.
(= (logicalProbe (mkTree $node $children) $perms $addIfInExemplar $discProbeDisabled)
   (logicalProbe (mkTree $node $children) (mkTree $node $children) (mkNodeId (0)) (mkNodeId (0)) $perms $addIfInExemplar $discProbeDisabled))

;; Test entry: $globalTree is the local tree.
(= (logicalProbe $tree $probeRootId $targetId $perms $addIfInExemplar $discProbeDisabled)
   (logicalProbe $tree $tree $probeRootId $targetId $perms $addIfInExemplar $discProbeDisabled))

(= (logicalProbe (mkTree $node $children) $globalTree $probeRootId $targetId $perms $addIfInExemplar $discProbeDisabled)
   (let*
     (
      ($exemplar (mkTree $node $children))
      ($updatedChildLskPairs (map-atom $perms $perm (logicalSubtreeKnob $exemplar $perm)))
      ($probedChildLskPairs (if $discProbeDisabled
                              $updatedChildLskPairs 
                              (map-atom $updatedChildLskPairs $pair (probeLogicalPair $globalTree $probeRootId $targetId $children $pair))))
      ($filteredChildrenLskPair (filter-atom $probedChildLskPairs $pair (and (not (allDisallowed (second $pair))) (or $addIfInExemplar (not (inExemplar (getDiscKnob (second $pair))))))))
      ($updatedChildren (map-atom $filteredChildrenLskPair $ch (first $ch)))
      ($newLskPair (map-atom $filteredChildrenLskPair $ch (second $ch)))
      ($index (map-atom (genList (- (size-atom $updatedChildren) 1)) $i (+ $i (get-state &knobCount))))
      ($_knobCountUpdated (incrementState &knobCount (size-atom $index)))
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
