!(import! &self ../../../utilities/general-helpers)
!(import! &self ../../../utilities/list-methods)
!(import! &self ../../../utilities/ordered-multimap)
!(import! &self ../../../utilities/ordered-set)
!(import! &self ../../../utilities/lazy-random-selector)
!(import! &self ../../../utilities/nodeId)
!(import! &self ../../../utilities/tree)
!(import! &self ../../../utilities/lru-cache)

!(import! &self ../../../parameters/registry)
!(import! &self ../../../parameters/defaults)

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

;; The raw-champion merge regression exercises actual metapopulation ordering,
;; selection, and resizing rather than checking only an intermediate list.
!(import! &self ../../../metapopulation/exemplar-type)
!(import! &self ../../../metapopulation/exemplar-selection)
!(import! &self ../../../metapopulation/metapopulation)

!(import! &self ../ant-domain)
;; merge-demes' ant branch uses the domain's score vocabulary, so load that
;; vocabulary before importing the generic merge implementation, as moses.metta does.
!(import! &self ../../../deme/merge-demes)

!(import! &self ../../../optimization/hillclimbing/cross-top-one-helpers)
!(import! &self ../../../optimization/hillclimbing/cross-top-one)
!(import! &self ../../../optimization/hillclimbing/hill-climbing-helpers)
;; Mirror the production import graph so the counted expansion helper can
;; specialize its higher-order hill-climbing call in this integration test.
!(import! &self ../../../deme/expand-deme)

!(py-call (random.seed 10))

;; The complete-run evaluator limit is registered only when the ant domain is
;; loaded, protecting unrelated generic parameter specialization.
!(assertEqual (param antMaxEvals) 100000)

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

;; Constant action-result exemplars contain no mutable coordinate.  This is the
;; compact form produced by action representation building for such trees and
;; is therefore the boundary C++ rejects before starting an optimizer.
(= (emptyAntRep $tree)
   (mkRep (mkKbMap (mkDscMp ())) $tree))

(= (antMoveTree) (mkTree (mkNode move_forward) ()))
(= (antTurnRightTree) (mkTree (mkNode turn_right) ()))
(= (antFoodAheadTree) (mkTree (mkNode is_food_ahead) ()))

(= (trailFollowerTree)
   (mkTree (mkNode action_bool_if)
      ((antFoodAheadTree) (antMoveTree) (antTurnRightTree))))

;; Deliberately expose the same move action through two different knob
;; settings. Real randomized representations can acquire the same redundancy
;; after action reduction; this compact representation makes that case stable.
(= (duplicateReducedAntRep)
   (let* (
          (($controlledSubtree $ask)
            (actionSubtreeKnob ((antMoveTree) (antMoveTree))))
          ($tree
            (mkTree (mkNode and_seq)
              ((mkKnob $controlledSubtree $ask 0))))
          ($mmp
            (MultiMap.insert
              ((getKnobSpec $ask) $ask) () discSpec<))
         )
     (mkRep (mkKbMap (mkDscMp $mmp)) $tree)))

;; Fix the semantic reference used by the representation round-trip below:
;; the standard one-condition trail follower eats eleven pellets in 600 steps.
!(assertEqual
  (scoreAntTree (trailFollowerTree) 600)
  (mkBScore (-89 11)))

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

(= (antDemeFunctionalSummaries $demes)
   (map-atom $demes $deme (antDemeFunctionalSummary $deme)))

;; Ant deme multiplicity must be driven only by nDeme. This also guards against
;; an unresolved list-producing helper being interpreted as literal map input.
!(assertEqual
  (createDeme 0 () (ant-exemplar) (antContextForTest))
  ())

;; Empty representations must be distinguished from real action
;; representations before hill climbing.  The latter would otherwise try to
;; read knob zero from an empty multimap.
!(assertEqual
  ((antRepresentationExpandable
     (emptyAntRep (mkTree (mkNode action_success) ())))
   (antRepresentationExpandable (manualAntRep)))
  (False True))

