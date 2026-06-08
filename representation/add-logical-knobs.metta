;;;;;;;; addLogicalKnotree knobs in to a multimap
;; Params:
;;   $exemplar: Reference tree containing the target node.
;;   (mkNodeId $targetId): ID of the target node in the exemplar.
;;   $addIfInExemplar: If true, include knobs even if in exemplar.
;;   $map: a multimap to add the new knobs into
;;   $argLabels: list of argument labels (input variables) from the ITable
;; Return: a multimap of ($knobSpec $knob) and the updated tree

;; All available game moves
(= (getAllGameMoves) (playcenter playblock playwin playcorner playside))

;; helper function to the addLogicalKnobs
;; takes a tuple of knobs and return a tuple of knob and knobSpec pairs
;; (: pairKnobWithSpec (-> Expression Expression))
(= (pairKnobWithSpec $tuple) (map-atom $tuple $knob ((getKnobSpec $knob) $knob) ))

;; addLogicalKnobs
;; (: addLogicalKnobs (-> (Tree $a) NodeId Bool (MultiMap ($k $v)) Expression Expression))
(= (addLogicalKnobs $exemplar $nodeId $addIfInExemplar $map $argLabels) 
   (addLogicalKnobs $exemplar $nodeId $addIfInExemplar $map $argLabels True))

(= (addLogicalKnobs $exemplar $nodeId $addIfInExemplar $map $argLabels $disable-discprobe)
   (addLogicalKnobsAt $exemplar $nodeId $nodeId $addIfInExemplar $map $argLabels $disable-discprobe))

;; addLogicalKnobsAt keeps the logical probe root distinct from the target node.
;; Strategy knobs ignore the root and are not disc-probed.
(= (addLogicalKnobsAt $exemplar $probeRootId $nodeId $addIfInExemplar $map $argLabels $disable-discprobe)
   (let*
     (

      ((mkTree (mkNode $op) $children) (getNodeById $exemplar $nodeId))
      ;; ($_ (println! (Adding knobs to: (preOrder (mkTree (mkNode $op) $children)))))
      ;; Use complete game moves for strategy operators, argLabels for boolean operators
      ($labels (if (== $op PRIORITIZED-OR) (getAllGameMoves) $argLabels))
      ($lengthOfArgs (length $labels))
      ($perms (sampleStrategyPerms $op $lengthOfArgs $labels))
      ($treePerms (map-atom $perms $perm (buildTree $perm)))
      (($knobs $updatedTree) (strategyProbe $exemplar $nodeId $treePerms $addIfInExemplar ()))

      ;; ($_ (println! (Adding (length $knobs) Knobs)))

      ($pairs (pairKnobWithSpec $knobs))
      ($mmp (expToMMap $pairs $map discSpec<))
     )
     ($updatedTree $mmp)))

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
