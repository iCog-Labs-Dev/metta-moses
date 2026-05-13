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

;; General discrete knob representation (for any discrete domain)
;; Unlike LSK and SSK which are domain-specific (boolean/game), 
;; GeneralDiscreteKnob stores an explicit list of atoms (the domain) 
;; that the knob can take. This allows MOSES to evolve programs 
;; by selecting from any set of discrete choices (operators, constants, etc.).
;; (: GeneralDiscreteKnob Type)
;; (: mkGDK (-> DiscreteKnob (List Atom) GeneralDiscreteKnob))

;; Checks if a DiscreteKnob is considered part of the exemplar based on its default specifier.
;; Params:
;;   $discKnob: DiscreteKnob
;; Return: True if the default specifier is non-zero (not in exemplar), False otherwise.
;; (: inExemplar (-> DiscreteKnob Bool))
(= (inExemplar (mkDiscKnob $knob $multiplicity (mkDiscSpec $curr) (mkDiscSpec $def) $dis)) 
   (not (== $def 0)))

;; Extracts the DiscreteKnob component from a LogicalSubtreeKnob (mkLSK), 
;; StrategySubtreeKnob (mkSSK), or GeneralDiscreteKnob (mkGDK).
;; Params:
;;   $knob: mkLSK, mkSSK, or mkGDK
;; Return: The extracted DiscKnob
;; (: getDiscKnob (-> LogicalSubtreeKnob DiscreteKnob))
;; (: getDiscKnob (-> StrategySubtreeKnob DiscreteKnob))
;; (: getDiscKnob (-> GeneralDiscreteKnob DiscreteKnob))
(= (getDiscKnob (mkLSK $DiscKnob )) $DiscKnob)
(= (getDiscKnob (mkSSK $DiscKnob )) $DiscKnob)
(= (getDiscKnob (mkGDK $DiscKnob $domain)) $DiscKnob)

;; Extracts the Tree component from a LogicalSubtreeKnob (mkLSK).
;; Params:
;;   $lsk: LogicalSubtreeKnob


;; Extracts the multiplicity from a discrete or a logical/strategy/general subtree knob.
;; Params:
;;  $knob: Either discrete, logical subtree, strategy subtree, or general discrete knob
;; Returns: The multiplicity of the knob.
;; (: getKnobMultip (-> DiscreteKnob Multiplicity))
;; (: getKnobMultip (-> LogicalSubtreeKnob Multiplicity))
;; (: getKnobMultip (-> StrategySubtreeKnob Multiplicity))
;; (: getKnobMultip (-> GeneralDiscreteKnob Multiplicity))

(= (getKnobMultip (mkDiscKnob $knob $multiplicity $curr $def $disAll)) $multiplicity)
(= (getKnobMultip (mkLSK $discKnob )) (getKnobMultip $discKnob))
(= (getKnobMultip (mkSSK $discKnob )) (getKnobMultip $discKnob))
(= (getKnobMultip (mkGDK $discKnob $domain)) (getKnobMultip $discKnob))

;; Calculates the knob Specification of an LSK or SSK
;; (: getKnobSpec (-> LogicalSubtreeKnob DiscSpec))
;; (: getKnobSpec (-> StrategySubtreeKnob DiscSpec))
(= (getKnobSpec (mkLSK (mkDiscKnob $knob (mkMultip $multip) $curr $def $dis) ))
(mkDiscSpec (- $multip (List.length $dis))))
(= (getKnobSpec (mkSSK (mkDiscKnob $knob (mkMultip $multip) $curr $def $dis) ))
(mkDiscSpec (- $multip (List.length $dis))))

;; Extracts the location from a discrete, logical subtree, strategy subtree, or general discrete knob.
;; Params:
;;  $knob: Either discrete, logical subtree, strategy subtree, or general discrete knob
;; Returns: The location of the knob.
;; (: getKnobLoc (-> DiscreteKnob (NodeId)))
;; (: getKnobLoc (-> LogicalSubtreeKnob (NodeId)))
;; (: getKnobLoc (-> StrategySubtreeKnob (NodeId)))
;; (: getKnobLoc (-> GeneralDiscreteKnob (NodeId)))
(= (getKnobLoc (mkDiscKnob (mkKnob $loc) $multip $curr $def $dis)) $loc)
(= (getKnobLoc (mkLSK $discKnob )) (getKnobLoc $discKnob))
(= (getKnobLoc (mkSSK $discKnob )) (getKnobLoc $discKnob))
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
