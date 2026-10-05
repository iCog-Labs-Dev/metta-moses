;; Generic action-domain regression for the Ant fixture.
;;
;; The Ant world, actions, perception, episode loop, and small-domain fitness
;; are defined only in examples/ant/ant-action-domain.metta.  This file owns
;; test fixtures and assertions, including the independent 89-pellet trail.

!(import! &self utilities/general-helpers)
!(import! &self parameters/registry)
!(import! &self parameters/defaults)
!(import! &self utilities/list-methods)
!(import! &self utilities/pair)
!(import! &self utilities/map)
!(import! &self utilities/ordered-multimap)
!(import! &self utilities/ordered-set)
!(import! &self utilities/ordered-multiset)
!(import! &self utilities/nodeId)
!(import! &self utilities/lazy-random-selector)
!(import! &self utilities/lru-cache)

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
!(callPredicate (Predicate (consult "moses/tests/rte-helpers-fast.pl")))
!(import! &self utilities/tree)

!(import! &self scoring/cacheSpace)
!(import! &self scoring/fitness)
!(import! &self scoring/boolean-ops)
!(import! &self scoring/action-registry)
!(import! &self scoring/action-eval)
!(import! &self scoring/action-ops)
!(import! &self scoring/bscore)
!(import! &self scoring/cscore)
!(import! &self scoring/action-score)

!(import! &self feature-selection/feature-selection-helpers)
!(import! &self feature-selection/similarity-scorers)
!(import! &self feature-selection/select-top-features)
!(import! &self feature-selection/simple)
!(import! &self feature-selection/smd)
!(import! &self feature-selection/incremental)
!(import! &self feature-selection/hc)
!(import! &self feature-selection/random-feature-selection)
!(import! &self feature-selection/feature-selection-main)

!(import! &self representation/knob-representation)
!(import! &self representation/lsk)
!(import! &self representation/disc-probe)
!(import! &self representation/logical-probe)
!(import! &self representation/sample-logical-perms)
!(import! &self representation/logical-canonize)
!(import! &self representation/add-logical-knobs)
!(import! &self representation/build-logical)
!(import! &self representation/build-action)
!(import! &self representation/build-knobs)
!(import! &self representation/knob-mapper)
!(import! &self representation/representation)
!(import! &self representation/create-representation)
!(import! &self scoring/complexity-based-scorer)

!(import! &self optimization/hillclimbing/crossover-helpers)
!(import! &self optimization/hillclimbing/crossover)
!(import! &self optimization/hillclimbing/hill-climbing-helpers)
!(import! &self deme/create-deme)
!(import! &self moses/neighborhood-sampling)
!(import! &self metapopulation/exemplar-type)
!(import! &self metapopulation/exemplar-selection)
!(import! &self metapopulation/metapopulation)
!(import! &self representation/instance)
!(import! &self deme/deme-id-creation)
!(import! &self deme/score-deme)
!(import! &self deme/merge-demes)
!(import! &self deme/expand-deme)

!(import! &self examples/ant/ant-action-domain)

!(set-param fitness antFitness)
!(set-param bestScore antBestScore)
!(set-param actions (quote (antMoveForward antTurnLeft antTurnRight)))
!(set-param perceptions (quote (antFoodAhead)))
!(set-param nTrials 4)

;; Basic evaluator coverage uses a deliberately local world fixture; all
;; primitive dispatch still comes from the authoritative Ant domain module.
(= (antTestWorld)
   (mkAntWorld ((A F E E E E E E)
                (E E E E E E E E)
                (E E E E E E E E))
               (mkPair 0 0) E 0 9))

!(assertEqual
  (evalAction (quote (antMoveForward ())) (antTestWorld))
  (mkARes True
    (mkAntWorld ((E A E E E E E E)
                 (E E E E E E E E)
                 (E E E E E E E E))
                (mkPair 1 0) E 1 8)))

!(assertEqual
  (scoreActionTree
    (mkTree (mkNode and_seq)
      (cons (mkTree (mkNode action_bool_if)
              (cons (mkTree (mkNode antFoodAhead) ())
              (cons (mkTree (mkNode antMoveForward) ())
              (cons (mkTree (mkNode antTurnRight) ()) ()))))
            ()))
    4 &actionScoreCache)
  (mkBScore (5 5 5 5)))

(= (antClassicTrail)
   ((A F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F)
    (F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F)
    (F F F F F F F F F F F F F F F F F F F F F F F F F E E E E E E E)))

(= (antCountFood $grid)
   (foldl-atom $grid 0 $acc $row
      (+ $acc (foldl-atom $row 0 $a $c
         (if (== $c F) (+ $a 1) $a)))))

(= (antClassicFitness $exp $i)
   (antRunEpisode $exp
     (mkAntWorld (antClassicTrail) (mkPair 0 0) E 0 120)))

(= (antClassicMetaPop)
   ((mkExemplar (mkTree (mkNode and_seq) ()) (mkDemeId "1")
                (mkCscore -1.0 0 3.5 0 -1.0)
                (mkBScore (-1.0)))))

!(assertEqual (antCountFood (antClassicTrail)) 89)
!(set-param fitness antClassicFitness)
!(set-param bestScore antBestScore)
!(py-call (random.seed 0))
!(set-param maxCandOutput 3)
!(set-param hcMaxEvals 60)
!(set-param genCount 2)
!(assertEqual
  (let* (( $m (runMoses 6 89.0 (antClassicMetaPop) 0 1
                     (mkActionCtx 1 3.5 89.0) hillClimbing))
        ($_ (println! (Final Exemplar with (getExemplarTree (OS.getByIdx 0 $m))))))
    (getScore (getExemplarCscore (OS.getByIdx 0 $m))))
  89)
