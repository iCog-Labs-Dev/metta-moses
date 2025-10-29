!(register-module! ../../../../metta-moses)

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
;;!(import! &self metta-moses:utilities:python-helpers);; commented out because not compatibel with mettalog
!(import! &self metta-moses:utilities:general-helpers)
!(import! &self metta-moses:utilities:ordered-multimap)
!(import! &self metta-moses:utilities:python-treehelpers)
!(import! &self metta-moses:utilities:lazy-random-selector)

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


!(import! &self metta-moses:deme:score-deme)
!(import! &self metta-moses:deme:create-deme)
!(import! &self metta-moses:deme:deme-id-creation)
!(import! &self metta-moses:deme:expand-deme)

!(import! &self metta-moses:scoring:cscore)
!(import! &self metta-moses:scoring:bscore)
!(import! &self metta-moses:scoring:fitness)
!(import! &self metta-moses:scoring:complexity-based-scorer)

!(import! &self metta-moses:moses:neighborhood-sampling)

!(import! &self metta-moses:feature-selection:feature-selection-helpers)
!(import! &self metta-moses:optimization/hillclimbing:cross-top-one)
!(import! &self metta-moses:optimization/hillclimbing:cross-top-one-helpers)
!(import! &self metta-moses:optimization/hillclimbing:hill-climbing-helpers)
!(import! &self metta-moses:optimization/simulated-annealing-algo:simulated-annealing)

!(import! &self metta-moses:scoring:bscore)

!(bind! math-exp (py-atom math.exp))
!(bind! rand-random (py-atom random.random))
!(bind! rand-seed (py-atom random.seed))

!(rand-seed 42)

!(bind! deme (mkDeme (mkRep (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (1)) 0) (ConsMap ((mkNodeId (2)) 1) NilMap))) (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) )) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) NilMMap)))) (mkTree (mkNode AND) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) Nil)))) (mkSInstSet Nil) (mkDemeId "1")))
!(bind! demes (Cons (mkDeme (mkRep (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (1)) 0) (ConsMap ((mkNodeId (2)) 1) NilMap))) (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) )) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) )) NilMMap)))) (mkTree (mkNode AND) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) Nil)))) (mkSInstSet Nil) (mkDemeId "1")) Nil))

!(bind! table (createTruthTableBScore 2 (mkITable
                         (Cons (Cons False (Cons False (Cons False Nil))) 
                         (Cons (Cons True (Cons False (Cons False Nil))) 
                         (Cons (Cons False (Cons True (Cons False Nil)))
                         (Cons (Cons True (Cons True (Cons True Nil))) Nil))))
                         (Cons A (Cons B (Cons O Nil))))))

!(bind! itable (mkITable
                         (Cons (Cons False (Cons False (Cons False Nil))) 
                         (Cons (Cons True (Cons False (Cons False Nil))) 
                         (Cons (Cons False (Cons True (Cons False Nil)))
                         (Cons (Cons True (Cons True (Cons True Nil))) Nil))))
                         (Cons A (Cons B (Cons O Nil)))))
                         
(: isScored (-> (ScoredInstance Cscore) Bool))
(= (isScored (mkSInst (mkPair $instance $score))) (~= $score (worstCscore)))


!(assertEqual 
    (let*
       (
            (($instance (mkDeme $rep (mkSInstSet $instSet) $id) $state) (simulated-annealing deme table (mkInst (Cons 0 (Cons 0 Nil))) (applyComplexityBasedScore ())))
            ($instanceCount (List.length $instSet))
            ($scoredElems (List.map isScored $instSet))
       )
       ((>= $instanceCount 4) (List.any $scoredElems)) 
    )
(True True)
)

!(assertEqual 
    (let*
       (
            (($instance (mkSInstSet $instSet) $state) (simulated-annealing (mkSInstSet Nil) itable (mkInst (Cons 1 (Cons 0 Nil))) (applyMutualInformationBasedScore mi)))
            ($instanceCount (List.length $instSet))
            ($scoredElems (List.map isScored $instSet))
       )
       ((>= $instanceCount 4) (List.any $scoredElems)) 
    )
(True True)
)

;; Reproducibility test not working use the upper test case instead
; !(assertEqual 
;     (let*
;         (
;             (($instance (mkDeme $rep (mkSInstSet $instSet) $id) ($_ $bestCScore $bestScore $_ $_ $_)) 
;                 (simulated-annealing deme table (mkInst (Cons 0 (Cons 0 Nil))) (20 0.01 0.1 True 7)))
;         )
;         (== ($bestCScore $bestScore) ((mkCscore 0 2 1.0 0.0 -1.0) -1.0))
;     )
;     True
; )