;; A tree's expandability cannot be inferred from its root symbol because the
;; randomized builder may add an insertion knob even around a constant.  Match
;; C++ by filtering the actual representations independently and preserving the
;; order of those that contain fields.
!(assertEqual
  (let* (
         ($validRep (manualAntRep))
         ($filtered
           (antExpandableRepresentations
             ((emptyAntRep (mkTree (mkNode action_success) ()))
              $validRep
              (emptyAntRep (mkTree (mkNode action_failure) ())))))
        )
    ((List.length $filtered) (== (List.head $filtered) $validRep)))
  (1 True))

;; Seed 19 takes the builder's no-insertion branch for both action-result
;; constants, providing a direct deterministic regression for the empty-field
;; rejection seen in the full search.  Other seeds can add a valid insertion
;; knob around the same constant, so reseed each case and restore the suite's
;; standard seed afterward instead of classifying constants by syntax.
!(assertEqual
  (let* (
         ($_successSeed (py-call (random.seed 19)))
         ($successDemes
           (createDeme
             1 ((mkDemeId "ant-constant-success"))
             (mkTree (mkNode action_success) ())
             (antContextForTest)))
         ($_failureSeed (py-call (random.seed 19)))
         ($failureDemes
           (createDeme
             1 ((mkDemeId "ant-constant-failure"))
             (mkTree (mkNode action_failure) ())
             (antContextForTest)))
         ($_restoreSeed (py-call (random.seed 10)))
        )
    ($successDemes $failureDemes))
  (() ()))

!(assertEqual
  (let* (
         ($_seed (py-call (random.seed 10)))
         ($demes
           (createDeme
             1
             ((mkDemeId "ant-1"))
             (ant-exemplar)
             (antContextForTest)))
        )
    (antDemeFunctionalSummaries $demes))
  (((mkDemeId "ant-1") True True -89 -89 True)))

!(assertEqual
  (let* (
         ($_seed (py-call (random.seed 10)))
         ($demes
           (createDeme
             2
             ((mkDemeId "ant-1") (mkDemeId "ant-2"))
             (ant-exemplar)
             (antContextForTest)))
        )
    (antDemeFunctionalSummaries $demes))
  (((mkDemeId "ant-1") True True -89 -89 True)
   ((mkDemeId "ant-2") True True -89 -89 True)))

;; The counted expansion exposes `(() 0)` as the retry signal without invoking
;; the simulator.  nDeme=0 makes that signal deterministic without depending on
;; randomized knob placement.  The outer loop must consume it cleanly: a
;; singleton metapopulation is returned unchanged after visit exhaustion rather
;; than reducing the complete search to `()`.
(= (constantAntExemplar)
   (mkExemplar
     (mkTree (mkNode action_success) ())
     (mkDemeId "ant-constant")
     (mkCscore -89 1 6.25 0.0 -95.25)
     (mkBScore (-89 0))))

!(assertEqual
  (expandSelectedAntExemplarCounted
    (constantAntExemplar) 7 0 (antContextForTest)
    hillClimbing 25)
  (() 0))

!(assertEqual
  (runAntMosesCounted
    1 0 ((constantAntExemplar)) 7 0
    (antContextForTest) hillClimbing () 11)
  ((constantAntExemplar)))

;; Combine the deterministic empty-representation signal above with the
;; actual retry transition.  The failed tree becomes ineligible at revisit=0,
;; the second tree remains selectable, and no counter advances.
!(assertEqual
  (let* (
         ($nextExemplar
           (mkExemplar
             (antMoveTree) (mkDemeId "ant-next")
             (mkCscore -86 1 6.25 0.0 -92.25)
             (mkBScore (-89 3))))
         ($updatedVisits
           (recordAntVisit
             (getExemplarTree (constantAntExemplar)) ()))
         (($retryGen $retryExpansion $retryVisits $retryEvaluations)
           (antEmptyRepresentationRetryState
             5 7 $updatedVisits 11))
         ($eligible
           (antEligibleExemplars
             ((constantAntExemplar) $nextExemplar)
             $retryVisits 0))
        )
    ($retryGen $retryExpansion $retryEvaluations $eligible))
  (5 7 11
   ((mkExemplar
      (mkTree (mkNode move_forward) ()) (mkDemeId "ant-next")
      (mkCscore -86 1 6.25 0.0 -92.25)
      (mkBScore (-89 3))))))

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

