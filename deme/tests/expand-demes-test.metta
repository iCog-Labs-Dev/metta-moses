!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/pair)
!(import! &self ../../utilities/map)
!(import! &self ../../utilities/ordered-multimap)
!(import! &self ../../utilities/ordered-set)
!(import! &self ../../utilities/ordered-multiset)
!(import! &self ../../utilities/nodeId)
!(import! &self ../../utilities/lazy-random-selector)
!(import! &self ../../utilities/lru-cache)

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

!(import! &self ../../feature-selection/feature-selection-helpers)
!(import! &self ../../feature-selection/select-top-features)
!(import! &self ../../feature-selection/similarity-scorers)
!(import! &self ../../feature-selection/simple)
!(import! &self ../../feature-selection/smd)
!(import! &self ../../feature-selection/incremental)
!(import! &self ../../feature-selection/hc)
!(import! &self ../../feature-selection/random-feature-selection)
!(import! &self ../../feature-selection/feature-selection-main)

!(import! &self ../../representation/knob-representation)
!(import! &self ../../representation/lsk)
!(import! &self ../../representation/logical-probe)
!(import! &self ../../representation/logical-canonize)
!(import! &self ../../representation/sample-logical-perms)
!(import! &self ../../representation/add-logical-knobs)
!(import! &self ../../representation/build-logical)
!(import! &self ../../representation/build-knobs)
!(import! &self ../../representation/knob-mapper)

!(import! &self ../../representation/representation)
!(import! &self ../../representation/create-representation)

!(import! &self ../../scoring/strategy-score-cache)
!(import! &self ../../examples/tic-tac-toe/tic-tac-toe-helpers)
!(import! &self ../../examples/tic-tac-toe/random-player)
!(import! &self ../../examples/tic-tac-toe/minimax-player)
!(import! &self ../../examples/tic-tac-toe/game-engine)
!(import! &self ../../examples/tic-tac-toe/moves)
!(import! &self ../../examples/tic-tac-toe/moses-player)
!(import! &self ../../examples/tic-tac-toe/strategy-scoring)

!(import! &self ../../scoring/cacheSpace)
!(import! &self ../../scoring/fitness)
!(import! &self ../../scoring/bscore)
!(import! &self ../../scoring/cscore)
!(import! &self ../../scoring/complexity-based-scorer)

!(import! &self ../../optimization/hillclimbing/cross-top-one-helpers)
!(import! &self ../../optimization/hillclimbing/cross-top-one)
!(import! &self ../../optimization/hillclimbing/hill-climbing-helpers)

!(import! &self ../create-deme)

!(import! &self ../../moses/neighborhood-sampling)

!(import! &self ../../metapopulation/exemplar-type)
!(import! &self ../../metapopulation/exemplar-selection)
!(import! &self ../../metapopulation/metapopulation)

!(import! &self ../../representation/instance)

!(import! &self ../deme-id-creation)
!(import! &self ../score-deme)
!(import! &self ../merge-demes)
!(import! &self ../expand-deme)

(= (deme) (mkDeme (mkRep (mkKbMap (mkDscKbMp (cons ((mkNodeId (1)) 0) (cons ((mkNodeId (2)) 1) ()))) (mkDscMp (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob  (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ())))) (mkTree (mkNode AND) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) ())))) (mkSInstSet ()) (mkDemeId "1")))
(= (table1) (eval (createTruthTableBScore 2 (mkITable
                         (cons (cons False (cons False (cons False ()))) 
                         (cons (cons True (cons False (cons False ()))) 
                         (cons (cons False (cons True (cons False ())))
                         (cons (cons True (cons True (cons True ()))) ()))))
                         (cons A (cons B (cons O ())))))))

(= (ttable1) (mkITable
                         (cons (cons False (cons False (cons False ()))) 
                         (cons (cons True (cons False (cons False ()))) 
                         (cons (cons False (cons True (cons False ())))
                         (cons (cons True (cons True (cons True ()))) ()))))
                         (cons A (cons B (cons O ())))))                         

(= (ortable) (eval (createTruthTableBScore 2 (mkITable
                         (cons (cons False (cons False (cons False ()))) 
                         (cons (cons True (cons False (cons True ()))) 
                         (cons (cons False (cons True (cons True ())))
                         (cons (cons True (cons True (cons True ()))) ()))))
                         (cons A (cons B (cons O ())))))))

