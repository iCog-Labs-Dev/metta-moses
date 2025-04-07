!(register-module! ../../../metta-moses)

!(import! &self metta-moses:utilities:knob-representation)

! (assertEqual (mkKnob (mkTree (mkNode AND) Nil) (mkNodeId (2))) 
               (Knob (Tree (mkTree (mkNode AND) Nil)) (Position (mkNodeId (2))))
               )
! (assertEqual (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (2))) (mkMultip 3)) 
               (DiscKnob (Knob (Tree (mkTree (mkNode A) Nil)) (Position (mkNodeId (2)))) (Multip (mkMultip 3)) (Curr 0) (Def 0) (Dis ()))
               )
! (assertEqual (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (2))) (mkMultip 3)) (mkTree (mkNode A) Nil)) 
               (LSK (DiscKnob (Knob (Tree (mkTree (mkNode A) Nil)) (Position (mkNodeId (2)))) (Multip (mkMultip 3)) (Curr 0) (Def 0) (Dis ())) (Subtree (mkTree (mkNode A) Nil)))
               )


! (assertEqual (get-type (mkKnob (mkTree (mkNode AND) Nil) (mkNodeId (2)))) Knob)
! (assertEqual (get-type (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (2))) (mkMultip 3))) DiscreteKnob) 
! (assertEqual (get-type (mkLSK (mkDiscKnob (mkKnob (mkTree (MkNode) Nil) (mkNodeId (2))) (mkMultip 3)) (mkTree (mkNode A) Nil))) LogicalSubtreeKnob)


