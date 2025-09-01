!(register-module! ../../../../metta-moses)

!(import! &self metta-moses:utilities:general-helpers)
!(import! &self metta-moses:representation:representation)
!(import! &self metta-moses:representation:knob-representation)
!(import! &self metta-moses:representation:create-representation)
!(import! &self metta-moses:representation:sample-logical-perms)
!(import! &self metta-moses:representation:build-knobs)
!(import! &self metta-moses:representation:build-logical)
!(import! &self metta-moses:representation:add-logical-knobs)
!(import! &self metta-moses:representation:logical-probe)
!(import! &self metta-moses:representation:lsk)
!(import! &self metta-moses:representation:instance)
!(import! &self metta-moses:representation:knob-mapper)

!(import! &self metta-moses:utilities:map)
!(import! &self metta-moses:utilities:tree)
!(import! &self metta-moses:utilities:pair)
!(import! &self metta-moses:utilities:nodeId)
!(import! &self metta-moses:utilities:list-methods)
!(import! &self metta-moses:utilities:ordered-multimap)
!(import! &self metta-moses:utilities:lazy-random-selector)
!(import! &self metta-moses:utilities:python-treehelpers)

!(import! &self metta-moses:reduct:enf)

!(import! &self metta-moses:deme:score-deme)
!(import! &self metta-moses:deme:create-deme)
!(import! &self metta-moses:deme:deme-id-creation)
!(import! &self metta-moses:deme:expand-deme)

!(import! &self metta-moses:scoring:cscore)
!(import! &self metta-moses:scoring:bscore)
!(import! &self metta-moses:scoring:complexity-based-scorer)
!(import! &self metta-moses:scoring:fitness)

!(import! &self metta-moses:optimization/hillclimbing:hill-climbing-helpers)
!(import! &self metta-moses:moses:neighborhood-sampling)
!(import! &self metta-moses:optimization/univariate:un)

;; Copy the exact working deme from hillclimbing test
!(bind! deme (mkDeme (mkRep (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (1)) 0) (ConsMap ((mkNodeId (2)) 1) NilMap))) (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) )) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) NilMMap)))) (mkTree (mkNode AND) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) Nil)))) (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 Nil))) (worstCscore))) Nil)) 0))

;; Copy the exact working table from hillclimbing test
!(bind! ttb (createTruthTableBScore 2 (mkITable
                         (Cons (Cons False (Cons False (Cons False Nil))) 
                         (Cons (Cons True (Cons False (Cons False Nil))) 
                         (Cons (Cons False (Cons True (Cons False Nil)))
                         (Cons (Cons True (Cons True (Cons True Nil))) Nil))))
                         (Cons A (Cons B (Cons O Nil))))))

;; Center instance with two values for two knobs
!(bind! center (mkInst (Cons 0 (Cons 0 Nil))))

;; Test the univariate optimization with the working deme
!(assertEqual (univariate deme ttb center) ((mkInst (Cons 1 (Cons 1 Nil))) (mkDeme (mkRep (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (1)) 0) (ConsMap ((mkNodeId (2)) 1) NilMap))) (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) NilMMap)))) (mkTree (mkNode AND) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) Nil)))) (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 2 Nil))) (mkCscore -3 1 0.5 0.0 -3.5))) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 Nil))) (mkCscore -4 0 0.0 0.0 -4.0))) (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 1 Nil))) (mkCscore 0 2 1.0 0.0 -1.0))) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 Nil))) (mkCscore -4 0 0.0 0.0 -4.0))) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 Nil))) (mkCscore -1 1 0.5 0.0 -1.5))) (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 0 Nil))) (mkCscore -1 1 0.5 0.0 -1.5))) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 2 Nil))) (mkCscore -3 1 0.5 0.0 -3.5))) Nil)))))))) 0) ()))
