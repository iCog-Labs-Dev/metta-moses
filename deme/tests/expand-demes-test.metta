!(import! &self ../../representation/lsk)
!(import! &self ../../representation/instance)
!(import! &self ../../representation/build-knobs)
!(import! &self ../../representation/knob-mapper)
!(import! &self ../../representation/logical-probe)
!(import! &self ../../representation/build-logical)
!(import! &self ../../representation/representation)
!(import! &self ../../representation/add-logical-knobs)
!(import! &self ../../representation/knob-representation)
!(import! &self ../../representation/sample-logical-perms)
!(import! &self ../../representation/create-representation)
!(import! &self ../../utilities/map)
!(import! &self ../../utilities/tree)
!(import! &self ../../utilities/pair)
!(import! &self ../../utilities/nodeId)
!(import! &self ../../utilities/list-methods)
; !(import! &self ../../utilities/python-helpers)
; !(import! &self ../../utilities/python-treehelpers)
!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/ordered-multimap)
!(import! &self ../../utilities/ordered-multiset)
!(import! &self ../../utilities/ordered-set)
!(import! &self ../../utilities/lazy-random-selector)
!(import! &self ../../utilities/lru-cache)
!(import! &self ../score-deme)
!(import! &self ../create-deme)
!(import! &self ../deme-id-creation)
!(import! &self ../expand-deme)
!(import! &self ../merge-demes)

!(import! &self ../../scoring/strategy-score-cache)
!(import! &self ../../examples/tic-tac-toe/tic-tac-toe-helpers)
!(import! &self ../../examples/tic-tac-toe/random-player)
!(import! &self ../../examples/tic-tac-toe/strategy-scoring)
!(import! &self ../../examples/tic-tac-toe/minimax-player)
!(import! &self ../../examples/tic-tac-toe/game-engine)
!(import! &self ../../examples/tic-tac-toe/moves)
!(import! &self ../../examples/tic-tac-toe/moses-player)


!(import! &self ../../scoring/cscore)
!(import! &self ../../scoring/bscore)
!(import! &self ../../scoring/fitness)
!(import! &self ../../scoring/complexity-based-scorer)
!(import! &self ../../scoring/cacheSpace)

!(import! &self ../../moses/neighborhood-sampling)
!(import! &self ../../optimization/hillclimbing/cross-top-one)
!(import! &self ../../optimization/hillclimbing/cross-top-one-helpers)
!(import! &self ../../optimization/hillclimbing/hill-climbing-helpers)

!(import! &self ../../metapopulation/exemplar-type)
!(import! &self ../../metapopulation/exemplar-selection)
!(import! &self ../../metapopulation/metapopulation)

!(import! &self ../../feature-selection/feature-selection-helpers)
!(import! &self ../../feature-selection/feature-selection-main)
!(import! &self ../../feature-selection/select-top-features)
!(import! &self ../../feature-selection/similarity-scorers)
!(import! &self ../../feature-selection/simple)
!(import! &self ../../feature-selection/smd)
!(import! &self ../../feature-selection/incremental)
!(import! &self ../../feature-selection/hc)
!(import! &self ../../feature-selection/random-feature-selection)

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

; (= (APPEND_CHILD $tree $nodeId $child ) (py_appendChild $tree $nodeId $child))

; (= (GetByID $tree $nodeId) (py_getById $tree $nodeId))
; (= (INSERT_ABOVE $tree $nodeId $subtree) (py_insertAbove  $tree $nodeId $subtree))
; (= (pyExprToList $expr) (py_exprToList $expr))

(= (deme) (mkDeme (mkRep (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (1)) 0) (ConsMap ((mkNodeId (2)) 1) NilMap))) (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob  (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) NilMMap)))) (mkTree (mkNode AND) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) Nil)))) (mkSInstSet Nil) (mkDemeId "1")))
(= (table1) (eval (createTruthTableBScore 2 (mkITable
                         (Cons (Cons False (Cons False (Cons False Nil))) 
                         (Cons (Cons True (Cons False (Cons False Nil))) 
                         (Cons (Cons False (Cons True (Cons False Nil)))
                         (Cons (Cons True (Cons True (Cons True Nil))) Nil))))
                         (Cons A (Cons B (Cons O Nil)))))))

