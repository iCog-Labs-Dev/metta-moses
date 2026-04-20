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
          (cons (mkTree (mkNode A) ())
          (cons (mkTree (mkNode OR)
                  (cons (mkTree (mkNode B) ())
                  (cons (mkTree (mkNode C) ())
                  (cons (mkNullVex
                          (cons (mkTree (mkNode D) ()) ())) ()))))
          (cons (mkNullVex
                  (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) ())) ())) ())))))

(= (lsk1)
        (mkLSK
            (mkDiscKnob
              (mkKnob (mkNodeId (2 3)))
              (mkMultip 3)
              (mkDiscSpec 0)
              (mkDiscSpec 0)
              ())
            ))

(= (lsk2)
        (mkLSK
            (mkDiscKnob
              (mkKnob (mkNodeId (3)))
              (mkMultip 3)
              (mkDiscSpec 0)
              (mkDiscSpec 0)
              ())
            ))

(= (lsk3)
        (mkLSK
            (mkDiscKnob
              (mkKnob (mkNodeId (1)))
              (mkMultip 3)
              (mkDiscSpec 1)
              (mkDiscSpec 1)
              ())
            ))

(= (knobMapObj) (mkKbMap
                      (mkDscKbMp (ConsMap ((mkNodeId (2 3)) 0) (ConsMap ((mkNodeId (3)) 1) (ConsMap ((mkNodeId (1)) 2) NilMap))))
               
                      (mkDscMp (ConsMMap ((mkDiscSpec 1) (lsk1)) (ConsMMap ((mkDiscSpec 0) (lsk2)) (ConsMMap ((mkDiscSpec 1) (lsk3)) NilMMap))))))
(= (ttable1) (mkITable (cons (cons True (cons False (cons True ())))
                        (cons (cons True (cons True  (cons True ()))) ())) 
                        (cons A (cons B (cons O ())))))
(= (ttable2) (mkITable
                    (cons (cons True (cons True (cons True (cons True ()))))
                    (cons (cons True (cons False (cons False (cons False ()))))
                    (cons (cons False (cons True (cons False (cons False ()))))
                    (cons (cons False (cons False (cons False (cons False ())))) ()))))
                    (cons A (cons B (cons C (cons output ()))))))
;; NOTE: All the instances in the deme don't include lsk1 (or they all start with '0') because we are testing it using ttable2. 
;;       ttable2 is a truth table which doesn't have a 'D' column.
;; Testcases for applyComplexityBasedScore
!(assertEqual 
   (applyComplexityBasedScore 
      (mkRep (knobMapObj) (tree1))
      (cons (mkInst (cons 0 (cons 0 (cons 2 ())))) (cons (mkInst (cons 0 (cons 0 (cons 1 ())))) (cons (mkInst (cons 0 (cons 2 (cons 2 ())))) ())))
      (ttable2)
      2.0)
   (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 2 ())))) (mkCscore -2 3 1.5 0.0 -3.5))) (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) (mkCscore 0 3 1.5 0.0 -1.5))) (cons (mkSInst (mkPair (mkInst (cons 0 (cons 2 (cons 2 ())))) (mkCscore -2 4 2.0 0.0 -4.0))) ()))))

!(assertEqual
   (applyComplexityBasedScore 
      (mkRep (knobMapObj) (tree1))
      (cons (mkInst (cons 0 (cons 1 (cons 2 ())))) (cons (mkInst (cons 0 (cons 2 (cons 1 ())))) ()))
      (ttable2)
      2.0)
      (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 2 ())))) (mkCscore -4 0 0.0 0.0 -4.0))) (cons (mkSInst (mkPair (mkInst (cons 0 (cons 2 (cons 1 ())))) (mkCscore -4 0 0.0 0.0 -4.0))) ())))

;; Testcases for transform
!(assertEqual
   (transform
   (mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 2 ())))) -1.0000000000000001e308)) (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) -1.0000000000000001e308)) ())))
   (mkRep (knobMapObj) (tree1))
   (ttable2)
   2.0)
   (mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 2 ())))) (mkCscore -2 3 1.5 0.0 -3.5))) (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) (mkCscore 0 3 1.5 0.0 -1.5))) ()))))