;; Instance coordinates must follow the ordered multimap's insertion order,
;; not a later sort by knob multiplicity.  Insert the four-way ASK first and
;; the two-way ASK second; their distinct defaults make any reordering visible.
!(assertEqual
  (let* (
         ($wideASK
           (mkASK
             (mkDiscKnob (mkMultip 4) (mkDiscSpec 2) (mkDiscSpec 2) ())
             ((antMoveTree) (antTurnRightTree) (trailFollowerTree))))
         ($binaryASK
           (mkASK
             (mkDiscKnob (mkMultip 2) (mkDiscSpec 1) (mkDiscSpec 1) ())
             ((antMoveTree))))
         ($withWide
           (MultiMap.insert ((getKnobSpec $wideASK) $wideASK) () discSpec<))
         ($mixed
           (MultiMap.insert
             ((getKnobSpec $binaryASK) $binaryASK) $withWide discSpec<))
        )
    ((MultiMap.keys $mixed) (createInitialInstance $mixed)))
  (((mkDiscSpec 4) (mkDiscSpec 2)) (2 1)))

;; The ninth hill-climbing state field is the number of real scorer calls.
;; Keep this positional contract explicit because the outer ant budget relies
;; on it rather than estimating evaluations from retained deme size.
!(assertEqual
  (antHillStateEvaluationCount
    (False False True previous-center 0 12
     (worstCscore) -42 37 4 6))
  37)

;; Exercise the global budget boundary and unlimited sentinel together.  The
;; final set-param deliberately restores the production default so later
;; integration assertions and tests in this process cannot inherit test state.
!(assertEqual
  (let* (
         ($_finite (set-param antMaxEvals 10))
         ($below
           ((antEvaluationBudgetReached 9)
            (antRemainingEvaluationBudget 9)))
         ($atLimit
           ((antEvaluationBudgetReached 10)
            (antRemainingEvaluationBudget 10)))
         ($pastLimit
           ((antEvaluationBudgetReached 14)
            (antRemainingEvaluationBudget 14)))
         ($_unlimited (set-param antMaxEvals -1))
         ($unlimited
           ((antEvaluationBudgetReached 1000000)
            (antRemainingEvaluationBudget 1000000)))
         ($_restore (set-param antMaxEvals 100000))
        )
    ($below $atLimit $pastLimit $unlimited (param antMaxEvals)))
  ((False 1) (True 0) (True 0) (False -1) 100000))

;; A direct or resumed ant run may already contain a target-reaching raw
;; champion. Detect it before representation construction or optimization.
!(assertEqual
  ((antRawTargetReached
     (mkExemplar
       (trailFollowerTree) (mkDemeId "target")
       (mkCscore 0 2 12.5 0.0 -12.5) (mkBScore (-89 89)))
     0)
   (antRawTargetReached
     (mkExemplar
       (trailFollowerTree) (mkDemeId "below-target")
       (mkCscore -1 2 12.5 0.0 -13.5) (mkBScore (-89 88)))
     0)
   (antRawTargetReached () 0))
  (True False False))

;; Invalid zero-work configurations terminate before entering hill climbing.
;; Restore the local limit immediately so no later assertion inherits the test.
!(assertEqual
  (let* (
         ($previousLocalLimit (param hcMaxEvalsAnt))
         ($zeroDemes (antExpansionEnabled 0))
         ($_zeroLocal (set-param hcMaxEvalsAnt 0))
         ($zeroLocal (antExpansionEnabled 2))
         ($_restore (set-param hcMaxEvalsAnt $previousLocalLimit))
        )
    ($zeroDemes $zeroLocal (antExpansionEnabled 2)))
  (False False True))

;; moses-ant-run seeds the counted loop with one initial simulation.  Starting
;; that loop at a one-call global limit must therefore return the seed without
;; constructing or optimizing a representation.
!(assertEqual
  (let* (
         ($previousBudget (param antMaxEvals))
         ($_limit (set-param antMaxEvals 1))
         ($result
           (runAntMosesCounted
             100 0 ((constantAntExemplar)) 0 2
             (antContextForTest) hillClimbing () 1))
         ($_restore (set-param antMaxEvals $previousBudget))
        )
    $result)
  ((constantAntExemplar)))

