!(import! &self ../../../utilities/general-helpers)
!(import! &self ../../../parameters/registry)
!(import! &self ../../../parameters/defaults)
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


(= (knobmap1)
        (
          ((mkDiscSpec 1) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())))
          ((mkDiscSpec 1) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())))))

(= (knobmap2)
        ( ((mkDiscSpec 1) (mkLSK (mkDiscKnob (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ())))
          ((mkDiscSpec 1) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())))))

(= (knobmap3)
  (mkKbMap
    (mkDscMp
      ( ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())))
        ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())))
        ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())))))))

;; Test informationTheoreticBits with a knob 
;; map containing two knobs with same multiplicity of 3
;; Previous sum-of-multiplicities expectation: 6.
;; !(assertEqual (informationTheoreticBits (knobmap1)) 6)
!(assertEqual
  (informationTheoreticBits (knobmap1))
  (+ (log-math 2 3) (log-math 2 3)))

;; Test informationTheoreticBits with a knob
;; map containing two knobs with different multiplicity of 2 and 3
;; Previous sum-of-multiplicities expectation: 5.
;; !(assertEqual (informationTheoreticBits (knobmap2)) 5)
!(assertEqual
  (informationTheoreticBits (knobmap2))
  (+ (log-math 2 2) (log-math 2 3)))

;; Testcase for informationTheoreticBitsFs
!(assertEqual
  (informationTheoreticBitsFs (cons A (cons B (cons O ())))) 2)

;; Testing estimateNeighborhood on the above knob maps
!(assertEqual (estimateNeighborhood 0 (knobmap1)) 1)
;; C++ truncates the information sum to size_t: floor(log2(2)+log2(3))=2
;; and floor(2*log2(3))=3 before estimating these neighborhoods.
;; Previous multiplicity-based expectations: 10, 15, 10, and 20.
;; !(assertEqual (estimateNeighborhood 1 (knobmap2)) 10)
;; !(assertEqual (estimateNeighborhood 2 (knobmap1)) 15)
;; !(assertEqual (estimateNeighborhood 2 (knobmap2)) 10)
;; !(assertEqual (estimateNeighborhood 3 (knobmap1)) 20)
!(assertEqual (estimateNeighborhood 1 (knobmap2)) 4)
!(assertEqual (estimateNeighborhood 2 (knobmap1)) 3)
!(assertEqual (estimateNeighborhood 2 (knobmap2)) 1)
!(assertEqual (estimateNeighborhood 3 (knobmap1)) 1)

;; The old estimator sent distance 7 directly to binomial(3, 7), incorrectly
;; treating the over-wide request as an empty neighborhood.
;; !(assertEqual (estimateNeighborhood 7 (knobmap1)) 0)
;; C++ clamps the request to the estimated bit dimension first: C(3, 3) = 1.
!(assertEqual (estimateNeighborhood 7 (knobmap1)) 1)
;; Exercise the same clamp with a different estimated dimension so this does
;; not merely duplicate the boundary case above.
!(assertEqual (estimateNeighborhood 3 (knobmap2)) 1)

;; Action-subtree knobs are the shape exercised by the ant pipeline.  This
;; catches the former nested `int` expression that stayed unreduced at the
;; second hill-climbing iteration even though direct arithmetic tests passed.
!(assertEqual
  (estimateNeighborhood
    1
    (((mkDiscSpec 7)
       (mkASK
         (mkDiscKnob (mkMultip 7) (mkDiscSpec 0) (mkDiscSpec 0) ())
         ()))))
  4)

;; Testcase for estimateNeighborhoodFs
!(assertEqual
 (estimateNeighborhoodFs 2 (cons A (cons B (cons O ())))) 1)

; Testcase for countNeighborhoodFs
!(assertEqual (countNeighborhoodFs (mkInst (cons 1 (cons 0 (cons 1 ())))) 2 20) 3)

; Testcase for factorial
!(assertEqual (factorial 3) 6)

; Testcase for binomial
!(assertEqual (binomial 5 2) 10)

;; Shared crossover merging appends unique offspring after the scored
;; population. Ant therefore preserves the previous sample range without a
;; domain-specific merge implementation.
!(assertEqual
  (let* (
         ($old1 (mkSInst (mkPair (mkInst (0)) (mkCscore -2 0 0 0 -2))))
         ($old2 (mkSInst (mkPair (mkInst (1)) (mkCscore -1 0 0 0 -1))))
         ($new1 (mkSInst (mkPair (mkInst (2)) (worstCscore))))
         ($new2 (mkSInst (mkPair (mkInst (3)) (worstCscore))))
         ($new3 (mkSInst (mkPair (mkInst (4)) (worstCscore))))
         ;; This has the same instance as $old1 but a placeholder score.  A
         ;; whole-row comparison used to append it and rescore vector (0).
         ($rediscoveredOld1 (mkSInst (mkPair (mkInst (0)) (worstCscore))))
         (($mergedDeme $added)
           (merge3Demes
             (mkDeme ant-rep (mkSInstSet ($old1 $old2)) (mkDemeId "ant-x"))
             ($new1) ($new2 $new1 $rediscoveredOld1) ($new3)))
         ((mkDeme $rep (mkSInstSet (cons $prefix1 (cons $prefix2 $offspring))) $id)
          $mergedDeme)
        )
    ($prefix1 $prefix2 $added $offspring
      (is-member $rediscoveredOld1 $offspring)))
  ((mkSInst (mkPair (mkInst (0)) (mkCscore -2 0 0 0 -2)))
   (mkSInst (mkPair (mkInst (1)) (mkCscore -1 0 0 0 -1)))
   3
   ((mkSInst (mkPair (mkInst (2)) (worstCscore)))
    (mkSInst (mkPair (mkInst (3)) (worstCscore)))
    (mkSInst (mkPair (mkInst (4)) (worstCscore))))
   False))

