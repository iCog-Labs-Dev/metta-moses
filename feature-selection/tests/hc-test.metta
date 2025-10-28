!(register-module! ../../../metta-moses)

!(import! &self metta-moses:representation:lsk)
!(import! &self metta-moses:representation:instance)
!(import! &self metta-moses:representation:build-knobs)
!(import! &self metta-moses:representation:knob-mapper)
!(import! &self metta-moses:representation:logical-probe) 
!(import! &self metta-moses:representation:build-logical)
!(import! &self metta-moses:representation:representation)
!(import! &self metta-moses:representation:add-logical-knobs)
!(import! &self metta-moses:representation:knob-representation)
!(import! &self metta-moses:representation:sample-logical-perms)
!(import! &self metta-moses:representation:create-representation)

!(import! &self metta-moses:utilities:map)
!(import! &self metta-moses:utilities:tree)
!(import! &self metta-moses:utilities:pair) 
!(import! &self metta-moses:utilities:nodeId)
!(import! &self metta-moses:utilities:list-methods)
;;!(import! &self metta-moses:utilities:python-helpers);; commented out because not compatibel with mettalog
!(import! &self metta-moses:utilities:general-helpers)
!(import! &self metta-moses:utilities:ordered-multimap)
!(import! &self metta-moses:utilities:python-treehelpers)
!(import! &self metta-moses:utilities:lazy-random-selector)

!(import! &self metta-moses:reduct:enf)

!(import! &self metta-moses:deme:score-deme)
!(import! &self metta-moses:deme:create-deme)
!(import! &self metta-moses:deme:deme-id-creation)
!(import! &self metta-moses:deme:expand-deme)

!(import! &self metta-moses:scoring:cscore)
!(import! &self metta-moses:scoring:bscore)
!(import! &self metta-moses:scoring:fitness)
!(import! &self metta-moses:scoring:complexity-based-scorer)

!(import! &self metta-moses:moses:neighborhood-sampling)

!(import! &self metta-moses:feature-selection:feature-selection-helpers)
!(import! &self metta-moses:feature-selection:hc)
!(import! &self metta-moses:scoring:precision-bscore)

!(import! &self metta-moses:optimization/hillclimbing:cross-top-one)
!(import! &self metta-moses:optimization/hillclimbing:hill-climbing-helpers)
!(import! &self metta-moses:optimization/hillclimbing:cross-top-one-helpers)

! (bind! ttable2 
    (mkITable 
        (Cons (Cons False (Cons False (Cons True (Cons True (Cons True Nil)))))
        (Cons (Cons True (Cons False (Cons False (Cons True (Cons True Nil)))))
        (Cons (Cons False (Cons True (Cons False (Cons True (Cons False Nil)))))
        (Cons (Cons False (Cons False (Cons False (Cons True (Cons False Nil))))) Nil))))
        (Cons A (Cons B (Cons C (Cons D (Cons Output Nil)))))))
            
                                                              ;;miConf PrePenalty  PreMInActivation   PreMaxActivation  PrePositive   ScorerType
! (assertEqual (hcFtSetPop ttable2 (Cons 1 (Cons 0 (Cons 0 (Cons 0 Nil)))) mi)
    ((1.0 (0 2 3)) (0.311 (2 3)) (0.311 (0)) (0.311 (0 3)) (0.311 (2)))
 )

! (assertEqual (hcFtSetPop ttable2 (Cons 1 (Cons 0 (Cons 0 (Cons 0 Nil)))) pre)
    ((1.0 (0 2)) (0.5 (0 3)) (0.5 (0)))
)
