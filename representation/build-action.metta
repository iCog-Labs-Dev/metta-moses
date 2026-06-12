;; =============================================================================
;; build-action.metta
;;
;; Action-domain knob building for action selection trees. This ports the
;; action-selection branch onto dev's embedded mkKnob representation style.
;; =============================================================================

(= (randElement $list)
   (if (== $list ())
       ()
       (let* (($len (length $list))
              ($idx (py-call (random.randint 0 (- $len 1)))))
         (List.getByIdx $list $idx))))

(= (randint $max) (py-call (random.randint 0 $max)))

(= (isActionOperator $op)
   (is-member $op (and_seq or_seq seq_exec action_not action_bool_if
                   bool_action_if contin_action_if action_action_if
                   action_success action_failure
                   action_while bool_while return_success repeat_n)))

(= (isBuiltinAction $op) (not (isActionOperator $op)))
(= (isBuiltinAction $op $actions) (is-member $op $actions))

(= (sampleActionPerms $actions $perceptions)
   (if (== $perceptions ())
       $actions
       (sampleActionPerms $actions $perceptions (length $actions))))

(= (sampleActionPerms $actions $perceptions $n)
   (let $actionCount (length $actions)
     (if (or (== $n 0) (< $actionCount 2))
         $actions
         (let*
           (
             ($pairCount (* $actionCount (- $actionCount 1)))
             ($sampleCount (if (> $n $pairCount) $pairCount $n))
             ($pairIdxs (lazyRandomSelector 0 (- $pairCount 1) $sampleCount))
             ($pairs (actionPairsFromIndexes $pairIdxs $perceptions $actions $actionCount))
           )
           (concatT $actions $pairs)))))

(= (actionPairFromIndex $perceptions $actions $actionCount $pairIdx)
   (let*
     (
       ($width (- $actionCount 1))
       ($aIdx (int (/ $pairIdx $width)))
       ($bRaw (- $pairIdx (* $aIdx $width)))
       ($bIdx (if (== $bRaw $aIdx) (- $actionCount 1) $bRaw))
       ($perception (randElement $perceptions))
       ($actA (List.getByIdx $actions $aIdx))
       ($actB (List.getByIdx $actions $bIdx))
     )
     (action_bool_if $perception $actA $actB)))

(= (actionPairsFromIndexes () $perceptions $actions $actionCount) ())
(= (actionPairsFromIndexes (cons $pairIdx $rest) $perceptions $actions $actionCount)
   (cons (actionPairFromIndex $perceptions $actions $actionCount $pairIdx)
         (actionPairsFromIndexes $rest $perceptions $actions $actionCount)))

(= (registerActionKnob $controlledSubtree $ask $MMap)
   (let*
     (
       ($index (get-state &knobCount))
       ($_ (incrementState &knobCount 1))
       ($knobChild (mkKnob $controlledSubtree $ask $index))
       ($mmp (expToMMap (((getKnobSpec $ask) $ask)) $MMap discSpec<))
     )
     ($knobChild $mmp)))

(= (makeActionInsertionKnob $actions $perceptions $MMap)
   (let*
     (
       ($perms (sampleActionPerms $actions $perceptions))
       ($treePerms (map-atom $perms $perm (buildTree $perm)))
     )
     (if (== $perms ())
         (() $MMap)
         (let*
           (
             (($controlledSubtree $ask) (actionSubtreeKnob $treePerms))
             (($knobChild $mmp) (registerActionKnob $controlledSubtree $ask $MMap))
           )
           ($knobChild $mmp)))))

(= (wrapSimpleActionSubtree $subtree $MMap)
   (let*
     (
       (($controlledSubtree $ask) (simpleActionSubtreeKnob $subtree))
       (($knobChild $mmp) (registerActionKnob $controlledSubtree $ask $MMap))
     )
     ($knobChild $mmp)))

(= (appendActionInsertionChild $children $MMap $actions $perceptions)
   (let ($knobChild $mmp) (makeActionInsertionKnob $actions $perceptions $MMap)
     (if (== $knobChild ())
         ($children $mmp)
         ((append $children ($knobChild)) $mmp))))

(= (buildActionChildren () $MMap $actions $perceptions) (() $MMap))
(= (buildActionChildren (cons $child $rest) $MMap $actions $perceptions)
   (let*
     (
       (($updatedChild $m1) (buildActionChild $child $MMap $actions $perceptions))
       (($updatedRest $m2) (buildActionChildren $rest $m1 $actions $perceptions))
     )
     ((cons $updatedChild $updatedRest) $m2)))

