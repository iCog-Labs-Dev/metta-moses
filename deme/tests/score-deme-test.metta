!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/map)
!(import! &self ../../utilities/ordered-multimap)
!(import! &self ../../utilities/nodeId)

!(import! &self ../../reduct/boolean-reduct/rte-helpers)
!(import! &self ../../reduct/boolean-reduct/cut-unnecessary-or)
!(import! &self ../../reduct/boolean-reduct/cut-unnecessary-and)
!(import! &self ../../reduct/boolean-reduct/n-ary-propagate-not)
!(import! &self ../../reduct/boolean-reduct/n-ary-gather-junctors)
!(import! &self ../../reduct/boolean-reduct/delete-inconsistent-handle)
!(import! &self ../../reduct/boolean-reduct/zero-constraint-subsumption)
!(import! &self ../../reduct/boolean-reduct/one-constraint-subsumption)
!(import! &self ../../reduct/boolean-reduct/promote-common-constraints)
!(import! &self ../../reduct/boolean-reduct/reduce-to-elegance)

!(import! &self ../../utilities/tree)
!(import! &self ../../scoring/strategy-score-cache)

!(import! &self ../../examples/tic-tac-toe/tic-tac-toe-helpers)
!(import! &self ../../examples/tic-tac-toe/random-player)
!(import! &self ../../examples/tic-tac-toe/strategy-scoring)
!(import! &self ../../examples/tic-tac-toe/minimax-player)
!(import! &self ../../examples/tic-tac-toe/game-engine)
!(import! &self ../../examples/tic-tac-toe/moves)
!(import! &self ../../examples/tic-tac-toe/moses-player)

!(import! &self ../../representation/knob-representation)
!(import! &self ../../representation/lsk)
!(import! &self ../../representation/knob-mapper)
!(import! &self ../../feature-selection/feature-selection-helpers)
!(import! &self ../../representation/representation)

!(import! &self ../../representation/instance)

!(import! &self ../../scoring/fitness)
!(import! &self ../../scoring/bscore)
!(import! &self ../../scoring/cscore)
!(import! &self ../../scoring/precision-bscore)
!(import! &self ../../scoring/complexity-based-scorer)

!(import! &self ../../moses/neighborhood-sampling.metta)

!(import! &self ../score-deme)


(= (tree1)
        (mkTree (mkNode AND)
          (Cons (mkTree (mkNode A) Nil)
          (Cons (mkTree (mkNode OR)
                  (Cons (mkTree (mkNode B) Nil)
                  (Cons (mkTree (mkNode C) Nil)
                  (Cons (mkNullVex
                          (Cons (mkTree (mkNode D) Nil) Nil)) Nil))))
          (Cons (mkNullVex
                  (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) Nil)) Nil)) Nil)))))

(= (lsk1)
        (mkLSK
            (mkDiscKnob
              (mkKnob (mkNodeId (2 3)))
              (mkMultip 3)
              (mkDiscSpec 0)
              (mkDiscSpec 0)
              Nil)
            ))

(= (lsk2)
        (mkLSK
            (mkDiscKnob
              (mkKnob (mkNodeId (3)))
              (mkMultip 3)
              (mkDiscSpec 0)
              (mkDiscSpec 0)
              Nil)
            ))

(= (lsk3)
        (mkLSK
            (mkDiscKnob
              (mkKnob (mkNodeId (1)))
              (mkMultip 3)
              (mkDiscSpec 1)
              (mkDiscSpec 1)
              Nil)
            ))

(= (knobMapObj) (mkKbMap
                      (mkDscKbMp (ConsMap ((mkNodeId (2 3)) 0) (ConsMap ((mkNodeId (3)) 1) (ConsMap ((mkNodeId (1)) 2) NilMap))))
               
                      (mkDscMp (ConsMMap ((mkDiscSpec 1) (lsk1)) (ConsMMap ((mkDiscSpec 0) (lsk2)) (ConsMMap ((mkDiscSpec 1) (lsk3)) NilMMap))))))
(= (ttable1) (mkITable (Cons (Cons True (Cons False (Cons True Nil)))
                        (Cons (Cons True (Cons True  (Cons True Nil))) Nil)) 
                        (Cons A (Cons B (Cons O Nil)))))
(= (ttable2) (mkITable
                    (Cons (Cons True (Cons True (Cons True (Cons True Nil))))
                    (Cons (Cons True (Cons False (Cons False (Cons False Nil))))
                    (Cons (Cons False (Cons True (Cons False (Cons False Nil))))
                    (Cons (Cons False (Cons False (Cons False (Cons False Nil)))) Nil))))
                    (Cons A (Cons B (Cons C (Cons output Nil))))))
;; NOTE: All the instances in the deme don't include lsk1 (or they all start with '0') because we are testing it using ttable2. 
;;       ttable2 is a truth table which doesn't have a 'D' column.
;; Testcases for applyComplexityBasedScore
!(assertEqual 
   (applyComplexityBasedScore 
      (mkRep (knobMapObj) (tree1))
      (Cons (mkInst (Cons 0 (Cons 0 (Cons 2 Nil)))) (Cons (mkInst (Cons 0 (Cons 0 (Cons 1 Nil)))) (Cons (mkInst (Cons 0 (Cons 2 (Cons 2 Nil)))) Nil)))
      (ttable2)
      2.0)
   (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 2 Nil)))) (mkCscore -2 3 1.5 0.0 -3.5))) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 1 Nil)))) (mkCscore 0 3 1.5 0.0 -1.5))) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 2 (Cons 2 Nil)))) (mkCscore -2 4 2.0 0.0 -4.0))) Nil))))

