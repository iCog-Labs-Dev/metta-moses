!(import! &self ../../../utilities/general-helpers)
!(import! &self ../../../utilities/list-methods)
!(import! &self ../../../utilities/nodeId)
!(import! &self ../../../utilities/map)
!(import! &self ../../../utilities/ordered-multimap)
!(import! &self ../../../utilities/lazy-random-selector)
!(import! &self ../../../utilities/pair) 
!(import! &self ../../../utilities/tree)

!(import! &self ../../../representation/knob-representation)
!(import! &self ../../../representation/lsk)
!(import! &self ../../../representation/logical-probe) 
!(import! &self ../../../representation/logical-canonize)
!(import! &self ../../../representation/sample-logical-perms)
!(import! &self ../../../representation/add-logical-knobs)
!(import! &self ../../../representation/build-logical)
!(import! &self ../../../representation/build-knobs)
!(import! &self ../../../representation/knob-mapper)
!(import! &self ../../../feature-selection/feature-selection-helpers)
!(import! &self ../../../representation/representation)
!(import! &self ../../../representation/create-representation)

!(import! &self ../../../representation/instance)

!(import! &self ../cross-top-one-helpers)
!(import! &self ../cross-top-one)



!(import! &self ../../../scoring/strategy-score-cache)

!(import! &self ../../../examples/tic-tac-toe/tic-tac-toe-helpers)
!(import! &self ../../../examples/tic-tac-toe/random-player)
!(import! &self ../../../examples/tic-tac-toe/minimax-player)
!(import! &self ../../../examples/tic-tac-toe/game-engine)
!(import! &self ../../../examples/tic-tac-toe/moves)
!(import! &self ../../../examples/tic-tac-toe/moses-player)
!(import! &self ../../../examples/tic-tac-toe/strategy-scoring)

!(import! &self ../../../scoring/fitness)
!(import! &self ../../../scoring/bscore)
!(import! &self ../../../scoring/cscore)
!(import! &self ../../../scoring/complexity-based-scorer)

!(import! &self ../../../deme/deme-id-creation)
!(import! &self ../../../deme/create-deme)
!(import! &self ../../../deme/score-deme)
!(import! &self ../../../deme/expand-deme)

!(import! &self ../hill-climbing-helpers)

!(import! &self ../../../moses/neighborhood-sampling)

!(py-call (random.seed 42))

