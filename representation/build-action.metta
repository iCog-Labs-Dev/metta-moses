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
       ;; quote: action_bool_if is a live bare-head clause
       ;; (scoring/action-ops), so an unquoted (action_bool_if ...) literal
       ;; in this tail position would be an arity-3 call of the arity-2
       ;; head (a hard Prolog length/2 error in this imported-module
       ;; context). quote substitutes the bound values and strips once,
       ;; yielding the plain flat tuple.
       ($perm (quote (action_bool_if $perception $actA $actB)))
     )
     $perm))

(= (actionPairsFromIndexes () $perceptions $actions $actionCount) ())
(= (actionPairsFromIndexes (cons $pairIdx $rest) $perceptions $actions $actionCount)
   (cons (actionPairFromIndex $perceptions $actions $actionCount $pairIdx)
         (actionPairsFromIndexes $rest $perceptions $actions $actionCount)))

;; Add action-subtree ASK knobs to a subtree.
;; Input: subtree
;; Output: (updatedSubtree updatedMMap)
(= (addActionKnobs $subtree $addIfInExemplar $MMap $actions $perceptions)
   (let*
     (
       ($perms (sampleActionPerms $actions $perceptions))
       ($treePerms (map-atom $perms $perm (buildTree $perm)))
       ($idx (MultiMap.length $MMap))
       (($knobs $updatedSubtree) (actionProbe $subtree (mkNodeId (0)) $treePerms $addIfInExemplar () $idx))
       ($pairs (pairKnobWithSpec $knobs))
       ($mmp (expToMMap $pairs $MMap discSpec<))
     )
     ($updatedSubtree $mmp)))

;; Add simple-action ASK knobs to a subtree.
;; Input: subtree
;; Output: (updatedSubtree updatedMMap)
(= (addSimpleActionKnobs $subtree $addIfInExemplar $MMap)
   (let*
     (
       ($idx (MultiMap.length $MMap))
       (($knobs $updatedSubtree) (simpleActionProbe $subtree (mkNodeId (0)) $addIfInExemplar () $idx))
       ($pairs (pairKnobWithSpec $knobs))
       ($mmp (expToMMap $pairs $MMap discSpec<))
     )
     ($updatedSubtree $mmp)))

;; Process a single child of an and_seq subtree.
;; Applies the C++ p=80 action-knob insertion policy.
;; Returns:(rebuiltChild updatedMMap)
(= (processActionChild $child $MMap $actions $perceptions $p)
   (let (mkTree (mkNode $childOp) $_) $child
      (if (isDomainAction $childOp $actions)
          (if (> (randint 99) $p)
              (addSimpleActionKnobs $child True $MMap)
              (addActionKnobs (mkTree (mkNode and_seq) (cons $child ())) False $MMap $actions $perceptions))
              
          (if (== $childOp action_bool_if)
              (if (>= (randint 99) $p)
                  (let*
                    (
                      (($child1 $m1)
                          (addSimpleActionKnobs $child True $MMap))
                    )
                    (buildAction $child1 $m1 $actions $perceptions))
                  (buildAction $child $MMap $actions $perceptions))
              ($child $MMap)))))

;; Existing action knobs are rebuilt recursively.
(= (processActionChild (mkKnob $controlledSubtree $ask $idx) $MMap $actions $perceptions $p)
   (let*
      (
          (($rebuiltSubtree $m1) (buildAction $controlledSubtree $MMap $actions $perceptions))
      )
      ((mkKnob $rebuiltSubtree $ask $idx) $m1)))
;; Process the children of an and_seq subtree.
;; Each child is rebuilt recursively while preserving the C++ p=80
;; action-knob insertion policy. Returns:
;;   (rebuiltChildren updatedMMap)
(= (processActionChildren () $MMap $actions $perceptions $p) (() $MMap))

(= (processActionChildren (cons $child $rest) $MMap $actions $perceptions $p)
   (let*
     (
       (($newChild $m1) (processActionChild $child $MMap $actions $perceptions $p))
       (($newRest $m2) (processActionChildren $rest $m1 $actions $perceptions $p))
     )
     ((cons $newChild $newRest) $m2)))

;; Process one action branch of an action_bool_if subtree.
;; The perception child is handled separately.
(= (processActionBoolIfChild $child $MMap $actions $perceptions)
   (let (mkTree (mkNode $childOp) $_) $child
      (if (isDomainAction $childOp $actions)
         (addActionKnobs (mkTree (mkNode and_seq) (cons $child ())) False $MMap $actions $perceptions)

          (if (== $childOp and_seq)
              (buildAction $child $MMap $actions $perceptions)
              ($child $MMap)))))

;; Process the children of an action_bool_if subtree.
;; The first child is the perception and is preserved unchanged.
;; Remaining action branches are rebuilt recursively.
(= (processActionBoolIfChildren () $MMap $actions $perceptions) 
   (() $MMap))

