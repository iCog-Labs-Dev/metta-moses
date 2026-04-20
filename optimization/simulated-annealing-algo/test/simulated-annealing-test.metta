!(import! &self ../../../../metta-moses/utilities/general-helpers)
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


(= (deme) (mkDeme (mkRep (mkKbMap (mkDscKbMp (cons ((mkNodeId (1)) 0) (cons ((mkNodeId (2)) 1) ()))) (mkDscMp (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) )) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ())))) (mkTree (mkNode AND) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) ())))) (mkSInstSet ()) (mkDemeId "1")))
(= (demes) (cons (mkDeme (mkRep (mkKbMap (mkDscKbMp (cons ((mkNodeId (1)) 0) (cons ((mkNodeId (2)) 1) ()))) (mkDscMp (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) )) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) )) ())))) (mkTree (mkNode AND) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) ())))) (mkSInstSet ()) (mkDemeId "1")) ()))

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
          (($instance (mkDeme $rep (mkSInstSet $instSet) $id) $state) (simulated-annealing (deme) (table1) (mkInst (cons 0 (cons 0 ()))) (mkParams applyComplexityBasedScore ())))
           ($instanceCount (List.length $instSet))
           ($scoredElems (List.map isScored $instSet))
      )
      ((>= $instanceCount 1) (List.any $scoredElems)) 
   )
(True True)
)
!(assertEqual 
   (let*
      (
           (($instance (mkSInstSet $instSet) $state) (simulated-annealing (mkSInstSet ()) (itable) (mkInst (cons 1 (cons 0 ()))) (mkParams applyMutualInformationBasedScore mi)))
           ($instanceCount (List.length $instSet))
           ($scoredElems (List.map isScored $instSet))
      )
      ((>= $instanceCount 1) (List.any $scoredElems)) 
   )
(True True)
)


;; Reproducibility test 
!(assertEqual 
    (let*
        (
            (($instance (mkDeme $rep (mkSInstSet $instSet) $id) $state) 
                (simulated-annealing (deme) (table1) (mkInst (cons 0 (cons 0 ()))) (mkParams applyComplexityBasedScore ())))
           (($prevCenter $prevStart $prevSize $bestSscore $bestScore $currentNInstances $d $i) $state)
        )
        ((== $bestSscore (mkCscore -1 1 0.5 0.0 -1.5))(== $bestScore -1.5))
    )
    (True True))
