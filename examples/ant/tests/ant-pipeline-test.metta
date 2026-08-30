;; Deterministic end-to-end Santa Fe ant perfect-convergence regression.
;;
;; The generation and evaluation limits are deliberately generous, but raw-target
;; termination ends the verified seed-1 search as soon as it finds a
;; perfect program. The test covers ant dispatch, action representation, hill
;; climbing, scoring, deme expansion, metapopulation merging, and FinalResult
;; conversion, and requires the evolved program to eat all 89 pellets.

!(import! &self ../../../utilities/general-helpers)
!(import! &self ../../../parameters/registry)
!(import! &self ../../../parameters/defaults)

!(import! &self ../../../utilities/list-methods)
!(import! &self ../../../utilities/pair)
!(import! &self ../../../utilities/map)
!(import! &self ../../../utilities/ordered-multimap)
!(import! &self ../../../utilities/ordered-set)
!(import! &self ../../../utilities/ordered-multiset)
!(import! &self ../../../utilities/nodeId)
!(import! &self ../../../utilities/lazy-random-selector)
!(import! &self ../../../utilities/lru-cache)
!(import! &self ../../../utilities/tree)

!(import! &self ../../../scoring/cacheSpace)
!(import! &self ../../../scoring/fitness)
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
!(import! &self ../../../representation/disc-probe)
!(import! &self ../../../representation/logical-probe)
!(import! &self ../../../representation/sample-logical-perms)
!(import! &self ../../../representation/add-logical-knobs)
!(import! &self ../../../representation/build-logical)
!(import! &self ../../../representation/logical-canonize)
!(import! &self ../../../representation/build-action)
!(import! &self ../../../representation/build-knobs)
!(import! &self ../../../representation/knob-mapper)
!(import! &self ../../../representation/representation)
!(import! &self ../../../representation/create-representation)
!(import! &self ../../../representation/instance)

!(import! &self ../../../scoring/complexity-based-scorer)
!(import! &self ../ant-domain)

!(import! &self ../../../optimization/hillclimbing/crossover-helpers)
!(import! &self ../../../optimization/hillclimbing/crossover)
!(import! &self ../../../optimization/hillclimbing/hill-climbing-helpers)

!(import! &self ../../../deme/create-deme)
!(import! &self ../../../moses/neighborhood-sampling)
!(import! &self ../../../metapopulation/exemplar-type)
!(import! &self ../../../metapopulation/exemplar-selection)
!(import! &self ../../../metapopulation/metapopulation)
!(import! &self ../../../deme/deme-id-creation)
!(import! &self ../../../deme/score-deme)
!(import! &self ../../../deme/merge-demes)
!(import! &self ../../../deme/expand-deme)
!(import! &self ../../../moses/demo-problems)

;; FinalResult rows have the form: (<pre-order action expression> <raw score>).
;; Raw ant score is -89 + pellets-eaten, so every valid result is in [-89, 0].
(= (antFinalScoresValid $rows)
   (foldl-atom $rows True $valid $row
     (let ($treeExpr $score) $row
       (and $valid
            (and (>= $score (- 0 (ant-food-count)))
                 (<= $score (ant-best-possible-score)))))))

;; Rebuild and clean each returned expression, then verify that independent ant
;; simulation reproduces the behavioral score stored by the pipeline.
(= (antFinalRescoresMatch $rows $steps)
   (foldl-atom $rows True $matches $row
     (let ($treeExpr $score) $row
       (let $rescored
            (sumBScore
              (scoreAntTree (cleanActionTree (buildTree $treeExpr)) $steps))
         (and $matches (== $rescored $score))))))


(= (antBestFinalRow (cons $firstRow $rest))
   (foldl-atom $rest $firstRow $bestRow $row
     (let* (
            (($bestTreeExpr $bestScore) $bestRow)
            (($treeExpr $score) $row)
           )
       (if (> $score $bestScore) $row $bestRow))))