(= (orttable) (mkITable
                         (cons (cons False (cons False (cons False ()))) 
                         (cons (cons True (cons False (cons True ()))) 
                         (cons (cons False (cons True (cons True ())))
                         (cons (cons True (cons True (cons True ()))) ()))))
                         (cons A (cons B (cons O ()))))) 

(= (xortable) (mkITable
                         (cons (cons False (cons False (cons False ()))) 
                         (cons (cons True (cons False (cons True ()))) 
                         (cons (cons False (cons True (cons True ())))
                         (cons (cons True (cons True (cons False ()))) ()))))
                         (cons A (cons B (cons O ())))))

;; (= (metaPop2) (cons (mkExemplar (mkTree (mkNode AND) ()) (mkDemeId "1") (eval (worstCscore)) (mkBScore (cons -1 (cons -1 ())))) ()))
;; (= (metaPop2) (cons (mkExemplar (mkTree (mkNode AND) ()) (mkDemeId "1") (eval (worstCscore)) (mkBScore (cons -1 (cons -1 (cons -1 (cons -1 ())))))) ()))
(= (metaPop2) (cons (mkExemplar (mkTree (mkNode AND) ()) (mkDemeId "1") (mkCscore -4 2 1.0 0.0 -4.0) (mkBScore  (cons -1 (cons -1 (cons -1 (cons -1 ())))))) ()))

(= (metaPop) (cons (mkExemplar (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ()))) (mkDemeId "1") (mkCscore -0.2 1 0.1 0.1 -0.4) (mkBScore (cons 0 (cons 0 (cons 0 (cons 0 ()))))))
                 (cons (mkExemplar (mkTree (mkNode OR) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ())) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (cons 0 (cons 0 (cons 0 (cons 0 ())))))) 
                 ())))
       
(= (bigtable) (mkITable
                        (cons (cons True  (cons False (cons True  (cons False (cons True  (cons True  ()))))))
                        (cons (cons False (cons True  (cons True  (cons False (cons False (cons False ()))))))
                        (cons (cons True  (cons True  (cons False (cons True  (cons True  (cons True  ()))))))
                        (cons (cons False (cons False (cons True  (cons True  (cons False (cons False ()))))))
                        (cons (cons True  (cons False (cons False (cons True  (cons True  (cons True  ()))))))
                        (cons (cons False (cons True  (cons False (cons False (cons False (cons False ()))))))
                        (cons (cons True  (cons True  (cons True  (cons False (cons True  (cons True  ()))))))
                        (cons (cons False (cons False (cons False (cons True  (cons False (cons False ()))))))
                        (cons (cons True  (cons True  (cons False (cons False (cons True  (cons True  ()))))))
                        (cons (cons False (cons True  (cons True  (cons True  (cons False (cons False ()))))))
                        (cons (cons True  (cons False (cons True  (cons True  (cons True  (cons True  ()))))))
                        (cons (cons False (cons False (cons False (cons False (cons False (cons False ()))))))
                        (cons (cons True  (cons True  (cons True  (cons True  (cons True  (cons True  ()))))))
                        (cons (cons False (cons False (cons True  (cons False (cons False (cons False ()))))))
                        (cons (cons True  (cons False (cons False (cons False (cons True  (cons True  ()))))))
                        (cons (cons False (cons True  (cons False (cons True  (cons False (cons False ())))))) ()))))))))))))))))
                        
                        (cons A (cons B (cons C (cons D (cons E (cons T ()))))))))                     
;; truthTableBScore for  bigtable
(= (bigtablet) (eval (createTruthTableBScore 2 (bigtable))))                        

