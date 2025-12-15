!(import! &self ../../../representation/lsk)
!(import! &self ../../../representation/instance)
!(import! &self ../../../representation/build-knobs)
!(import! &self ../../../representation/knob-mapper)
!(import! &self ../../../representation/logical-probe) 
!(import! &self ../../../representation/build-logical)
!(import! &self ../../../representation/representation)
!(import! &self ../../../representation/add-logical-knobs)
!(import! &self ../../../representation/knob-representation)
!(import! &self ../../../representation/sample-logical-perms)
!(import! &self ../../../representation/create-representation)

!(import! &self ../../../utilities/map)
!(import! &self ../../../utilities/tree)
!(import! &self ../../../utilities/pair) 
!(import! &self ../../../utilities/nodeId)
!(import! &self ../../../utilities/list-methods)
!(import! &self ../../../utilities/general-helpers)
!(import! &self ../../../utilities/ordered-multimap)
!(import! &self ../../../utilities/lazy-random-selector)


!(import! &self ../../../deme/score-deme)
!(import! &self ../../../deme/create-deme)
!(import! &self ../../../deme/deme-id-creation)
!(import! &self ../../../deme/expand-deme)

!(import! &self ../../../scoring/cscore)
!(import! &self ../../../scoring/bscore)
!(import! &self ../../../scoring/fitness)
!(import! &self ../../../scoring/complexity-based-scorer)

!(import! &self ../../../moses/neighborhood-sampling)

!(import! &self ../../../optimization/hillclimbing/cross-top-one)
!(import! &self ../../../optimization/hillclimbing/hill-climbing-helpers)
!(import! &self ../../../feature-selection/feature-selection-helpers)
!(import! &self ../../../optimization/hillclimbing/cross-top-one-helpers)
!(import! &self ../../../optimization/univariate/univariate)
(= (deme) (mkDeme (mkRep (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (1)) 0) (ConsMap ((mkNodeId (2)) 1) NilMap))) (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) )) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) NilMMap)))) (mkTree (mkNode AND) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) Nil)))) (mkSInstSet Nil) (mkDemeId "1")))
(= (table1) (mkITable
                         (Cons (Cons False (Cons False (Cons False Nil))) 
                         (Cons (Cons True (Cons False (Cons False Nil))) 
                         (Cons (Cons False (Cons True (Cons False Nil)))
                         (Cons (Cons True (Cons True (Cons True Nil))) Nil))))
                         (Cons A (Cons B (Cons O Nil)))))

;; Testcase -- tournamentSelection
!(assertEqual (let $selected (eval (tournamentSelection (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 2 (Cons 0 Nil))) (mkCscore -3 1 0.5 0.0 -3.5))) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 Nil))) (mkCscore -1 1 0.5 0.0 -1.5))) Nil))
) 2 1 Nil)) (== (eval (List.length $selected)) 1)) True)

;; Testcase -- getNthInstFields
!(assertEqual (getNthInstFields (((0 1) (-1 1 0.5 0.0 -1.5)) ((2 3) (-3 1 0.5 0.0 -3.5))) 2 0 0 ()) (0 2))

;; Testcase -- instsToFieldValues
!(assertEqual (instsToFieldValues (((0 1) (-1 1 0.5 0.0 -1.5)) ((2 3) (-3 1 0.5 0.0 -3.5))) 2 2 0 ()) ((0 2) (1 3)))

;; Testcase -- learnProbability
!(assertEqual (learnProbability ((0 2) (1 3)) ()) ((1 0 1) (0 1 0)))

;; Testcase -- replaceTheWorst
!(assertEqual (replaceTheWorst (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 2 (Cons 1 Nil))) (mkCscore -2 2 1.0 0.0 -3.0))) (Cons (mkSInst (mkPair (mkInst (Cons 2 (Cons 0 Nil))) (mkCscore -3 1 0.5 0.0 -3.5))) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 Nil))) (mkCscore -4 0 0.0 0.0 -4.0))) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 Nil))) (mkCscore -4 0 0.0 0.0 -4.0))) Nil)))))
(mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 2 (Cons 0 Nil))) (mkCscore -3 1 0.5 0.0 -3.5))) (Cons (mkSInst (mkPair (mkInst (Cons 2 (Cons 1 Nil))) (mkCscore -2 2 1.0 0.0 -3.0))) (Cons (mkSInst (mkPair (mkInst (Cons 2 (Cons 0 Nil))) (mkCscore -3 1 0.5 0.0 -3.5))) Nil))))
) (Cons (mkSInst (mkPair (mkInst (Cons 2 (Cons 1 Nil))) (mkCscore -2 2 1.0 0.0 -3.0))) (Cons (mkSInst (mkPair (mkInst (Cons 2 (Cons 0 Nil))) (mkCscore -3 1 0.5 0.0 -3.5))) (Cons (mkSInst (mkPair (mkInst (Cons 2 (Cons 1 Nil))) (mkCscore -2 2 1.0 0.0 -3.0))) (Cons (mkSInst (mkPair (mkInst (Cons 2 (Cons 0 Nil))) (mkCscore -3 1 0.5 0.0 -3.5))) Nil)))))

;;Testcase -- univariate
;; This test case is commented out because when the transform function is called more than once, it duplicates values exponentially.
;; In this case, the transform function is called inside univariateMainLoop,
;; which is recursive and is executed 6 times (until $genCount equals $MaxGensCount).
;; Additionally, it is also called in the univariateOptimize function, which is also recursive.
;; The test case works correctly (it returns is true, shoud true as expected), but it is being
;; executed recursively multiple times.
;; Therefore, until the transform function is fixed, this test case remains commented out.
  
; !(assertEqual
;     (let (mkDeme $rep (mkSInstSet $instSet) $id) 
;          (eval (univariate (deme) (table1) 2.0 1 0.5 0.5 (mkCscore -0.1 2 0.1 0.1 3)))          
;          (== (eval (List.length $instSet)) 7)) True)


