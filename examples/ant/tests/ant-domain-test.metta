;; Ant is tested here only through the generic action-domain contract.
;; World state, primitive actions, and episode execution belong to the domain
;; module; scoring and search behavior are shared framework behavior.

!(import! &self ../../../utilities/general-helpers)
!(import! &self ../../../utilities/list-methods)
!(import! &self ../../../utilities/pair)
!(import! &self ../../../utilities/tree)
!(import! &self ../../../parameters/registry)
!(import! &self ../../../parameters/defaults)
!(import! &self ../../../scoring/cacheSpace)
!(import! &self ../../../scoring/bscore)
!(import! &self ../../../scoring/cscore)
!(import! &self ../../../scoring/action-registry)
!(import! &self ../../../scoring/action-eval)
!(import! &self ../../../scoring/action-score)
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
!(import! &self ../ant-action-domain)

!(set-param fitness antFitness)
!(set-param bestScore antBestScore)
!(set-param actions (quote (antMoveForward antTurnLeft antTurnRight)))
!(set-param perceptions (quote (antFoodAhead)))
!(set-param nTrials 4)

(= (antForwardTree)
   (mkTree (mkNode antMoveForward) ()))
(= (antFollowerTree)
   (mkTree (mkNode action_bool_if)
     ((mkTree (mkNode antFoodAhead) ())
      (mkTree (mkNode and_seq) ((antForwardTree)))
      (mkTree (mkNode and_seq)
        ((mkTree (mkNode antTurnRight) ()))))))

!(assertEqual
  ((antFitness (ant-exemplar) 0)
   (antBestScore (param nTrials))
   (actionTreeComplexity (ant-exemplar))
   (actionTreeComplexity (antForwardTree)))
  (0 20 0 1))

!(assertEqual
  (scoreActionTree (antFollowerTree) (param nTrials) &actionScoreCache)
  (mkBScore (0 0 0 0)))

!(assertEqual
  (getScore
    (getActionCscore (antFollowerTree)
                     (mkActionCtx (param nTrials))
                     (param complexityRatio)
                     &actionScoreCache))
  0)
