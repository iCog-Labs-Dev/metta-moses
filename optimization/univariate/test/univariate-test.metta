!(import! &self ../../../utilities/general-helpers)
!(import! &self ../../../utilities/list-methods)
!(import! &self ../../../utilities/map)
!(import! &self ../../../utilities/ordered-multimap)
!(import! &self ../../../utilities/nodeId)
!(import! &self ../../../utilities/lazy-random-selector)
!(import! &self ../../../utilities/pair) 

!(import! &self ../../../utilities/tree)

!(import! &self ../../../representation/knob-representation)
!(import! &self ../../../representation/lsk)
!(import! &self ../../../representation/logical-probe) 
!(import! &self ../../../representation/sample-logical-perms)
!(import! &self ../../../representation/add-logical-knobs)
!(import! &self ../../../representation/build-logical)
!(import! &self ../../../representation/build-knobs)
!(import! &self ../../../representation/knob-mapper)
!(import! &self ../../../feature-selection/feature-selection-helpers)
!(import! &self ../../../representation/representation)
!(import! &self ../../../representation/create-representation)

!(import! &self ../../../scoring/fitness)
!(import! &self ../../../scoring/bscore)
!(import! &self ../../../scoring/cscore)
!(import! &self ../../../scoring/complexity-based-scorer)

!(import! &self ../../../representation/instance)

!(import! &self ../../../deme/deme-id-creation)
!(import! &self ../../../deme/create-deme)
!(import! &self ../../../deme/score-deme)
!(import! &self ../../../deme/expand-deme)

!(import! &self ../../../optimization/hillclimbing/cross-top-one-helpers)
!(import! &self ../../../optimization/hillclimbing/cross-top-one)
!(import! &self ../../../optimization/hillclimbing/hill-climbing-helpers)
!(import! &self ../../../moses/neighborhood-sampling)

!(import! &self ../../../optimization/univariate/univariate)

(= (deme) (mkDeme (mkRep (mkKbMap (mkDscKbMp (cons ((mkNodeId (1)) 0) (cons ((mkNodeId (2)) 1) ()))) (mkDscMp (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) )) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ())))) (mkTree (mkNode AND) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) ())))) (mkSInstSet ()) (mkDemeId "1")))
(= (table1) (mkITable
                         (cons (cons False (cons False (cons False ()))) 
                         (cons (cons True (cons False (cons False ()))) 
                         (cons (cons False (cons True (cons False ())))
                         (cons (cons True (cons True (cons True ()))) ()))))
                         (cons A (cons B (cons O ())))))

;; Testcase -- tournamentSelection
!(assertEqual (let $selected (tournamentSelection (mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 2 (cons 0 ()))) (mkCscore -3 1 0.5 0.0 -3.5))) (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 ()))) (mkCscore -1 1 0.5 0.0 -1.5))) ()))
) 2 1 ()) (== (List.length $selected) 1)) True)

;; Testcase -- getNthInstFields
!(assertEqual (getNthInstFields (((0 1) (-1 1 0.5 0.0 -1.5)) ((2 3) (-3 1 0.5 0.0 -3.5))) 2 0 0 ()) (0 2))

;; Testcase -- instsToFieldValues
!(assertEqual (instsToFieldValues (((0 1) (-1 1 0.5 0.0 -1.5)) ((2 3) (-3 1 0.5 0.0 -3.5))) 2 2 0 ()) ((0 2) (1 3)))

;; Testcase -- learnProbability
!(assertEqual (learnProbability ((0 2) (1 3)) ()) ((1 0 1) (0 1 0)))

;; Testcase -- replaceTheWorst
!(assertEqual (replaceTheWorst (mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 2 (cons 1 ()))) (mkCscore -2 2 1.0 0.0 -3.0))) (cons (mkSInst (mkPair (mkInst (cons 2 (cons 0 ()))) (mkCscore -3 1 0.5 0.0 -3.5))) (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 ()))) (mkCscore -4 0 0.0 0.0 -4.0))) (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 ()))) (mkCscore -4 0 0.0 0.0 -4.0))) ())))))
(mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 2 (cons 0 ()))) (mkCscore -3 1 0.5 0.0 -3.5))) (cons (mkSInst (mkPair (mkInst (cons 2 (cons 1 ()))) (mkCscore -2 2 1.0 0.0 -3.0))) (cons (mkSInst (mkPair (mkInst (cons 2 (cons 0 ()))) (mkCscore -3 1 0.5 0.0 -3.5))) ()))))
) (cons (mkSInst (mkPair (mkInst (cons 2 (cons 1 ()))) (mkCscore -2 2 1.0 0.0 -3.0))) (cons (mkSInst (mkPair (mkInst (cons 2 (cons 0 ()))) (mkCscore -3 1 0.5 0.0 -3.5))) (cons (mkSInst (mkPair (mkInst (cons 2 (cons 1 ()))) (mkCscore -2 2 1.0 0.0 -3.0))) (cons (mkSInst (mkPair (mkInst (cons 2 (cons 0 ()))) (mkCscore -3 1 0.5 0.0 -3.5))) ())))))

;;Testcase -- univariate
;; This test case is commented out because when the transform function is called more than once, it duplicates values exponentially.
;; In this case, the transform function is called inside univariateMainLoop,
;; which is recursive and is executed 6 times (until $genCount equals $MaxGensCount).
;; Additionally, it is also called in the univariateOptimize function, which is also recursive.
;; The test case works correctly (it returns is true, shoud true as expected), but it is being
;; executed recursively multiple times.
;; Therefore, until the transform function is fixed, this test case remains commented out.
  
!(assertEqual
    (let (mkDeme $rep (mkSInstSet $instSet) $id) 
         (univariate (deme) (table1) 2.0 1 0.5 0.5 (mkCscore -0.1 2 0.1 0.1 3))          
         (== (List.length $instSet) 7)) True)