(= (ttable1) (mkITable
                         (Cons (Cons False (Cons False (Cons False Nil))) 
                         (Cons (Cons True (Cons False (Cons False Nil))) 
                         (Cons (Cons False (Cons True (Cons False Nil)))
                         (Cons (Cons True (Cons True (Cons True Nil))) Nil))))
                         (Cons A (Cons B (Cons O Nil)))))                         

(= (ortable) (eval (createTruthTableBScore 2 (mkITable
                         (Cons (Cons False (Cons False (Cons False Nil))) 
                         (Cons (Cons True (Cons False (Cons True Nil))) 
                         (Cons (Cons False (Cons True (Cons True Nil)))
                         (Cons (Cons True (Cons True (Cons True Nil))) Nil))))
                         (Cons A (Cons B (Cons O Nil)))))))

(= (orttable) (mkITable
                         (Cons (Cons False (Cons False (Cons False Nil))) 
                         (Cons (Cons True (Cons False (Cons True Nil))) 
                         (Cons (Cons False (Cons True (Cons True Nil)))
                         (Cons (Cons True (Cons True (Cons True Nil))) Nil))))
                         (Cons A (Cons B (Cons O Nil))))) 

(= (metaPop2) (ConsOS (mkExemplar (mkTree (mkNode AND) Nil) (mkDemeId "1") (eval (worstCscore)) (mkBScore (Cons 0 (Cons 0 Nil)))) NilOS)) 

(= (metaPop) (ConsOS (mkExemplar (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil))) (mkDemeId "1") (mkCscore -0.2 1 0.1 0.1 -0.4) (mkBScore (Cons 0 (Cons 0 (Cons 0 (Cons 0 Nil))))))
                 (ConsOS (mkExemplar (mkTree (mkNode OR) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (Cons 0 (Cons 0 (Cons 0 (Cons 0 Nil)))))) 
                 NilOS)))
       
(= (bigtable) (mkITable
                        (Cons (Cons True  (Cons False (Cons True  (Cons False (Cons True  (Cons True  Nil))))))
                        (Cons (Cons False (Cons True  (Cons True  (Cons False (Cons False (Cons False Nil))))))
                        (Cons (Cons True  (Cons True  (Cons False (Cons True  (Cons True  (Cons True  Nil))))))
                        (Cons (Cons False (Cons False (Cons True  (Cons True  (Cons False (Cons False Nil))))))
                        (Cons (Cons True  (Cons False (Cons False (Cons True  (Cons True  (Cons True  Nil))))))
                        (Cons (Cons False (Cons True  (Cons False (Cons False (Cons False (Cons False Nil))))))
                        (Cons (Cons True  (Cons True  (Cons True  (Cons False (Cons True  (Cons True  Nil))))))
                        (Cons (Cons False (Cons False (Cons False (Cons True  (Cons False (Cons False Nil))))))
                        (Cons (Cons True  (Cons True  (Cons False (Cons False (Cons True  (Cons True  Nil))))))
                        (Cons (Cons False (Cons True  (Cons True  (Cons True  (Cons False (Cons False Nil))))))
                        (Cons (Cons True  (Cons False (Cons True  (Cons True  (Cons True  (Cons True  Nil))))))
                        (Cons (Cons False (Cons False (Cons False (Cons False (Cons False (Cons False Nil))))))
                        (Cons (Cons True  (Cons True  (Cons True  (Cons True  (Cons True  (Cons True  Nil))))))
                        (Cons (Cons False (Cons False (Cons True  (Cons False (Cons False (Cons False Nil))))))
                        (Cons (Cons True  (Cons False (Cons False (Cons False (Cons True  (Cons True  Nil))))))
                        (Cons (Cons False (Cons True  (Cons False (Cons True  (Cons False (Cons False Nil)))))) Nil))))))))))))))))
                        
                        (Cons A (Cons B (Cons C (Cons D (Cons E (Cons T Nil))))))))                     
;; truthTableBScore for  bigtable
(= (bigtablet) (eval (createTruthTableBScore 2 (bigtable))))                        

