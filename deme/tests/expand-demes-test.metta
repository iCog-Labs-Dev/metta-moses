!(import! &self ../../utilities/general-helpers)
!(import! &self ../../parameters/registry)
!(import! &self ../../parameters/defaults)
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
!(import! &self ../../feature-selection/incremental-feature-selection)
!(import! &self ../../feature-selection/hc)
!(import! &self ../../feature-selection/random-feature-selection)
!(import! &self ../../feature-selection/feature-selection-main)

!(import! &self ../../scoring/action-registry)
!(import! &self ../../representation/knob-representation)
!(import! &self ../../representation/lsk)
!(import! &self ../../representation/disc-probe)
!(import! &self ../../representation/logical-probe)
!(import! &self ../../representation/logical-canonize)
!(import! &self ../../representation/sample-logical-perms)
!(import! &self ../../representation/add-logical-knobs)
!(import! &self ../../representation/build-logical)
!(import! &self ../../representation/build-knobs)
!(import! &self ../../representation/knob-mapper)

!(import! &self ../../representation/representation)
!(import! &self ../../representation/create-representation)

!(import! &self ../../examples/tic-tac-toe/tic-tac-toe-helpers)
!(import! &self ../../examples/tic-tac-toe/random-player)
!(import! &self ../../examples/tic-tac-toe/minimax-player)
!(import! &self ../../examples/tic-tac-toe/moves)

!(import! &self ../../scoring/cacheSpace)
!(import! &self ../../scoring/fitness)
!(import! &self ../../scoring/boolean-ops)
!(import! &self ../../scoring/bscore)
!(import! &self ../../scoring/cscore)
!(import! &self ../../scoring/complexity-based-scorer)

!(import! &self ../../optimization/hillclimbing/crossover-helpers)
!(import! &self ../../optimization/hillclimbing/crossover)
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

 !(callPredicate (Predicate (consult "moses/tests/rte-helpers-fast.pl")))

(= (deme) (mkDeme (mkRep (mkKbMap (mkDscMp (((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())))))) (mkTree (mkNode AND) (cons (mkKnob (mkNullVex (cons (mkTree (mkNode A) ()) ())) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 0) (cons (mkKnob (mkNullVex (cons (mkTree (mkNode B) ()) ())) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 1) ())))) (mkSInstSet ()) (mkDemeId "1")))
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

;; The original tests passed `5 2 0 1 3 0.004 1000` (and
;; `maxCandOutput=3`). Test 4 nudges minPoolSize from 0 to 2 just before
;; its call.
!(set-param maxCandOutput 3)
!(set-param nEval 5)
!(set-param maxCandPerDeme 2)
!(set-param minPoolSize 0)
!(set-param complexityTemperature 1)
!(set-param nToKeep 3)
!(set-param capCoef 0.004)
!(set-param genCount 1000)

;; Testcase for runMoses
!(assertEqual
(let*
(
    ($_ (println! (running started)))
    ($topCandidates (runMoses 2 0 (metaPop2) 0 2 (False sim
    (table1)
    (ttable1))
    hillClimbing))
    ($topCandidatesLength (OS.length $topCandidates))
)
(>= $topCandidatesLength 1)
) True)

;; Testcase for runMoses
!(assertEqual
(let*
(
    ($topCandidates (runMoses 1 0 (metaPop2) 0 2 (False rd
    (table1)
    (ttable1))
    hillClimbing))
    ($topCandidatesLength (OS.length $topCandidates))
)
(>= $topCandidatesLength 1)
) True)

;; Testcase for runMoses
!(assertEqual
(let*
(
    ($topCandidates (runMoses 1 0 (metaPop2) 0 2 (False inc
    (table1)
    (ttable1))
    hillClimbing))
    ($topCandidatesLength (OS.length $topCandidates))
)
(>= $topCandidatesLength 1)
) True)

