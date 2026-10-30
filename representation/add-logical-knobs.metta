;; helper function to the addLogicalKnobs
;; takes a tuple of knobs and return a tuple of knob and knobSpec pairs
;; (: pairKnobWithSpec (-> Expression Expression))
(= (pairKnobWithSpec $tuple) (map-atom $tuple $knob ((getKnobSpec $knob) $knob) ))

(= (addLogicalKnobs (mkTree (mkNode $op) $children) $addIfInExemplar $map $argLabels)
   (addLogicalKnobs (mkTree (mkNode $op) $children) $addIfInExemplar $map $argLabels True (mkTree (mkNode $op) $children) (mkNodeId (0)) (param ignoreOps)))

(= (addLogicalKnobs (mkTree (mkNode $op) $children) $addIfInExemplar $map $argLabels $discProbeDisabled $globalTree $currentNodeId $ignoreOps)
   (let*
     (
      ;; ($_ (println! (addLogicalKnobs 1)))
      ($lengthOfLabels (size-atom $argLabels))
      ;; ($_ (println! (addLogicalKnobs 2)))
      ($perms (sampleLogicalPerms $op $lengthOfLabels $argLabels $ignoreOps))
      ;; ($_ (println! (addLogicalKnobs 3)))
      ($treePerms (map-atom $perms $perm (buildTree $perm)))
      ;; ($_ (println! (addLogicalKnobs 4)))
      ;; logicalProbe gets the local subtree, the global exemplar and the
      ;; absolute id of the local subtree in the global tree.
      (($knobs $updatedTree) (logicalProbe (mkTree (mkNode $op) $children) $globalTree (mkNodeId (0)) $currentNodeId $treePerms $addIfInExemplar $discProbeDisabled))
      ;; ($_ (println! (addLogicalKnobs 5)))
      ($pairs (pairKnobWithSpec $knobs))
      ;; ($_ (println! (addLogicalKnobs 6)))
      ($mmp (append $map $pairs))
      ;; ($_ (println! (addLogicalKnobs 7)))
     )
     ($updatedTree $mmp)
   )
)