(= (bigtable2) (mkITable
                        (Cons (Cons True  (Cons False (Cons True  (Cons False (Cons True  (Cons True  Nil))))))
                        (Cons (Cons False (Cons True  (Cons False (Cons True  (Cons False (Cons False Nil))))))
                        (Cons (Cons True  (Cons True  (Cons True  (Cons False (Cons False (Cons True  Nil))))))
                        (Cons (Cons False (Cons False (Cons True  (Cons True  (Cons True  (Cons True  Nil))))))
                        (Cons (Cons True  (Cons False (Cons False (Cons True  (Cons True  (Cons False Nil))))))
                        (Cons (Cons False (Cons True  (Cons True  (Cons True  (Cons False (Cons True  Nil))))))
                        (Cons (Cons True  (Cons True  (Cons False (Cons False (Cons True  (Cons True  Nil))))))
                        (Cons (Cons False (Cons False (Cons False (Cons True  (Cons False (Cons False Nil))))))
                        (Cons (Cons True  (Cons True  (Cons True  (Cons True  (Cons True  (Cons True  Nil))))))
                        (Cons (Cons False (Cons True  (Cons False (Cons False (Cons True  (Cons False Nil))))))
                        (Cons (Cons True  (Cons False (Cons True  (Cons True  (Cons False (Cons True  Nil))))))
                        (Cons (Cons False (Cons False (Cons True  (Cons False (Cons True  (Cons False Nil))))))
                        (Cons (Cons True  (Cons True  (Cons False (Cons True  (Cons False (Cons True  Nil))))))
                        (Cons (Cons False (Cons True  (Cons True  (Cons False (Cons True  (Cons True  Nil))))))
                        (Cons (Cons True  (Cons False (Cons False (Cons False (Cons False (Cons False Nil))))))
                        (Cons (Cons False (Cons False (Cons False (Cons True  (Cons True  (Cons True  Nil)))))) Nil))))))))))))))))

                        (Cons A (Cons B (Cons C (Cons D (Cons E (Cons T Nil))))))))

; (= (bigtablet2) (createTruthTableBScore 2 bigtable2))                        

; (: isScored (-> (ScoredInstance Cscore) Bool))
(= (isScored (mkSInst (mkPair $instance $score))) (~= $score (eval (worstCscore))))

; Testcase for optimizeDemes               
; 

