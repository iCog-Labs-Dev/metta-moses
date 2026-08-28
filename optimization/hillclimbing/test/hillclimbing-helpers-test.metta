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

!(import! &self ../crossover-helpers)
!(import! &self ../crossover)



!(import! &self ../../../scoring/cacheSpace)
!(import! &self ../../../scoring/strategy-score-cache)

!(import! &self ../../../examples/tic-tac-toe/tic-tac-toe-helpers)
!(import! &self ../../../examples/tic-tac-toe/random-player)
!(import! &self ../../../examples/tic-tac-toe/minimax-player)
!(import! &self ../../../examples/tic-tac-toe/game-engine)
!(import! &self ../../../examples/tic-tac-toe/moves)
!(import! &self ../../../examples/tic-tac-toe/moses-player)
!(import! &self ../../../examples/tic-tac-toe/strategy-scoring)

!(import! &self ../../../scoring/fitness)
!(import! &self ../../../scoring/boolean-ops)
!(import! &self ../../../scoring/bscore)
!(import! &self ../../../scoring/cscore)
!(import! &self ../../../scoring/complexity-based-scorer)

!(import! &self ../../../deme/deme-id-creation)
!(import! &self ../../../deme/create-deme)
!(import! &self ../../../deme/score-deme)
!(import! &self ../../../deme/domain-adapter)
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
!(assertEqual
  (informationTheoreticBits (knobmap1))
  3)

;; Test informationTheoreticBits with a knob
;; map containing two knobs with different multiplicity of 2 and 3
!(assertEqual
  (informationTheoreticBits (knobmap2))
  2)

;; Testcase for informationTheoreticBitsFs
!(assertEqual
  (informationTheoreticBitsFs (cons A (cons B (cons O ())))) 2)

;; Testing estimateNeighborhood on the above knob maps
!(assertEqual (estimateNeighborhood 0 (knobmap1)) 1)
;; C++ truncates the information sum to size_t: floor(log2(2)+log2(3))=2
;; and floor(2*log2(3))=3 before estimating these neighborhoods.
!(assertEqual (estimateNeighborhood 1 (knobmap2)) 4)
!(assertEqual (estimateNeighborhood 2 (knobmap1)) 3)
!(assertEqual (estimateNeighborhood 2 (knobmap2)) 1)
!(assertEqual (estimateNeighborhood 3 (knobmap1)) 1)

;; C++ clamps the request to the estimated bit dimension first: C(3, 3) = 1.
!(assertEqual (estimateNeighborhood 7 (knobmap1)) 1)
;; Exercise the same clamp with a different estimated dimension so this does
;; not merely duplicate the boundary case above.
!(assertEqual (estimateNeighborhood 3 (knobmap2)) 1)

