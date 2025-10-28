! (register-module! ../../../metta-moses)

! (import! &self metta-moses:reduct/boolean-reduct:rte-helpers)
! (import! &self metta-moses:reduct/boolean-reduct:cut-unnecessary-or)
! (import! &self metta-moses:reduct/boolean-reduct:cut-unnecessary-and)
! (import! &self metta-moses:reduct/boolean-reduct:n-ary-propagate-not)
! (import! &self metta-moses:reduct/boolean-reduct:n-ary-gather-junctors)
! (import! &self metta-moses:reduct/boolean-reduct:delete-inconsistent-handle)
! (import! &self metta-moses:reduct/boolean-reduct:zero-constraint-subsumption)
! (import! &self metta-moses:reduct/boolean-reduct:one-constraint-subsumption)
! (import! &self metta-moses:reduct/boolean-reduct:promote-common-constraints)
! (import! &self metta-moses:reduct/boolean-reduct:reduce-to-elegance)

!(import! &self metta-moses:representation:lsk)
!(import! &self metta-moses:representation:instance)
!(import! &self metta-moses:representation:build-knobs)
!(import! &self metta-moses:representation:knob-mapper)
!(import! &self metta-moses:representation:logical-probe) 
!(import! &self metta-moses:representation:build-logical)
!(import! &self metta-moses:representation:representation)
!(import! &self metta-moses:representation:add-logical-knobs)
!(import! &self metta-moses:representation:knob-representation)
!(import! &self metta-moses:representation:sample-logical-perms)
!(import! &self metta-moses:representation:create-representation)

!(import! &self metta-moses:utilities:map)
!(import! &self metta-moses:utilities:tree)
!(import! &self metta-moses:utilities:pair) 
!(import! &self metta-moses:utilities:nodeId)
!(import! &self metta-moses:utilities:list-methods)
!(import! &self metta-moses:utilities:python-helpers)
!(import! &self metta-moses:utilities:python-treehelpers)
!(import! &self metta-moses:utilities:general-helpers)
!(import! &self metta-moses:utilities:ordered-multimap)
!(import! &self metta-moses:utilities:ordered-multiset)
!(import! &self metta-moses:utilities:ordered-set)
!(import! &self metta-moses:utilities:lazy-random-selector)
!(import! &self metta-moses:utilities:lru-cache)

; !(import! &self metta-moses:reduct:enf)

!(import! &self metta-moses:deme:score-deme)
!(import! &self metta-moses:deme:create-deme)
!(import! &self metta-moses:deme:deme-id-creation)
!(import! &self metta-moses:deme:expand-deme)
!(import! &self metta-moses:deme:merge-demes)

!(import! &self metta-moses:scoring:cscore)
!(import! &self metta-moses:scoring:bscore)
!(import! &self metta-moses:scoring:fitness)
!(import! &self metta-moses:scoring:complexity-based-scorer)
!(import! &self metta-moses:scoring:cacheSpace)

!(import! &self metta-moses:moses:neighborhood-sampling)

!(import! &self metta-moses:optimization/hillclimbing:cross-top-one)
!(import! &self metta-moses:optimization/hillclimbing:cross-top-one-helpers)
!(import! &self metta-moses:optimization/hillclimbing:hill-climbing-helpers)
! (import! &self metta-moses:metapopulation:exemplar-type)
! (import! &self metta-moses:metapopulation:exemplar-selection)
! (import! &self metta-moses:metapopulation:metapopulation)

!(import! &self metta-moses:feature-selection:feature-selection-helpers)
!(import! &self metta-moses:feature-selection:feature-selection-main)
!(import! &self metta-moses:feature-selection:select-top-features)
!(import! &self metta-moses:feature-selection:similarity-scorers)
!(import! &self metta-moses:feature-selection:simple)
!(import! &self metta-moses:feature-selection:smd)
!(import! &self metta-moses:feature-selection:incremental)
!(import! &self metta-moses:utilities:lru-cache)
!(import! &self metta-moses:feature-selection:hc)
!(import! &self metta-moses:feature-selection:random-feature-selection)


(= (APPEND_CHILD $tree $nodeId $child ) (py_appendChild $tree $nodeId $child))

(= (GetByID $tree $nodeId) (py_getById $tree $nodeId))
(= (INSERT_ABOVE $tree $nodeId $subtree) (py_insertAbove  $tree $nodeId $subtree))
(= (pyExprToList $expr) (py_exprToList $expr))

!(bind! deme (mkDeme (mkRep (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (1)) 0) (ConsMap ((mkNodeId (2)) 1) NilMap))) (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob  (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) NilMMap)))) (mkTree (mkNode AND) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) Nil)))) (mkSInstSet Nil) (mkDemeId "1")))
!(bind! table (createTruthTableBScore 2 (mkITable
                         (Cons (Cons False (Cons False (Cons False Nil))) 
                         (Cons (Cons True (Cons False (Cons False Nil))) 
                         (Cons (Cons False (Cons True (Cons False Nil)))
                         (Cons (Cons True (Cons True (Cons True Nil))) Nil))))
                         (Cons A (Cons B (Cons O Nil))))))

! (bind! ttable1 (mkITable
                         (Cons (Cons False (Cons False (Cons False Nil))) 
                         (Cons (Cons True (Cons False (Cons False Nil))) 
                         (Cons (Cons False (Cons True (Cons False Nil)))
                         (Cons (Cons True (Cons True (Cons True Nil))) Nil))))
                         (Cons A (Cons B (Cons O Nil)))))                         

!(bind! ortable (createTruthTableBScore 2 (mkITable
                         (Cons (Cons False (Cons False (Cons False Nil))) 
                         (Cons (Cons True (Cons False (Cons True Nil))) 
                         (Cons (Cons False (Cons True (Cons True Nil)))
                         (Cons (Cons True (Cons True (Cons True Nil))) Nil))))
                         (Cons A (Cons B (Cons O Nil))))))

