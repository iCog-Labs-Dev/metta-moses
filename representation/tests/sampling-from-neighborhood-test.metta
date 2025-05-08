!(register-module! ../../../metta-moses)
!(import! &self metta-moses:utilities:tree)
!(import! &self metta-moses:utilities:list-methods)
!(import! &self metta-moses:representation:knob-representation)
!(import! &self metta-moses:representation:sampling-from-neighborhood)
!(import! &self metta-moses:utilities:ordered-multimap) 
!(import! &self metta-moses:utilities:lazy-random-selector) 
!(import! &self metta-moses:utilities:general-helpers)

! (bind! KNOBMAPPER (Cons (mkDiscKnob (mkKnob (mkTree (mkNode B) Nil) (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil)(Cons (mkDiscKnob (mkKnob (mkTree (mkNode B) Nil) (mkNodeId (2))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (Cons (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (3))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil) Nil))))

! (bind! CENTERAL (Cons (mkDiscKnob (mkKnob (mkTree (mkNode B) Nil) (mkNodeId (3))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil)(Cons (mkDiscKnob (mkKnob (mkTree (mkNode B) Nil) (mkNodeId (4))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (Cons (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (5))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil) Nil))))

! (assertEqual (let $returned (sfn 2 1  KNOBMAPPER CENTERAL) (List.length $returned)) 2)
! (assertEqual (let $returned (sfn 1 2  KNOBMAPPER CENTERAL) (List.length $returned)) 1)
! (assertEqual (let $returned (sfn 3 1  KNOBMAPPER CENTERAL) (List.length $returned)) 3)
! (assertEqual (let $returned (sfn 1 2  KNOBMAPPER Nil) (List.length $returned)) (Error (The length of center instance must equal with knob maper) ()))