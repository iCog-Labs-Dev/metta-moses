!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/map)
!(import! &self ../../utilities/ordered-multimap)
!(import! &self ../../utilities/ordered-multiset)
!(import! &self ../../utilities/ordered-set)
!(import! &self ../../utilities/pair)
!(import! &self ../../utilities/nodeId)
!(import! &self ../../utilities/lazy-random-selector)
!(import! &self ../../utilities/lru-cache)

!(import! &self ../../feature-selection/feature-selection-helpers)
!(import! &self ../../feature-selection/select-top-features)
!(import! &self ../../feature-selection/similarity-scorers)
!(import! &self ../../feature-selection/simple)
!(import! &self ../../feature-selection/smd)
!(import! &self ../../feature-selection/incremental)
!(import! &self ../../feature-selection/hc)
!(import! &self ../../feature-selection/random-feature-selection)
!(import! &self ../../feature-selection/feature-selection-main)

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

!(import! &self ../../representation/instance)

!(import! &self ../../moses/neighborhood-sampling)

!(import! &self ../../optimization/hillclimbing/cross-top-one-helpers)
!(import! &self ../../optimization/hillclimbing/cross-top-one)
!(import! &self ../../optimization/hillclimbing/hill-climbing-helpers)

!(import! &self ../../metapopulation/exemplar-type)
!(import! &self ../../metapopulation/exemplar-selection)
!(import! &self ../../metapopulation/metapopulation)

!(import! &self ../../scoring/cacheSpace)
!(import! &self ../../scoring/fitness)
!(import! &self ../../scoring/bscore)
!(import! &self ../../scoring/cscore)
!(import! &self ../../scoring/complexity-based-scorer)

!(import! &self ../deme-id-creation)
!(import! &self ../create-deme)
!(import! &self ../score-deme)
!(import! &self ../merge-demes)
!(import! &self ../expand-deme)

;; (= (expandDeme $metaPop $nExpansion $nDeme $prune-exemplar $fs-algo $truthTableBScore $optimize $nEval $maxCandsPerDeme $minPoolSize $complexityTemperature $itable $nToKeep $capCoef $genCount)
    ;; ($updatedDeme (expandDeme metaPop2 0 1 False sim table hillClimbing 5 2 0 1 ttable1 3 0.004 1000))
    ;; ($demes (trace! "Creating Deme" (createDeme $nDeme $demeIds $tree $itable $fs-algo $prune-exemplar ())))                   ;;createRepresentation and createDemeId are under this
;; (= (createDeme $nDeme $demeIds $exemplar (mkITable $table $labels) $algo $prune-exemplar $enforced-fts))
;; (= (createDeme 1 (cons (mkDemeId "1") $tree ) $exemplar ttable1 $algo $prune-exemplar $enforced-fts))
;;

(= (table1) (mkITable
                         (cons (cons False (cons False (cons False ()))) 
                         (cons (cons True (cons False (cons False ()))) 
                         (cons (cons False (cons True (cons False ())))
                         (cons (cons True (cons True (cons True ()))) ()))))
                         (cons A (cons B (cons O ())))))

;; INFO: This test case passes but hangs after finishing. No idea why. The function it self doesn't hang but the execution does.
;; !(assertEqual (createDeme 1 (cons (mkDemeId "1") ()) (mkTree (mkNode OR) (cons (mkTree (mkNode B) ()) ())) 
;;               (table1)
;;               sim False () mi)
;;               ((mkDeme (mkRep (mkKbMap (mkDscKbMp (cons ((mkNodeId (1 1)) 5) (cons ((mkNodeId (1 1 2)) 8) (cons ((mkNodeId (1 1 3)) 9) (cons ((mkNodeId (1 1 4)) 10) (cons ((mkNodeId (1 2)) 4) (cons ((mkNodeId (1 3)) 6) (cons ((mkNodeId (1 4)) 7) (cons ((mkNodeId (1 5 1)) 11) (cons ((mkNodeId (1 5 2)) 12) (cons ((mkNodeId (1 5 3)) 13) (cons ((mkNodeId (1 5 4)) 14) (cons ((mkNodeId (2)) 0) (cons ((mkNodeId (3)) 1) (cons ((mkNodeId (4)) 2) (cons ((mkNodeId (5)) 3) (cons ((mkNodeId (6 1)) 15) (cons ((mkNodeId (6 2)) 16) (cons ((mkNodeId (6 3)) 17) (cons ((mkNodeId (6 4)) 18) ())))))))))))))))))))) (mkDscMp (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (5))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 1))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 1 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 1 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 1 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 5 1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 5 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 5 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 5 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (6 1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (6 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (6 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (6 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ()))))))))))))))))))))) (mkTree (mkNode AND) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) ()))))) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkTree (mkNode AND) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) ()))))) ())))))) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkTree (mkNode OR) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) ()))))) ())))))))) (mkSInstSet ()) (mkDemeId "1"))))
