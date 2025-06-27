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
;; Calculates the knob Specification of an LSK
(: getKnobSpec (-> LogicalSubtreeKnob DiscSpec))
(= (getKnobSpec (mkLSK (mkDiscKnob $knob (mkMultip $multip) $curr $def $dis) $subtree))
(mkDiscSpec (- $multip (List.length $dis))))

;; Extracts the location from a discrete or a logical subtree knob.
;; Params:
;;  $knob: Either discrete or logical subtree knob
;; Returns: The location of the knob.
(: getKnobLoc (-> DiscreteKnob (NodeId)))
(: getKnobLoc (-> LogicalSubtreeKnob (NodeId)))
(= (getKnobLoc (mkDiscKnob (mkKnob $tree $loc) $multip $curr $def $dis)) $loc)
(= (getKnobLoc (mkLSK $discKnob $subtree)) (getKnobLoc $discKnob))

;; A comparison function for discSpec 
;; (used as a $compFunc to insert knobSpec and knob pairs into a multimap ) 
(: discSpec<= (-> DiscSpec DiscSpec Bool))
(= (discSpec<= (mkDiscSpec $newKey) (mkDiscSpec $currKey))
(<= $newKey $currKey))

;; Checks of nodeId1 is lessthan nodeId2.
;; Params: $id1 & $id2
;; Returns: True/False
(: nodeId< (-> NodeId NodeId Bool))
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
