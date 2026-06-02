;;;knob base representation
;;    <- TODO ->
;; knob representation only contains nodeid
;; we don't need this constractor since we are passing the updated tree as state

;; (: Knob Type)
;; (: mkKnob (-> NodeId Knob)) 
;;
;;; Discrete knob representation
;      Multiplicity: number of possible distinct states/settings a knob can have
;      DiscSpec: Disc specification containing the states
;; (: DiscreteKnob Type)
;; (: Multiplicity Type)
;; (: mkMultip (-> Number Multiplicity))
;;
;; (: DiscSpec Type)
;; (: mkDiscSpec (-> Number DiscSpec))

;; (: mkDiscKnob (-> Knob Multiplicity DiscreteKnob))  
;; (: mkDiscKnob (-> Knob Multiplicity DiscSpec DiscSpec (List DiscSpec) DiscreteKnob))
;; (= (mkDiscKnob $knob $multiplicity)
;;    (mkDiscKnob $knob $multiplicity (mkDiscSpec 0) (mkDiscSpec 0) ())
;; )

;; Logical subtree knob representation
       ;Subtree: represents a portion of the tree that will be controlled by the knob
;; (: LogicalSubtreeKnob Type)
;; (: mkLSK (-> DiscreteKnob LogicalSubtreeKnob))

;; Strategy subtree knob representation (for game strategies)
;; (: StrategySubtreeKnob Type)
;; (: mkSSK (-> DiscreteKnob StrategySubtreeKnob))

;; Checks if a DiscreteKnob is considered part of the exemplar based on its default specifier.
;; Params:
;;   $discKnob: DiscreteKnob
;; Return: True if the default specifier is non-zero (not in exemplar), False otherwise.
;; (: inExemplar (-> DiscreteKnob Bool))
(= (inExemplar (mkDiscKnob $knob $multiplicity (mkDiscSpec $curr) (mkDiscSpec $def) $dis)) 
   (not (== $def 0)))

;; Extracts the DiscreteKnob component from a LogicalSubtreeKnob (mkLSK) or StrategySubtreeKnob (mkSSK).
;; Params:
;;   $lsk: LogicalSubtreeKnob or StrategySubtreeKnob
;; Return: The extracted DiscKnob
;; (: getDiscKnob (-> LogicalSubtreeKnob DiscreteKnob))
;; (: getDiscKnob (-> StrategySubtreeKnob DiscreteKnob))
(= (getDiscKnob (mkLSK $DiscKnob )) $DiscKnob)
(= (getDiscKnob (mkSSK $DiscKnob )) $DiscKnob)

;; Extracts the Tree component from a LogicalSubtreeKnob (mkLSK).
;; Params:
;;   $lsk: LogicalSubtreeKnob


;; Extracts the raw multiplicity stored on a discrete or logical/strategy knob.
;; The effective multiplicity below subtracts disallowed non-default settings.
;; (: getRawKnobMultip (-> DiscreteKnob Multiplicity))
;; (: getRawKnobMultip (-> LogicalSubtreeKnob Multiplicity))
;; (: getRawKnobMultip (-> StrategySubtreeKnob Multiplicity))
(= (getRawKnobMultip (mkDiscKnob $knob $multiplicity $curr $def $disAll)) $multiplicity)
(= (getRawKnobMultip (mkLSK $discKnob )) (getRawKnobMultip $discKnob))
(= (getRawKnobMultip (mkSSK $discKnob )) (getRawKnobMultip $discKnob))

;; Extracts the default setting and disallowed settings from a knob.
;; (: getKnobDefault (-> DiscreteKnob DiscSpec))
;; (: getKnobDefault (-> LogicalSubtreeKnob DiscSpec))
;; (: getKnobDefault (-> StrategySubtreeKnob DiscSpec))
(= (getKnobDefault (mkDiscKnob $knob $multiplicity $current $default $disAll)) $default)
(= (getKnobDefault (mkLSK $discKnob )) (getKnobDefault $discKnob))
(= (getKnobDefault (mkSSK $discKnob )) (getKnobDefault $discKnob))

;; (: getDisallowedSpecs (-> DiscreteKnob (List DiscSpec)))
;; (: getDisallowedSpecs (-> LogicalSubtreeKnob (List DiscSpec)))
;; (: getDisallowedSpecs (-> StrategySubtreeKnob (List DiscSpec)))
(= (getDisallowedSpecs (mkDiscKnob $knob $multiplicity $current $default $disAll)) $disAll)
(= (getDisallowedSpecs (mkLSK $discKnob )) (getDisallowedSpecs $discKnob))
(= (getDisallowedSpecs (mkSSK $discKnob )) (getDisallowedSpecs $discKnob))

(= (countNonDefaultDisallowed (mkDiscSpec $default) ()) 0)
(= (countNonDefaultDisallowed (mkDiscSpec $default) (cons (mkDiscSpec $setting) $tail))
   (+ (if (== $setting $default) 0 1)
      (countNonDefaultDisallowed (mkDiscSpec $default) $tail)))