;; Testcase 2 for runmoses.
;; When maxGen become 10, test number of returned instances is not greater than maxCandOutput,
;;              where maxCandOutput is 3 and minPoolSize is 2
!(set-param minPoolSize 2)
!(assertEqual
(let $length
((OS.length (runMoses 10 0 (metaPop2) 0 2
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
    hillClimbing)
    ))
        (> $length 3)
)
    False
)
;; ; ; with OR table and AND init exemplar     
;; ; !(runMoses 7 1 3 (metaPop) 0 2 
;; ;     False    ;; the new arguments for prune-exemplar -- we are saying dont prune the exemplar
;; ;     smd      ;; the new arguments for feature selection algo
;; ;     (eval (createTruthTableBScore 2 (mkITable
;; ;                          (cons (cons False (cons False (cons False ()))) 
;; ;                          (cons (cons True (cons False (cons True ()))) 
;; ;                          (cons (cons False (cons True (cons True ())))
;; ;                          (cons (cons True (cons True (cons True ()))) ()))))
;; ;                          (cons A (cons B (cons O ())))))) 
;; ;     hillClimbing 
;; ;     5 2 0 1 
;; ;     (mkITable
;; ;                          (cons (cons False (cons False (cons False ()))) 
;; ;                          (cons (cons True (cons False (cons True ()))) 
;; ;                          (cons (cons False (cons True (cons True ())))
;; ;                          (cons (cons True (cons True (cons True ()))) ()))))
;; ;                          (cons A (cons B (cons O ())))) 
;; ;     3 0.004 1000)
;; ; ; with OR table and AND init exemplar     
;; ; !(runMoses 7 1 3 (metaPop) 0 2 
;; ;     False    ;; the new arguments for prune-exemplar -- we are saying dont prune the exemplar
;; ;     smd      ;; the new arguments for feature selection algo
;; ;     (eval (createTruthTableBScore 2 (mkITable
;; ;                           (cons (cons False (cons False (cons False ()))) 
;; ;                           (cons (cons True (cons False (cons True ()))) 
;; ;                           (cons (cons False (cons True (cons True ())))
;; ;                           (cons (cons True (cons True (cons True ()))) ()))))
;; ;                           (cons A (cons B (cons O ()))))))  
;; ;     hillClimbing 
;; ;     5 2 0 1 
;; ;     (mkITable
;; ;                           (cons (cons False (cons False (cons False ()))) 
;; ;                           (cons (cons True (cons False (cons True ()))) 
;; ;                           (cons (cons False (cons True (cons True ())))
;; ;                           (cons (cons True (cons True (cons True ()))) ()))))
;; ;                           (cons A (cons B (cons O ()))))  
;; ;     3 0.004 1000)
;;
;; ; !(runMoses 1 1 3 (metaPop2) 0 2 
;; ;     False    ;; the new arguments for prune-exemplar -- we are saying dont prune the exemplar
;; ;     smd      ;; the new arguments for feature selection algo
;; ;     (eval (createTruthTableBScore 2 
;; ;     (bigtable)))
;; ;     hillClimbing 
;; ;     5 2 0 1 
;; ;     (bigtable) 
;; ;     3 0.004 1000)
;;
;; ;; Parameters:
;;   ;; $maxGen $maxScore $maxCandOutput $metaPop $nExpansion $nDeme
;;   ;; $prune-exemplar
;;   ;; $fs-algo
;;   ;; $truthTableBScore
;;   ;; $optimize
;;   ;; $nEval $maxCandsPerDeme $minPoolSize $complexityTemperature
;;   ;; $itable
;;   ;; $nToKeep $capCoef $genCount
;;
;; ;; The following configuration can result to XOR.
;; ;; A⊕B=(A∨B)∧¬(A∧B)
;; ;; (AND (OR A B) (OR (NOT A) (NOT B)))
;; ;; A⊕B=(¬A∧B)∨(A∧¬B)
;; ;; (AND (OR (AND A (NOT B)) (AND (NOT A) B)))
;; ;; !(let*
;; ;;    (
;; ;;     ($result (runMoses 20 1 10 (metaPop2) 0 2
;; ;;                   False    ;; the new arguments for prune-exemplar -- we are saying dont prune the exemplar
;; ;;                   smd      ;; the new arguments for feature selection algo
;; ;;                   (eval (createTruthTableBScore 2 (xortable)))
;; ;;                   hillClimbing
;; ;;                   100 10 20 2
;; ;;                   (xortable)
;; ;;                   10 0.004 1000))
;; ;;     ($nt (println! ""))
;; ;;     ($newR (mapG cleanedExemplar $result))
;; ;;     ($_ (mapG printExemplar $result))
;; ;;    )
;; ;;    $newR
;; ;;  )
;; ;;