! (bind! orttable (mkITable
                         (Cons (Cons False (Cons False (Cons False Nil))) 
                         (Cons (Cons True (Cons False (Cons True Nil))) 
                         (Cons (Cons False (Cons True (Cons True Nil)))
                         (Cons (Cons True (Cons True (Cons True Nil))) Nil))))
                         (Cons A (Cons B (Cons O Nil))))) 

! (bind! metaPop2 (ConsOS (mkExemplar (mkTree (mkNode AND) Nil) (mkDemeId "1") (worstCscore) (mkBScore (Cons 0 (Cons 0 Nil)))) NilOS)) 

! (bind! metaPop (ConsOS (mkExemplar (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil))) (mkDemeId "1") (mkCscore -0.2 1 0.1 0.1 -0.4) (mkBScore (Cons 0 (Cons 0 Nil))))
                 (ConsOS (mkExemplar (mkTree (mkNode OR) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (Cons 0 (Cons 0 Nil)))) 
                 NilOS)))
       
! (bind! bigtable (mkITable
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
! (bind! bigtablet (createTruthTableBScore 2 bigtable))                        

! (bind! bigtable2 (mkITable
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

! (bind! bigtablet2 (createTruthTableBScore 2 bigtable2))                        

(: isScored (-> (ScoredInstance Cscore) Bool))
(= (isScored (mkSInst (mkPair $instance $score))) (~= $score (worstCscore)))


;; Testcase for optimizeDemes               
!(assertEqual 
(let* 
(
    ($optimizeDemesReturn (optimizeDemes deme table (mkInst (Cons 0 (Cons 0 Nil))) hillClimbing (applyComplexityBasedScore ())))
    (() (println! "optimizeDemes Returns"))
    (() (println! $optimizeDemesReturn))
    (($instance (mkDeme $rep (mkSInstSet $instSet) $id) $state) $optimizeDemesReturn)
    ($instanceCount (List.length $instSet))
    ($scoredElems (List.map isScored $instSet))
)
((>= $instanceCount 4) (List.any $scoredElems)))
(True True))

; Testcase for expandDeme
!(assertEqual
(let*
(
    ($updatedDeme (expandDeme metaPop2 0 1 False sim table hillClimbing (applyComplexityBasedScore mi) 5 2 0 1 ttable1 3 0.004 1000))
    ($updatedDemeLength (size-atom $updatedDeme))
)
(>= $updatedDemeLength 1)
) True)

;; Testcase for runMoses
!(assertEqual
(let*
(
    ($topCandidates (runMoses 1 (mkCscore -0.1 2 0.1 0.1 3) 3 metaPop2 0 2 False sim table hillClimbing (applyComplexityBasedScore mi) 5 2 0 1 ttable1 3 0.004 1000))
    ($topCandidatesLength (OS.length $topCandidates))
)
(>= $topCandidatesLength 1)
) True)
;; Testcase for runMoses
!(assertEqual
(let*
(
    ($topCandidates (runMoses 1 (mkCscore -0.1 2 0.1 0.1 3) 3 metaPop2 0 2 False rd table hillClimbing (applyComplexityBasedScore mi) 5 2 0 1 ttable1 3 0.004 1000))
    ($topCandidatesLength (OS.length $topCandidates))
)
(>= $topCandidatesLength 1)
) True)
; ;; Testcase for runMoses
!(assertEqual
(let*
(
    ($topCandidates (runMoses 1 (mkCscore -0.1 2 0.1 0.1 3) 3 metaPop2 0 2 False inc table hillClimbing (applyComplexityBasedScore mi) 5 2 0 1 ttable1 3 0.004 1000))
    ($topCandidatesLength (OS.length $topCandidates))
)
(>= $topCandidatesLength 1)
) True)

; ! (runMoses 2 (mkCscore -0.1 2 0.1 0.1 3) 3 metaPop2 0 2 
;     False    ;; the new arguments for prune-exemplar -- we are saying dont prune the exemplar
;     inc      ;; the new arguments for feature selection algo
;     table hillClimbing 5 2 0 1 ttable1 3 0.004 1000)

; ! (runMoses 2 (mkCscore -0.1 2 0.1 0.1 3) 3 metaPop2 0 2 
;     False    ;; the new arguments for prune-exemplar -- we are saying dont prune the exemplar
;     inc      ;; the new arguments for feature selection algo
;     table hillClimbing 5 2 0 1 ttable1 3 0.004 1000)

; with OR table and AND init exemplar     
; ! (runMoses 7 (mkCscore -0.1 2 0.1 0.1 3) 3 metaPop2 0 2 
;     False    ;; the new arguments for prune-exemplar -- we are saying dont prune the exemplar
;     smd      ;; the new arguments for feature selection algo
;     ortable hillClimbing 5 2 0 1 orttable 3 0.004 1000)
; with OR table and AND init exemplar     
; ! (runMoses 7 (mkCscore -0.1 2 0.1 0.1 3) 3 metaPop2 0 2 
;     False    ;; the new arguments for prune-exemplar -- we are saying dont prune the exemplar
;     smd      ;; the new arguments for feature selection algo
;     ortable hillClimbing 5 2 0 1 orttable 3 0.004 1000)


; ! (runMoses 1 (mkCscore -0.1 2 0.1 0.1 3) 3 metaPop2 0 2 
;     False    ;; the new arguments for prune-exemplar -- we are saying dont prune the exemplar
;     smd      ;; the new arguments for feature selection algo
;     bigtablet hillClimbing 5 2 0 1 bigtable 3 0.004 1000)
