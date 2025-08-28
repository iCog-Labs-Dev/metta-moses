!(register-module! ../../../../metta-moses)

!(import! &self metta-moses:utilities:general-helpers)
!(import! &self metta-moses:representation:representation)
!(import! &self metta-moses:representation:knob-representation)
!(import! &self metta-moses:representation:create-representation)

!(import! &self metta-moses:utilities:map)
!(import! &self metta-moses:utilities:tree)
!(import! &self metta-moses:utilities:pair)
!(import! &self metta-moses:utilities:nodeId)
!(import! &self metta-moses:utilities:list-methods)
!(import! &self metta-moses:utilities:ordered-multimap)
!(import! &self metta-moses:utilities:lazy-random-selector)


!(import! &self metta-moses:deme:score-deme)

!(import! &self metta-moses:scoring:cscore)
!(import! &self metta-moses:scoring:bscore)
!(import! &self metta-moses:scoring:complexity-based-scorer)

!(import! &self metta-moses:optimization/hillclimbing:hill-climbing-helpers)
!(import! &self metta-moses:moses:neighborhood-sampling)
!(import! &self metta-moses:optimization/univariate:un)

;; Build a minimal Deme like hillclimbing tests

!(bind! deme (mkDeme (mkRep (mkKbMap
  (mkDscKbMp (ConsMap ((mkNodeId (1)) 0) NilMap))
  (mkDscMp (ConsMMap ((mkDiscSpec 1) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) NilMMap))) (mkTree (mkNodeId (1)) Nil)) (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 0 Nil)) (worstCscore))) Nil)) 0))

;; Truth table based scorer object
!(bind! ttb
  (createTruthTableBScore 0.1
    (mkITable
      (Cons (Cons False (Cons False (Cons False Nil)))
      (Cons (Cons True  (Cons False (Cons False Nil)))
      (Cons (Cons False (Cons True  (Cons False Nil)))
      (Cons (Cons True  (Cons True  (Cons True  Nil))) Nil))))
      (Cons A (Cons B (Cons O Nil))))))

;; Center instance
!(bind! center (mkInst (Cons 0 Nil)))

;; Run univariate optimizer
!(univariate deme ttb center)


