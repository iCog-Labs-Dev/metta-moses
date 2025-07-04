! (register-module! ../../../metta-moses)
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

!(import! &self metta-moses:reduct:enf)

!(import! &self metta-moses:deme:score-deme)
!(import! &self metta-moses:deme:create-deme)
!(import! &self metta-moses:deme:deme-id-creation)
!(import! &self metta-moses:deme:expand-deme)
!(import! &self metta-moses:deme:merge-demes)

!(import! &self metta-moses:scoring:cscore)
!(import! &self metta-moses:scoring:bscore)
!(import! &self metta-moses:scoring:fitness)
!(import! &self metta-moses:scoring:complexity-based-scorer)

!(import! &self metta-moses:moses:neighborhood-sampling)

!(import! &self metta-moses:optimization:hillclimbing:cross-top-one)
!(import! &self metta-moses:optimization:hillclimbing:hill-climbing-helpers)
! (import! &self metta-moses:metapopulation:exemplar-type)
! (import! &self metta-moses:metapopulation:exemplar-selection)
! (import! &self metta-moses:metapopulation:metapopulation)

(= (ARGS) args) 

(= (APPEND_CHILD $tree $nodeId $child ) (py_appendChild $tree $nodeId $child))

(= (GetByID $tree $nodeId) (py_getById $tree $nodeId))
(= (INSERT_ABOVE $tree $nodeId $subtree) (py_insertAbove  $tree $nodeId $subtree))
(= (pyExprToList $expr) (py_exprToList $expr))

!(bind! demes (Cons (mkDeme (mkRep (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (1)) 0) (ConsMap ((mkNodeId (2)) 1) NilMap))) (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode AND) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) Nil)) (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode A) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode AND) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) Nil))) (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode B) Nil))) NilMMap)))) (mkTree (mkNode AND) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) Nil)))) (mkSInstSet Nil) (mkDemeId "1")) Nil))
!(bind! table (createTruthTableBScore 2 (mkITable
                         (Cons (Cons False (Cons False (Cons False Nil))) 
                         (Cons (Cons True (Cons False (Cons False Nil))) 
                         (Cons (Cons False (Cons True (Cons False Nil)))
                         (Cons (Cons True (Cons True (Cons True Nil))) Nil))))
                         (Cons A (Cons B (Cons O Nil))))))
! (bind! metaPop2 (ConsOS (mkExemplar (mkTree (mkNode AND) Nil) (mkDemeId "1") (worstCscore) (mkBScore (Cons 0 (Cons 0 Nil)))) NilOS)) 

! (bind! metaPop (ConsOS (mkExemplar (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil))) (mkDemeId "1") (mkCscore -0.2 1 0.1 0.1 -0.4) (mkBScore (Cons 0 (Cons 0 Nil))))
                 (ConsOS (mkExemplar (mkTree (mkNode OR) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (Cons 0 (Cons 0 Nil)))) 
                 NilOS)))

! (bind! ttable1 (mkITable (Cons (Cons True (Cons False (Cons True Nil)))
                        (Cons (Cons True (Cons True  (Cons True Nil))) Nil)) 
                        (Cons A (Cons B (Cons O Nil)))))
        
(: isScored (-> (ScoredInstance Cscore) Bool))
(= (isScored (mkSInst (mkPair $instance $score))) (~= $score (worstCscore)))

;; NOTE!!!!!!!
;; merger -- this is a function implemented as part if the main crossTopOne in optimization/hillclimbing/cross-top-one.metta but results in error unless this is imported in the test file
(: merger (-> Expression Instance Instance Expression))
(= (merger $targetInstances $baseInst $referenceInst)
    (collapse (let (mkSInst (mkPair $targetInst $score)) (superpose $targetInstances)
        (mkSInst (mkPair (mergeInstance $targetInst $baseInst $referenceInst) (worstCscore))))))

;; Testcase for optimizeDemes               
!(assertEqual 
(let* 
(
    ($optimizeDemesReturn (optimizeDemes demes table (mkInst (Cons 0 (Cons 0 Nil))) hillClimbing))
    (() (println! "optimizeDemes Returns"))
    (() (println! $optimizeDemesReturn))
    ((Cons ($instance (mkDeme $rep (mkSInstSet $instSet) $id) $state) Nil) $optimizeDemesReturn)
    ($instanceCount (List.length $instSet))
    ($scoredElems (List.map isScored $instSet))
)
((>= $instanceCount 4) (List.any $scoredElems)))
(True True))

;; Testcase for expandDeme
!(assertEqual
(let*
(
    ($updatedMetapop (expandDeme metaPop2 0 1 table hillClimbing 5 2 0 1 ttable1 3 0.004 1000))
    ($updatedMetapopLength (OS.length $updatedMetapop))
)
(>= $updatedMetapopLength 1)
) True)

;; Testcase for runMoses
!(assertEqual
(let*
(
    ($topCandidates (runMoses 1 (mkCscore -0.1 2 0.1 0.1 3) 3 metaPop2 0 1 table hillClimbing 5 2 0 1 ttable1 3 0.004 1000))
    ($topCandidatesLength (OS.length $topCandidates))
)
(>= $topCandidatesLength 1)
) True)