;; A small allowance is divided across both requested demes rather than being
;; consumed greedily by the first. It must never be exceeded, and the temporary
;; local HC limit must be restored for later callers. Exact scorer use remains
;; flexible because duplicate reduced trees can share one simulation.
!(assertEqual
  (let* (
         ($_seed (py-call (random.seed 10)))
         ($seedExemplar
           (mkExemplar
             (ant-exemplar) (mkDemeId "ant-budget-seed")
             (mkCscore -89 0 0.0 0.0 -89.0)
             (mkBScore (-89 0))))
         (($demes $used)
           (expandSelectedAntExemplarCounted
             $seedExemplar 3 2 (antContextForTest) hillClimbing 3))
        )
    ((> $used 0)
     (<= $used 3)
     (== (List.length $demes) 2)
     (get-state &antLocalEvalLimit)))
  (True True True -1))

;; A real ant representation may introduce semantically neutral `and_seq`
;; wrappers, so validate its default materialization by behavior and complexity
;; rather than exact syntax. This also exercises multimap order, knob indexes,
;; ASK defaults, materialization, and action reduction.
!(assertEqual
  (let* (
         ($_seed (py-call (random.seed 10)))
         ($rep
           (representation
             1
             (trailFollowerTree)
             (mkITable () ())
             None
             False
             ()
             mi
             True
             (ant-actions)
             (ant-perceptions)))
         ((mkRep (mkKbMap (mkDscMp $mmp)) $representedTree) $rep)
         ($defaultInstance (mkInst (createInitialInstance $mmp)))
         ($materialized
           ;; getCandidate already performs action-domain finalization; running
           ;; cleanActionTree a second time is not part of materialization.
           (getCandidate $rep (mkDemeId "ant-default-round-trip")
                         $defaultInstance))
         ($exemplar (trailFollowerTree))
        )
    ((== (scoreAntTree $materialized 600)
          (scoreAntTree $exemplar 600))
     (== (antTreeComplexity $materialized)
          (antTreeComplexity $exemplar))
     (not (== $materialized ()))))
  (True True True))

;; The ant behavioral-score protocol is loss baseline plus pellets eaten:
;; raw=-89+pellets, so pellets can be recovered as raw+89 without simulation.
!(assertEqual
  (let $storedCscore (mkCscore -86 1 6.25 0.0 -92.25)
    (mkBScore
      ((- 0 (ant-food-count))
       (+ (getScore $storedCscore) (ant-food-count)))))
  (mkBScore (-89 3)))

;; Ant deme merging must reuse the raw score already stored on a scored
;; instance.  The first two fields prove that the derived behavioral score is
;; identical to a direct trail simulation; the third proves that demeToTrees
;; carries the complete composite score through unchanged.
!(assertEqual
  (let* (
         ($storedCscore (mkCscore -86 1 6.25 0.0 -92.25))
         ($exemplars
           (demeToTrees
             (mkDeme
               (manualAntRep)
               (mkSInstSet
                 ((mkSInst (mkPair (mkInst (1)) $storedCscore))))
               (mkDemeId "ant-merge-score"))
             (antContextForTest)))
         ((mkExemplar $tree $demeId $retainedCscore $derivedBscore)
           (List.head $exemplars))
        )
    ($derivedBscore
     (scoreAntTree (cleanActionTree $tree) 600)
     $retainedCscore))
  ((mkBScore (-89 3))
   (mkBScore (-89 3))
   (mkCscore -86 1 6.25 0.0 -92.25)))

