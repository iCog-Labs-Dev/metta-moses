
!(register-module! ../../../metta-moses)

! (import! &self metta-moses:representation:knob-mapper)
! (import! &self metta-moses:representation:knob-representation)


!(assertEqual (findDiscKnob (mkNodeId (0)) (ConsMMap ((mkNodeId (0)) ((mkDiscSpec 0) (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (0))))) (ConsMMap ((mkNodeId (1)) ((mkDiscSpec 0) (mkKnob (mkTree (mkNode B) Nil) (mkNodeId (1))))) (ConsMMap ((mkNodeId (0)) ((mkDiscSpec 2) (mkKnob (mkTree (mkNode C) Nil) (mkNodeId (0))))) NilMMap)))) (Cons (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (0))) (Cons (mkKnob (mkTree (mkNode C) Nil) (mkNodeId (0))) Nil)))

!(assertEqual (findDiscKnob (mkNodeId (2)) (ConsMMap ((mkNodeId (0)) ((mkDiscSpec 0) (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (0))))) (ConsMMap ((mkNodeId (1)) ((mkDiscSpec 0) (mkKnob (mkTree (mkNode B) Nil) (mkNodeId (1))))) (ConsMMap ((mkNodeId (0)) ((mkDiscSpec 2) (mkKnob (mkTree (mkNode C) Nil) (mkNodeId (0))))) NilMMap)))) Nil)

!(assertEqual (findDiscKnob (mkNodeId (1)) (ConsMMap ((mkNodeId (0)) ((mkDiscSpec 0) (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (0))))) (ConsMMap ((mkNodeId (1)) ((mkDiscSpec 0) (mkKnob (mkTree (mkNode B) Nil) (mkNodeId (1))))) (ConsMMap ((mkNodeId (0)) ((mkDiscSpec 2) (mkKnob (mkTree (mkNode C) Nil) (mkNodeId (0))))) NilMMap)))) (Cons (mkKnob (mkTree (mkNode B) Nil) (mkNodeId (1))) Nil))
