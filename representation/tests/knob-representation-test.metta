!(import! &self ../../utilities/tree)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/general-helpers)
!(import! &self ../knob-representation)
!(import! &self ../../utilities/ordered-multimap) 

!(assertEqual (let $return (mkKnob  (mkNodeId (1))) $return)  
              (mkKnob (mkNodeId (1)))
              )
!(assertEqual (let $return (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil) $return)
              (mkDiscKnob (mkKnob  (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil)
              )
!(assertEqual (let $return (mkDiscKnob (mkKnob  (mkNodeId (1))) (mkMultip 2)) $return)
              (mkDiscKnob (mkKnob  (mkNodeId (1))) (mkMultip 2))
              ) 
!(assertEqual (let $return (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil) ) $return)
              (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil) )
              )             
!(assertEqual (let $return (mkLSK (mkDiscKnob (mkKnob  (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil)) $return)
               (mkLSK (mkDiscKnob (mkKnob  (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil))
               )

; ; these type tests have been commented out because they fail on mettalog and in PeTTa 
; ! (assertEqual (let $type (get-type (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1)))) $type) Knob)
; ! (assertEqual (let $type (get-type (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil)) $type) DiscreteKnob)
; ! (assertEqual (let $type (get-type (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2))) $type) DiscreteKnob)
; ! (assertEqual (let $type (get-type (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil) )) $type) LogicalSubtreeKnob)
; ! (assertEqual (let $type (get-type (mkLSK (mkDiscKnob (mkKnob  (mkNodeId (1))) (mkMultip 2)) )) $type) LogicalSubtreeKnob)


; inExemplar tests
!(assertEqual (inExemplar (mkDiscKnob $knob $multiplicity (mkDiscSpec 0) (mkDiscSpec 1) Nil)) True)
!(assertEqual (inExemplar (mkDiscKnob $knob $multiplicity (mkDiscSpec 0) (mkDiscSpec 0) Nil)) False)

; ; getDiscKnob Tests
!(assertEqual (getDiscKnob (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil)))
  (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil))
!(assertEqual (getDiscKnob (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil)))
  (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil))


; getKnobSpec Tests
!(assertEqual (getKnobSpec (mkLSK 
       (mkDiscKnob 
       (mkKnob
               (mkNodeId (1 1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) (Cons (mkDiscSpec 1) Nil)) 
       )) (mkDiscSpec 2))

; Testing getmultiplicity function
!(assertEqual (getKnobMultip (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil)) (mkMultip 2))
!(assertEqual (getKnobMultip (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (mkMultip 2))
!(assertEqual (getKnobSpec (mkLSK 
       (mkDiscKnob 
       (mkKnob 
               (mkNodeId (1 1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) 
       ) ) (mkDiscSpec 3))

; Test for getKnobLoc
!(assertEqual (getKnobLoc (mkLSK (mkDiscKnob (mkKnob  (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (mkNodeId (1)))
!(assertEqual (getKnobLoc (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (mkNodeId (1)))

; Test for discSpec<=
!(assertEqual (discSpec<= (mkDiscSpec 2) (mkDiscSpec 3)) True)
!(assertEqual (discSpec<= (mkDiscSpec 3) (mkDiscSpec 2)) False)

; Test for nodeId<
!(assertEqual (nodeId< (mkNodeId (2 1)) (mkNodeId (2 1 1))) True)
!(assertEqual (nodeId< (mkNodeId (2 1)) (mkNodeId (2 2))) True)
!(assertEqual (nodeId< (mkNodeId (2 2 3)) (mkNodeId (2 3))) True)
!(assertEqual (nodeId< (mkNodeId (2 3)) (mkNodeId (1 2))) False)
!(assertEqual (nodeId< (mkNodeId (2 3)) (mkNodeId (2 3))) False)

