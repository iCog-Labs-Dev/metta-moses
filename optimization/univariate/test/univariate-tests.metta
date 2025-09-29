!(register-module! ../../../../metta-moses)

!(import! &self metta-moses:utilities:general-helpers)
!(import! &self metta-moses:utilities:list-methods)
!(import! &self metta-moses:utilities:map)
!(import! &self metta-moses:utilities:nodeId)
!(import! &self metta-moses:utilities:ordered-multimap)
!(import! &self metta-moses:utilities:ordered-set)
!(import! &self metta-moses:utilities:pair)
!(import! &self metta-moses:utilities:tree)
!(import! &self metta-moses:representation:representation)
!(import! &self metta-moses:representation:knob-representation)
!(import! &self metta-moses:representation:lsk)
!(import! &self metta-moses:representation:knob-mapper)
!(import! &self metta-moses:scoring:bscore)
!(import! &self metta-moses:representation:instance)
!(import! &self metta-moses:scoring:cscore)
!(import! &self metta-moses:scoring:complexity-based-scorer)
!(import! &self metta-moses:optimization:eda/sampling)
!(import! &self metta-moses:optimization:eda/eda-parameters)
!(import! &self metta-moses:optimization:eda/initialization)
!(import! &self metta-moses:optimization:eda/probability-learning)
!(import! &self metta-moses:optimization:eda/selection)
!(import! &self metta-moses:optimization:eda/replacement)
!(import! &self metta-moses:optimization:eda/termination)
!(import! &self metta-moses:optimization:eda/local-structure)
!(import! &self metta-moses:optimization/univariate:univariate)
!(import! &self metta-moses:deme:score-deme)
!(import! &self metta-moses:deme:create-deme)
!(import! &self metta-moses:moses:neighborhood-sampling)
!(import! &self metta-moses:feature-selection:feature-selection-helpers)


;; ================================================================================
;; Test Data Setup
;; ================================================================================

;; Create test deme with 2 knobs, each with 3 possible values (0, 1, 2)
!(bind! test_deme (mkDeme 
  (mkRep 
    (mkKbMap 
      (mkDscKbMp (ConsMap ((mkNodeId (1)) 0) (ConsMap ((mkNodeId (2)) 1) NilMap))) 
      (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) 
                        (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) NilMMap)))) 
    (mkTree (mkNode AND) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) Nil)))) 
  (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 Nil))) (worstCscore))) Nil)) 
  0))

;; Create test truth table for AND operation
!(bind! test_ttb (createTruthTableBScore 2 (mkITable
                         (Cons (Cons False (Cons False (Cons False Nil))) 
                         (Cons (Cons True (Cons False (Cons False Nil))) 
                         (Cons (Cons False (Cons True (Cons False Nil)))
                         (Cons (Cons True (Cons True (Cons True Nil))) Nil))))
                         (Cons A (Cons B (Cons O Nil))))))

;; Test center instance
!(bind! test_center (mkInst (Cons 0 (Cons 0 Nil))))

;; ================================================================================
;; Deterministic Assertions
;; ================================================================================

;; EDA parameters (deterministic)
!(bind! DEFAULT_PARAMS (defaultEdaParameters))
!(assertEqual (getSelection DEFAULT_PARAMS) 2)
!(assertEqual (getSelectionRatio DEFAULT_PARAMS) 1.0)
!(assertEqual (getReplacementRatio DEFAULT_PARAMS) 0.5)
!(assertEqual (getModelComplexity DEFAULT_PARAMS) 1.0)

;; Information theoretic calculations
!(assertEqual (discSpecMultiplicity (mkDiscSpec 3)) 3)
!(assertEqual (ilog2ceil 1) 0)
!(assertEqual (ilog2ceil 2) 1)
!(assertEqual (ilog2ceil 3) 2)
!(assertEqual (ilog2ceil 4) 2)
!(assertEqual (ilog2ceil 8) 3)

;; Univariate results (deterministic under seeded RNG)
!(assertEqual (let $val (univariate test_deme test_ttb test_center) (car-atom $val)) (mkInst (Cons 0 (Cons 0 Nil))))
!(assertEqual
  (let $val (univariate test_deme test_ttb test_center)
    (let $rest (cdr-atom $val)
      (getRep (car-atom $rest))))
  (getRep test_deme))

;; univariate-with-eda with explicit params
!(assertEqual (let $val (univariateEdaLoop test_deme test_ttb test_center (mkEDAParameters 2 1.0 0.5 1.0)) (car-atom $val)) (mkInst (Cons 0 (Cons 0 Nil))))