;; Raw termination tracking is independent of which candidate has the best
;; complexity-penalized score.
!(assertEqual
  (bestRawAntScore
    ((mkSInst (mkPair (mkInst (0)) (mkCscore 0 20 100 0 -100)))
     (mkSInst (mkPair (mkInst (1)) (mkCscore -1 0 0 0 -1)))))
  0)

;; Folding an empty deme retains the previous raw-score sentinel.
!(assertEqual (bestRawAntScore ()) ())

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

(= (deme) (mkDeme (mkRep (mkKbMap (mkDscMp (((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) )) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())))))) (mkTree (mkNode AND) ( (mkKnob (mkNullVex ((mkTree (mkNode A) ()))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 0) (mkKnob (mkNullVex ((mkTree (mkNode B) ()))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 1)))) (mkSInstSet ()) (mkDemeId "1")))

(= (demes) ((mkDeme (mkRep (mkKbMap (mkDscMp (((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) )) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) ))))) (mkTree (mkNode AND) ((mkKnob (mkNullVex ((mkTree (mkNode A) ()))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 0) (mkKnob (mkNullVex ((mkTree (mkNode B) ()))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 1)))) (mkSInstSet ()) (mkDemeId "1"))))

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

;; Checks the returned center instance is either the absolute best instance found in the deme, or if not, that the gap between the best instance's score and the original center's score is within the improvement threshold (0.5)
;; It uses (mkInst (cons 2 (cons 2 ()))) as the first center instance which has a penalty score of -5  
!(assertEqual 
  (let* 
  (
    (($instance (mkDeme $rep (mkSInstSet $sInstSet) $demeId) $state) (hillClimbing (deme) (table1) (mkInst (cons 2 (cons 2 ()))) (mkParams applyComplexityBasedScore ())))
    ((mkSInst (mkPair $bestInst $bestScore)) (List.foldl hillScoreHelper (mkSInst (mkPair (mkInst (2 2)) (mkCscore -4 2 1.0 0.0 -5.0))) $sInstSet))
  )
  (or (== $instance $bestInst) (<= (- (getPenScore $bestScore) -5) 0.5))
) True)

;; deme for strategy hill climbing
;; INFO: Uncomment once the strategy refactor is done.
;; (= (strategyDeme)
;;    (mkDeme 
;;      (mkRep 
;;        (mkKbMap 
;;          (mkDscKbMp (cons ((mkNodeId (1)) 0) (cons ((mkNodeId (2)) 1) ())))
;;          (mkDscMp 
;;            (cons ((mkDiscSpec 2) 
;;                       (mkSSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 1) (mkDiscSpec 1) ())))
;;              (cons ((mkDiscSpec 2) 
;;                         (mkSSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 2) (mkDiscSpec 1) (mkDiscSpec 1) ())))
;;                ()))))
;;        (mkTree (mkNode PRIORITIZED-OR) 
;;          (cons (mkTree (mkNode playwin) ()) 
;;                (cons (mkTree (mkNode playblock) ()) ()))))
;;      (mkSInstSet ())
;;      (mkDemeId "1")))
;;
;; !(assertEqual (hillClimbing (strategyDeme) (mkCscore 3.0 5 1.43 0.0 3) (mkInst (cons 1 (cons 1 ()))) (mkParams applyStrategyBasedScore (3 3.5))
;; ) ((mkInst (1 1)) (mkDeme (mkRep (mkKbMap (mkDscKbMp (((mkNodeId (1)) 0) ((mkNodeId (2)) 1))) (mkDscMp (((mkDiscSpec 2) (mkSSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 1) (mkDiscSpec 1) ()))) ((mkDiscSpec 2) (mkSSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 2) (mkDiscSpec 1) (mkDiscSpec 1) ())))))) (mkTree (mkNode PRIORITIZED-OR) ((mkTree (mkNode playwin) ()) (mkTree (mkNode playblock) ())))) (mkSInstSet ((mkSInst (mkPair (mkInst (0 1)) (mkCscore -3.0 1 0.2857142857142857 0.0 -3.2857142857142856))) (mkSInst (mkPair (mkInst (1 1)) (mkCscore -3.0 2 0.5714285714285714 0.0 -3.571428571428571))) (mkSInst (mkPair (mkInst (0 1)) (mkCscore -3.0 1 0.2857142857142857 0.0 -3.2857142857142856))) (mkSInst (mkPair (mkInst (1 0)) (mkCscore -3.0 1 0.2857142857142857 0.0 -3.2857142857142856))))) (mkDemeId "1")) (true false false (mkInst (1 1)) 3 1 (mkCscore -3.0 1 0.2857142857142857 0.0 -3.2857142857142856) -3.2857142857142856 4 2 3)))
