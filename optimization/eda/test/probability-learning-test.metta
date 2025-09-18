!(register-module! ../../../../metta-moses)

!(import! &self metta-moses:optimization:eda/probability-learning)
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



;; ================================================================================
;; Probability Learning Tests
;; ================================================================================

;; Create test deme with instances
!(bind! test_deme (mkDeme 
  (mkRep 
    (mkKbMap 
      (mkDscKbMp (ConsMap ((mkNodeId (1)) 0) (ConsMap ((mkNodeId (2)) 1) NilMap))) 
      (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) 
                        (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) NilMMap)))) 
    (mkTree (mkNode AND) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) Nil)))) 
  (mkSInstSet (Cons 
    (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 Nil))) (mkCscore -1 1 0.5 0.0 -1.5))) 
    (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 0 Nil))) (mkCscore -1 1 0.5 0.0 -1.5))) 
    (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 1 Nil))) (mkCscore 0 2 1.0 0.0 -1.0))) 
    (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 2 Nil))) (mkCscore -3 1 0.5 0.0 -3.5))) Nil))))) 
  0))

;; Create test instances with different scores
!(bind! test_instances (mkSInstSet (Cons 
  (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 Nil))) (mkCscore -1 1 0.5 0.0 -1.5))) 
  (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 0 Nil))) (mkCscore -1 1 0.5 0.0 -1.5))) 
  (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 1 Nil))) (mkCscore 0 2 1.0 0.0 -1.0))) 
  (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 2 Nil))) (mkCscore -3 1 0.5 0.0 -3.5))) Nil))))))

;; Test knob value counting (deterministic counts)
!(assertEqual (count-knob-values (getDiscMap (getRep test_deme)) test_instances)
  (ConsMap ((mkNodeId (1)) (ConsMap ((mkKnobValue 0) 2) (ConsMap ((mkKnobValue 1) 2) NilMap)))
           (ConsMap ((mkNodeId (2)) (ConsMap ((mkKnobValue 0) 1) (ConsMap ((mkKnobValue 1) 2) (ConsMap ((mkKnobValue 2) 1) NilMap)))) NilMap)))

;; Test probability computation (Laplace-smoothed, normalized)
!(assertEqual (Map.getByKey (mkNodeId (1)) (compute-probabilities (count-knob-values (getDiscMap (getRep test_deme)) test_instances)))
  (ConsMap ((mkKnobValue 0) 0.5) (ConsMap ((mkKnobValue 1) 0.5) NilMap)))
!(assertEqual (Map.getByKey (mkNodeId (2)) (compute-probabilities (count-knob-values (getDiscMap (getRep test_deme)) test_instances)))
  (ConsMap ((mkKnobValue 0) (/ 2.0 7.0)) (ConsMap ((mkKnobValue 1) (/ 3.0 7.0)) (ConsMap ((mkKnobValue 2) (/ 2.0 7.0)) NilMap))))

; ;; Test KnobValue comparison functions
!(assertEqual (knobValueEq (mkKnobValue 1) (mkKnobValue 1)) True)
!(assertEqual (knobValueEq (mkKnobValue 1) (mkKnobValue 2)) False)
!(assertEqual (knobValueLt (mkKnobValue 1) (mkKnobValue 2)) True)
!(assertEqual (knobValueLt (mkKnobValue 2) (mkKnobValue 1)) False)
