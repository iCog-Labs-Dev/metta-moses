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

;; getAllActions - list of available builtin actions for the action domain.
;; Domain-specific: override this binding per experiment/problem.
;; Mirrors the _actions parameter in C++ build_knobs.
(= (getAllActions) ())

;; getAllPerceptions - list of available perceptions for the action domain.
;; Domain-specific: override this binding per experiment/problem.
;; Mirrors the _perceptions parameter in C++ build_knobs.
(= (getAllPerceptions) ())

;; sampleActionPerms - samples action permutations for ActionSubtreeKnob building.
;; Mirrors C++ build_knobs::sample_action_perms.
;; Generates: (a) each single action as a permutation, plus
;;            (b) n random ACTION-BOOLEAN-IF(perception action1 action2) combos.
;; Returns a list of expressions (symbols or tuples) to be built into trees by addActionKnobs.
;; (: sampleActionPerms (-> Expression Expression Expression))
(= (sampleActionPerms $actions $perceptions)
   (let*
   (
    ($nActions (List.length $actions))
    ($hasPerceptions (not (== $perceptions ())))
    ;; Pair perms: random action_boolean_if(perception a b) combinations
    ($pairPerms
        (if (or (<= $nActions 1) (not $hasPerceptions))
            ()
            (let*
            (
             ($idxList (genList (- $nActions 1)))
             ($idxPairs (collapse (genPairs $idxList)))
             ($nPairs $nActions)
             ($upperbound (- (* $nActions (- $nActions 1)) 1))
             ($picked (lazyRandomSelector 0 $upperbound $nPairs))
            )
            (collapse (let ($a $b) (index-atom $idxPairs (superpose $picked))
                           (let ($act1 $act2) ((index-atom $actions $a) (index-atom $actions $b))
                           (let $perc (superpose $perceptions)
                                (ACTION-BOOLEAN-IF $perc $act1 $act2))))))))
   )
   (concatT $actions $pairPerms)))

;; addActionKnobs - creates ONE ActionSubtreeKnob at the given node with all sampled permutations.
;; Mirrors C++ build_knobs::add_action_knobs.
;; (: addActionKnobs (-> (Tree $a) NodeId Bool (MultiMap ($k $v)) Expression Expression ((Tree $a) (MultiMap ($k $v)))))
(= (addActionKnobs $exemplar $nodeId $addIfInExemplar $map $actions $perceptions)
   (let*
   (
    ($perms (sampleActionPerms $actions $perceptions))
    ($treePerms (map-atom $perms $perm (buildTree $perm)))
    (($knobs $updatedTree) (actionProbe $exemplar $nodeId $treePerms $addIfInExemplar ()))
    ($pairs (pairKnobWithSpec $knobs))
    ($mmp (expToMMap $pairs $map discSpec<))
   )
   ($updatedTree $mmp)))

;; addSimpleActionKnobs - creates a SimpleActionSubtreeKnob for a single action node.
;; Mirrors C++ build_knobs::add_simple_action_knobs.
;; (: addSimpleActionKnobs (-> (Tree $a) NodeId (Tree $a) Bool (MultiMap ($k $v)) ((Tree $a) (MultiMap ($k $v)))))
(= (addSimpleActionKnobs $exemplar $nodeId $subtree $addIfInExemplar $map)
   (let*
   (
    (($knobs $updatedTree) (simpleActionProbe $exemplar $nodeId $subtree $addIfInExemplar ()))
    ($pairs (pairKnobWithSpec $knobs))
    ($mmp (expToMMap $pairs $map discSpec<))
   )
   ($updatedTree $mmp)))

;; getDiscreteDomain - list of discrete atoms for the general discrete domain.
;; Override this binding per experiment/problem to enable buildDiscrete.
(= (getDiscreteDomain) ())

;; addDiscreteKnobs - creates ONE GeneralDiscreteKnob at the given node covering all domain atoms.
;; (: addDiscreteKnobs (-> (Tree $a) NodeId Bool (MultiMap ($k $v)) (List Atom) ((Tree $a) (MultiMap ($k $v)))))
(= (addDiscreteKnobs $exemplar $nodeId $addIfInExemplar $map $domain)
   (let*
   (
    (($knobs $updatedTree) (discreteProbe $exemplar $nodeId $domain $addIfInExemplar ()))
    ($pairs (pairKnobWithSpec $knobs))
    ($mmp (expToMMap $pairs $map discSpec<))
   )
   ($updatedTree $mmp)))

;; helper function to the addLogicalKnobs
;; takes a tuple of knobs and return a tuple of knob and knobSpec pairs
;; (: pairKnobWithSpec (-> Expression Expression))
(= (pairKnobWithSpec $tuple)   (map-atom $tuple $knob ( (getKnobSpec $knob) $knob) ))

;; addLogicalKnobs
;; (: addLogicalKnobs (-> (Tree $a) NodeId Bool (MultiMap ($k $v)) Expression Expression))
(= (addLogicalKnobs $exemplar $nodeId $addIfInExemplar $map $argLabels) 
   (let*
     (

      ((mkTree (mkNode $op) $children) (getNodeById $exemplar $nodeId))
      ;; ($_ (println! (Adding knobs to: (preOrder (mkTree (mkNode $op) $children)))))
      ;; Use complete game moves for strategy operators, argLabels for boolean operators
      ($labels (if (== $op PRIORITIZED-OR) (getAllGameMoves) $argLabels))
      ($lengthOfArgs (length $labels))
      ($perms (if (== $op PRIORITIZED-OR)
                  (sampleStrategyPerms $op $lengthOfArgs $labels)
                  (sampleLogicalPerms $op $lengthOfArgs $labels)))
      ($treePerms (map-atom $perms $perm (buildTree $perm)))
      (($knobs $updatedTree) (if (== $op PRIORITIZED-OR)
                                 (strategyProbe $exemplar $nodeId $treePerms $addIfInExemplar ())
                                 (logicalProbe $exemplar $nodeId $treePerms $addIfInExemplar ())))

      ;; ($_ (println! (Adding (length $knobs) Knobs)))

      ($pairs (pairKnobWithSpec $knobs))
      ($mmp (expToMMap $pairs $map discSpec<))
      ($temp (cut))
     )
     ($updatedTree $mmp)))