(= (bigtable2) (mkITable
                        (cons (cons True  (cons False (cons True  (cons False (cons True  (cons True  ()))))))
                        (cons (cons False (cons True  (cons False (cons True  (cons False (cons False ()))))))
                        (cons (cons True  (cons True  (cons True  (cons False (cons False (cons True  ()))))))
                        (cons (cons False (cons False (cons True  (cons True  (cons True  (cons True  ()))))))
                        (cons (cons True  (cons False (cons False (cons True  (cons True  (cons False ()))))))
                        (cons (cons False (cons True  (cons True  (cons True  (cons False (cons True  ()))))))
                        (cons (cons True  (cons True  (cons False (cons False (cons True  (cons True  ()))))))
                        (cons (cons False (cons False (cons False (cons True  (cons False (cons False ()))))))
                        (cons (cons True  (cons True  (cons True  (cons True  (cons True  (cons True  ()))))))
                        (cons (cons False (cons True  (cons False (cons False (cons True  (cons False ()))))))
                        (cons (cons True  (cons False (cons True  (cons True  (cons False (cons True  ()))))))
                        (cons (cons False (cons False (cons True  (cons False (cons True  (cons False ()))))))
                        (cons (cons True  (cons True  (cons False (cons True  (cons False (cons True  ()))))))
                        (cons (cons False (cons True  (cons True  (cons False (cons True  (cons True  ()))))))
                        (cons (cons True  (cons False (cons False (cons False (cons False (cons False ()))))))
                        (cons (cons False (cons False (cons False (cons True  (cons True  (cons True  ())))))) ()))))))))))))))))

                        (cons A (cons B (cons C (cons D (cons E (cons T ()))))))))

; (= (bigtablet2) (createTruthTableBScore 2 bigtable2))                        

; (: isScored (-> (ScoredInstance Cscore) Bool))
(= (isScored (mkSInst (mkPair $instance $score))) (~= $score (eval (worstCscore))))

;; Testcase for optimizeDemes               
!(assertEqual 
(let* 
(
    ($optimizeDemesReturn (optimizeDemes (deme) 
                (table1) 
                (mkInst (cons 0 (cons 0 ()))) 
                hillClimbing
                ))
    ($_ (println! "optimizeDemes Returns"))
    ($_ (println! $optimizeDemesReturn))
    (($instance (mkDeme $rep (mkSInstSet $instSet) $id) $state) $optimizeDemesReturn)
    ($instanceCount (List.length $instSet))
    ($scoredElems (List.map isScored $instSet))
)
((>= $instanceCount 4) (List.any $scoredElems)))
(True True))

;; ;; Testcase for expandDeme INFO: For some reason this test case disturbs the next test case but is fine alone.
;; !(assertEqual
;; (let*
;; (
;;     ($updatedDeme (expandDeme (metaPop2) 0 1 False sim 
;;                     (table1)
;;                     hillClimbing 
;;                     (ttable1)
;;                     mi))
;;     ($updatedDemeLength (size-atom $updatedDeme)))
;; (>= $updatedDemeLength 1)) True)

;; Testcase for runMoses
!(assertEqual
(let*
(
    ($_ (println! (running started)))
    ($topCandidates (runMoses 2 (mkCscore -0.1 2 0.1 0.1 3) 3 (metaPop2) 0 2 (False sim 
    (table1) 
    (ttable1)) 
    hillClimbing 5 2 0 1 
    3 0.004 1000))
    ($topCandidatesLength (OS.length $topCandidates))
)
(>= $topCandidatesLength 1)
) True)

;; Testcase for runMoses
!(assertEqual
(let*
(
    ($topCandidates (runMoses 1 (mkCscore -0.1 2 0.1 0.1 3) 3 (metaPop2) 0 2 (False rd 
    (table1)  
    (ttable1))
    hillClimbing 5 2 0 1 
    3 0.004 1000))
    ($topCandidatesLength (OS.length $topCandidates))
)
(>= $topCandidatesLength 1)
) True)

;; Testcase for runMoses
!(assertEqual
(let*
(
    ($topCandidates (runMoses 1 (mkCscore -0.1 2 0.1 0.1 3) 3 (metaPop2) 0 2 (False inc 
    (table1)
    (ttable1))
    hillClimbing 5 2 0 1
    3 0.004 1000))
    ($topCandidatesLength (OS.length $topCandidates))
)
(>= $topCandidatesLength 1)
) True)

