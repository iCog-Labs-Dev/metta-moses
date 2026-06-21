;; =============================================================================
;; build-action.metta
;;
;; Action-domain knob building, mirroring the action section of C++ build_knobs.cc.
;; =============================================================================

(= (randElement $list)
   (if (== $list ())
       ()
       (let* (($len (length $list))
              ($idx (py-call (random.randint 0 (- $len 1)))))
         (List.getByIdx $list $idx))))

(= (randint $max) (py-call (random.randint 0 $max)))

(= (isDomainAction $op $actions) (is-member $op $actions))

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

;; Add one action-subtree ASK at the target node.
(= (addActionKnobsAt $tree $probeRootId (mkNodeId $tgtId) $addIfInExemplar $MMap $actions $perceptions)
   (let*
     (
       ($perms (sampleActionPerms $actions $perceptions))
       ($treePerms (map-atom $perms $perm (buildTree $perm)))
       ($idx (MultiMap.length $MMap))
       (($knobs $updatedTree) (actionProbe $tree (mkNodeId $tgtId) $treePerms $addIfInExemplar () $idx))
       ($pairs (pairKnobWithSpec $knobs))
       ($mmp (expToMMap $pairs $MMap discSpec<))
     )
     ($updatedTree $mmp)))

;; Add one simple-action ASK over an existing subtree.
(= (addSimpleActionKnobsAt $tree $probeRootId (mkNodeId $tgtId) $addIfInExemplar $MMap $actions $perceptions)
   (let*
     (
       ($idx (MultiMap.length $MMap))
       (($knobs $updatedTree) (simpleActionProbe $tree (mkNodeId $tgtId) $addIfInExemplar () $idx))
       ($pairs (pairKnobWithSpec $knobs))
       ($mmp (expToMMap $pairs $MMap discSpec<))
     )
     ($updatedTree $mmp)))

;; Process one child of and_seq. This preserves the C++ p=80 policy.
(= (processActionChildAt $tree (mkNodeId $parentId) (mkNodeId $childId) $child $MMap $actions $perceptions $p)
   (let (mkTree (mkNode $childOp) $_) $child
      (if (isDomainAction $childOp $actions)
          (if (> (randint 99) $p)
              (addSimpleActionKnobsAt $tree $parentId (mkNodeId $childId) True $MMap $actions $perceptions)
              (let $wrappedTree (insertNodeAtPosition $tree (mkNodeId $childId) (mkNode and_seq))
                 (addActionKnobsAt $wrappedTree $parentId (mkNodeId $childId) False $MMap $actions $perceptions)))
          (if (== $childOp action_bool_if)
              (if (>= (randint 99) $p)
                  (let ($t1 $m1) (addSimpleActionKnobsAt $tree $parentId (mkNodeId $childId) True $MMap $actions $perceptions)
                      (buildAction $t1 (mkNodeId $childId) $m1 $actions $perceptions))
                  (buildAction $tree (mkNodeId $childId) $MMap $actions $perceptions))
              ($tree $MMap)))))

(= (processActionChildren $tree (mkNodeId $parentId) () $childIdx $MMap $actions $perceptions $p)
   ($tree $MMap))

(= (processActionChildren $tree (mkNodeId $parentId) (cons $child $rest) $childIdx $MMap $actions $perceptions $p)
   (let*
     (
       ($childId (if (== $parentId (0)) ($childIdx) (concatT $parentId ($childIdx))))
       (($t1 $m1) (processActionChildAt $tree (mkNodeId $parentId) (mkNodeId $childId) $child $MMap $actions $perceptions $p))
     )
     (processActionChildren $t1 (mkNodeId $parentId) $rest (+ $childIdx 1) $m1 $actions $perceptions $p)))

;; Process action_bool_if branches. Child 1 is perception and is skipped.
(= (processActionBoolIfChildAt $tree (mkNodeId $parentId) (mkNodeId $childId) $child $MMap $actions $perceptions)
   (let (mkTree (mkNode $childOp) $_) $child
      (if (isDomainAction $childOp $actions)
          (let $wrappedTree (insertNodeAtPosition $tree (mkNodeId $childId) (mkNode and_seq))
            (addActionKnobsAt $wrappedTree $parentId (mkNodeId $childId) False $MMap $actions $perceptions))
          (if (== $childOp and_seq)
              (buildAction $tree (mkNodeId $childId) $MMap $actions $perceptions)
              ($tree $MMap)))))

