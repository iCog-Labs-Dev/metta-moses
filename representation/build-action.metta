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

;; Domain-membership predicates must return one Boolean, not is-member's
;; comparison-by-comparison alternatives.
(= (isDomainAction $op $actions) (once (is-member $op $actions)))

(= (sampleActionPerms $actions $perceptions $ignoreOps)
   (if (== $perceptions ())
       $actions
       (sampleActionPerms $actions $perceptions (length $actions) $ignoreOps)))

(= (sampleActionPerms $actions $perceptions $n $ignoreOps)
   (let $actionCount (length $actions)
     (if (or (== $n 0) (< $actionCount 2))
         $actions
         (let*
           (
             ($pairCount (* $actionCount (- $actionCount 1)))
             ($sampleCount (min $n $pairCount))
             ($pairIdxs (lazyRandomSelector 0 (- $pairCount 1) $sampleCount))
             ($pairs (actionPairsFromIndexes $pairIdxs $perceptions $actions $actionCount $ignoreOps))
           )
           (append $actions $pairs)))))

(= (actionPairFromIndex $perceptions $actions $actionCount $pairIdx $ignoreOps)
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
       ($perm
         (if (operatorAllowed action_bool_if $ignoreOps)
            (quote (action_bool_if $perception $actA $actB))
           ()))
     )
     $perm))

;; One action_bool_if perm per index, in index order; () (action_bool_if
;; ignored) is dropped. map-atom runs left to right, so randElement draws
;; in index order.
(= (actionPairsFromIndexes $pairIdxs $perceptions $actions $actionCount $ignoreOps)
   (filter-atom
     (map-atom $pairIdxs $pairIdx (actionPairFromIndex $perceptions $actions $actionCount $pairIdx $ignoreOps))
     $pair
     (!= $pair ())))

;; Add action-subtree ASK knobs to a subtree.
;; Input: subtree
;; Output: (updatedSubtree updatedMMap)
(= (addActionKnobs $subtree $addIfInExemplar $knobMap $actions $perceptions $ignoreOps)
   (let*
     (
       ($perms (sampleActionPerms $actions $perceptions $ignoreOps))
       ($treePerms (map-atom $perms $perm (buildTree $perm)))
       ($idx (MultiMap.length $knobMap))
       (($knobs $updatedSubtree) (actionProbe $subtree (mkNodeId (0)) $treePerms $addIfInExemplar () $idx))
       ($pairs (pairKnobWithSpec $knobs))
       ($mmp (append $knobMap $pairs))
     )
     ($updatedSubtree $mmp)))

;; Add simple-action ASK knobs to a subtree.
;; Input: subtree
;; Output: (updatedSubtree updatedMMap)
(= (addSimpleActionKnobs $subtree $addIfInExemplar $knobMap)
   (let*
     (
       ($idx (MultiMap.length $knobMap))
       (($knobs $updatedSubtree) (simpleActionProbe $subtree (mkNodeId (0)) $addIfInExemplar () $idx))
       ($pairs (pairKnobWithSpec $knobs))
       ($mmp (append $knobMap $pairs))
     )
     ($updatedSubtree $mmp)))

;; Wrap a domain action in an and_seq subtree that gets action ASK knobs.
;; Returns (rebuiltChild updatedMMap); unchanged when and_seq is ignored.
(= (wrapInAndSeqKnob $child $knobMap $actions $perceptions $ignoreOps)
   (if (operatorAllowed and_seq $ignoreOps)
       (addActionKnobs (mkTree (mkNode and_seq) ($child)) False $knobMap $actions $perceptions $ignoreOps)
       ($child $knobMap)))

;; Builds the and_seq node from its rebuilt children. With the C++ p=80
;; policy, it appends an empty and_seq with action knobs. `and` draws
;; (randint 99) every time, as before.
(= (appendExtraAndSeqKnob $children $knobMap $actions $perceptions $p $ignoreOps)
   (if (and (>= (randint 99) $p)
            (operatorAllowed and_seq $ignoreOps))
       (let ($extraWrapped $m) (addActionKnobs (mkTree (mkNode and_seq) ()) False $knobMap $actions $perceptions $ignoreOps)
          ((mkTree (mkNode and_seq) (append $children ($extraWrapped))) $m))
       ((mkTree (mkNode and_seq) $children) $knobMap)))