; The these test cases are commented out because they behave non deterministically when running all the 3 representation together 
;; but runs correctly when running them separately !!
!(assertEqual
   (transform
   (mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 2 ())))) -1.0000000000000001e308)) (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 1 ())))) -1.0000000000000001e308)) ())))
   (mkRep (knobMapObj) (tree1))
   (ttable2)
   1)
   (mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 2 ())))) (mkCscore -4 0 0.0 0.0 -4.0))) (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 1 ())))) (mkCscore 0 3 3.0 0.0 -3.0))) ())))) 

;; Testcase for the bitsToIndices
!(assertEqual (bitsToIndices (cons 1 (cons 0 (cons 1 (cons 0 ())))) 0 ()) (0 2))

; ; Testcase for applyMutualInformationBasedScore
!(assertEqual
  (applyMutualInformationBasedScore 
      (cons (mkInst (cons 0 (cons 0 (cons 2 ())))) (cons (mkInst (cons 0 (cons 0 (cons 1 ())))) (cons (mkInst (cons 0 (cons 2 (cons 2 ())))) ())))
      (ttable2)
      100.0  ;; confidence parameter
      ())
  (cons (mkSInst (mkPair (mkInst (cons 0 (cons 2 (cons 2 ())))) 0.0)) (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) 0.811)) (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 2 ())))) 0.0)) ()))))

; ; Test for applyPrecisionBasedScore
!(assertEqual
   (applyPrecisionBasedScore 
      (cons (mkInst (cons 0 (cons 0 (cons 2 ())))) (cons (mkInst (cons 0 (cons 0 (cons 1 ())))) (cons (mkInst (cons 0 (cons 2 (cons 2 ())))) ())))
      (ttable2)
      100.0 1.0 0.5 1.0 True
      ())
   (cons (mkSInst (mkPair (mkInst (cons 0 (cons 2 (cons 2 ())))) 0.0)) (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) 0.30678094352750773)) (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 2 ())))) 0.0)) ())))
      )

;; Testcase for transformFs
!(assertEqual
   (transformFs
   (mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 1 ())))) 0)) (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 0 ())))) 0)) ())))
   (ttable2)
   100.0 1.0 0.5 1.0 True mi
   )
   (mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 0 ())))) 0.311)) (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 1 ())))) 0.811)) ()))))

!(assertEqual
   (transformFs
      (mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 1 ())))) 0)) (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 0 ())))) 0)) ())))
      (ttable2)
      100.0 1.0 0.5 1.0 True pre
      )
   (mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 0 ())))) 0.5)) (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 1 ())))) 0.33333333333333337)) ())))
   )

(= (StrategyRep)
   (mkRep 
     (mkKbMap 
       (mkDscKbMp (ConsMap ((mkNodeId (1)) 0) (ConsMap ((mkNodeId (2)) 1) NilMap)))
       (mkDscMp 
         (ConsMMap ((mkDiscSpec 2) (mkSSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 1) (mkDiscSpec 1) ()))) 
         (ConsMMap ((mkDiscSpec 2) (mkSSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 2) (mkDiscSpec 1) (mkDiscSpec 1) ()))) 
         NilMMap))))
     (mkTree (mkNode PRIORITIZED-OR) 
       (cons (mkTree (mkNode playcenter) ()) 
             (cons (mkTree (mkNode playcorner) ()) ())))))

!(assertEqual (applyStrategyBasedScore (StrategyRep) () 1 random-player 3.5 ()) ())

!(assertEqual (applyStrategyBasedScore (StrategyRep) 
                     (cons (mkInst (cons 1 (cons 1 ())))  ()) 1 random-player 3.5 ()) 
                     (cons (mkSInst (mkPair (mkInst (cons 1 (cons 1 ()))) (mkCscore 1.0 2 0.5714285714285714 0.0 0.4285714285714286))) ()))

!(assertEqual
   (transform (mkSInstSet ()) (StrategyRep) (1 random-player) 3.5)
   (mkSInstSet ()))

!(assertEqual (transform
   (mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 1 (cons 1 ()))) -1.0e308)) ()))
   (StrategyRep) (1 random-player) 3.5) (mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 1 (cons 1 ()))) (mkCscore 1.0 2 0.5714285714285714 0.0 0.4285714285714286))) ())))
