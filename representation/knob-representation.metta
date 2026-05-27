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

;; Extracts the Tree component from a LogicalSubtreeKnob (mkLSK).
;; Params:
;;   $lsk: LogicalSubtreeKnob


;; Extracts the multiplicity from a discrete or a logical/strategy subtree knob.
;; Params:
;;  $knob: Either discrete, logical subtree, or strategy subtree knob
;; Returns: The multiplicity of the knob.
;; (: getKnobMultip (-> DiscreteKnob Multiplicity))
;; (: getKnobMultip (-> LogicalSubtreeKnob Multiplicity))
;; (: getKnobMultip (-> StrategySubtreeKnob Multiplicity))

(= (getKnobMultip (mkDiscKnob $knob $multiplicity $curr $def $disAll)) $multiplicity)

;; Calculates the knob Specification of a DiscreteKnob or ActionSubtreeKnob
;; (: getKnobSpec (-> DiscreteKnob DiscSpec))
(= (getKnobSpec (mkDiscKnob $knob (mkMultip $multip) $curr $def $dis))
(mkDiscSpec (- $multip (List.length $dis))))

;; Extracts the location from a discrete, logical subtree, or strategy subtree knob.
;; Params:
;;  $knob: Either discrete, logical subtree, or strategy subtree knob
;; Returns: The location of the knob.
;; (: getKnobLoc (-> DiscreteKnob (NodeId)))
;; (: getKnobLoc (-> LogicalSubtreeKnob (NodeId)))
;; (: getKnobLoc (-> StrategySubtreeKnob (NodeId)))
(= (getKnobLoc (mkDiscKnob (mkKnob $loc) $multip $curr $def $dis)) $loc)

;; ActionSubtreeKnob: mirrors C++ action_subtree_knob (extends discrete_knob<MAX_PERM_ACTIONS>).
;; This is the only discrete-domain knob that needs its own subtype beyond DiscreteKnob
;; because it carries an extra attribute — the list of action permutations (_perms in C++).
;; Setting 0 = absent (null vertex), Setting k >= 1 = perms[k-1].
;; Multiplicity = 1 + len(perms).
(: ActionSubtreeKnob Type)
(: mkASK (-> DiscreteKnob (List Tree) ActionSubtreeKnob))

(= (getDiscKnob (mkASK $discKnob $perms)) $discKnob)

(= (getKnobMultip (mkASK $discKnob $perms)) (getKnobMultip $discKnob))

(= (getKnobSpec (mkASK (mkDiscKnob $knob (mkMultip $multip) $curr $def $dis) $perms))
   (mkDiscSpec (- $multip (List.length $dis))))

(= (getKnobLoc (mkASK $discKnob $perms)) (getKnobLoc $discKnob))

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