;; Action-subtree knobs exercise the nested estimator shape used by the ant
;; pipeline.
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
;; population, so every problem preserves the previous sample range without a
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
           (mergeOffspring
             (mkDeme test-rep (mkSInstSet ($old1 $old2)) (mkDemeId "deme-x"))
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

;; Feature-selection crossover follows the same prefix-plus-fresh-suffix
;; contract and returns the number of rows that were actually appended.
!(assertEqual
  (let* (
         ($old1 (mkSInst (mkPair (mkInst (0 0 0)) 0.9)))
         ($old2 (mkSInst (mkPair (mkInst (1 0 0)) 0.8)))
         ($old3 (mkSInst (mkPair (mkInst (0 1 0)) 0.7)))
         (($updated $added)
           (crossoverFs
             3 3 0 3 (mkInst (0 0 0))
             (mkSInstSet ($old1 $old2 $old3))))
         ((mkSInstSet (cons $prefix1 (cons $prefix2 (cons $prefix3 $suffix))))
          $updated)
        )
    ($prefix1 $prefix2 $prefix3
     $added (List.length $suffix)))
  ((mkSInst (mkPair (mkInst (0 0 0)) 0.9))
   (mkSInst (mkPair (mkInst (1 0 0)) 0.8))
   (mkSInst (mkPair (mkInst (0 1 0)) 0.7))
   1 1))

;; Raw termination tracking is independent of which candidate has the best
;; complexity-penalized score.
!(assertEqual
  (bestRawScore
    ((mkSInst (mkPair (mkInst (0)) (mkCscore 0 20 100 0 -100)))
     (mkSInst (mkPair (mkInst (1)) (mkCscore -1 0 0 0 -1)))))
  0)

;; Folding an empty deme retains the previous raw-score sentinel.
!(assertEqual (bestRawScore ()) ())

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

;; Incremental scoring is shared with Boolean evolution: an existing score is
;; retained exactly, only the worstCscore-marked row is scored, and the count
;; reports that one new scorer invocation.
!(assertEqual
  (let* (
         ($_reset (resetCandidateScoreCache))
         ((mkDeme $rep $unusedSet $id) (deme))
         ($retainedScore (mkCscore -7 3 1.5 0.0 -8.5))
         (($scoredSet $actualEvaluations)
           (transformIncremental
             (mkSInstSet
               ((mkSInst (mkPair (mkInst (0 0)) $retainedScore))
                (mkSInst (mkPair (mkInst (1 1)) (worstCscore)))))
             $rep $id ((itable) 2)))
         ((mkSInstSet
            ((mkSInst (mkPair $oldInst $oldScore))
             (mkSInst (mkPair $newInst $newScore))))
          $scoredSet)
        )
    (($oldScore $actualEvaluations)
     (> (getScore $newScore) (* -1 (pow-math 10 90)))))
  (((mkCscore -7 3 1.5 0.0 -8.5) 1) True))

;; The hot hill-climbing path receives an existing scored prefix followed by
;; newly appended rows. It must preserve that prefix exactly and report only
;; scorer calls made for the suffix.
!(assertEqual
  (let* (
         ($_reset (resetCandidateScoreCache))
         ((mkDeme $rep $unusedSet $id) (deme))
         ($old1
           (mkSInst
             (mkPair (mkInst (0 0))
                     (mkCscore -7 3 1.5 0.0 -8.5))))
         ($old2
           (mkSInst
             (mkPair (mkInst (1 0))
                     (mkCscore -5 2 1.0 0.0 -6.0))))
         ($new (mkSInst (mkPair (mkInst (1 1)) (worstCscore))))
         (($scoredSet $actualEvaluations)
           (transformAppendedIncremental
             (mkSInstSet ($old1 $old2 $new)) 2
             $rep $id ((itable) 2)))
         ((mkSInstSet (cons $prefix1 (cons $prefix2 $suffix)))
          $scoredSet)
        )
    ($prefix1 $prefix2 $actualEvaluations
     (List.length $suffix)
     (scoreNeedsEvaluation
       (getSInstScore (List.head $suffix)))))
  ((mkSInst (mkPair (mkInst (0 0))
                    (mkCscore -7 3 1.5 0.0 -8.5)))
   (mkSInst (mkPair (mkInst (1 0))
                    (mkCscore -5 2 1.0 0.0 -6.0)))
   1 1 False))

;; Feature-selection batches obey the same append-only contract even though
;; they do not have a representation/id pair. This test transform deliberately
;; overwrites every row it receives, proving that the retained prefix is never
;; sent through the scorer again.
(= (markFeatureSelectionRows
      (mkSInstSet $instances) $itable
      $miConfidence $prePenalty $preMinActivation $preMaxActivation
      $prePositive $scorerType)
   (mkSInstSet
     (map-atom $instances $scoredInst
       (mkSInst
         (mkPair
           (getInst $scoredInst)
           (mkCscore -3 0 0.0 0.0 -3.0))))))

!(assertEqual
  (let* (
         ($retained
           (mkSInst
             (mkPair (mkInst (0 0))
                     (mkCscore -7 3 1.5 0.0 -8.5))))
         ($new
           (mkSInst
             (mkPair (mkInst (1 1)) (worstCscore))))
         (($scoredSet $actualEvaluations)
           (transformAppendedFeatureSelection
             (mkSInstSet ($retained $new)) 1
             markFeatureSelectionRows (itable)
             0.95 0.0 0.0 1.0 True mi))
         ((mkSInstSet ($preserved $scoredNew)) $scoredSet)
        )
    ($preserved (getSInstScore $scoredNew) $actualEvaluations))
  ((mkSInst
     (mkPair (mkInst (0 0))
             (mkCscore -7 3 1.5 0.0 -8.5)))
   (mkCscore -3 0 0.0 0.0 -3.0)
   1))

;; The recursive hillClimbing implementation commits its choice points with
;; `cut`, so direct top-level assertions after invoking it never reach
;; assertEqual under PeTTa. End-to-end Boolean hill-climbing behavior is
;; covered by demo-problems-benchmark-test; the shared incremental scorer is
;; exercised above without crossing that cut boundary.

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
