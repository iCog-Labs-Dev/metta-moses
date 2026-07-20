;; helper function to the addLogicalKnobs
;; takes a tuple of knobs and return a tuple of knob and knobSpec pairs
;; (: pairKnobWithSpec (-> Expression Expression))
(= (pairKnobWithSpec $tuple) (map-atom $tuple $knob ((getKnobSpec $knob) $knob) ))

(= (addLogicalKnobs (mkTree (mkNode $op) $children) $addIfInExemplar $map $argLabels)
   (addLogicalKnobsFast (mkTree (mkNode $op) $children) $addIfInExemplar $map $argLabels True (mkTree (mkNode $op) $children) (mkNodeId (0))))

(= (addLogicalKnobsFast (mkTree (mkNode $op) $children) $addIfInExemplar $map $argLabels $disable-discprobe $globalTree $currentNodeId)
   (let*
     (
      ;; ($_ (println! (addLogicalKnobs 1)))
      ($lengthOfLabels (size-atom $argLabels))
      ;; ($_ (println! (addLogicalKnobs 2)))
      ($perms (sampleLogicalPerms $op $lengthOfLabels $argLabels))
      ;; ($_ (println! (addLogicalKnobs 3)))
      ($treePerms (map-atom $perms $perm (buildTree $perm)))
      ;; ($_ (println! (addLogicalKnobs 4)))
      ;; logicalProbe now receives: $localTree (current subtree) + $globalTree
      ;; (static exemplar context) + $probeRootId (stays (mkNodeId (0)),
      ;; reserved for future tighter scopes) + $targetId (absolute path to
      ;; current subtree's root in the global tree).
      (($knobs $updatedTree) (logicalProbe (mkTree (mkNode $op) $children) $globalTree (mkNodeId (0)) $currentNodeId $treePerms $addIfInExemplar $disable-discprobe))
      ;; ($_ (println! (addLogicalKnobs 5)))
      ($pairs (pairKnobWithSpec $knobs))
      ;; ($_ (println! (addLogicalKnobs 6)))
      ($mmp (expToMMap $pairs $map discSpec<))
      ;; ($_ (println! (addLogicalKnobs 7)))
     )
     ($updatedTree $mmp)
   )
)
