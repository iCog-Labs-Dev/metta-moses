;;;knob base representation
;      Tree: a tree reference
;      NodeId: a position pointing to current position in the tree
(: Knob Type)
(: mkKnob (-> (Tree $a) NodeId Knob)) 

;;; Discrete knob representation
;      Multiplicity: number of possible distinct states/settings a knob can have
;      DiscSpec: Disc specification containing the states
(: DiscreteKnob Type)
(: Multiplicity Type)
(: mkMultip (-> Number Multiplicity))

(: DiscSpec Type)
(: mkDiscSpec (-> Number DiscSpec))

(: mkDiscKnob (-> Knob Multiplicity DiscreteKnob))
(: mkDiscKnob (-> Knob Multiplicity DiscSpec DiscSpec (List DiscSpec) DiscreteKnob))
(= (mkDiscKnob $knob $multiplicity) 
   (mkDiscKnob $knob $multiplicity (mkDiscSpec 0) (mkDiscSpec 0) Nil)
)

;; Logical subtree knob representation
       ;Subtree: represents a portion of the tree that will be controlled by the knob
(: LogicalSubtreeKnob Type)
(: mkLSK (-> DiscreteKnob (Tree $a) LogicalSubtreeKnob))

;; Checks if a DiscreteKnob is considered part of the exemplar based on its default specifier.
;; Params:
;;   $discKnob: DiscreteKnob
;; Return: True if the default specifier is non-zero (not in exemplar), False otherwise.
(: inExemplar (-> DiscreteKnob Bool))
(= (inExemplar (mkDiscKnob $knob $multiplicity (mkDiscSpec $curr) (mkDiscSpec $def) $dis)) 
   (not (== $def 0)))

;; Extracts the DiscreteKnob component from a LogicalSubtreeKnob (mkLSK).
;; Params:
;;   $lsk: LogicalSubtreeKnob
;; Return: The extracted DiscKnob
(: getDiscKnob (-> LogicalSubtreeKnob DiscreteKnob))
(= (getDiscKnob (mkLSK $DiscKnob $Subtree)) $DiscKnob)

;; Extracts the Tree component from a LogicalSubtreeKnob (mkLSK).
;; Params:
;;   $lsk: LogicalSubtreeKnob
;; Return: The extracted Tree
(: getTree LogicalSubtreeKnob (Tree $a))
(= (getTree (mkLSK (mkDiscKnob (mkKnob $tree $nodeId) $multip $curr $def $dis) $sub)) $tree)

;; Extracts the multiplicity from a discrete or a logical subtree knob.
;; Params:
;;  $knob: Either discrete or logical subtree knob
;; Returns: The multiplicity of the knob.
(: getKnobMultip (-> DiscreteKnob Multiplicity))
(: getKnobMultip (-> LogicalSubtreeKnob Multiplicity))
(= (getKnobMultip (mkDiscKnob $knob $multiplicity $curr $def $disAll)) $multiplicity)
(= (getKnobMultip (mkLSK $discKnob $subtree)) (getKnobMultip $discKnob))