; ; with OR table and AND init exemplar     
; !(runMoses 7 (mkCscore -0.1 2 0.1 0.1 3) 3 (metaPop) 0 2 
;     False    ;; the new arguments for prune-exemplar -- we are saying dont prune the exemplar
;     smd      ;; the new arguments for feature selection algo
;     (eval (createTruthTableBScore 2 (mkITable
;                          (Cons (Cons False (Cons False (Cons False Nil))) 
;                          (Cons (Cons True (Cons False (Cons True Nil))) 
;                          (Cons (Cons False (Cons True (Cons True Nil)))
;                          (Cons (Cons True (Cons True (Cons True Nil))) Nil))))
;                          (Cons A (Cons B (Cons O Nil)))))) 
;     hillClimbing 
;     5 2 0 1 
;     (mkITable
;                          (Cons (Cons False (Cons False (Cons False Nil))) 
;                          (Cons (Cons True (Cons False (Cons True Nil))) 
;                          (Cons (Cons False (Cons True (Cons True Nil)))
;                          (Cons (Cons True (Cons True (Cons True Nil))) Nil))))
;                          (Cons A (Cons B (Cons O Nil)))) 
;     3 0.004 1000)
; ; with OR table and AND init exemplar     
; !(runMoses 7 (mkCscore -0.1 2 0.1 0.1 3) 3 (metaPop) 0 2 
;     False    ;; the new arguments for prune-exemplar -- we are saying dont prune the exemplar
;     smd      ;; the new arguments for feature selection algo
;     (eval (createTruthTableBScore 2 (mkITable
;                           (Cons (Cons False (Cons False (Cons False Nil))) 
;                           (Cons (Cons True (Cons False (Cons True Nil))) 
;                           (Cons (Cons False (Cons True (Cons True Nil)))
;                           (Cons (Cons True (Cons True (Cons True Nil))) Nil))))
;                           (Cons A (Cons B (Cons O Nil))))))  
;     hillClimbing 
;     5 2 0 1 
;     (mkITable
;                           (Cons (Cons False (Cons False (Cons False Nil))) 
;                           (Cons (Cons True (Cons False (Cons True Nil))) 
;                           (Cons (Cons False (Cons True (Cons True Nil)))
;                           (Cons (Cons True (Cons True (Cons True Nil))) Nil))))
;                           (Cons A (Cons B (Cons O Nil))))  
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

;; Tests for Game Strategy Functions

; Create initial strategy metapop
; (= (strategyMetaPop)
;    (ConsOS
;      (mkExemplar
;        (mkTree (mkNode PRIORITIZED-OR)
;          (Cons (mkTree (mkNode playwin) Nil)
;                (Cons (mkTree (mkNode playblock) Nil) Nil)))
;        (mkDemeId "0")
;        (mkBScore (Cons -1.0 Nil))
;        (mkBScore (Cons 0.0 Nil)))
;      NilOS))

; !(assertEqual
;    (let*
;      (
;        ($optimizedDemes (expandDemeStrategy (strategyMetaPop) 0 1 1 random-player hillClimbingStrategy))
;        ($demeCount (size-atom $optimizedDemes))
;      )
;      (>= $demeCount 1))
;    True)

; !(assertEqual
;    (let*
;      (
;        ($result (runMosesStrategy 1 1.0 3 (strategyMetaPop) 0 1 1 random-player hillClimbingStrategy 5 2 0 3))
;        ($resultSize (eval (OS.length $result)))
;      )
;      (>= $resultSize 1))
;    True)
;
;; Empty strategy metapop -  empty PRIORITIZED-OR with worst CScore
(= (emptyStrategyMetaPop)
   (ConsOS
     (mkExemplar
       (mkTree (mkNode PRIORITIZED-OR) Nil)  ;;  empty - no children
       (mkDemeId "0")
       (eval (worstCscore))  ;; Worst CScore
       (mkBScore (Cons -10000.0 Nil)))  ;; Worst BScore (very negative, not empty)
     NilOS))

;; Test runMosesStrategy - evolve from empty strategy
;; Target: 10 wins out of 10 games (100% win rate)
;; Calculation: 10 wins - (5 moves × 0.286) = 10 - 1.43 ≈ 8.57 penalized score
!(runMosesStrategy 
    2                             ;; maxGen - 10 generations (more exploration)
    (mkCscore 10.0 5 1.43 0.0 8.57) ;; Target: 10/10 wins, complexity≤5, penalized≥8.57
    3                              ;; maxCandOutput - return top 3 strategies
    (emptyStrategyMetaPop)         ;; metaPop - start with empty strategy
    0                              ;; nExpansion - generation counter
    1                              ;; nDeme - 3 demes (more diversity)
    10                             ;; nGames - 10 games per evaluation
    random-player                  ;; opponentPolicy - opponent
    3.5                            ;; complexityRatio - standard penalty (coef≈0.286)
    hillClimbingStrategy           ;; optimize - optimizer function
    30                             ;; nEval - not used
    5                              ;; maxCandsPerDeme - top 5 per deme
    2                              ;; minPoolSize - min deme size
    1.0                            ;; complexityTemperature - for trimming
    5                              ;; nToKeep - keep top 5
    0.004                          ;; capCoef - capacity coefficient
    1000)                          ;; genCount - generation count


;; Test evolved strategy by playing a single game
;; Top strategy from evolution: (PRIORITIZED-OR (PRIORITIZED-OR playblock playcenter))
; (= (topStrategy) 
;    (mkTree (mkNode PRIORITIZED-OR) 
;       (Cons (mkTree (mkNode PRIORITIZED-OR)
;          (Cons (mkTree (mkNode playblock) Nil)
;                (Cons (mkTree (mkNode playcenter) Nil) Nil)))
;       Nil)))

; ;; Play one game with the evolved strategy vs random-player
; !(play-game (PRIORITIZED-OR (PRIORITIZED-OR playblock playcenter)) random-player)


;; Initial strategy with 3 key moves - good starting point
;; Note: Scores are placeholders - expandDemeStrategy immediately rescores before use
; (= (threeMovesStrategyMetaPop)
;    (ConsOS
;      (mkExemplar
;        (mkTree (mkNode PRIORITIZED-OR)
;          (Cons (mkTree (mkNode playwin) Nil)
;          (Cons (mkTree (mkNode playblock) Nil)
;          (Cons (mkTree (mkNode playside) Nil) Nil))))
;        (mkDemeId "0")
;        (mkCscore 0.0 0 0.0 0.0 0.0)  ;; Placeholder - gets rescored immediately
;        (mkBScore (Cons 0.0 Nil)))     ;; Placeholder - gets rescored immediately
;      NilOS))

; ;; Test with 3-move initial strategy
; !(runMosesStrategy 
;     10                          ;; maxGen - 10 generations
;     (mkCscore 5.0 10 5.0 0.0 0.0)  ;; maxCScore
;     2                           ;; maxCandOutput - return top 2
;     (threeMovesStrategyMetaPop) ;; metaPop - start with 3 moves
;     0                           ;; nExpansion
;     2                           ;; nDeme - 2 demes per expansion
;     50                          ;; nGames - 50 games for stable scores
;     random-player               ;; opponentPolicy
;     0.5                         ;; complexityRatio - low penalty
;     hillClimbingStrategy        ;; optimize
;     30                          ;; nEval
;     5                           ;; maxCandsPerDeme
;     2                           ;; minPoolSize
;     1.0                         ;; complexityTemperature
;     5                           ;; nToKeep
;     0.004                       ;; capCoef
;     1000)                       ;; genCount
;!(play-game (PRIORITIZED-OR (PRIORITIZED-OR playblock playcenter)) random-player) 
;; Test getCandidate to see what tree structure it produces

;; First, create a simple representation with 3 options
;; This simulates what generation 0 creates
(= (testRepTree)
   (mkTree (mkNode PRIORITIZED-OR)
      (Cons (mkNullVex (mkTree (mkNode playwin) Nil))
      (Cons (mkNullVex (mkTree (mkNode playblock) Nil))
      (Cons (mkNullVex (mkTree (mkNode playcenter) Nil)) Nil)))))

;; Create a mock representation with knobs
;; Assume we have 3 binary knobs at positions 0, 1, 2
(= (testRep)
   (mkRep 
      (mkKbMap 
         (mkDscKbMp NilMap)  ;; Empty for simplicity
         (mkDscMp 
            (ConsMMap ((mkDiscSpec 0) (mkSSK (mkDiscKnob (mkKnob (mkNodeId (11))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil)))
            (ConsMMap ((mkDiscSpec 0) (mkSSK (mkDiscKnob (mkKnob (mkNodeId (12))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil)))
            (ConsMMap ((mkDiscSpec 0) (mkSSK (mkDiscKnob (mkKnob (mkNodeId (13))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) NilMMap)))))
      (testRepTree)))

; ;; Test instance 1: All zeros (all options wrapped/inactive)
; !(println! "=== Test 1: Instance (0 0 0) - all inactive ===")
; !(let $result (eval (getCandidate (testRep) (mkInst (Cons 0 (Cons 0 (Cons 0 Nil))))))
;    (println! $result))

; ;; Test instance 2: First option active (1 0 0)
; !(println! "=== Test 2: Instance (1 0 0) - first active ===")
; !(let $result (eval (getCandidate (testRep) (mkInst (Cons 1 (Cons 0 (Cons 0 Nil))))))
;    (println! $result))

; ;; Test instance 3: First and third active (1 0 1)
; !(println! "=== Test 3: Instance (1 0 1) - first and third active ===")
; !(let $result (eval (getCandidate (testRep) (mkInst (Cons 1 (Cons 0 (Cons 1 Nil))))))
;    (println! $result))

; ;; Test instance 4: All active (1 1 1)
; !(println! "=== Test 4: Instance (1 1 1) - all active ===")
; !(let $result (eval (getCandidate (testRep) (mkInst (Cons 1 (Cons 1 (Cons 1 Nil))))))
;    (println! $result))
!(getCandidate (testRep) (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))))