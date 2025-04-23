!(register-module! ../../../../metta-moses)

!(import! &self metta-moses:representation:knob-representation)
!(import! &self metta-moses:utilities:list-methods)
!(import! &self metta-moses:utilities:ordered-multimap)
!(import! &self metta-moses:utilities:general-helpers)
!(import! &self metta-moses:utilities:nodeId)
!(import! &self metta-moses:optimization:hillclimbing:hill-climbing-helpers)

!(bind! knobmap1
        (ConsMMap (
                    (mkNodeId (0))
                    (
                      (mkDiscSpec 1)
                      (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode A) Nil))))
        (ConsMMap (
                    (mkNodeId (0))
                    (
                      (mkDiscSpec 1)
                      (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode B) Nil) (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode B) Nil))))
        NilMMap)))

!(bind! knobmap2
        (ConsMMap (
                    (mkNodeId (0))
                    (
                      (mkDiscSpec 1)
                      (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode A) Nil))))
        (ConsMMap (
                    (mkNodeId (0))
                    (
                      (mkDiscSpec 1)
                      (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode B) Nil) (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode B) Nil))))
        NilMMap)))

;; Test informationTheoreticBits with a knob 
;; map containing two knobs with same multiplicity of 3
!(assertEqual (informationTheoreticBits knobmap1) 6)

;; Test informationTheoreticBits with a knob
;; map containing two knobs with different multiplicity of 2 and 3
!(assertEqual (informationTheoreticBits knobmap2) 5)