(= (processActionBoolIfChildren $tree (mkNodeId $parentId) () $childIdx $MMap $actions $perceptions)
   ($tree $MMap))

(= (processActionBoolIfChildren $tree (mkNodeId $parentId) (cons $child $rest) $childIdx $MMap $actions $perceptions)
   (if (== $childIdx 1)
       (processActionBoolIfChildren $tree (mkNodeId $parentId) $rest (+ $childIdx 1) $MMap $actions $perceptions)
       (let*
         (
           ($childId (if (== $parentId (0)) ($childIdx) (concatT $parentId ($childIdx))))
           (($t1 $m1) (processActionBoolIfChildAt $tree (mkNodeId $parentId) (mkNodeId $childId) $child $MMap $actions $perceptions))
         )
         (processActionBoolIfChildren $t1 (mkNodeId $parentId) $rest (+ $childIdx 1) $m1 $actions $perceptions))))

;; Handle sequential_and nodes with the fixed internal C++ probability p=80.
(= (buildActionAndSeq $tree (mkNodeId $nodeId) $children $MMap $actions $perceptions)
   (let $p 80
    (if (or (== $children ()) (< (randint 99) $p))
        (let*
          (
            (($t1 $m1) (addActionKnobsAt $tree (mkNodeId $nodeId) (mkNodeId $nodeId) True $MMap $actions $perceptions))
            (($t2 $m2) (processActionChildren $t1 (mkNodeId $nodeId) $children 1 $m1 $actions $perceptions $p))
          )
          (if (>= (randint 99) $p)
              (let*
                (
                  ($builtTree (buildTree (and_seq)))
                  (($t3 $newId) (appendChild $t2 (mkNodeId $nodeId) $builtTree))
                )
                (addActionKnobsAt $t3 (mkNodeId $nodeId) $newId False $m2 $actions $perceptions))
              ($t2 $m2)))
        (let ($t1 $m1) (processActionChildren $tree (mkNodeId $nodeId) $children 1 $MMap $actions $perceptions $p)
          (if (>= (randint 99) $p)
              (let*
                (
                  ($builtTree (buildTree (and_seq)))
                  (($t2 $newId) (appendChild $t1 (mkNodeId $nodeId) $builtTree))
                )
                (addActionKnobsAt $t2 (mkNodeId $nodeId) $newId False $m1 $actions $perceptions))
              ($t1 $m1))))))

(= (buildActionBoolIf $tree (mkNodeId $nodeId) $children $MMap $actions $perceptions)
   (processActionBoolIfChildren $tree (mkNodeId $nodeId) $children 1 $MMap $actions $perceptions))

(= (buildAction $tree (mkNodeId $nodeId) $MMap $actions $perceptions)
  (let $subtree (getNodeById $tree (mkNodeId $nodeId))
    (case $subtree
      (
        ((mkKnob $controlledSubtree (mkASK $discKnob $perms) $i)
           (let*
             (
               ($ask (mkASK $discKnob $perms))
               ((mkDiscSpec $defaultSetting) (getKnobDefault $ask))
             )
             (if (== $defaultSetting 0)
                 ($tree $MMap)
                 (let*
                   (
                     (($rebuiltSubtree $updatedMMap) (buildAction $controlledSubtree (mkNodeId (0)) $MMap $actions $perceptions))
                     ($updatedTree (replaceNodeById $tree (mkNodeId $nodeId) (mkKnob $rebuiltSubtree $ask $i)))
                   )
                   ($updatedTree $updatedMMap)))))
        ($other
          (if (or (== $subtree ()) (isNullVertex $subtree))
              ($tree $MMap)
              (let (mkTree (mkNode $op) $_) $subtree
                (if (== $op and_seq)
                    (let $children (getChildren $subtree)
                      (buildActionAndSeq $tree (mkNodeId $nodeId) $children $MMap $actions $perceptions))
                    (if (== $op action_bool_if)
                        (let $children (getChildren $subtree)
                          (buildActionBoolIf $tree (mkNodeId $nodeId) $children $MMap $actions $perceptions))
                        ($tree $MMap))))))))))

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
