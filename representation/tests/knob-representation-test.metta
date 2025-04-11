!(register-module! ../../../metta-moses)
!(import! &self metta-moses:utilities:tree)
!(import! &self metta-moses:utilities:list-methods)
!(import! &self metta-moses:representation:knob-representation)

! (assertEqual (let $return (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) $return)  
               (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1)))
               )
! (assertEqual (let $return (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil) $return)
               (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil)
               )
! (assertEqual (let $return (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2)) $return)
               (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2))
               ) 
! (assertEqual (let $return (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode A) Nil)) $return)
               (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2)) (mkTree (mkNode A) Nil))
               )             
! (assertEqual (let $return (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode A) Nil)) $return)
               (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2)) (mkTree (mkNode A) Nil))
               )

! (assertEqual (let $type (get-type (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1)))) $type) Knob)
! (assertEqual (let $type (get-type (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil)) $type) DiscreteKnob)
! (assertEqual (let $type (get-type (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2))) $type) DiscreteKnob)
! (assertEqual (let $type (get-type (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode A) Nil))) $type) LogicalSubtreeKnob)
! (assertEqual (let $type (get-type (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2)) (mkTree (mkNode A) Nil))) $type) LogicalSubtreeKnob)