;; Process a single child of an and_seq subtree.
;; Applies the C++ p=80 action-knob insertion policy.
;; Returns:(rebuiltChild updatedMMap)
(= (processActionChild $child $knobMap $actions $perceptions $p $ignoreOps)
   (let (mkTree (mkNode $childOp) $_) $child
      (if (isDomainAction $childOp $actions)
          (if (> (randint 99) $p)
              (addSimpleActionKnobs $child True $knobMap)
              (wrapInAndSeqKnob $child $knobMap $actions $perceptions $ignoreOps))

          (if (== $childOp action_bool_if)
              (if (>= (randint 99) $p)
                  (let ($child1 $m1) (addSimpleActionKnobs $child True $knobMap)
                    (buildAction $child1 $m1 $actions $perceptions $ignoreOps))
                  (buildAction $child $knobMap $actions $perceptions $ignoreOps))
              ($child $knobMap)))))

;; Existing action knobs are rebuilt recursively.
(= (processActionChild (mkKnob $controlledSubtree $ask $idx) $knobMap $actions $perceptions $p $ignoreOps)
   (let ($rebuiltSubtree $m1) (buildAction $controlledSubtree $knobMap $actions $perceptions $ignoreOps)
      ((mkKnob $rebuiltSubtree $ask $idx) $m1)))
;; Process the children of an and_seq subtree.
;; Each child is rebuilt recursively while preserving the C++ p=80
;; action-knob insertion policy. Returns:
;;   (rebuiltChildren updatedMMap)
;; foldl-atom runs left to right, so the random draws keep their order.
(= (processActionChildren $children $knobMap $actions $perceptions $p $ignoreOps)
   (let* ((($reversedChildren $finalMap)
            (foldl-atom $children (() $knobMap) $acc $child
              (let* ((($prevChildren $prevMap) $acc)
                     (($newChild $newMap) (processActionChild $child $prevMap $actions $perceptions $p $ignoreOps)))
                ((cons $newChild $prevChildren) $newMap))))
          ($rebuiltChildren (reverse $reversedChildren)))
     ($rebuiltChildren $finalMap)))

;; Process one action branch of an action_bool_if subtree.
;; The perception child is handled separately.
(= (processActionBoolIfChild $child $knobMap $actions $perceptions $ignoreOps)
   (let (mkTree (mkNode $childOp) $_) $child
      (if (isDomainAction $childOp $actions)
          (wrapInAndSeqKnob $child $knobMap $actions $perceptions $ignoreOps)
          (if (== $childOp and_seq)
              (buildAction $child $knobMap $actions $perceptions $ignoreOps)
              ($child $knobMap)))))

;; Process the children of an action_bool_if subtree.
;; The first child is the perception and is preserved unchanged.
;; Remaining action branches are rebuilt recursively.
(= (processActionBoolIfChildren () $knobMap $actions $perceptions $ignoreOps)
   (() $knobMap))

;; The first child is the perception predicate.
;; Only the action branches are recursively rebuilt.
(= (processActionBoolIfChildren (cons $perception $rest) $knobMap $actions $perceptions $ignoreOps)
   (let ($rebuiltRest $m1) (processActionBoolIfBranches $rest $knobMap $actions $perceptions $ignoreOps)
     ((cons $perception $rebuiltRest) $m1)))

;; Rebuild the action branches of an action_bool_if subtree.
;; Returns:  (rebuiltBranches updatedMMap)
(= (processActionBoolIfBranches $branches $knobMap $actions $perceptions $ignoreOps)
   (let* ((($reversedBranches $finalMap)
            (foldl-atom $branches (() $knobMap) $acc $child
              (let* ((($prevBranches $prevMap) $acc)
                     (($rebuiltChild $newMap) (processActionBoolIfChild $child $prevMap $actions $perceptions $ignoreOps)))
                ((cons $rebuiltChild $prevBranches) $newMap))))
          ($rebuiltBranches (reverse $reversedBranches)))
     ($rebuiltBranches $finalMap)))

