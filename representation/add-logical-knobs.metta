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
(= (pairKnobWithSpec $tuple)   (map-atom $tuple $knob ( (eval (getKnobSpec $knob)) $knob) ))

;; addLogicalKnobs
;; (: addLogicalKnobs (-> (Tree $a) NodeId Bool (MultiMap ($k $v)) Expression Expression))
(= (addLogicalKnobs $exemplar $nodeId $addIfInExemplar $map $argLabels) 
(let (mkTree (mkNode $op) $children) (eval (getNodeById $exemplar $nodeId))
    (let* (
        ;; Use complete game moves for strategy operators, argLabels for boolean operators
        ($labels (if (== $op PRIORITIZED-OR) (getAllGameMoves) $argLabels))
        ($lengthOfArgs (length $labels))
        ;; Choose appropriate sampling function based on operator
        ($perms (if (== $op PRIORITIZED-OR)
                    (eval (sampleStrategyPerms $op $lengthOfArgs $labels))
                    (eval (sampleLogicalPerms $op $lengthOfArgs $labels))))
        ($treePerms (map-atom $perms $perm (buildTree $perm)))
        ;; Use strategyProbe for PRIORITIZED-OR, logicalProbe for others
        (($knobs $updatedTree) (if (== $op PRIORITIZED-OR)
                                   (eval (strategyProbe $exemplar $nodeId $treePerms $addIfInExemplar ()))
                                   (eval (logicalProbe $exemplar $nodeId $treePerms $addIfInExemplar ()))))
        ($pairs (eval (pairKnobWithSpec $knobs)))
        ($mmp (eval (expToMMap $pairs $map discSpec<=)))
        ($temp (cut))
    )
    ($updatedTree $mmp)
)))