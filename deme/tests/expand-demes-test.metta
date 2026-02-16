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
!(import! &self ../../representation/sample-logical-perms)
!(import! &self ../../representation/add-logical-knobs)
!(import! &self ../../representation/build-logical)
!(import! &self ../../representation/build-knobs)
!(import! &self ../../representation/knob-mapper)

!(import! &self ../../representation/representation)
!(import! &self ../../representation/create-representation)

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

(= (xortable) (mkITable
                         (Cons (Cons False (Cons False (Cons False Nil))) 
                         (Cons (Cons True (Cons False (Cons True Nil))) 
                         (Cons (Cons False (Cons True (Cons True Nil)))
                         (Cons (Cons True (Cons True (Cons False Nil))) Nil))))
                         (Cons A (Cons B (Cons O Nil)))))

;; (= (metaPop2) (ConsOS (mkExemplar (mkTree (mkNode AND) Nil) (mkDemeId "1") (eval (worstCscore)) (mkBScore (Cons -1 (Cons -1 Nil)))) NilOS))
;; (= (metaPop2) (ConsOS (mkExemplar (mkTree (mkNode AND) Nil) (mkDemeId "1") (eval (worstCscore)) (mkBScore (Cons -1 (Cons -1 (Cons -1 (Cons -1 Nil)))))) NilOS))
(= (metaPop2) (ConsOS (mkExemplar (mkTree (mkNode AND) Nil) (mkDemeId "1") (mkCscore -4 2 1.0 0.0 -4.0) (mkBScore  (Cons -1 (Cons -1 (Cons -1 (Cons -1 Nil)))))) NilOS))

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

;; Testcase for optimizeDemes               
!(assertEqual 
(let* 
(
    ($optimizeDemesReturn (optimizeDemes (deme) 
                (table1) 
                (mkInst (Cons 0 (Cons 0 Nil))) 
                hillClimbing
                ))
    ($_ (println! "optimizeDemes Returns"))
    ($_ (println! $optimizeDemesReturn))
    (($instance (mkDeme $rep (mkSInstSet $instSet) $id) $state) $optimizeDemesReturn)
    ($instanceCount (eval (List.length $instSet)))
    ($scoredElems (eval (List.map isScored $instSet)))
)
((>= $instanceCount 4) (eval (List.any $scoredElems))))
(True True))

; Testcase for expandDeme
!(assertEqual
(let*
(
    ($updatedDeme (expandDeme (metaPop2) 0 1 False sim 
                    (table1)
                    hillClimbing 
                    (ttable1)
                    mi))
    ($updatedDemeLength (size-atom $updatedDeme)))
(>= $updatedDemeLength 1)) True)

; Testcase for runMoses
!(assertEqual
(let*
(
    ($topCandidates (runMoses 2 (mkCscore -0.1 2 0.1 0.1 3) 3 (metaPop2) 0 2 False sim 
    (table1) 
    hillClimbing 5 2 0 1 
    (ttable1) 
    3 0.004 1000))
    ($topCandidatesLength (eval (OS.length $topCandidates)))
)
(>= $topCandidatesLength 1)
) True)

; ; Testcase for runMoses
!(assertEqual
(let*
(
    ($topCandidates (runMoses 1 (mkCscore -0.1 2 0.1 0.1 3) 3 (metaPop2) 0 2 False rd 
    (table1)  
    hillClimbing 5 2 0 1 
    (ttable1) 
    3 0.004 1000))
    ($topCandidatesLength (OS.length $topCandidates))
)
(>= $topCandidatesLength 1)
) True)

; ;; Testcase for runMoses
!(assertEqual
(let*
(
    ($topCandidates (runMoses 1 (mkCscore -0.1 2 0.1 0.1 3) 3 (metaPop2) 0 2 False inc 
    (table1) 
    hillClimbing 5 2 0 1 
    (ttable1)
    3 0.004 1000))
    ($topCandidatesLength (eval (OS.length $topCandidates)))
)
(>= $topCandidatesLength 1)
) True)

;; Testcase 2 for runmoses. 
;; When maxGen become 10, test number of returned instances is not greater than maxCandOutput, 
;;              where maxCandOutput is 3 and minPoolSize is 2
!(assertEqual
(let $length
(OS.length (runMoses 10 (mkCscore -0.1 2 0.1 0.1 3) 3 (metaPop2) 0 2 
    False    ;; the new arguments for prune-exemplar -- we are saying dont prune the exemplar
    inc      ;; the new arguments for feature selection algo
    (eval (createTruthTableBScore 2 (mkITable
                          (Cons (Cons False (Cons False (Cons False Nil))) 
                          (Cons (Cons True (Cons False (Cons False Nil))) 
                          (Cons (Cons False (Cons True (Cons False Nil)))
                          (Cons (Cons True (Cons True (Cons True Nil))) Nil))))
                          (Cons A (Cons B (Cons O Nil))))))  
    hillClimbing 5 2 2 1 
    (mkITable
                          (Cons (Cons False (Cons False (Cons False Nil))) 
                          (Cons (Cons True (Cons False (Cons False Nil))) 
                          (Cons (Cons False (Cons True (Cons False Nil)))
                          (Cons (Cons True (Cons True (Cons True Nil))) Nil))))
                          (Cons A (Cons B (Cons O Nil))))  
    3 0.004 1000)
    )
        (> $length 3)
)
    False
)

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
