!(register-module! ../../../metta-moses)

! (import! &self metta-moses:representation:lsk)
! (import! &self metta-moses:representation:knob-mapper)
! (import! &self metta-moses:representation:representation)
! (import! &self metta-moses:representation:knob-representation)

! (import! &self metta-moses:utilities:map)
! (import! &self metta-moses:utilities:tree)
! (import! &self metta-moses:utilities:nodeId)
! (import! &self metta-moses:utilities:list-methods)
! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:utilities:ordered-multimap)


!(bind! tree1
        (mkTree (mkNode AND)
          (Cons (mkTree (mkNode A) Nil)
          (Cons (mkTree (mkNode OR)
                  (Cons (mkTree (mkNode B) Nil)
                  (Cons (mkTree (mkNode C) Nil)
                  (Cons (mkNullVex
                          (Cons (mkTree (mkNode D) Nil) Nil)) Nil))))
          (Cons (mkNullVex
                  (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) Nil)) Nil)) Nil)))))

!(bind! lsk1
        (mkLSK
            (mkDiscKnob
              (mkKnob tree1 (mkNodeId (2 3)))
              (mkMultip 3)
              (mkDiscSpec 0)
              (mkDiscSpec 0)
              Nil)
            (mkTree (mkNode D) Nil)))

!(bind! lsk2
        (mkLSK
            (mkDiscKnob
              (mkKnob tree1 (mkNodeId (3)))
              (mkMultip 3)
              (mkDiscSpec 0)
              (mkDiscSpec 0)
              Nil)
            (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) Nil))))

!(bind! lsk3
        (mkLSK
            (mkDiscKnob
              (mkKnob tree1 (mkNodeId (1)))
              (mkMultip 3)
              (mkDiscSpec 1)
              (mkDiscSpec 1)
              Nil)
            (mkTree (mkNode A) Nil)))

!(bind! knobMapObj (mkKbMap
                      (mkDscKbMp (ConsMap ((mkNodeId (2 3)) 0) (ConsMap ((mkNodeId (3)) 1) (ConsMap ((mkNodeId (1)) 2) NilMap))))
                      (mkDscMp (ConsMMap ((mkDiscSpec 1) lsk1) (ConsMMap ((mkDiscSpec 0) lsk2) (ConsMMap ((mkDiscSpec 1) lsk3) NilMMap))))))


!(assertEqual (findDiscKnob knobMapObj (mkNodeId (2 3))) (lsk1 0))
!(assertEqual (findDiscKnob knobMapObj (mkNodeId (0))) (() -1))
!(assertEqual (findDiscKnob knobMapObj (mkNodeId (2 2))) (() -1))
!(assertEqual (findDiscKnob knobMapObj (mkNodeId (3))) (lsk2 1))
!(assertEqual (findDiscKnob knobMapObj (mkNodeId (1))) (lsk3 2))
