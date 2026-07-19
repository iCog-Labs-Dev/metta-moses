;; End-to-end Santa Fe ant search regression.
;;
;; This deliberately runs several generations instead of stubbing the optimizer:
;; the test covers ant dispatch, action representation, hill climbing, scoring,
;; deme expansion, metapopulation merging, and FinalResult conversion.  Finding a
;; perfect 89-pellet program is reported, but is not required for the test to pass.

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

!(import! &self ../../../optimization/hillclimbing/cross-top-one-helpers)
!(import! &self ../../../optimization/hillclimbing/cross-top-one)
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
(= (antFinalScoresValid ()) True)
(= (antFinalScoresValid (cons ($treeExpr $score) $rest))
   (and (>= $score (- 0 (ant-food-count)))
        (and (<= $score (ant-best-possible-score))
             (antFinalScoresValid $rest))))

;; Rebuild and clean each returned expression, then verify that independent ant
;; simulation reproduces the behavioral score stored by the pipeline.
(= (antFinalRescoresMatch () $steps) True)
(= (antFinalRescoresMatch (cons ($treeExpr $score) $rest) $steps)
   (let $rescored
        (sumBScore (scoreAntTree (cleanActionTree (buildTree $treeExpr)) $steps))
     (and (== $rescored $score)
          (antFinalRescoresMatch $rest $steps))))

(= (antBestFinalRow (cons $row ())) $row)
(= (antBestFinalRow (cons ($treeExpr $score) $rest))
   (let ($bestTreeExpr $bestScore) (antBestFinalRow $rest)
     (if (>= $score $bestScore)
         ($treeExpr $score)
         ($bestTreeExpr $bestScore))))

;; The empty initial exemplar prints as `and_seq`.  Require the evolutionary
;; pipeline to return at least one materialized candidate in addition to merely
;; carrying that seed through unchanged.
(= (antHasMaterializedCandidate ()) False)
(= (antHasMaterializedCandidate (cons ($treeExpr $score) $rest))
   (if (== $treeExpr and_seq)
       (antHasMaterializedCandidate $rest)
       True))

!(set-param problem ant)
!(set-param seed 10)
;; Build two independently randomized representations from each selected
;; parent. The seed-10 search first reaches its -24 result at expansion 23; a
;; 50-generation trial found no later improvement while doubling pool growth,
;; so 25 generations is the evidence-based regression cutoff.
!(set-param maxGen 25)
!(set-param nDeme 2)
!(set-param optAlgo hc)
!(set-param antSteps 600)
;; A ratio of 0.20 lowers the per-node penalty from 6.25 to 5.0, allowing a raw
;; fitness gain to promote moderately larger trail-following trees more often.
!(set-param antComplexityRatio 0.20)
!(set-param antComplexityTemperature 2000)
;; Preserve breadth: retain dominated stepping stones and expand each program
;; only once while unvisited candidates remain available.
!(set-param antDiscardDominated False)
!(set-param antRevisit 0)
;; Print unique candidate coverage and raw/penalized progress each generation
;; so a stable plateau can be distinguished from insufficient exploration.
!(set-param antDiagnostics True)
!(set-param hcMaxDistAnt 4)
!(set-param hcMinXoverNeighborsAnt 400)
!(set-param hcMaxEvalsAnt 2000)
!(set-param hcWidenSearch False)
!(set-param hcCrossover True)
!(set-param maxCandPerDeme -1)

;; Keep all checks inside one assertion so the expensive search executes once.
!(assertEqual
  (let (FinalResult $rows) (moses-run)
    (let* (
           (($bestTreeExpr $bestScore) (antBestFinalRow $rows))
           ($pelletsEaten (+ (ant-food-count) $bestScore))
           ($_ (println! (AntSearchBestTree: $bestTreeExpr)))
           ($_ (println! (AntSearchBestScore: $bestScore)))
           ($_ (println! (AntSearchPelletsEaten: $pelletsEaten of (ant-food-count))))
           ($_ (if (== $bestScore (ant-best-possible-score))
                   (println! "ANT SEARCH FOUND A PERFECT 89-PELLET TREE")
                   (println! "Ant search completed without requiring a perfect tree"))))
      (and (> (List.length $rows) 0)
           (and (antFinalScoresValid $rows)
                (and (> $bestScore -28)
                     (and (antHasMaterializedCandidate $rows)
                          (antFinalRescoresMatch $rows (param antSteps))))))))
  True)