;; Extracts the effective multiplicity from a discrete or logical/strategy subtree knob.
;; Params:
;;  $knob: Either discrete, logical subtree, or strategy subtree knob
;; Returns: The multiplicity after removing disallowed non-default settings.
;; (: getKnobMultip (-> DiscreteKnob Multiplicity))
;; (: getKnobMultip (-> LogicalSubtreeKnob Multiplicity))
;; (: getKnobMultip (-> StrategySubtreeKnob Multiplicity))

(= (getKnobMultip (mkDiscKnob $knob (mkMultip $multiplicity) $current $default $disAll))
   (mkMultip (- $multiplicity (countNonDefaultDisallowed $default $disAll))))
(= (getKnobMultip (mkLSK $discKnob )) (getKnobMultip $discKnob))
(= (getKnobMultip (mkSSK $discKnob )) (getKnobMultip $discKnob))

;; Calculates the knob Specification of an LSK or SSK
;; (: getKnobSpec (-> LogicalSubtreeKnob DiscSpec))
;; (: getKnobSpec (-> StrategySubtreeKnob DiscSpec))
(= (getKnobSpec (mkLSK $discKnob))
   (let (mkMultip $multip) (getKnobMultip (mkLSK $discKnob)) (mkDiscSpec $multip)))
(= (getKnobSpec (mkSSK $discKnob))
   (let (mkMultip $multip) (getKnobMultip (mkSSK $discKnob)) (mkDiscSpec $multip)))

(= (allDisallowed $knob)
   (let*
      (
        ((mkMultip $effectiveMultip) (getKnobMultip $knob))
      )
      (<= $effectiveMultip 1)))

(= (settingDisallowed $setting $disAll)
   (List.contains (mkDiscSpec $setting) $disAll))

(= (allowedNonDefaultSetting $setting $default $disAll)
   (and (not (== $setting $default))
        (not (settingDisallowed $setting $disAll))))

(= (nthAllowedActualSetting $candidate $remaining $default $disAll)
   (if (allowedNonDefaultSetting $candidate $default $disAll)
       (if (== $remaining 1)
           $candidate
           (nthAllowedActualSetting (+ $candidate 1) (- $remaining 1) $default $disAll))
       (nthAllowedActualSetting (+ $candidate 1) $remaining $default $disAll)))
       
;; mapEffectiveDiscSpec acts as a translator between two numbering systems for knob settings: 
;; the effective index and the actual logical setting.
;; Existing tests and hand-built instances use raw settings when nothing has
;; been pruned. Once discprobe disallows settings, non-zero effective settings
;; compactly enumerate the remaining actual settings.
(= (mapEffectiveDiscSpec $knob $effectiveSetting)
   (let*
      (
        ((mkDiscSpec $default) (getKnobDefault $knob))
        ($disAll (getDisallowedSpecs $knob))
      )
      (if (== $disAll ())
          $effectiveSetting
          (if (or (== $effectiveSetting 0) (allDisallowed $knob))
              $default
              (nthAllowedActualSetting 0 $effectiveSetting $default $disAll)))))

;; Extracts the location from a discrete, logical subtree, or strategy subtree knob.
;; Params:
;;  $knob: Either discrete, logical subtree, or strategy subtree knob
;; Returns: The location of the knob.
;; (: getKnobLoc (-> DiscreteKnob (NodeId)))
;; (: getKnobLoc (-> LogicalSubtreeKnob (NodeId)))
;; (: getKnobLoc (-> StrategySubtreeKnob (NodeId)))
(= (getKnobLoc (mkDiscKnob (mkKnob $loc) $multip $curr $def $dis)) $loc)
(= (getKnobLoc (mkLSK $discKnob )) (getKnobLoc $discKnob))
(= (getKnobLoc (mkSSK $discKnob )) (getKnobLoc $discKnob))

;; A comparison function for discSpec 
;; (used as a $compFunc to insert knobSpec and knob pairs into a multimap ) 
;; (: discSpec<= (-> DiscSpec DiscSpec Bool))
(= (discSpec< (mkDiscSpec $newKey) (mkDiscSpec $currKey))
(< $newKey $currKey))

;; Checks of nodeId1 is lessthan nodeId2.
;; Params: $id1 & $id2
;; Returns: True/False
;; (: nodeId< (-> NodeId NodeId Bool))
;; FIX: Non-determinsitic logic if nodeId is both () or either is empty.
(= (nodeId< (mkNodeId ()) (mkNodeId $id2)) True)
(= (nodeId< (mkNodeId $id1) (mkNodeId ())) False)
(= (nodeId< (mkNodeId $id1) (mkNodeId $id2)) 
(if (== (mkNodeId $id1) (mkNodeId $id2)) False
    (let* 
       (
          (($headId1 $tailId1) (decons-atom $id1))
          (($headId2 $tailId2) (decons-atom $id2)))
       (if (== $headId1 $headId2) 
           (nodeId< (mkNodeId $tailId1) (mkNodeId $tailId2))
           (< $headId1 $headId2)))))
