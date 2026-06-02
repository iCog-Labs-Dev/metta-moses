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

;; Identity for bare DiscreteKnob — getDiscKnob is a no-op when the knob IS the disc knob.
;; (: getDiscKnob (-> DiscreteKnob DiscreteKnob))
(= (getDiscKnob (mkDiscKnob $k $m $c $d $dis)) (mkDiscKnob $k $m $c $d $dis))

;; Raw multiplicity — the stored value before subtracting disallowed settings.
;; Use getKnobMultip for the effective count that the optimizer actually works with.
;; (: getRawKnobMultip (-> DiscreteKnob Multiplicity))
(= (getRawKnobMultip (mkDiscKnob $knob $multiplicity $curr $def $disAll)) $multiplicity)

;; (: getKnobDefault (-> DiscreteKnob DiscSpec))
(= (getKnobDefault (mkDiscKnob $knob $multiplicity $current $default $disAll)) $default)

;; (: getDisallowedSpecs (-> DiscreteKnob (List DiscSpec)))
(= (getDisallowedSpecs (mkDiscKnob $knob $multiplicity $current $default $disAll)) $disAll)

(= (countNonDefaultDisallowed (mkDiscSpec $default) ()) 0)
(= (countNonDefaultDisallowed (mkDiscSpec $default) (cons (mkDiscSpec $setting) $tail))
   (+ (if (== $setting $default) 0 1)
      (countNonDefaultDisallowed (mkDiscSpec $default) $tail)))

;; Effective multiplicity — raw multiplicity minus disallowed non-default settings.
;; Needed because discprobe marks redundant settings as disallowed; the optimizer
;; only iterates over the effective range.
;; (: getKnobMultip (-> DiscreteKnob Multiplicity))
(= (getKnobMultip (mkDiscKnob $knob (mkMultip $multiplicity) $current $default $disAll))
   (mkMultip (- $multiplicity (countNonDefaultDisallowed $default $disAll))))

;; Effective spec: number of settings the optimizer can pick from.
;; (: getKnobSpec (-> DiscreteKnob DiscSpec))
(= (getKnobSpec (mkDiscKnob $k $m $c $d $dis))
   (let (mkMultip $effective) (getKnobMultip (mkDiscKnob $k $m $c $d $dis))
        (mkDiscSpec $effective)))

;; (: getKnobLoc (-> DiscreteKnob NodeId))
(= (getKnobLoc (mkDiscKnob (mkKnob $loc) $multip $curr $def $dis)) $loc)

;; Returns True when all non-default settings are disallowed (effective multiplicity <= 1).
(= (allDisallowed $knob)
   (let* (((mkMultip $effectiveMultip) (getKnobMultip $knob)))
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

;; Translates from optimizer-facing effective index to the actual stored setting.
;; When discprobe disallows settings the effective indices form a compact sequence
;; over the remaining allowed values; this maps them back to actual settings.
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

;; ActionSubtreeKnob: mirrors C++ action_subtree_knob (extends discrete_knob<MAX_PERM_ACTIONS>).
;; A discrete-domain knob subtype carrying an extra attribute — the list of action permutations (_perms in C++).
;; Setting 0 = absent (null vertex), Setting k >= 1 = perms[k-1].
;; Multiplicity = 1 + len(perms).
(: ActionSubtreeKnob Type)
(: mkASK (-> DiscreteKnob (List Tree) ActionSubtreeKnob))

(= (getDiscKnob (mkASK $discKnob $perms)) $discKnob)
(= (getRawKnobMultip (mkASK $discKnob $perms)) (getRawKnobMultip $discKnob))
(= (getKnobDefault (mkASK $discKnob $perms)) (getKnobDefault $discKnob))
(= (getDisallowedSpecs (mkASK $discKnob $perms)) (getDisallowedSpecs $discKnob))
(= (getKnobMultip (mkASK $discKnob $perms)) (getKnobMultip $discKnob))
(= (getKnobSpec (mkASK $discKnob $perms))
   (let (mkMultip $multip) (getKnobMultip (mkASK $discKnob $perms)) (mkDiscSpec $multip)))
(= (getKnobLoc (mkASK $discKnob $perms)) (getKnobLoc $discKnob))

;; GeneralDiscreteKnob: subtype for any discrete atom domain.
;; Carries extra $domain list — the only reason it exists as a subtype (it has more attributes than DiscreteKnob).
;; Setting 0 = absent (null vertex), Setting k >= 1 = domain[k-1] as a leaf tree node.
;; Multiplicity = 1 + len(domain).
(: GeneralDiscreteKnob Type)
(: mkGDK (-> DiscreteKnob (List Atom) GeneralDiscreteKnob))

(= (getDiscKnob (mkGDK $discKnob $domain)) $discKnob)
(= (getRawKnobMultip (mkGDK $discKnob $domain)) (getRawKnobMultip $discKnob))
(= (getKnobDefault (mkGDK $discKnob $domain)) (getKnobDefault $discKnob))
(= (getDisallowedSpecs (mkGDK $discKnob $domain)) (getDisallowedSpecs $discKnob))
(= (getKnobMultip (mkGDK $discKnob $domain)) (getKnobMultip $discKnob))
(= (getKnobSpec (mkGDK $discKnob $domain))
   (let (mkMultip $multip) (getKnobMultip (mkGDK $discKnob $domain)) (mkDiscSpec $multip)))
(= (getKnobLoc (mkGDK $discKnob $domain)) (getKnobLoc $discKnob))

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