;; Testcase 2 for runmoses. 
;; When maxGen become 10, test number of returned instances is not greater than maxCandOutput, 
;;              where maxCandOutput is 3 and minPoolSize is 2
!(assertEqual
(let $length
((OS.length (runMoses 10 (mkCscore -0.1 2 0.1 0.1 3) 3 (metaPop2) 0 2 
    (False    ;; the new arguments for prune-exemplar -- we are saying dont prune the exemplar
    inc      ;; the new arguments for feature selection algo
    (eval (createTruthTableBScore 2 (mkITable
                          (cons (cons False (cons False (cons False ()))) 
                          (cons (cons True (cons False (cons False ()))) 
                          (cons (cons False (cons True (cons False ())))
                          (cons (cons True (cons True (cons True ()))) ()))))
                          (cons A (cons B (cons O ()))))))
    (mkITable
                          (cons (cons False (cons False (cons False ()))) 
                          (cons (cons True (cons False (cons False ()))) 
                          (cons (cons False (cons True (cons False ())))
                          (cons (cons True (cons True (cons True ()))) ()))))
                          (cons A (cons B (cons O ())))))
    hillClimbing 5 2 2 1
    3 0.004 1000)
    ))
        (> $length 3)
)
    False
) 
; ; with OR table and AND init exemplar     
; !(runMoses 7 (mkCscore -0.1 2 0.1 0.1 3) 3 (metaPop) 0 2 
;     False    ;; the new arguments for prune-exemplar -- we are saying dont prune the exemplar
;     smd      ;; the new arguments for feature selection algo
;     (eval (createTruthTableBScore 2 (mkITable
;                          (cons (cons False (cons False (cons False ()))) 
;                          (cons (cons True (cons False (cons True ()))) 
;                          (cons (cons False (cons True (cons True ())))
;                          (cons (cons True (cons True (cons True ()))) ()))))
;                          (cons A (cons B (cons O ())))))) 
;     hillClimbing 
;     5 2 0 1 
;     (mkITable
;                          (cons (cons False (cons False (cons False ()))) 
;                          (cons (cons True (cons False (cons True ()))) 
;                          (cons (cons False (cons True (cons True ())))
;                          (cons (cons True (cons True (cons True ()))) ()))))
;                          (cons A (cons B (cons O ())))) 
;     3 0.004 1000)
; ; with OR table and AND init exemplar     
; !(runMoses 7 (mkCscore -0.1 2 0.1 0.1 3) 3 (metaPop) 0 2 
;     False    ;; the new arguments for prune-exemplar -- we are saying dont prune the exemplar
;     smd      ;; the new arguments for feature selection algo
;     (eval (createTruthTableBScore 2 (mkITable
;                           (cons (cons False (cons False (cons False ()))) 
;                           (cons (cons True (cons False (cons True ()))) 
;                           (cons (cons False (cons True (cons True ())))
;                           (cons (cons True (cons True (cons True ()))) ()))))
;                           (cons A (cons B (cons O ()))))))  
;     hillClimbing 
;     5 2 0 1 
;     (mkITable
;                           (cons (cons False (cons False (cons False ()))) 
;                           (cons (cons True (cons False (cons True ()))) 
;                           (cons (cons False (cons True (cons True ())))
;                           (cons (cons True (cons True (cons True ()))) ()))))
;                           (cons A (cons B (cons O ()))))  
;     3 0.004 1000)

; !(runMoses 1 (mkCscore -0.1 2 0.1 0.1 3) 3 (metaPop2) 0 2 
;     False    ;; the new arguments for prune-exemplar -- we are saying dont prune the exemplar
;     smd      ;; the new arguments for feature selection algo
;     (eval (createTruthTableBScore 2 
;     (bigtable)))
;     hillClimbing 
;     5 2 0 1 
;     (bigtable) 
;     3 0.004 1000)

;; Parameters:
  ;; $maxGen $maxScore $maxCandOutput $metaPop $nExpansion $nDeme
  ;; $prune-exemplar
  ;; $fs-algo
  ;; $truthTableBScore
  ;; $optimize
  ;; $nEval $maxCandsPerDeme $minPoolSize $complexityTemperature
  ;; $itable
  ;; $nToKeep $capCoef $genCount

