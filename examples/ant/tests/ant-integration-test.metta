;; Generic action-domain integration coverage for Ant.
;;
;; Ant-specific world execution is supplied by ant-action-domain.metta.
;; Framework lifecycle tests use only the shared action context and scorer
;; contracts; no Ant-specific adapter or scorer path is exercised here.

!(import! &self ../../../utilities/general-helpers)
!(import! &self ../../../utilities/list-methods)
!(import! &self ../../../utilities/map)
!(import! &self ../../../utilities/nodeId)
!(import! &self ../../../utilities/pair)
!(import! &self ../../../utilities/ordered-multimap)
!(import! &self ../../../utilities/ordered-set)
!(import! &self ../../../utilities/tree)
!(import! &self ../../../utilities/lazy-random-selector)
!(import! &self ../../../utilities/lru-cache)

!(import! &self ../../../parameters/registry)
!(import! &self ../../../parameters/defaults)
!(import! &self ../../../scoring/cacheSpace)
!(import! &self ../../../scoring/boolean-ops)
!(import! &self ../../../scoring/bscore)
!(import! &self ../../../scoring/cscore)
!(import! &self ../../../scoring/action-registry)
!(import! &self ../../../scoring/action-eval)
!(import! &self ../../../scoring/action-score)

!(import! &self ../../../feature-selection/feature-selection-helpers)
!(import! &self ../../../reduct/action-reduct/action-vocab)
!(import! &self ../../../reduct/action-reduct/action-helpers)
!(import! &self ../../../reduct/action-reduct/action-properties)
!(import! &self ../../../reduct/action-reduct/reduce-action-if)
!(import! &self ../../../reduct/action-reduct/reduce-action-action-if)
!(import! &self ../../../reduct/action-reduct/reduce-const-action-seq)
!(import! &self ../../../reduct/action-reduct/reduce-action-not)
!(import! &self ../../../reduct/action-reduct/reduce-action-while)
!(import! &self ../../../reduct/action-reduct/reduce-seq-result)
!(import! &self ../../../reduct/action-reduct/reduce-null-vertices)
!(import! &self ../../../reduct/action-reduct/reduce-action-properties)
!(import! &self ../../../reduct/action-reduct/action-reduction)

!(import! &self ../../../representation/knob-representation)
!(import! &self ../../../representation/lsk)
!(import! &self ../../../representation/disc-probe)
!(import! &self ../../../representation/logical-probe)
!(import! &self ../../../representation/sample-logical-perms)
!(import! &self ../../../representation/logical-canonize)
!(import! &self ../../../representation/add-logical-knobs)
!(import! &self ../../../representation/build-logical)
!(import! &self ../../../representation/build-action)
!(import! &self ../../../representation/build-knobs)
!(import! &self ../../../representation/knob-mapper)
!(import! &self ../../../representation/representation)
!(import! &self ../../../representation/create-representation)
!(import! &self ../../../representation/instance)

!(import! &self ../../../deme/deme-id-creation)
!(import! &self ../../../deme/create-deme)
!(import! &self ../../../deme/score-deme)
!(import! &self ../../../deme/merge-demes)
!(import! &self ../../../deme/expand-deme)
!(import! &self ../../../optimization/hillclimbing/crossover-helpers)
!(import! &self ../../../optimization/hillclimbing/crossover)
!(import! &self ../../../optimization/hillclimbing/hill-climbing-helpers)
!(import! &self ../ant-action-domain)

!(set-param fitness antFitness)
!(set-param bestScore antBestScore)
!(set-param actions (quote (antMoveForward antTurnLeft antTurnRight)))
!(set-param perceptions (quote (antFoodAhead)))
!(set-param nTrials 4)

(= (antActionContext)
   (mkActionCtx (param nTrials) (param complexityRatio) (antBestScore (param nTrials))))

(= (antSeed)
   (mkExemplar
     (ant-exemplar)
     (mkDemeId "ant-generic")
     (mkCscore (-4)
               0
               (param complexityRatio)
               0
               (-4))
     (mkBScore (List.repeat (param nTrials) -1.0))))

!(assertEqual
  ((antActionContext)
   (optimizerContextFor (antActionContext) (antBestScore (param nTrials)))
   (mergeContextFor (antActionContext))
   (initialEvaluationCount (antActionContext)))
  ((mkActionCtx 4 3.5 20)
   (mkOptimizerContext (mkActionCtx 4 3.5 20) 20)
   (mkActionCtx 4 3.5 20)
   0))

!(assertEqual
  ((representationExpandable
      (representation (ant-exemplar)
                      (param actions)
                      (param perceptions)))
   (antBestScore (param nTrials)))
  (True 20))

!(assertEqual
  (let $seed (antSeed)
    (getScore (getExemplarCscore $seed)))
  (-4))

!(assertEqual
  (scoreActionTree (ant-exemplar) (param nTrials) &actionScoreCache)
  (mkBScore (0 0 0 0)))