;; The empty initial exemplar prints as `and_seq`.  Require the evolutionary
;; pipeline to return at least one materialized candidate in addition to merely
;; carrying that seed through unchanged.
(= (antHasMaterializedCandidate ()) False)
(= (antHasMaterializedCandidate (cons ($treeExpr $score) $rest))
   (if (== $treeExpr and_seq)
       (antHasMaterializedCandidate $rest)
       True))

!(set-param problem ant)
;; Repository history and repeated local runs verify this perfect trajectory.
;; Seed 10 is a separate near-perfect convergence experiment, not this fast
;; regression fixture.
!(set-param seed 1)
;; Use a generous generation ceiling for convergence. Target-score termination
;; stops the verified trajectory through expansion ID 2, so the ordinary suite
;; does not execute all 1,000 expansions.
!(set-param maxGen 1000)
;; Build two independently randomized representations around each selected tree.
!(set-param nDeme 2)
!(set-param optAlgo hc)
!(set-param steps 600)
;; getComplexityCoef is the inverse of this ratio. Raising it to 0.5 lowers the
;; per-action penalty from 6.25 to 2 while preserving penalized-score hill
;; climbing. That lets useful control structure survive long enough to evolve a
;; perfect complexity-8 tree, whose penalized score is -16 instead of -50.
!(set-param complexityRatio 0.5)
!(set-param complexityTemperature 2000)
;; Preserve breadth: retain dominated stepping stones and expand each program
;; only once while unvisited candidates remain available.
!(set-param discardDominated False)
!(set-param revisit 0)
;; C++-parity search always uses hot penalized-score Boltzmann selection.
;; Keep ordinary test output compact; detailed generation telemetry remains
;; available through --diagnostics=True for opt-in convergence runs.
!(set-param diagnostics False)
!(set-param maxDist 4)
!(set-param minXoverNeighbors 400)
;; This is a complete-run safety ceiling over actual scorer calls, not a request
;; to spend all 30,000. Remaining budget is shared by the generated demes.
!(set-param maxEvals 30000)
!(set-param hcWidenSearch False)
!(set-param hcCrossover True)
!(set-param maxCandPerDeme -1)

;; Keep all checks inside one assertion so the expensive search executes once.
;; Assert behavior and an independent rescore rather than one exact tree syntax;
;; the FinalResult may contain several semantically perfect programs.
!(assertEqual
  (let (FinalResult $rows) (moses-run)
    (case $rows
      (
        (() False)
        ((cons $firstRow $rest)
          (let* (
                 (($bestTreeExpr $bestScore) (antBestFinalRow $rows))
                 ($pelletsEaten (+ (ant-food-count) $bestScore))
                 ($initialExemplarScore
                   (sumBScore
                     (scoreAntTree (ant-exemplar) (param steps))))
                 ($scoresValid (antFinalScoresValid $rows))
                 ($hasMaterializedCandidate (antHasMaterializedCandidate $rows))
                 ($rescoresMatch
                   (antFinalRescoresMatch $rows (param steps)))
                 ($_ (println! (AntSearchBestTree: $bestTreeExpr)))
                 ($_ (println! (AntSearchBestScore: $bestScore)))
                 ($_ (println! (AntSearchPelletsEaten: $pelletsEaten of (ant-food-count))))
                 ($_ (if (== $bestScore (ant-best-possible-score))
                         (println! "ANT SEARCH FOUND A PERFECT 89-PELLET TREE")
                         (println! "ANT SEARCH FAILED TO FIND THE REQUIRED PERFECT TREE"))))
            (and $scoresValid
                 (and (== $bestScore (ant-best-possible-score))
                      (and (== $pelletsEaten (ant-food-count))
                           (and (> $bestScore $initialExemplarScore)
                                (and $hasMaterializedCandidate
                                     $rescoresMatch)))))))
      )))
  True)
