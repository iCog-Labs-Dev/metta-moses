!(register-module! ../../../metta-moses)
!(import! &self metta-moses:scoring:complexity-based-scorer)
!(import! &self metta-moses:scoring:cscore)
!(import! &self metta-moses:scoring:bscore)
!(import! &self metta-moses:scoring:fitness)
! (import! &self metta-moses:representation:lsk)
! (import! &self metta-moses:representation:knob-mapper)
! (import! &self metta-moses:representation:instance)
! (import! &self metta-moses:representation:representation)
! (import! &self metta-moses:representation:knob-representation)

! (import! &self metta-moses:utilities:map)
! (import! &self metta-moses:utilities:tree) 
! (import! &self metta-moses:utilities:nodeId)
! (import! &self metta-moses:utilities:list-methods) 
! (import! &self metta-moses:utilities:general-helpers) 
! (import! &self metta-moses:utilities:ordered-multimap)
! (import! &self metta-moses:utilities:python-treehelpers)

;; TODO: Add REDUCE Function here when it's edge case if fixed.
(= (APPEND_CHILD $tree $nodeId $child ) (py_appendChild $tree $nodeId $child))

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

! (bind! knobMapObj (mkKbMap
                      (mkDscKbMp (ConsMap ((mkNodeId (2 3)) 0) (ConsMap ((mkNodeId (3)) 1) (ConsMap ((mkNodeId (1)) 2) NilMap))))
               
                      (mkDscMp (ConsMMap ((mkDiscSpec 1) lsk1) (ConsMMap ((mkDiscSpec 0) lsk2) (ConsMMap ((mkDiscSpec 1) lsk3) NilMMap))))))
! (bind! ttable1 (mkITable (Cons (Cons True (Cons False (Cons False (Cons True (Cons True Nil)))))
                        (Cons (Cons True (Cons True (Cons True (Cons False (Cons True Nil))))) Nil))
                        (Cons A (Cons B (Cons C (Cons D (Cons O Nil)) )))))
! (bind! ttable2 (mkITable
                    (Cons (Cons True (Cons True (Cons False (Cons True (Cons True Nil)))))
                    (Cons (Cons True (Cons False (Cons False (Cons True (Cons True Nil)))))
                    (Cons (Cons False (Cons True (Cons False (Cons True (Cons False Nil)))))
                    (Cons (Cons False (Cons False (Cons False (Cons True (Cons False Nil))))) Nil))))
                    (Cons A (Cons B (Cons C (Cons D (Cons Output Nil)))))))

;; Testcases for the complexityBasedScorer
!(assertEqual 
 (complexityBasedScorer 
         (mkRep knobMapObj tree1)
         (mkInst (Cons 2 (Cons 0 (Cons 1 Nil))))
         ttable1
         2.0)
 (mkCscore -1 4 2.0 0.0 -3.0))

!(assertEqual
 (complexityBasedScorer 
         (mkRep knobMapObj tree1)
         (mkInst (Cons 1 (Cons 0 (Cons 1 Nil))))
         ttable2
         2.0)
 (mkCscore 0 4 2.0 0.0 -2.0))
 