(= (knobmap1)
        (cons (
                    (mkDiscSpec 1)
                    (mkLSK (mkDiscKnob (mkKnob  (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) ))
        (cons (
                    (mkDiscSpec 1)
                    (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) ))
        ())))

(= (knobmap2)
        (cons (
                    (mkDiscSpec 1)
                    (mkLSK (mkDiscKnob (mkKnob  (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ())))
        (cons (
                    (mkDiscSpec 1)
                    (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) ))
        ())))

(= (knobmap3)
  (mkKbMap
    (mkDscKbMp
      (cons ((mkNodeId (1 2)) 0)
        (cons ((mkNodeId (2)) 1)
          (cons ((mkNodeId (3)) 2) ()))))
    (mkDscMp 
      (cons 
        ((mkDiscSpec 3)
         (mkLSK 
           (mkDiscKnob 
             (mkKnob 
               (mkNodeId (1 2)))
             (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())
           ))
        (cons 
          ((mkDiscSpec 3)
           (mkLSK 
             (mkDiscKnob 
               (mkKnob 
                 (mkNodeId (2)))
               (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())
             ))
          (cons 
            ((mkDiscSpec 3)
             (mkLSK 
               (mkDiscKnob 
                 (mkKnob 
                   (mkNodeId (3)))
                 (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())
               ))
            ()))))))
;; Test informationTheoreticBits with a knob 
;; map containing two knobs with same multiplicity of 3
!(assertEqual (informationTheoreticBits (knobmap1)) 6)

;; Test informationTheoreticBits with a knob
;; map containing two knobs with different multiplicity of 2 and 3
!(assertEqual (informationTheoreticBits (knobmap2)) 5)
;; Test informationTheoreticBits with a knob 
;; map containing two knobs with same multiplicity of 3
!(assertEqual (informationTheoreticBits (knobmap1)) 6)
; ;; Test informationTheoreticBits with a knob 
; ;; map containing two knobs with same multiplicity of 3
!(assertEqual (informationTheoreticBits (knobmap1)) 6)

;; Test informationTheoreticBits with a knob
;; map containing two knobs with different multiplicity of 2 and 3
!(assertEqual (informationTheoreticBits (knobmap2)) 5)

;; Testcase for informationTheoreticBitsFs
!(assertEqual
  (informationTheoreticBitsFs (cons A (cons B (cons O ())))) 2)

;; Testing estimateNeighborhood on the above knob maps
!(assertEqual (estimateNeighborhood 0 (knobmap1)) 1)
!(assertEqual (estimateNeighborhood 1 (knobmap2)) 10)
!(assertEqual (estimateNeighborhood 2 (knobmap1)) 12)
!(assertEqual (estimateNeighborhood 2 (knobmap2)) 10)

;; Testcase for estimateNeighborhoodFs
!(assertEqual
  (estimateNeighborhoodFs 3 (cons A (cons B (cons O ())))) 4)

; Testcase for countNeighborhoodFs
!(assertEqual (countNeighborhoodFs (mkInst (cons 1 (cons 0 (cons 1 ())))) 2 20) 3)

; Testcase for factorial
!(assertEqual (factorial 3) 6)

; Testcase for binomial
!(assertEqual (binomial 5 2) 10)

; Testcase 1 for countNeighborhood
!(assertEqual 
 (countNeighborhood
  (knobmap3)  ;knobmap
  (mkInst (cons 1 (cons 0 (cons 2 ())))) ;instance
  2 ; distance
  20) ; maximum count
  12)

;Testcase 2 for countNeighborhood
!(assertEqual 
 (countNeighborhood
  (knobmap3) ;knobmap
  (mkInst (cons 1 (cons 0 (cons 2 ())))) ;instance
  3 ;distance
  20) ;maxCount
  8) 

;Testcase 3 for countNeighborhood
!(assertEqual 
 (let*
    (
       ($totalSize (countNeighborhood (knobmap3) (mkInst (cons 0 (cons 0 (cons 0 ())))) 3 20))
       ($generatedSize (List.length (generateAllInNeighborhood (mkMultip 3) (mkInst (cons 0 (cons 0 (cons 0 ())))) 3)))
    )
    (<= (* 3 $totalSize) (* 4 $generatedSize))) True)

;Testcase 4 for countNeighborhood
!(assertEqual 
 (let*
    (
       ($totalSize (countNeighborhood (knobmap3) (mkInst (cons 0 (cons 0 (cons 0 ())))) 2 20))
       ($generatedSize (List.length (generateAllInNeighborhood (mkMultip 3) (mkInst (cons 0 (cons 0 (cons 0 ())))) 2)))
    )
    (<= (* 3 $totalSize) (* 4 $generatedSize))) True)

;Testcase 5 for countNeighborhood
!(assertEqual
 (let*
    (
       ($totalSize (countNeighborhood (knobmap3) (mkInst (cons 0 (cons 0 (cons 0 ())))) 1 20))
       ($generatedSize (List.length (generateAllInNeighborhood (mkMultip 3) (mkInst (cons 0 (cons 0 (cons 0 ())))) 1)))
    )
(<= (* 3 $totalSize) (* 4 $generatedSize))) True)

(= (deme) (mkDeme (mkRep (mkKbMap (mkDscKbMp (cons ((mkNodeId (1)) 0) (cons ((mkNodeId (2)) 1) ()))) (mkDscMp (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) )) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ())))) (mkTree (mkNode AND) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) ())))) (mkSInstSet ()) (mkDemeId "1")))
(= (demes) (cons (mkDeme (mkRep (mkKbMap (mkDscKbMp (cons ((mkNodeId (1)) 0) (cons ((mkNodeId (2)) 1) ()))) (mkDscMp (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) )) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) )) ())))) (mkTree (mkNode AND) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) ())))) (mkSInstSet ()) (mkDemeId "1")) ()))