;; A raw-perfect instance can rank behind a much weaker but simpler instance
;; on penalized score.  The raw accumulator observes it before trimming, while
;; normal merge keeps only the penalized survivor in the selectable archive.
;; Restore every temporary merge parameter afterward.
!(assertEqual
  (let* (
         ($previousMaxCandidates (param maxCandPerDeme))
         ($previousMinPoolSize (param minPoolSize))
         ($previousTemperature (param complexityTemperature))
         ($_maxCandidates (set-param maxCandPerDeme 1))
         ($_minPool (set-param minPoolSize 0))
         ($_temperature (set-param complexityTemperature 1.0))
         ($penalizedWinner
           (mkSInst
             (mkPair (mkInst (0))
                     (mkCscore -78 0 0.0 0.0 -78.0))))
         ($rawPerfect
           (mkSInst
             (mkPair (mkInst (1))
                     (mkCscore 0 20 125.0 0.0 -125.0))))
         ($deme
           (mkDeme
             (manualAntRep)
             (mkSInstSet ($penalizedWinner $rawPerfect))
             (mkDemeId "ant-raw-champion")))
         ($trackedRaw
           (bestRawAntExemplarFromDemes
             ($deme) (antContextForTest)))
         ($merged
           (mergeDemes ($deme) (antContextForTest) ()))
         ($selectableRaw (bestRawAntExemplar $merged))
         ($bestPenalized (OS.getByIdx 0 $merged))
         ($summary
           ((getScore (getExemplarCscore $trackedRaw))
            (getScore (getExemplarCscore $selectableRaw))
            (getPenScore (getExemplarCscore $bestPenalized))
            (>= (getScore (getExemplarCscore $trackedRaw))
                (ant-best-possible-score))
            (OS.length $merged)))
         ($_restoreMaxCandidates
           (set-param maxCandPerDeme $previousMaxCandidates))
         ($_restoreMinPool
           (set-param minPoolSize $previousMinPoolSize))
         ($_restoreTemperature
           (set-param complexityTemperature $previousTemperature))
        )
    $summary)
  (0 -78 -78.0 True 1))

;; Raw-champion extraction happens before penalized trimming.  When behavioral
;; scores tie, it must expose the lower-complexity instance to the outer
;; accumulator; an exact raw/complexity tie retains the earlier row.
!(assertEqual
  (let* (
         ($first
           (mkSInst (mkPair (mkInst (0))
                            (mkCscore -3 4 25.0 0.0 -28.0))))
         ($simpler
           (mkSInst (mkPair (mkInst (1))
                            (mkCscore -3 2 12.5 0.0 -15.5))))
         ($exactTie
           (mkSInst (mkPair (mkInst (2))
                            (mkCscore -3 2 12.5 0.0 -15.5))))
        )
    (bestRawAntScoredInstance
      (mkSInstSet ($first $simpler $exactTie))))
  (mkSInst
    (mkPair (mkInst (1))
            (mkCscore -3 2 12.5 0.0 -15.5))))

;; Final conversion reserves an output slot for the independent raw champion,
;; but the selectable archive itself remains unchanged.  This mirrors C++'s
;; separate `_best_candidates` and `_scored_trees` collections.
!(assertEqual
  (let* (
         ($penalizedWinner
           (mkExemplar
             (antMoveTree) (mkDemeId "penalized")
             (mkCscore -78 0 0.0 0.0 -78.0)
             (mkBScore (-89 11))))
         ($rawPerfect
           (mkExemplar
             (trailFollowerTree) (mkDemeId "raw")
             (mkCscore 0 20 125.0 0.0 -125.0)
             (mkBScore (-89 89))))
         ($selectable ($penalizedWinner))
         ($trackedRaw
           (betterRawAntExemplar $penalizedWinner $rawPerfect))
         ($finished (finishAntMetapop $selectable $trackedRaw))
        )
    ((getScore
       (getExemplarCscore $trackedRaw))
     (getPenScore
       (getExemplarCscore (OS.getByIdx 0 $selectable)))
     (getScore
       (getExemplarCscore (bestRawAntExemplar $finished)))
     (OS.length $selectable)
     (OS.length $finished)))
  (0 -78.0 0 1 2))

