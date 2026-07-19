!(import! &self ../../../../metta-moses/utilities/general-helpers)
!(import! &self ../../../../metta-moses/parameters/registry)
!(import! &self ../../../../metta-moses/parameters/defaults)
!(import! &self ../../../../metta-moses/utilities/list-methods)
!(import! &self ../../../../metta-moses/utilities/map)
!(import! &self ../../../../metta-moses/utilities/ordered-multimap)
!(import! &self ../../../../metta-moses/utilities/nodeId)
!(import! &self ../../../../metta-moses/utilities/lazy-random-selector)
!(import! &self ../../../../metta-moses/utilities/pair) 

!(import! &self ../../../../metta-moses/reduct/boolean-reduct/rte-helpers)
!(import! &self ../../../../metta-moses/reduct/boolean-reduct/cut-unnecessary-or)
!(import! &self ../../../../metta-moses/reduct/boolean-reduct/cut-unnecessary-and)
!(import! &self ../../../../metta-moses/reduct/boolean-reduct/n-ary-propagate-not)
!(import! &self ../../../../metta-moses/reduct/boolean-reduct/n-ary-gather-junctors)
!(import! &self ../../../../metta-moses/reduct/boolean-reduct/delete-inconsistent-handle)
!(import! &self ../../../../metta-moses/reduct/boolean-reduct/zero-constraint-subsumption)
!(import! &self ../../../../metta-moses/reduct/boolean-reduct/one-constraint-subsumption)
!(import! &self ../../../../metta-moses/reduct/boolean-reduct/promote-common-constraints)
!(import! &self ../../../../metta-moses/reduct/boolean-reduct/reduce-to-elegance)


!(import! &self ../../../../metta-moses/utilities/tree)

!(import! &self ../../../../metta-moses/representation/knob-representation)
!(import! &self ../../../../metta-moses/representation/lsk)
!(import! &self ../../../../metta-moses/representation/logical-probe) 
!(import! &self ../../../../metta-moses/representation/sample-logical-perms)
!(import! &self ../../../../metta-moses/representation/add-logical-knobs)
!(import! &self ../../../../metta-moses/representation/build-logical)
!(import! &self ../../../../metta-moses/representation/build-knobs)
!(import! &self ../../../../metta-moses/representation/knob-mapper)
!(import! &self ../../../../metta-moses/feature-selection/feature-selection-helpers)
!(import! &self ../../../../metta-moses/representation/representation)
!(import! &self ../../../../metta-moses/representation/create-representation)


!(import! &self ../../../../metta-moses/representation/instance)


!(import! &self ../../../../metta-moses/optimization/hillclimbing/cross-top-one-helpers)
!(import! &self ../../../../metta-moses/optimization/hillclimbing/cross-top-one)

!(import! &self ../../../../metta-moses/scoring/fitness)
!(import! &self ../../../../metta-moses/scoring/bscore)
!(import! &self ../../../../metta-moses/scoring/cscore)
!(import! &self ../../../../metta-moses/scoring/complexity-based-scorer)

!(import! &self ../../../../metta-moses/optimization/hillclimbing/hill-climbing-helpers)
!(import! &self ../../../../metta-moses/moses/neighborhood-sampling)

!(import! &self ../../../../metta-moses/deme/deme-id-creation)
!(import! &self ../../../../metta-moses/deme/create-deme)
!(import! &self ../../../../metta-moses/deme/score-deme)
!(import! &self ../../../../metta-moses/deme/expand-deme)


!(import! &self ../../../../metta-moses/optimization/simulated-annealing-algo/simulated-annealing)






!(py-call (random.seed 42))

!(bind! &deme1 (new-space))

(= (rep1) (mkRep (mkKbMap (mkDscMp (((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) )) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())))))) (mkTree (mkNode AND) (cons (mkKnob (mkNullVex (cons (mkTree (mkNode A) ()) ())) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 0) (cons (mkKnob (mkNullVex (cons (mkTree (mkNode B) ()) ())) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 1) ())))))
(= (instSet1) (mkSInstSet ()))
(= (demeId1) (mkDemeId "1")) 

!(let $x (rep1) (add-atom &deme1 $x))
!(let $y (instSet1) (add-atom &deme1 $y))
!(let $z (demeId1) (add-atom &deme1 $z))

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
                      
;;(: isScored (-> (ScoredInstance Cscore) Bool))
(= (isScored (mkSInst (mkPair $instance $score))) (~= $score (worstCscore)))
!(simulated annealing test ----------)

!(assertEqual 
   (let*
      (
          (($instance $demespace $state) (simulated-annealing &deme1 (table1) (mkInst (cons 0 (cons 0 ()))) (mkParams applyComplexityBasedScore ())))
           ($instSet (match $demespace (mkSInstSet $s) $s))
           ($instanceCount (List.length $instSet))
           ($scoredElems (List.map isScored $instSet))
      )
      ((>= $instanceCount 1) (List.any $scoredElems)) 
   )
(True True)
)

!(bind! &deme2 (new-space))
!(let $x (mkRep () ()) (add-atom &deme2 $x))
!(let $y (mkSInstSet ()) (add-atom &deme2 $y))
!(let $z (mkDemeId ()) (add-atom &deme2 $z))

!(assertEqual 
   (let*
      (
           (($instance $demespace $state) (simulated-annealing &deme2 (itable) (mkInst (cons 1 (cons 0 ()))) (mkParams applyMutualInformationBasedScore mi)))
           ($instSet (match $demespace (mkSInstSet $s) $s))
           ($instanceCount (List.length $instSet))
           ($scoredElems (List.map isScored $instSet))
      )
      ((>= $instanceCount 1) (List.any $scoredElems)) 
   )
(True True)
)

!(bind! &deme3 (new-space))
!(let $x (rep1) (add-atom &deme3 $x))
!(let $y (mkSInstSet ()) (add-atom &deme3 $y))
!(let $z (mkDemeId "3") (add-atom &deme3 $z))

;; Reproducibility test 
!(assertEqual 
    (let*
        (
            (($instance $representation $state) 
               (simulated-annealing &deme3 (table1) (mkInst (cons 0 (cons 0 ()))) (mkParams applyComplexityBasedScore ())))
           (($prevCenter $prevStart $prevSize $bestSscore $bestScore $currentNInstances $d $i) $state)
        )
        ((== $bestSscore (mkCscore -1 1 0.5 0.0 -1.5))(== $bestScore -1.5))
    )
    (True True))