(= (buildActionChild (mkTree (mkNode $op) $children) $MMap $actions $perceptions)
   (let $child (mkTree (mkNode $op) $children)
     (if (isBuiltinAction $op $actions)
         (wrapSimpleActionSubtree $child $MMap)
         (if (== $op and_seq)
             (buildActionTree $child $MMap $actions $perceptions)
             (if (== $op action_bool_if)
                 (let ($updatedChild $m1) (buildActionTree $child $MMap $actions $perceptions)
                   (wrapSimpleActionSubtree $updatedChild $m1))
                 ($child $MMap))))))

(= (buildActionChild $child $MMap $actions $perceptions)
   ($child $MMap))

(= (buildActionBoolIfBranches () $MMap $actions $perceptions) (() $MMap))
(= (buildActionBoolIfBranches (cons $child $rest) $MMap $actions $perceptions)
   (let*
     (
       (($updatedChild $m1) (buildActionBoolIfBranch $child $MMap $actions $perceptions))
       (($updatedRest $m2) (buildActionBoolIfBranches $rest $m1 $actions $perceptions))
     )
     ((cons $updatedChild $updatedRest) $m2)))

(= (buildActionBoolIfBranch (mkTree (mkNode $op) $children) $MMap $actions $perceptions)
   (let $branch (mkTree (mkNode $op) $children)
     (if (isBuiltinAction $op $actions)
         (buildActionTree (mkTree (mkNode and_seq) (cons $branch ())) $MMap $actions $perceptions)
         (if (or (== $op and_seq) (== $op action_bool_if))
             (buildActionTree $branch $MMap $actions $perceptions)
             ($branch $MMap)))))

(= (buildActionBoolIfBranch $branch $MMap $actions $perceptions)
   ($branch $MMap))

(= (buildActionTree (mkTree (mkNode and_seq) $children) $MMap $actions $perceptions)
   (let*
     (
       (($updatedChildren $m1) (buildActionChildren $children $MMap $actions $perceptions))
       (($finalChildren $m2) (appendActionInsertionChild $updatedChildren $m1 $actions $perceptions))
     )
     ((mkTree (mkNode and_seq) $finalChildren) $m2)))

(= (buildActionTree (mkTree (mkNode action_bool_if) ()) $MMap $actions $perceptions)
   ((mkTree (mkNode action_bool_if) ()) $MMap))
(= (buildActionTree (mkTree (mkNode action_bool_if) (cons $perception $branches)) $MMap $actions $perceptions)
   (let ($updatedBranches $m1) (buildActionBoolIfBranches $branches $MMap $actions $perceptions)
     ((mkTree (mkNode action_bool_if) (cons $perception $updatedBranches)) $m1)))

(= (buildAction $tree (mkNodeId $nodeId) $MMap $actions $perceptions)
   (let $subtree (getNodeById $tree (mkNodeId $nodeId))
     (if (or (== $subtree ()) (isNullVertex $subtree))
         ($tree $MMap)
         (let ($updatedSubtree $m1) (buildActionTree $subtree $MMap $actions $perceptions)
           ((replaceNodeById $tree (mkNodeId $nodeId) $updatedSubtree) $m1)))))

(= (isCleanupActionOperator $op)
   (is-member $op (and_seq or_seq seq_exec)))

(= (actionCleanup $tree)
   (let ($cleaned $keep) (actionCleanupNode $tree)
     (if $keep $cleaned (mkNullVex ()))))

(= (actionCleanupNode (mkNullVex $children))
   ((mkNullVex $children) True))
(= (actionCleanupNode (mkKnob $subtree $knob $i))
   ((mkKnob $subtree $knob $i) True))
(= (actionCleanupNode (mkTree (mkNode $rootOp) $children))
   (let $cleanedChildren (actionCleanupChildren $children)
     (if (and (== $cleanedChildren ()) (isCleanupActionOperator $rootOp))
         ((mkNullVex ()) False)
         ((mkTree (mkNode $rootOp) $cleanedChildren) True))))

(= (actionCleanupChildren ()) ())
(= (actionCleanupChildren (cons $child $rest))
   (let*
     (
       (($cleanedChild $keep) (actionCleanupNode $child))
       ($cleanedRest (actionCleanupChildren $rest))
     )
     (if $keep
         (cons $cleanedChild $cleanedRest)
         $cleanedRest)))

(= (actionCanonize $tree)
   (let (mkTree (mkNode $rootOp) $children) $tree
     (if (== $rootOp and_seq)
         $tree
         (insertNodeAtPosition $tree (mkNodeId (0)) (mkNode and_seq)))))
