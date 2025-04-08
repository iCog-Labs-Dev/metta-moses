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