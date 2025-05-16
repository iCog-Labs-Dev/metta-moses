! (register-module! ../../../metta-moses)
! (import! &self metta-moses:utilities:tree)
! (import! &self metta-moses:utilities:list-methods)
! (import! &self metta-moses:representation:knob-representation)
! (import! &self metta-moses:representation:instance)
! (import! &self metta-moses:representation:sampling-from-neighborhood)
! (import! &self metta-moses:utilities:ordered-multimap) 
! (import! &self metta-moses:utilities:lazy-random-selector) 
! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:utilities:tree)
! (import! &self metta-moses:utilities:nodeId)
! (import! &self metta-moses:utilities:ordered-multimap)


! (bind! tree1
        (mkTree (mkNode AND)
          (Cons (mkTree (mkNode A) Nil)
          (Cons (mkTree (mkNode OR)
                  (Cons (mkTree (mkNode B) Nil)
                  (Cons (mkTree (mkNode C) Nil)
                  (Cons (mkNullVex
                          (Cons (mkTree (mkNode D) Nil) Nil)) Nil))))
          (Cons (mkNullVex
                  (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) Nil)) Nil)) Nil)))))

! (bind! lsk1
        (mkLSK
            (mkDiscKnob
              (mkKnob tree1 (mkNodeId (2 3)))
              (mkMultip 3)
              (mkDiscSpec 0)
              (mkDiscSpec 0)
              Nil)
            (mkTree (mkNode D) Nil)))

! (bind! lsk2
        (mkLSK
            (mkDiscKnob
              (mkKnob tree1 (mkNodeId (3)))
              (mkMultip 3)
              (mkDiscSpec 0)
              (mkDiscSpec 0)
              Nil)
            (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) Nil))))

! (bind! lsk3
        (mkLSK
            (mkDiscKnob
              (mkKnob tree1 (mkNodeId (1)))
              (mkMultip 3)
              (mkDiscSpec 1)
              (mkDiscSpec 1)
              Nil)
            (mkTree (mkNode A) Nil)))

! (bind! knobMapObj (mkKbMap
                      (ConsMap ((mkNodeId (2 3)) 0) (ConsMap ((mkNodeId (3)) 1) (ConsMap ((mkNodeId (1)) 2) NilMap)))
                      (ConsMMap ((mkDiscSpec 1) lsk1) (ConsMMap ((mkDiscSpec 0) lsk2) (ConsMMap ((mkDiscSpec 1) lsk3) NilMMap)))))

! (assertEqual (let $returned (sfn 2 1  knobMapObj (mkInst (Cons 1 (Cons 2 (Cons 3 Nil))))) (List.length $returned)) 2)
! (assertEqual (let $returned (sfn 1 2  knobMapObj (mkInst (Cons 3 (Cons 1 (Cons 2 Nil))))) (List.length $returned)) 1)
! (assertEqual (let $returned (sfn 3 1  knobMapObj (mkInst (Cons 1 (Cons 2 (Cons 3 Nil))))) (List.length $returned)) 3)
! (assertEqual (let $returned (sfn 1 2  knobMapObj (mkInst Nil)) (List.length $returned)) (Error (3 0) "Not Equal"))
