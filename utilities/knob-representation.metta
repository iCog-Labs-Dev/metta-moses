(: List (-> $a Type))
(: Nil (List $a))
(: Cons (-> $a (List $a) (List $a)))

(: Tree (-> $a Type))   
(: mkTree (-> (Node $a) (List (Tree $a)) (Tree $a)))

(: Node (-> $a Type))
(: mkNode (-> $a (Node $a)))

(: NodeId Type)
(: mkNodeId (-> $tuple NodeId))
(: Node Type)

;;;knob base representation
;      Tree: a tree reference
;      Position: a NodeId pointing to current position in the tree
(: Knob Type)
(: mkKnob (-> (Tree $a) NodeId Knob))
(= (mkKnob $tree $nodeId)
   (Knob (Tree $tree) (Position $nodeId))
)  

;;; Discrete knob representation
;      Multiplicity: number of possible distinct states/settings a knob can have
;      Curr: Current(Tracks the current setting of the knob)
;      Def: Default(Stores the initial/default setting value)
;      Dis: Disallowed(tracks which settings are not allowed)
(: DiscreteKnob Type)
(: Multiplicity Type)
(: mkMultip (-> Number Multiplicity))

(: mkDiscKnob (-> Knob Multiplicity DiscreteKnob))
(= (mkDiscKnob $knob $multiplicity) 
   (DiscKnob $knob (Multip $multiplicity) (Curr 0) (Def 0) (Dis ()))
)

;; Logical subtree knob representation
       ;Subtree: represents a portion of the tree that will be controlled by the knob
(: LogicalSubtreeKnob Type)
(: mkLSK (-> DiscreteKnob (Tree $a) LogicalSubtreeKnob))
(= (mkLSK $discreteKnob $subtree) 
   (LSK $discreteKnob (Subtree $subtree))
)