(= (table1) (createTruthTableBScore 2 (mkITable
                         (cons (cons False (cons False (cons False ()))) 
                         (cons (cons True (cons False (cons False ()))) 
                         (cons (cons False (cons True (cons False ())))
                         (cons (cons True (cons True (cons True ()))) ()))))
                         (cons A (cons B (cons O ()))))))

(= (itable) (mkITable
                         (cons (cons False (cons False (cons False ()))) 
                         (cons (cons True (cons False (cons False ()))) 
                         (cons (cons False (cons True (cons False ())))
                         (cons (cons True (cons True (cons True ()))) ()))))
                         (cons A (cons B (cons O ())))))

; (: isScored (-> (ScoredInstance Cscore) Bool))
(= (isScored (mkSInst (mkPair $instance $score))) (~= $score (worstCscore)))

!(hillclimbing test ----------)
!(assertEqual
   (let*
     (
       (($instance (mkDeme $rep (mkSInstSet $instSet) $id) $state) (hillClimbing (deme) (table1) (mkInst (cons 0 (cons 0 ()))) (mkParams applyComplexityBasedScore ())))
       ($instanceCount (List.length $instSet))
       ($scoredElems (List.map isScored $instSet))
     )
     ((>= $instanceCount 4) (List.any $scoredElems)))
(True True))

!(assertEqual
   (let*
     (
       (($instance (mkSInstSet $instSet) $state) (hillClimbing (mkSInstSet ()) (itable) (mkInst (cons 1 (cons 0 ()))) (mkParams applyMutualInformationBasedScore mi)))
       ($instanceCount (List.length $instSet))
       ($scoredElems (List.map isScored $instSet))
     )
     ((>= $instanceCount 3) (List.any $scoredElems)))
   (True True))

;; deme for strategy hill climbing
(= (strategyDeme)
   (mkDeme 
     (mkRep 
       (mkKbMap 
         (mkDscKbMp (cons ((mkNodeId (1)) 0) (cons ((mkNodeId (2)) 1) ())))
         (mkDscMp 
           (cons ((mkDiscSpec 2) 
                      (mkSSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 1) (mkDiscSpec 1) ())))
             (cons ((mkDiscSpec 2) 
                        (mkSSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 2) (mkDiscSpec 1) (mkDiscSpec 1) ())))
               ()))))
       (mkTree (mkNode PRIORITIZED-OR) 
         (cons (mkTree (mkNode playwin) ()) 
               (cons (mkTree (mkNode playblock) ()) ()))))
     (mkSInstSet ())
     (mkDemeId "1")))

!(assertEqual (hillClimbing (strategyDeme) (mkCscore 3.0 5 1.43 0.0 3) (mkInst (cons 1 (cons 1 ()))) (mkParams applyStrategyBasedScore (3 random-player 3.5))) 
                    ((mkInst (cons 1 (cons 1 ()))) (mkDeme (mkRep (mkKbMap (mkDscKbMp (cons ((mkNodeId (1)) 0) (cons ((mkNodeId (2)) 1) ()))) (mkDscMp (cons ((mkDiscSpec 2) (mkSSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 1) (mkDiscSpec 1) ()))) (cons ((mkDiscSpec 2) (mkSSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 2) (mkDiscSpec 1) (mkDiscSpec 1) ()))) ())))) (mkTree (mkNode PRIORITIZED-OR) (cons (mkTree (mkNode playwin) ()) (cons (mkTree (mkNode playblock) ()) ())))) (mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 ()))) (mkCscore -3.0 1 0.2857142857142857 0.0 -3.2857142857142856))) (cons (mkSInst (mkPair (mkInst (cons 1 (cons 1 ()))) (mkCscore -3.0 2 0.5714285714285714 0.0 -3.571428571428571))) (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 ()))) (mkCscore -3.0 1 0.2857142857142857 0.0 -3.2857142857142856))) (cons (mkSInst (mkPair (mkInst (cons 1 (cons 0 ()))) (mkCscore -3.0 1 0.2857142857142857 0.0 -3.2857142857142856))) ()))))) (mkDemeId "1")) (true false false (mkInst (cons 1 (cons 1 ()))) 3 1 (mkCscore -3.0 1 0.2857142857142857 0.0 -3.2857142857142856) -3.2857142857142856 4 2 3))
)
