!(import! &self utilities/general-helpers)
!(import! &self utilities/list-methods)
!(import! &self utilities/map)
!(import! &self utilities/ordered-multimap)
!(import! &self utilities/nodeId)
!(import! &self utilities/lazy-random-selector)
!(import! &self utilities/pair) 

!(import! &self reduct/boolean-reduct/rte-helpers)
!(import! &self reduct/boolean-reduct/cut-unnecessary-or)
!(import! &self reduct/boolean-reduct/cut-unnecessary-and)
!(import! &self reduct/boolean-reduct/n-ary-propagate-not)
!(import! &self reduct/boolean-reduct/n-ary-gather-junctors)
!(import! &self reduct/boolean-reduct/delete-inconsistent-handle)
!(import! &self reduct/boolean-reduct/zero-constraint-subsumption)
!(import! &self reduct/boolean-reduct/one-constraint-subsumption)
!(import! &self reduct/boolean-reduct/promote-common-constraints)
!(import! &self reduct/boolean-reduct/reduce-to-elegance)


!(import! &self utilities/tree)

!(import! &self representation/knob-representation)
!(import! &self representation/lsk)
!(import! &self representation/logical-probe) 
!(import! &self representation/sample-logical-perms)
!(import! &self representation/add-logical-knobs)
!(import! &self representation/build-logical)
!(import! &self representation/build-knobs)
!(import! &self representation/knob-mapper)
!(import! &self feature-selection/feature-selection-helpers)
!(import! &self representation/representation)
!(import! &self representation/create-representation)


!(import! &self representation/instance)


!(import! &self optimization/hillclimbing/cross-top-one-helpers)
!(import! &self optimization/hillclimbing/cross-top-one)
!(import! &self optimization/hillclimbing/crossover-helpers)


!(import! &self scoring/fitness)
!(import! &self scoring/bscore)
!(import! &self scoring/cscore)
!(import! &self scoring/complexity-based-scorer)

!(import! &self optimization/hillclimbing/hill-climbing-helpers)
!(import! &self moses/neighborhood-sampling)

!(import! &self deme/deme-id-creation)
!(import! &self deme/create-deme)
!(import! &self deme/score-deme)
!(import! &self deme/expand-deme)


!(import! &self optimization/simulated-annealing-algo/simulated-annealing)






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
