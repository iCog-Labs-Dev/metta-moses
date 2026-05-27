!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/ordered-multimap) 
!(import! &self ../../utilities/tree)
!(import! &self ../knob-representation)

!(assertEqual (let $return (mkKnob  (mkNodeId (1))) $return)  
              (mkKnob (mkNodeId (1)))
              )
!(assertEqual (let $return (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ()) $return)
              (mkDiscKnob (mkKnob  (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ())
              )
!(assertEqual (let $return (mkDiscKnob (mkKnob  (mkNodeId (1))) (mkMultip 2)) $return)
              (mkDiscKnob (mkKnob  (mkNodeId (1))) (mkMultip 2))
              ) 
!(assertEqual (let $return (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ()) $return)
              (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ()))
!(assertEqual (let $return (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ()) $return)
              (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ()))

; ; these type tests have been commented out because they fail on mettalog and in PeTTa 
; ! (assertEqual (let $type (get-type (mkKnob (mkTree (mkNode A) ()) (mkNodeId (1)))) $type) Knob)
; ! (assertEqual (let $type (get-type (mkDiscKnob (mkKnob (mkTree (mkNode A) ()) (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ())) $type) DiscreteKnob)
; ! (assertEqual (let $type (get-type (mkDiscKnob (mkKnob (mkTree (mkNode A) ()) (mkNodeId (1))) (mkMultip 2))) $type) DiscreteKnob)
; ! (assertEqual (let $type (get-type (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ()) )) $type) LogicalSubtreeKnob)
; ! (assertEqual (let $type (get-type (mkLSK (mkDiscKnob (mkKnob  (mkNodeId (1))) (mkMultip 2)) )) $type) LogicalSubtreeKnob)


; inExemplar tests
!(assertEqual (inExemplar (mkDiscKnob $knob $multiplicity (mkDiscSpec 0) (mkDiscSpec 1) ())) True)
!(assertEqual (inExemplar (mkDiscKnob $knob $multiplicity (mkDiscSpec 0) (mkDiscSpec 0) ())) False)

; ; getDiscKnob Tests — identity on bare mkDiscKnob
!(assertEqual (getDiscKnob (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ()))
  (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ()))
!(assertEqual (getDiscKnob (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))
  (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))


; getKnobSpec Tests
!(assertEqual (getKnobSpec
       (mkDiscKnob
       (mkKnob
               (mkNodeId (1 1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) (cons (mkDiscSpec 1) ())))
       (mkDiscSpec 2))

; Testing getmultiplicity function
!(assertEqual (getKnobMultip (mkDiscKnob (mkKnob (mkTree (mkNode A) ()) (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ())) (mkMultip 2))
!(assertEqual (getKnobMultip (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ())) (mkMultip 2))
!(assertEqual (getKnobSpec
       (mkDiscKnob
       (mkKnob
               (mkNodeId (1 1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))
       (mkDiscSpec 3))

; Test for getKnobLoc
!(assertEqual (getKnobLoc (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ())) (mkNodeId (1)))
!(assertEqual (getKnobLoc (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ())) (mkNodeId (1)))

; Test for discSpec<
!(assertEqual (discSpec< (mkDiscSpec 2) (mkDiscSpec 3)) True)
!(assertEqual (discSpec< (mkDiscSpec 3) (mkDiscSpec 2)) False)

; Test for nodeId<
!(assertEqual (nodeId< (mkNodeId (2 1)) (mkNodeId (2 1 1))) True)
!(assertEqual (nodeId< (mkNodeId (2 1)) (mkNodeId (2 2))) True)
!(assertEqual (nodeId< (mkNodeId (2 2 3)) (mkNodeId (2 3))) True)
!(assertEqual (nodeId< (mkNodeId (2 3)) (mkNodeId (1 2))) False)
!(assertEqual (nodeId< (mkNodeId (2 3)) (mkNodeId (2 3))) False)

