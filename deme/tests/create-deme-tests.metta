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


;; (= (expandDeme $metaPop $nExpansion $nDeme $prune-exemplar $fs-algo $truthTableBScore $optimize $nEval $maxCandsPerDeme $minPoolSize $complexityTemperature $itable $nToKeep $capCoef $genCount)
    ;; ($updatedDeme (expandDeme metaPop2 0 1 False sim table hillClimbing 5 2 0 1 ttable1 3 0.004 1000))
    ;; ($demes (trace! "Creating Deme" (createDeme $nDeme $demeIds $tree $itable $fs-algo $prune-exemplar ())))                   ;;createRepresentation and createDemeId are under this
;; (= (createDeme $nDeme $demeIds $exemplar (mkITable $table $labels) $algo $prune-exemplar $enforced-fts)
;; (= (createDeme 1 (Cons (mkDemeId "1") $tree ) $exemplar ttable1 $algo $prune-exemplar $enforced-fts)
;;

(= (table1) (mkITable
                         (Cons (Cons False (Cons False (Cons False Nil))) 
                         (Cons (Cons True (Cons False (Cons False Nil))) 
                         (Cons (Cons False (Cons True (Cons False Nil)))
                         (Cons (Cons True (Cons True (Cons True Nil))) Nil))))
                         (Cons A (Cons B (Cons O Nil)))))

;; !(assertEqual (createDeme 1 (Cons (mkDemeId "1") Nil) (mkTree (mkNode OR) (Cons (mkTree (mkNode B) Nil) Nil)) 
;;               (table1)
;;               sim False () mi)
;;               (
;;                 (mkDeme
;;                    (mkRep
;;                       (mkKbMap
;;                          (mkDscKbMp (ConsMap ((mkNodeId (1)) 6) (ConsMap ((mkNodeId (1 1)) 2) (ConsMap ((mkNodeId (1 2)) 3) (ConsMap ((mkNodeId (1 3)) 1) (ConsMap ((mkNodeId (1 4)) 0) (ConsMap ((mkNodeId (2)) 7) (ConsMap ((mkNodeId (3)) 5) (ConsMap ((mkNodeId (4)) 4) NilMap)))))))))
;;                          (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 1))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) NilMMap))))))))))
;;                       (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil))))) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil))))))
;;                    (mkSInstSet Nil)
;;                    (mkDemeId "1"))))



;; !(createDeme 1 (Cons (mkDemeId "1") Nil) (mkTree (mkNode OR) (Cons (mkTree (mkNode B) Nil) Nil)) 
;;               (table1)
;;               sim False () mi)

!(createRepresentation 1 (mkTree (mkNode OR) (Cons (mkTree (mkNode B) Nil) Nil)) (table1) sim False () mi)