;; Rediscovering the tracked raw tree under a different deme ID must not emit
;; the same program twice or displace another top-N result at finalization.
!(assertEqual
  (let* (
         ($retained
           (mkExemplar
             (trailFollowerTree) (mkDemeId "retained-id")
             (mkCscore -78 2 12.5 0.0 -90.5)
             (mkBScore (-89 11))))
         ($sameTreeChampion
           (mkExemplar
             (trailFollowerTree) (mkDemeId "champion-id")
             (mkCscore -78 2 12.5 0.0 -90.5)
             (mkBScore (-89 11))))
         ($finished
           (finishAntMetapop ($retained) $sameTreeChampion))
         ((mkExemplar $tree (mkDemeId $id) $cscore $bscore)
           (List.head $finished))
        )
    ((List.length $finished) $id))
  (1 "retained-id"))

;; Active coverage for the declarative diagnostic traversal lives in this
;; focused integration test instead of the expensive pipeline file.  Two demes
;; are mapped independently, flattened exactly one level, and counted without
;; re-evaluating their candidates.
!(assertEqual
  (let* (
         ($tree
           (mkTree (mkNode and_seq)
             ((mkTree (mkNode move_forward) ()))))
         ($rep (mkRep (mkKbMap (mkDscMp ())) $tree))
         ($scored (mkSInst (mkPair (mkInst ()) (worstCscore))))
         ($demes
           ((mkDeme $rep (mkSInstSet ($scored $scored))
                    (mkDemeId "diagnostic-1"))
            (mkDeme $rep (mkSInstSet ($scored))
                    (mkDemeId "diagnostic-2"))))
        )
    ((antDiagnosticDemeTrees $demes)
     (antDiagnosticEvaluationCount $demes)))
  (((mkTree (mkNode and_seq) ((mkTree (mkNode move_forward) ())))
    (mkTree (mkNode and_seq) ((mkTree (mkNode move_forward) ())))
    (mkTree (mkNode and_seq) ((mkTree (mkNode move_forward) ()))))
   3))

;; Raw fitness is folded independently while the penalized maximum comes from
;; the already ordered metapopulation head.
!(assertEqual
  (antMetapopBestScores
    ((mkExemplar
       (mkTree (mkNode and_seq) ()) (mkDemeId "penalized-best")
       (mkCscore -5 0 0 0 -10) (mkBScore (-5)))
     (mkExemplar
       (mkTree (mkNode move_forward) ()) (mkDemeId "raw-best")
       (mkCscore -2 0 0 0 -20) (mkBScore (-2)))))
  (-2 -10))

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

;; Distinct new knob vectors can materialize to one reduced action tree. They
;; must retain their original order and both receive the same Cscore, while the
;; actual-evaluation count records only one invocation of the ant simulator.
!(assertEqual
  (let* (
         ($rep (duplicateReducedAntRep))
         ($id (mkDemeId "ant-cleaned-tree-cache"))
         (($scoredSet $actualEvaluations)
           (transformAntIncremental
             (mkSInstSet
               ((mkSInst (mkPair (mkInst (1)) (worstCscore)))
                (mkSInst (mkPair (mkInst (2)) (worstCscore)))))
             $rep $id (antContextForTest)))
         ($tree1 (cleanActionTree (getCandidate $rep $id (mkInst (1)))))
         ($tree2 (cleanActionTree (getCandidate $rep $id (mkInst (2)))))
        )
    ($scoredSet $actualEvaluations (== $tree1 $tree2)))
  ((mkSInstSet
     ((mkSInst (mkPair (mkInst (1))
        (mkCscore -86 1 6.25 0.0 -92.25)))
      (mkSInst (mkPair (mkInst (2))
        (mkCscore -86 1 6.25 0.0 -92.25)))))
   1
   True))

!(assertEqual
  (let* (($plainMoveEaten (antFoodEaten (antRunTree (antMoveTree) 600)))
         ($trailFollowerEaten (antFoodEaten (antRunTree (trailFollowerTree) 600))))
    ($plainMoveEaten $trailFollowerEaten))
  (3 11))

!(assertEqual
  (let* (
         ($_seed (py-call (random.seed 10)))
         ((mkRep (mkKbMap (mkDscMp $mmp)) $tree)
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
             (ant-perceptions)))
        )
    (> (MultiMap.length $mmp) 0))
  True)
