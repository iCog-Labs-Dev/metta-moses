;; Logical-only discrete probe. It tests non-default LSK settings in the
;; context of a logical root and disallows settings whose cleaned tree has
;; lower complexity.

;; probeControlledSubtree
;; Retrieves the controlled subtree of a node targeted by a Logical Subtree Knob (LSK).
;; If the target node is a null vertex, it returns its first child; otherwise, it returns the target node.
;; Params:
;;      $tree: The tree representation being probed.
;;      $lsk: The Logical Subtree Knob (LSK) targeting the node.
;; Return: The controlled subtree.
(= (probeControlledSubtree $tree $lsk)
   (let*
      (
        ((mkNodeId $targetId) (getNodeId $lsk))
        ($targetNode (getNodeById $tree (mkNodeId $targetId)))
      )
      (if (isNullVertex $targetNode)
          (car-atom (getChildren $targetNode))
          $targetNode)))

;; applyLogicalSettingToSubtree
;; Applies a logical modification/setting to a subtree.
;; Params:
;;      $subtree: The subtree to modify.
;;      $setting:
;;          The integer value representing the setting to apply:
;;          0 - Wrap the subtree under a null vertex.
;;          1 - Keep the subtree unchanged.
;;          2 - Insert a NOT node above the subtree.
;; Return: The modified subtree with the setting applied.

(= (applyLogicalSettingToSubtree $subtree 0) (mkNullVex (cons $subtree ())))
(= (applyLogicalSettingToSubtree $subtree 1) $subtree)
(= (applyLogicalSettingToSubtree $subtree 2) (insertAbove $subtree (mkNode NOT)))

;; probeTreeForActualSetting
;; Replaces the node controlled by the LSK with the subtree modified by the actual logical setting.
;; Params:
;;      $tree: The original tree representation.
;;      $lsk: The Logical Subtree Knob (LSK) specifying the target node to replace.
;;      $actualSetting: The logical setting integer (0, 1, or 2) to apply.
;; Return: The updated tree with the probed setting applied.

(= (probeTreeForActualSetting $tree $lsk $actualSetting)
   (let*
      (
        ((mkNodeId $targetId) (getNodeId $lsk))
        ($subtree (probeControlledSubtree $tree $lsk))
        ($probedSubtree (applyLogicalSettingToSubtree $subtree $actualSetting))
      )
      (replaceNodeById $tree (mkNodeId $targetId) $probedSubtree)))

;; settingReducesComplexity
;; Determines if applying a logical setting to the controlled subtree and cleaning it reduces tree complexity.
;; Params:
;;      $tree: The tree representation being evaluated.
;;      $probeRootId: The node ID of the logical root under which complexity is measured.
;;      $lsk: The Logical Subtree Knob (LSK) targeting the node.
;;      $actualSetting: The logical setting value to test.
;; Return: True if the cleaned tree has lower complexity than the initial probed tree; otherwise False.

(= (settingReducesComplexity $tree $probeRootId $lsk $actualSetting)
   (let*
      (
        ($probedTree (probeTreeForActualSetting $tree $lsk $actualSetting))
        ($probedRoot (getNodeById $probedTree $probeRootId))
        ($initialCpxy (treeComplexity $probedRoot))
        ($reducedRoot (cleanTree $probedRoot))
        ($reducedCpxy (treeComplexity $reducedRoot))
      )
      (> $initialCpxy $reducedCpxy)))

;; probeEffectiveSettings
;; Recursively tests and accumulates all complexity-reducing settings for a given LSK.
;; Params:
;;      $tree: The tree representation being evaluated.
;;      $probeRootId: The node ID of the logical root.
;;      $lsk: The Logical Subtree Knob (LSK) being probed.
;;      $setting: The current setting index being evaluated (starts at 1).
;;      $acc: The accumulator list containing the allowed discrete settings.
;; Return: The final list of allowed discrete specifications that reduce complexity.

(= (probeEffectiveSettings $tree $probeRootId $lsk $setting $acc)
   (let (mkMultip $m) (getRawKnobMultip $lsk)
      (if (>= $setting $m)
          $acc
          (let $actualSetting (mapEffectiveDiscSpec $lsk $setting)
             (if (settingReducesComplexity $tree $probeRootId $lsk $actualSetting)
                 (probeEffectiveSettings $tree $probeRootId $lsk (+ $setting 1) (cons-atom (mkDiscSpec $actualSetting) $acc))
                 (probeEffectiveSettings $tree $probeRootId $lsk (+ $setting 1) $acc))))))

;; discProbe (with logical root ID)
;; Identifies all complexity-reducing settings for an LSK in the context of a logical root,
;; and updates the LSK with the allowed discrete settings list.
;; Params:
;;      $tree: The tree representation.
;;      $probeRootId: The node ID of the logical root for complexity evaluation.
;;      $lsk: The Logical Subtree Knob (LSK) to probe and update.
;; Return: The updated LSK containing the list of allowed complexity-reducing settings.

(= (discProbe $tree $probeRootId $lsk)
   (let*
      (
        ($dis (probeEffectiveSettings $tree $probeRootId $lsk 1 ()))
        ((mkLSK (mkDiscKnob $k $m $default $current $_)) $lsk)
      )
      (mkLSK (mkDiscKnob $k $m $default $current $dis))))

;; discProbe (default logical root)
;; Probes the LSK using its own target node ID as the logical root for complexity evaluation.
;; Params:
;;      $tree: The tree representation.
;;      $lsk: The Logical Subtree Knob (LSK) to probe and update.
;; Return: The updated LSK containing the list of allowed complexity-reducing settings.

(= (discProbe $tree $lsk)
   (discProbe $tree (getNodeId $lsk) $lsk))