;; The first child is the perception predicate.
;; Only the action branches are recursively rebuilt.
(= (processActionBoolIfChildren (cons $perception $rest) $MMap $actions $perceptions)
   (let*
     (
       (($rebuiltRest $m1) (processActionBoolIfBranches $rest $MMap $actions $perceptions))
      )
       ((cons $perception $rebuiltRest) $m1)))

;; Rebuild the action branches of an action_bool_if subtree.
;; Returns:  (rebuiltBranches updatedMMap)
(= (processActionBoolIfBranches () $MMap $actions $perceptions) (() $MMap))

(= (processActionBoolIfBranches (cons $child $rest) $MMap $actions $perceptions)
   (let*
     (
       (($rebuiltChild $m1) (processActionBoolIfChild $child $MMap $actions $perceptions))
       (($rebuiltRest $m2) (processActionBoolIfBranches $rest $m1 $actions $perceptions))
     )
     ((cons $rebuiltChild $rebuiltRest) $m2)))

;; Build the representation of an and_seq subtree.
;; Mirrors the C++ action-knob construction using the
;; internal p=80 insertion policy.
(= (buildActionAndSeq (mkTree (mkNode and_seq) $children) $MMap $actions $perceptions)
   (let $p 80
      (if (or (== $children ()) (< (randint 99) $p))

          ;; Insert the knob, then recursively rebuild the returned tree.
          (let*
             (
                (((mkTree (mkNode and_seq) $updatedChildren) $m1) (addActionKnobs (mkTree (mkNode and_seq) $children) True $MMap $actions $perceptions))
                (($rebuiltChildren $m2) (processActionChildren $updatedChildren $m1 $actions $perceptions $p))
             )
           (if (>= (randint 99) $p)

                       (let*
                          (
                             ($extraChild (mkTree (mkNode and_seq) ()))
                             (($extraWrapped $m3) (addActionKnobs $extraChild False $m2 $actions $perceptions))
                          )
                          ((mkTree (mkNode and_seq) (append $rebuiltChildren (cons $extraWrapped ()))) $m3))

                        ((mkTree (mkNode and_seq) $rebuiltChildren) $m2)))
          ;; No knob added at this node.
          (let*
             (
                (($rebuiltChildren $m1) (processActionChildren $children $MMap $actions $perceptions $p))
             )
             (if (>= (randint 99) $p)

                 (let*
                    (
                       ($extraChild (mkTree (mkNode and_seq) ()))
                       (($extraWrapped $m2) (addActionKnobs $extraChild False $m1 $actions $perceptions))
                    )
                    ((mkTree (mkNode and_seq) (append $rebuiltChildren (cons $extraWrapped ()))) $m2))

                 ((mkTree (mkNode and_seq) $rebuiltChildren) $m1))))))

;; Build the representation of an action_bool_if subtree.
(= (buildActionBoolIf (mkTree (mkNode action_bool_if) $children) $MMap $actions $perceptions)
   (let*
      (
         (($rebuiltChildren $m1) (processActionBoolIfChildren $children $MMap $actions $perceptions))
      )
      ((mkTree (mkNode action_bool_if) $rebuiltChildren) $m1)))

;; Recursively rebuild an action subtree.
;; Input: subtree
;; Output: (rebuiltSubtree updatedMMap)
;; Existing knobs are rebuilt only when their default
;; setting is not the exemplar.
(= (buildAction () $MMap $actions $perceptions) (() $MMap))

(= (buildAction (mkNullVex $children) $MMap $actions $perceptions) 
  ((mkNullVex $children) $MMap))

(= (buildAction (mkKnob $controlledSubtree (mkASK $discKnob $perms) $i) $MMap $actions $perceptions)
   (let*
     (
      ($ask (mkASK $discKnob $perms)) ((mkDiscSpec $defaultSetting) (getKnobDefault $ask))
     )
     (if (== $defaultSetting 0)
         ((mkKnob $controlledSubtree $ask $i) $MMap)
         (let*
           (
             (($rebuiltSubtree $updatedMMap) (buildAction $controlledSubtree $MMap $actions $perceptions))
           )
           ((mkKnob $rebuiltSubtree $ask $i) $updatedMMap)))))
           
;; Dispatch to the appropriate subtree builder.
;; Non-action operators are returned unchanged.
(= (buildAction (mkTree (mkNode $op) $children) $MMap $actions $perceptions)
   (if (== $op and_seq)
       (buildActionAndSeq (mkTree (mkNode and_seq) $children) $MMap $actions $perceptions)

       (if (== $op action_bool_if)
           (buildActionBoolIf (mkTree (mkNode action_bool_if) $children) $MMap $actions $perceptions)
           ((mkTree (mkNode $op) $children) $MMap))))

;; The cleanup-op list now lives in scoring/action-registry.metta (seeded
;; identically with and_seq/or_seq/seq_exec -- behavior-preserving);
;; action-registry must load BEFORE this file.
(= (isCleanupActionOperator $op)
   (isRegisteredCleanupActionOp $op))

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
