;; Logical-only discrete probe. It tests non-default LSK settings in the
;; context of a logical root and disallows settings whose cleaned tree has
;; lower complexity.

;; Retrieves the subtree controlled by an explicit target ID.
;; If the target node is a null vertex, its first child is the controlled
;; subtree; otherwise the target node itself is controlled.
(= (probeControlledSubtree $tree $targetId)
   (let $targetNode (getNodeById $tree $targetId)
      (if (isNullVertex $targetNode)
          (car-atom (getChildren $targetNode))
          $targetNode)))

;; Applies a logical setting to a controlled subtree.
;; 0 - absent/null, 1 - present, 2 - negated.
(= (applyLogicalSettingToSubtree $subtree 0) (mkNullVex (cons $subtree ())))
(= (applyLogicalSettingToSubtree $subtree 1) $subtree)
(= (applyLogicalSettingToSubtree $subtree 2) (insertAbove $subtree (mkNode NOT)))

;; Replaces the explicitly targeted node with the controlled subtree after
;; applying the requested actual setting.
(= (probeTreeForActualSetting $tree $targetId $actualSetting)
   (let*
      (
        ($subtree (probeControlledSubtree $tree $targetId))
        ($probedSubtree (applyLogicalSettingToSubtree $subtree $actualSetting))
      )
      (replaceNodeById $tree $targetId $probedSubtree)))

;; True when applying a setting and cleaning the probed root lowers complexity.
(= (settingReducesComplexity $tree $probeRootId $targetId $actualSetting)
   (let*
      (
        ($probedTree (probeTreeForActualSetting $tree $targetId $actualSetting))
        ($probedRoot (getNodeById $probedTree $probeRootId))
        ($initialCpxy (treeComplexity $probedRoot))
        ($reducedRoot (cleanTree $probedRoot))
        ($reducedCpxy (treeComplexity $reducedRoot))
      )
      (> $initialCpxy $reducedCpxy)))

;; Tests all effective non-default settings and accumulates disallowed actual
;; settings for a knob.
(= (probeEffectiveSettings $tree $probeRootId $targetId $lsk $setting $acc)
   (let (mkMultip $m) (getKnobMultip $lsk)
      (if (>= $setting $m)
          $acc
          (let $actualSetting (mapEffectiveDiscSpec $lsk $setting)
             (if (settingReducesComplexity $tree $probeRootId $targetId $actualSetting)
                 (probeEffectiveSettings $tree $probeRootId $targetId $lsk (+ $setting 1) (cons-atom (mkDiscSpec $actualSetting) $acc))
                 (probeEffectiveSettings $tree $probeRootId $targetId $lsk (+ $setting 1) $acc))))))

;; Updates an id-free LSK with settings disallowed in the supplied context.
(= (discProbe $tree $probeRootId $targetId $lsk)
   (let*
      (
        ((mkLSK (mkDiscKnob $m $default $current $oldDis)) $lsk)
        ($dis (probeEffectiveSettings $tree $probeRootId $targetId $lsk 1 $oldDis))
      )
      (mkLSK (mkDiscKnob $m $default $current $dis))))