;; Build the representation of an and_seq subtree.
;; Mirrors the C++ action-knob construction using the
;; internal p=80 insertion policy.
(= (buildActionAndSeq (mkTree (mkNode and_seq) $children) $knobMap $actions $perceptions $ignoreOps)
   (let* (
          ($p 80)
          (($rebuiltChildren $m1)
            (if (or (== $children ()) (< (randint 99) $p))
                ;; Insert the knob, then recursively rebuild the returned tree.
                (let ((mkTree (mkNode and_seq) $updatedChildren) $m0)
                     (addActionKnobs (mkTree (mkNode and_seq) $children) True $knobMap $actions $perceptions $ignoreOps)
                   (processActionChildren $updatedChildren $m0 $actions $perceptions $p $ignoreOps))
                ;; No knob added at this node.
                (processActionChildren $children $knobMap $actions $perceptions $p $ignoreOps)))
         )
     (appendExtraAndSeqKnob $rebuiltChildren $m1 $actions $perceptions $p $ignoreOps)))

;; Build the representation of an action_bool_if subtree.
(= (buildActionBoolIf (mkTree (mkNode action_bool_if) $children) $knobMap $actions $perceptions $ignoreOps)
   (let ($rebuiltChildren $m1) (processActionBoolIfChildren $children $knobMap $actions $perceptions $ignoreOps)
      ((mkTree (mkNode action_bool_if) $rebuiltChildren) $m1)))

;; Recursively rebuild an action subtree.
;; Input: subtree
;; Output: (rebuiltSubtree updatedMMap)
;; Existing knobs are rebuilt only when their default
;; setting is not the exemplar.
(= (buildAction () $knobMap $actions $perceptions $ignoreOps) (() $knobMap))

(= (buildAction (mkNullVex $children) $knobMap $actions $perceptions $ignoreOps)
  ((mkNullVex $children) $knobMap))

(= (buildAction (mkKnob $controlledSubtree (mkASK $discKnob $perms) $i) $knobMap $actions $perceptions $ignoreOps)
   (let*
     (
      ($ask (mkASK $discKnob $perms))
      ((mkDiscSpec $defaultSetting) (getKnobDefault $ask))
     )
     (if (== $defaultSetting 0)
         ((mkKnob $controlledSubtree $ask $i) $knobMap)
         (let ($rebuiltSubtree $updatedMMap) (buildAction $controlledSubtree $knobMap $actions $perceptions $ignoreOps)
           ((mkKnob $rebuiltSubtree $ask $i) $updatedMMap)))))

;; Dispatch to the appropriate subtree builder.
;; Non-action operators are returned unchanged.
(= (buildAction (mkTree (mkNode $op) $children) $knobMap $actions $perceptions $ignoreOps)
   (if (== $op and_seq)
       (buildActionAndSeq (mkTree (mkNode and_seq) $children) $knobMap $actions $perceptions $ignoreOps)

       (if (== $op action_bool_if) ;; (action_bool_if ($cond $a $b))
           (buildActionBoolIf (mkTree (mkNode action_bool_if) $children) $knobMap $actions $perceptions $ignoreOps)
           ((mkTree (mkNode $op) $children) $knobMap))))

(= (actionCleanup $tree)
   (let ($cleaned $keep) (actionCleanupNode $tree)
     (if $keep $cleaned (mkNullVex ()))))

(= (actionCleanupNode (mkNullVex $children))
   ((mkNullVex $children) True))
(= (actionCleanupNode (mkKnob $subtree $knob $i))
   ((mkKnob $subtree $knob $i) True))
(= (actionCleanupNode (mkTree (mkNode $rootOp) $children))
   (let $cleanedChildren (actionCleanupChildren $children)
     (if (and (== $cleanedChildren ()) (isRegisteredCleanupActionOp $rootOp))
         ((mkNullVex ()) False)
         ((mkTree (mkNode $rootOp) $cleanedChildren) True))))

;; Cleans each child and keeps the ones that actionCleanupNode marks True.
(= (actionCleanupChildren $children)
   (let $cleanedPairs (map-atom $children $child (actionCleanupNode $child))
      (map-atom (filter-atom $cleanedPairs ($cleaned $keep) $keep)
                ($cleaned $keep)
                $cleaned)))

(= (actionCanonize $tree)
   (let (mkTree (mkNode $rootOp) $children) $tree
     (if (== $rootOp and_seq)
         $tree
         (insertNodeAtPosition $tree (mkNodeId (0)) (mkNode and_seq)))))
