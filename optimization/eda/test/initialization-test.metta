!(register-module! ../../../../metta-moses)

!(import! &self metta-moses:optimization:eda/initialization)
!(import! &self metta-moses:utilities:general-helpers)
!(import! &self metta-moses:utilities:list-methods)
!(import! &self metta-moses:representation:instance)
!(import! &self metta-moses:scoring:cscore)
!(import! &self metta-moses:deme:create-deme)
!(import! &self metta-moses:utilities:tree)
!(import! &self metta-moses:utilities:nodeId)
!(import! &self metta-moses:utilities:map)
!(import! &self metta-moses:utilities:pair)
!(import! &self metta-moses:utilities:ordered-multimap)
!(import! &self metta-moses:utilities:ordered-set)
!(import! &self metta-moses:representation:representation)
!(import! &self metta-moses:representation:knob-representation)
!(import! &self metta-moses:optimization:eda/sampling)
;; ================================================================================
;; Initialization Policy Tests
;; ================================================================================

;; Create test representation
!(bind! test_rep (mkRep 
  (mkKbMap 
    (mkDscKbMp (ConsMap ((mkNodeId (1)) 0) (ConsMap ((mkNodeId (2)) 1) NilMap))) 
    (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) 
                      (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) NilMMap)))) 
  (mkTree (mkNode AND) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) Nil)))))

;; Deterministic checks (no get-type, no bind). For exact asserts, use multiplicity-1 representation.
!(assertEqual (coll.length (getKnobIdsAndSpecs test_rep)) 2)

;; Multiplicity-1 rep produces fully deterministic uniform values
!(assertEqual 
  (getKnobIdsAndSpecs 
    (mkRep (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (1)) 0) (ConsMap ((mkNodeId (2)) 1) NilMap)))
                    (mkDscMp (ConsMMap ((mkDiscSpec 1) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 1) (mkDiscSpec 0) (mkDiscSpec 0) Nil)))
                                      (ConsMMap ((mkDiscSpec 1) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 1) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) NilMMap))))
           (mkTree (mkNode AND) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) Nil)))))
  (Cons ((mkNodeId (1)) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 1) (mkDiscSpec 0) (mkDiscSpec 0) Nil)))
        (Cons ((mkNodeId (2)) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 1) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) Nil)))

!(assertEqual 
  (sampleUniformKnobValues 
    (mkRep (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (1)) 0) (ConsMap ((mkNodeId (2)) 1) NilMap)))
                    (mkDscMp (ConsMMap ((mkDiscSpec 1) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 1) (mkDiscSpec 0) (mkDiscSpec 0) Nil)))
                                      (ConsMMap ((mkDiscSpec 1) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 1) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) NilMMap))))
           (mkTree (mkNode AND) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) Nil)))))
  (ConsMap ((mkNodeId (1)) (mkKnobValue 0)) (ConsMap ((mkNodeId (2)) (mkKnobValue 0)) NilMap)))

!(assertEqual 
  (sampleUniformInstance 
    (mkRep (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (1)) 0) (ConsMap ((mkNodeId (2)) 1) NilMap)))
                    (mkDscMp (ConsMMap ((mkDiscSpec 1) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 1) (mkDiscSpec 0) (mkDiscSpec 0) Nil)))
                                      (ConsMMap ((mkDiscSpec 1) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 1) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) NilMMap))))
           (mkTree (mkNode AND) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) Nil)))))
  (mkInst (Cons 0 (Cons 0 Nil))))

;; sampleUniformKvAcc explicit cases
!(assertEqual (sampleUniformKvAcc Nil NilMap) NilMap)
!(assertEqual 
  (sampleUniformKvAcc 
    (Cons ((mkNodeId (1)) (mkDiscSpec 1)) (Cons ((mkNodeId (2)) (mkDiscSpec 1)) Nil)) 
    NilMap)
  (ConsMap ((mkNodeId (1)) (mkKnobValue 0)) (ConsMap ((mkNodeId (2)) (mkKnobValue 0)) NilMap)))

