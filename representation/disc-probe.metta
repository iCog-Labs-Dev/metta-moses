;; Logical-only discrete probe, mirroring C++ build_knobs::disc_probe.
;; It probes non-default LSK settings in the context of a logical root and
;; disallows settings whose cleaned tree has lower complexity.

;; probeControlledSubtree: dig into the tree at the knob's location and 
;;                         extract the raw, underlying logic subtree we are trying to test.
(= (probeControlledSubtree $tree $lsk)
   (let*
      (
        ((mkNodeId $targetId) (getNodeId $lsk))
        ($targetNode (getNodeById $tree (mkNodeId $targetId)))
      )
      (if (isNullVertex $targetNode)
          (car-atom (getChildren $targetNode))
          $targetNode)))

(= (applyLogicalSettingToSubtree $subtree 0) (mkNullVex (cons $subtree ())))
(= (applyLogicalSettingToSubtree $subtree 1) $subtree)
(= (applyLogicalSettingToSubtree $subtree 2) (insertAbove $subtree (mkNode NOT)))

;; probeTreeForActualSetting: a simulator. It wants to see what the entire candidate 
;;                            program would look like if a specific setting were permanently locked in.
(= (probeTreeForActualSetting $tree $lsk $actualSetting)
   (let*
      (
        ((mkNodeId $targetId) (getNodeId $lsk))
        ($subtree (probeControlledSubtree $tree $lsk))
        ($probedSubtree (applyLogicalSettingToSubtree $subtree $actualSetting))
      )
      (replaceNodeById $tree (mkNodeId $targetId) $probedSubtree)))

;; settingReducesComplexity: takes the experimental tree and tests it for logical flaws. 
;;                            It measures the complexity of the tree (counting the nodes), runs the entire 
;;                            tree through the cleanTree Boolean Reducer to mathematically simplify it, and 
;;                            then measures the complexity again.
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

;; probeEffectiveSettings: steps through every single non-default setting 
;;                        inthe knob possesses (using $setting as an index) and runs them through settingReducesComplexity.
;;                        inOutput: A List of Disallowed Specifications. 
;;                        inExample: ((mkDiscSpec 1) (mkDiscSpec 2)) if both the present and negated versions of a subtree are proven to be mathematically redundant.
(= (probeEffectiveSettings $tree $probeRootId $lsk $setting $acc)
   (let (mkMultip $m) (getRawKnobMultip $lsk)
      (if (>= $setting $m)
          $acc
          (let $actualSetting (mapEffectiveDiscSpec $lsk $setting)
             (if (settingReducesComplexity $tree $probeRootId $lsk $actualSetting)
                 (probeEffectiveSettings $tree $probeRootId $lsk (+ $setting 1) (cons-atom (mkDiscSpec $actualSetting) $acc))
                 (probeEffectiveSettings $tree $probeRootId $lsk (+ $setting 1) $acc))))))

;; discProbe: Root-aware probe. $probeRootId is the logical subtree root whose complexity
;;             should be compared after probing the controlled node.
;;             discProbe calls on probeEffectiveSettings to find out which settings are bad
(= (discProbe $tree $probeRootId $lsk)
   (let*
      (
        ($dis (probeEffectiveSettings $tree $probeRootId $lsk 1 ()))
        ((mkLSK (mkDiscKnob $k $m $default $current $_)) $lsk)
      )
      (mkLSK (mkDiscKnob $k $m $default $current $dis))))

;; Backward-compatible wrapper for tests/callers that probe at the knob target.
(= (discProbe $tree $lsk)
   (discProbe $tree (getNodeId $lsk) $lsk))