!(assertEqual
   (applyComplexityBasedScore 
      (mkRep (knobMapObj) (tree1))
      (Cons (mkInst (Cons 0 (Cons 1 (Cons 2 Nil)))) (Cons (mkInst (Cons 0 (Cons 2 (Cons 1 Nil)))) Nil))
      (ttable2)
      2.0)
      (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 (Cons 2 Nil)))) (mkCscore -4 0 0.0 0.0 -4.0))) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 2 (Cons 1 Nil)))) (mkCscore -4 0 0.0 0.0 -4.0))) Nil)))

;; Testcases for transform
!(assertEqual
   (transform
   (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 2 Nil)))) -1.0000000000000001e308)) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 1 Nil)))) -1.0000000000000001e308)) Nil)))
   (mkRep (knobMapObj) (tree1))
   (ttable2)
   2.0)
   (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 2 Nil)))) (mkCscore -2 3 1.5 0.0 -3.5))) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 1 Nil)))) (mkCscore 0 3 1.5 0.0 -1.5))) Nil))))

; The these test cases are commented out because they behave non deterministically when running all the 3 representation together 
;; but runs correctly when running them separately !!
!(assertEqual
   (transform
   (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 (Cons 2 Nil)))) -1.0000000000000001e308)) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 (Cons 1 Nil)))) -1.0000000000000001e308)) Nil)))
   (mkRep (knobMapObj) (tree1))
   (ttable2)
   1)
   (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 (Cons 2 Nil)))) (mkCscore -4 0 0.0 0.0 -4.0))) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 (Cons 1 Nil)))) (mkCscore 0 3 3.0 0.0 -3.0))) Nil)))) 

;; Testcase for the bitsToIndices
!(assertEqual (bitsToIndices (Cons 1 (Cons 0 (Cons 1 (Cons 0 Nil)))) 0 ()) (0 2))

; ; Testcase for applyMutualInformationBasedScore
!(assertEqual
  (applyMutualInformationBasedScore 
      (Cons (mkInst (Cons 0 (Cons 0 (Cons 2 Nil)))) (Cons (mkInst (Cons 0 (Cons 0 (Cons 1 Nil)))) (Cons (mkInst (Cons 0 (Cons 2 (Cons 2 Nil)))) Nil)))
      (ttable2)
      100.0  ;; confidence parameter
      Nil)
  (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 2 (Cons 2 Nil)))) 0.0)) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 1 Nil)))) 0.811)) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 2 Nil)))) 0.0)) Nil))))

; ; Test for applyPrecisionBasedScore
!(assertEqual
   (applyPrecisionBasedScore 
      (Cons (mkInst (Cons 0 (Cons 0 (Cons 2 Nil)))) (Cons (mkInst (Cons 0 (Cons 0 (Cons 1 Nil)))) (Cons (mkInst (Cons 0 (Cons 2 (Cons 2 Nil)))) Nil)))
      (ttable2)
      100.0 1.0 0.5 1.0 True
      Nil)
   (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 2 (Cons 2 Nil)))) 0.0)) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 1 Nil)))) 0.30678094352750773)) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 2 Nil)))) 0.0)) Nil)))
      )

;; Testcase for transformFs
!(assertEqual
   (transformFs
   (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 (Cons 1 Nil)))) 0)) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 (Cons 0 Nil)))) 0)) Nil)))
   (ttable2)
   100.0 1.0 0.5 1.0 True mi
   )
   (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 (Cons 0 Nil)))) 0.311)) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 (Cons 1 Nil)))) 0.811)) Nil))))

!(assertEqual
   (transformFs
      (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 (Cons 1 Nil)))) 0)) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 (Cons 0 Nil)))) 0)) Nil)))
      (ttable2)
      100.0 1.0 0.5 1.0 True pre
      )
   (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 (Cons 0 Nil)))) 0.5)) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 (Cons 1 Nil)))) 0.33333333333333337)) Nil)))
   )

(= (StrategyRep)
   (mkRep 
     (mkKbMap 
       (mkDscKbMp (ConsMap ((mkNodeId (1)) 0) (ConsMap ((mkNodeId (2)) 1) NilMap)))
       (mkDscMp 
         (ConsMMap ((mkDiscSpec 2) (mkSSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 1) (mkDiscSpec 1) Nil))) 
         (ConsMMap ((mkDiscSpec 2) (mkSSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 2) (mkDiscSpec 1) (mkDiscSpec 1) Nil))) 
         NilMMap))))
     (mkTree (mkNode PRIORITIZED-OR) 
       (Cons (mkTree (mkNode playcenter) Nil) 
             (Cons (mkTree (mkNode playcorner) Nil) Nil)))))

!(assertEqual (applyStrategyBasedScore (StrategyRep) Nil 1 random-player 3.5 Nil) Nil)

!(assertEqual (applyStrategyBasedScore (StrategyRep) 
                     (Cons (mkInst (Cons 1 (Cons 1 Nil)))  Nil) 1 random-player 3.5 Nil) 
                     (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 1 Nil))) (mkCscore 1.0 2 0.5714285714285714 0.0 0.4285714285714286))) Nil))

!(assertEqual
   (transform (mkSInstSet Nil) (StrategyRep) (1 random-player) 3.5)
   (mkSInstSet Nil))

!(assertEqual (transform
   (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 1 Nil))) -1.0e308)) Nil))
   (StrategyRep) (1 random-player) 3.5) (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 1 Nil))) (mkCscore 1.0 2 0.5714285714285714 0.0 0.4285714285714286))) Nil)))
