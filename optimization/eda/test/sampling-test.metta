!(register-module! ../../../../metta-moses)

!(import! &self metta-moses:optimization:eda/sampling)
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
!(import! &self metta-moses:representation:knob-representation)
!(import! &self metta-moses:moses:neighborhood-sampling)
!(import! &self metta-moses:deme:create-deme)
!(import! &self metta-moses:representation:instance)


;; ================================================================================
;; Model Sampling Tests
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

;; Create a test probability model
!(bind! test_prob_model (mkKnobProbabilityModel (ConsMap 
  ((mkNodeId (1)) (ConsMap ((mkKnobValue 0) 0.3) (ConsMap ((mkKnobValue 1) 0.4) (ConsMap ((mkKnobValue 2) 0.3) NilMap))))
  (ConsMap 
  ((mkNodeId (2)) (ConsMap ((mkKnobValue 0) 0.2) (ConsMap ((mkKnobValue 1) 0.5) (ConsMap ((mkKnobValue 2) 0.3) NilMap))))
  NilMap))))

;; Deterministic checks (avoid randomness in unit tests)

;; getKnobProbabilities should return the exact map for a knob id
!(assertEqual
  (getKnobProbabilities test_prob_model (mkNodeId (1)))
  (ConsMap ((mkKnobValue 0) 0.3) (ConsMap ((mkKnobValue 1) 0.4) (ConsMap ((mkKnobValue 2) 0.3) NilMap))))

!(assertEqual
  (getKnobProbabilities test_prob_model (mkNodeId (2)))
  (ConsMap ((mkKnobValue 0) 0.2) (ConsMap ((mkKnobValue 1) 0.5) (ConsMap ((mkKnobValue 2) 0.3) NilMap))))

;; getKnobValue should unwrap the number
!(assertEqual (getKnobValue (mkKnobValue 2)) 2)

;; Test random distribution selection helper with deterministic target (cumulative 0.3, 0.7, 1.0)
!(assertEqual 
  (selectFromCumulativeList 
     (Cons ((mkKnobValue 0) 0.3) (Cons ((mkKnobValue 1) 0.4) (Cons ((mkKnobValue 2) 0.3) Nil))) 
     0.5 0.0) 
  (mkKnobValue 1))

;; createInstance should fill indices correctly using the disc knob map
!(assertEqual 
  (selectFromCumulativeList 
     (Cons ((mkKnobValue 0) 0.3) (Cons ((mkKnobValue 1) 0.4) (Cons ((mkKnobValue 2) 0.3) Nil))) 
     0.5 0.0) 
  (mkKnobValue 1))

; Randomized sampling functions are not asserted here to keep tests deterministic
;; Deterministic sampling using a degenerate probability model
!(assertEqual 
  (sampleKnobValues 
     (mkKnobProbabilityModel (ConsMap 
        ((mkNodeId (1)) (ConsMap ((mkKnobValue 2) 1.0) NilMap))
        (ConsMap 
        ((mkNodeId (2)) (ConsMap ((mkKnobValue 2) 1.0) NilMap))
        NilMap))) 
     (getRep test_deme))
  (ConsMap ((mkNodeId (2)) (mkKnobValue 2)) (ConsMap ((mkNodeId (1)) (mkKnobValue 2)) NilMap)))

!(assertEqual 
  (sampleInstance 
     (mkKnobProbabilityModel (ConsMap 
        ((mkNodeId (1)) (ConsMap ((mkKnobValue 2) 1.0) NilMap))
        (ConsMap 
        ((mkNodeId (2)) (ConsMap ((mkKnobValue 2) 1.0) NilMap))
        NilMap))) 
     (getRep test_deme))
  (mkInst (Cons 2 (Cons 2 Nil))))

!(assertEqual 
  (coll.length (generateInstances 
     (mkKnobProbabilityModel (ConsMap 
        ((mkNodeId (1)) (ConsMap ((mkKnobValue 2) 1.0) NilMap))
        (ConsMap 
        ((mkNodeId (2)) (ConsMap ((mkKnobValue 2) 1.0) NilMap))
        NilMap))) 
     (getRep test_deme) 2)) 
  2)

; Randomized model sampling intentionally not asserted deterministically
!(assertEqual 
  (createInstance (getRep test_deme) 
     (ConsMap ((mkNodeId (1)) (mkKnobValue 1)) (ConsMap ((mkNodeId (2)) (mkKnobValue 2)) NilMap))) 
  (mkInst (Cons 1 (Cons 2 Nil))))
