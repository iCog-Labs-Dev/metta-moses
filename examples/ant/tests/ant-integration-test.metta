!(import! &self ../../../utilities/general-helpers)
!(import! &self ../../../utilities/list-methods)
!(import! &self ../../../utilities/ordered-multimap)
!(import! &self ../../../utilities/lazy-random-selector)
!(import! &self ../../../utilities/nodeId)
!(import! &self ../../../utilities/tree)
!(import! &self ../../../utilities/lru-cache)

!(import! &self ../../../scoring/cacheSpace)
!(import! &self ../../../scoring/bscore)
!(import! &self ../../../scoring/cscore)

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
!(import! &self ../../../representation/logical-probe)
!(import! &self ../../../representation/sample-logical-perms)
!(import! &self ../../../representation/add-logical-knobs)
!(import! &self ../../../representation/build-logical)
!(import! &self ../../../representation/logical-canonize)
!(import! &self ../../../representation/build-action)
!(import! &self ../../../representation/build-knobs)
!(import! &self ../../../representation/representation)
!(import! &self ../../../representation/create-representation)
!(import! &self ../../../representation/instance)

!(import! &self ../../../deme/create-deme)

!(import! &self ../ant-domain)

!(import! &self ../../../optimization/hillclimbing/cross-top-one-helpers)
!(import! &self ../../../optimization/hillclimbing/cross-top-one)
!(import! &self ../../../optimization/hillclimbing/hill-climbing-helpers)

!(py-call (random.seed 10))

(= (antContextForTest)
   (mkAntContext 600 0.16 (ant-actions) (ant-perceptions)))

(= (manualAntRep)
   (let ($updatedTree $mmp)
        (addActionKnobsAt
           (ant-exemplar)
           (mkNodeId (0))
           (mkNodeId (0))
           True
           ()
           (ant-actions)
           (ant-perceptions))
      (mkRep (mkKbMap (mkDscMp $mmp)) $updatedTree)))

(= (antMoveTree) (mkTree (mkNode move_forward) ()))
(= (antTurnRightTree) (mkTree (mkNode turn_right) ()))
(= (antFoodAheadTree) (mkTree (mkNode is_food_ahead) ()))

(= (trailFollowerTree)
   (mkTree (mkNode action_bool_if)
      ((antFoodAheadTree) (antMoveTree) (antTurnRightTree))))

(= (antDemeFunctionalSummary
     (mkDeme
       (mkRep (mkKbMap (mkDscMp $mmp)) $tree)
       (mkSInstSet $scoredInstances)
       $id))
   (let* (
          ($rep (mkRep (mkKbMap (mkDscMp $mmp)) $tree))
          ($defaults (List.map getKnobDefault (MultiMap.values $mmp)))
          ($inst (mkInst (List.map second $defaults)))
          ($candidate (getCandidate $rep $id $inst))
          ($cscore (antBasedScorer $rep $id $inst (antContextForTest)))
          ($rescored (sumBScore (scoreAntTree (cleanActionTree $candidate) 600)))
         )
     ($id
      (== $scoredInstances ())
      (> (MultiMap.length $mmp) 0)
      (getScore $cscore)
      $rescored
      (not (== $candidate ())))))

(= (antDemeFunctionalSummaries ()) ())
(= (antDemeFunctionalSummaries (cons $deme $rest))
   (cons (antDemeFunctionalSummary $deme)
         (antDemeFunctionalSummaries $rest)))

;; Ant deme multiplicity must be driven only by nDeme. This also guards against
;; an unresolved list-producing helper being interpreted as literal map input.
!(assertEqual
  (createDeme 0 () (ant-exemplar) (antContextForTest))
  ())

!(assertEqual
  (antDemeFunctionalSummaries
    (createDeme
      1
      ((mkDemeId "ant-1"))
      (ant-exemplar)
      (antContextForTest)))
  (((mkDemeId "ant-1") True True -89 -89 True)))

!(assertEqual
  (antDemeFunctionalSummaries
    (createDeme
      2
      ((mkDemeId "ant-1") (mkDemeId "ant-2"))
      (ant-exemplar)
      (antContextForTest)))
  (((mkDemeId "ant-1") True True -89 -89 True)
   ((mkDemeId "ant-2") True True -89 -89 True)))

!(assertEqual
  (let (mkRep (mkKbMap (mkDscMp $mmp)) $tree) (manualAntRep)
    (MultiMap.length $mmp))
  1)

!(assertEqual
  (getCandidate (manualAntRep) AntAbsent (mkInst (0)))
  (mkTree (mkNode action_success) ()))

!(assertEqual
  (getCandidate (manualAntRep) AntMove (mkInst (1)))
  (mkTree (mkNode and_seq) ((mkTree (mkNode move_forward) ()))))

!(assertEqual
  (let* (($scored (applyAntBasedScore
                    (manualAntRep)
                    (mkDemeId "ant")
                    ((mkInst (0)) (mkInst (1)))
                    (antContextForTest)))
         ((mkSInst (mkPair $inst0 $score0)) (List.getByIdx $scored 0))
         ((mkSInst (mkPair $inst1 $score1)) (List.getByIdx $scored 1)))
    ((getScore $score0) (getScore $score1)))
  (-89 -86))

;; Incremental ant scoring must preserve a prior score verbatim and invoke the
;; simulator only for the worstCscore-marked new instance.
!(assertEqual
  (transformAntIncremental
    (mkSInstSet
      ((mkSInst (mkPair (mkInst (0)) (mkCscore -77 4 25.0 0.0 -102.0)))
       (mkSInst (mkPair (mkInst (1)) (worstCscore)))))
    (manualAntRep) (mkDemeId "ant-incremental")
    (antContextForTest))
  ((mkSInstSet
     ((mkSInst (mkPair (mkInst (0)) (mkCscore -77 4 25.0 0.0 -102.0)))
      (mkSInst (mkPair (mkInst (1)) (mkCscore -86 1 6.25 0.0 -92.25)))))
   1))

!(assertEqual
  (let* (($plainMoveEaten (antFoodEaten (antRunTree (antMoveTree) 600)))
         ($trailFollowerEaten (antFoodEaten (antRunTree (trailFollowerTree) 600))))
    ($plainMoveEaten $trailFollowerEaten))
  (3 11))

!(assertEqual
  (let (mkRep (mkKbMap (mkDscMp $mmp)) $tree)
       (representation
          1
          (ant-exemplar)
          (mkITable () ())
          None
          False
          ()
          mi
          True
          (ant-actions)
          (ant-perceptions))
    (> (MultiMap.length $mmp) 0))
  True)