;; The following configuration can result to XOR.
;; A⊕B=(A∨B)∧¬(A∧B)
;; (AND (OR A B) (OR (NOT A) (NOT B)))
;; A⊕B=(¬A∧B)∨(A∧¬B)
;; (AND (OR (AND A (NOT B)) (AND (NOT A) B)))
;; !(let*
;;    (
;;     ($result (runMoses 20 (mkCscore -0.1 2 0.1 0.1 3) 10 (metaPop2) 0 2
;;                   False    ;; the new arguments for prune-exemplar -- we are saying dont prune the exemplar
;;                   smd      ;; the new arguments for feature selection algo
;;                   (eval (createTruthTableBScore 2 (xortable)))
;;                   hillClimbing
;;                   100 10 20 2
;;                   (xortable)
;;                   10 0.004 1000))
;;     ($nt (println! ""))
;;     ($newR (mapG cleanedExemplar $result))
;;     ($_ (mapG printExemplar $result))
;;    )
;;    $newR
;;  )
;;
;; Empty strategy metapop -  empty PRIORITIZED-OR with worst CScore
;; this empty strategy can be used as a starting point to evolve better strategy 
(= (emptyStrategyMetaPop)
   (cons
     (mkExemplar
       (mkTree (mkNode PRIORITIZED-OR) ())  ;;  empty - no children
       (mkDemeId "0")
       (eval (worstCscore))  ;; Worst CScore
       (mkBScore (cons -10000.0 ())))
     ()))

;; by uncomment this test and also adjust the parameter settings we can check the full evolution process of runMosesStrategy, and see how the strategy evolves from empty strategy to better strategy.
; !(runMoses
;     2                              ;; maxGen - 3 generations 
;     (mkCscore 10.0 0 0 0.0 10)     ;; Target: 10/10 wins,
;     3                              ;; maxCandOutput - return top 3 strategies
;     (emptyStrategyMetaPop)         ;; metaPop - start with empty strategy
;     0                              ;; nExpansion - generation counter
;     2                              ;; nDeme - 3 demes (more diversity)
;     (10 random-player 3.5)       ;; nGames - 10 games per evaluation
;     hillClimbing                   ;; optimize - optimizer function
;     30                             ;; nEval - not used
;     5                              ;; maxCandsPerDeme - top 5 per deme
;     2                              ;; minPoolSize - min deme size
;     1.0                            ;; complexityTemperature - for trimming
;     5                              ;; nToKeep - keep top 5
;     0.004                          ;; capCoef - capacity coefficient
;     1000)   
;; metapop for testing
(= (strategyMetaPop)
   (cons
     (mkExemplar
       (mkTree (mkNode PRIORITIZED-OR)
         (cons (mkTree (mkNode playwin) ())
               (cons (mkTree (mkNode playblock) ()) ())))
       (mkDemeId "0")
       (mkCscore 2.0 2 0.57 0.0 1.43)
       (mkBScore (cons 2.0 ())))
     ()))

;; !(assertEqual ;; INFO: This test case is blocking the reset. But works fine on it's own.
;;    (let* (
;;      ($optimizedDemes (expandDeme
;;                         (strategyMetaPop) 
;;                         0 1 5 random-player 3.5 
;;                         (mkCscore 5.0 5 1.43 0.0 3.57) 
;;                         hillClimbing))
;;      ($demeCount (size-atom $optimizedDemes))
;;    )
;;    (>= $demeCount 1))
;;    True)
;;
!(assertEqual
   (let* (
     ($result (runMoses
                1                              ;; maxGen
                (mkCscore 5.0 5 1.43 0.0 3.57) ;; target
                3                              ;; maxCandOutput
                (strategyMetaPop)              ;; metaPop
                0 1                            ;; nExpansion, nDeme
                (5 random-player 3.5)            ;; nGames, opponent, ratio
                hillClimbing                   ;; optimizer
                30 5 2 1.0                     ;; nEval, maxCands, minPool, temp
                5 0.004 1000))                 ;; nToKeep, capCoef, genCount
     ($resultSize (eval (OS.length $result)))
   )
   (>= $resultSize 1))
   True)

!(assertEqual
   (let* (
     ($result (runMoses
                1                              ;; maxGen
                (mkCscore 5.0 5 1.43 0.0 3.57) ;; target
                1                              ;; maxCandOutput
                (strategyMetaPop)              ;; metaPop
                0 1                            ;; nExpansion, nDeme
                (5 random-player 3.5)            ;; nGames, opponent, ratio
                hillClimbing                   ;; optimizer
                30 5 2 1.0                     ;; nEval, maxCands, minPool, temp
                5 0.004 1000))                 ;; nToKeep, capCoef, genCount
     ($topExemplar (eval (OS.getByIdx 0 $result)))
     ($topScore (eval (getExemplarCscore $topExemplar)))
     ($penScore (eval (getPenScore $topScore)))
     ;; Score should be better than worst possible
     ($isValid (> $penScore -1000.0))
   )
   $isValid)
   True)
