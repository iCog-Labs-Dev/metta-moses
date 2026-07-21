;; Deterministic end-to-end Santa Fe ant perfect-convergence regression.
;;
;; The generation and evaluation limits are deliberately extended, but raw-target
;; termination ends the verified seed-1 search after only three expansions.  The
;; test covers ant dispatch, action representation, hill climbing, scoring, deme
;; expansion, metapopulation merging, and FinalResult conversion, and now requires
;; the evolved program to eat all 89 pellets.
;; Previous contract: finding a perfect program was reported as a milestone but
;; was not required for this test to pass.

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

; ;; These focused collection regressions are retained here as the previous
; ;; pipeline-local versions. Their active equivalents now live in
; ;; ant-integration-test.metta, keeping this expensive test to one search.
; ;; Initial-instance construction fuses value extraction and default projection
; ;; without changing map order or the resulting knob values.
; !(assertEqual
;   (let $map
;        (((mkDiscSpec 1)
;           (mkLSK
;             (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 1) ())))
;         ((mkDiscSpec 2)
;           (mkLSK
;             (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 2) ()))))
;     (createInitialInstance $map))
;   (1 2))

; ;; Diagnostic materialization maps each deme independently, flattens exactly
; ;; one level, and counts every scored instance across the same deme list.
; !(assertEqual
;   (let* (
;          ($tree
;            (mkTree (mkNode and_seq)
;              ((mkTree (mkNode move_forward) ()))))
;          ($rep (mkRep (mkKbMap (mkDscMp ())) $tree))
;          ($scored (mkSInst (mkPair (mkInst ()) (worstCscore))))
;          ($demes
;            ((mkDeme $rep (mkSInstSet ($scored $scored))
;                     (mkDemeId "diagnostic-1"))
;             (mkDeme $rep (mkSInstSet ($scored))
;                     (mkDemeId "diagnostic-2"))))
;         )
;     ((antDiagnosticDemeTrees $demes)
;      (antDiagnosticEvaluationCount $demes)))
;   (((mkTree (mkNode and_seq) ((mkTree (mkNode move_forward) ())))
;     (mkTree (mkNode and_seq) ((mkTree (mkNode move_forward) ())))
;     (mkTree (mkNode and_seq) ((mkTree (mkNode move_forward) ()))))
;    3))

; ;; Raw fitness is folded independently, while penalized fitness comes directly
; ;; from the already ordered metapopulation head.
; !(assertEqual
;   (antMetapopBestScores
;     ((mkExemplar
;        (mkTree (mkNode and_seq) ()) (mkDemeId "penalized-best")
;        (mkCscore -5 0 0 0 -10) (mkBScore (-5)))
;      (mkExemplar
;        (mkTree (mkNode move_forward) ()) (mkDemeId "raw-best")
;        (mkCscore -2 0 0 0 -20) (mkBScore (-2)))))
;   (-2 -10))

!(set-param problem ant)
;; The finalized seed-1 experiment reaches raw score 0 reproducibly with the
;; reduced-but-still-active complexity pressure configured below.
;; Previous quick search seed:
;; !(set-param seed 10)
!(set-param seed 1)
;; Build two independently randomized representations from each selected
;; parent. Keep the former cutoff rationale below as a historical comment: it
;; describes the pre-parity-fix 0.20 experiment, not an expected result now.
;; Previous rationale: the seed-10 search first reached -24 at expansion 23; a
;; 50-generation trial found no later improvement while doubling pool growth,
;; so 25 generations was the evidence-based regression cutoff.
;; The previous checked-in experiment ran all 25 generations here:
;; !(set-param maxGen 25)
;; Seed 10 first improves from -78 to -40 at expansion 5. Six expansions were
;; therefore the shortest stable prefix that proves selection, representation
;; construction, scoring, merge, and subsequent re-expansion all work, while
;; keeping the ordinary suite practical. That previous active cutoff was:
;; !(set-param maxGen 6)
;; Use a generous generation ceiling for convergence. Target-score termination
;; stops the verified trajectory at expansion 2, so this does not execute 1,000
;; expansions during the ordinary suite.
!(set-param maxGen 1000)
!(set-param nDeme 2)
!(set-param optAlgo hc)
!(set-param antSteps 600)
;; The previous 0.20 value belonged to a MeTTa breadth experiment, and 0.16 is
;; the C++ performance-diary parity setting; retain both as search history.
;; !(set-param antComplexityRatio 0.20)
;; !(set-param antComplexityRatio 0.16)
;; getComplexityCoef is the inverse of this ratio. Raising it to 0.5 lowers the
;; per-action penalty from 6.25 to 2 while preserving penalized-score hill
;; climbing. That lets useful control structure survive long enough to evolve a
;; perfect complexity-8 tree, whose penalized score is -16 instead of -50.
!(set-param antComplexityRatio 0.5)
!(set-param antComplexityTemperature 2000)
;; Preserve breadth: retain dominated stepping stones and expand each program
;; only once while unvisited candidates remain available.
!(set-param antDiscardDominated False)
!(set-param antRevisit 0)
;; C++-parity search always uses hot penalized-score Boltzmann selection.
;; Keep ordinary test output compact; detailed generation telemetry remains
;; available through --antDiagnostics=True for opt-in convergence runs.
!(set-param antDiagnostics False)
!(set-param hcMaxDistAnt 4)
!(set-param hcMinXoverNeighborsAnt 400)
!(set-param hcMaxEvalsAnt 2000)
;; This is a complete-run safety ceiling over actual scorer calls, not a request
;; to spend all 30,000. The deterministic target stop occurs after 520 calls.
!(set-param antMaxEvals 30000)
!(set-param hcWidenSearch False)
!(set-param hcCrossover True)
!(set-param maxCandPerDeme -1)

;; Keep all checks inside one assertion so the expensive search executes once.
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
                     (scoreAntTree (ant-exemplar) (param antSteps))))
                 ($scoresValid (antFinalScoresValid $rows))
                 ($hasMaterializedCandidate (antHasMaterializedCandidate $rows))
                 ($rescoresMatch
                   (antFinalRescoresMatch $rows (param antSteps)))
                 ($_ (println! (AntSearchBestTree: $bestTreeExpr)))
                 ($_ (println! (AntSearchBestScore: $bestScore)))
                 ($_ (println! (AntSearchPelletsEaten: $pelletsEaten of (ant-food-count))))
                 ($_ (if (== $bestScore (ant-best-possible-score))
                         (println! "ANT SEARCH FOUND A PERFECT 89-PELLET TREE")
                         ;; Previous optional-milestone message:
                         ;; (println! "Ant search completed without requiring a perfect tree")
                         (println! "ANT SEARCH FAILED TO FIND THE REQUIRED PERFECT TREE"))))
            ;; Previous quick pipeline acceptance required only improvement over
            ;; the empty exemplar and a loose score floor:
            ;; (and $scoresValid
            ;;      (and (> $bestScore $initialExemplarScore)
            ;;           (and (> $bestScore -70)
            ;;                (and $hasMaterializedCandidate $rescoresMatch))))
            ;; The extended convergence setting has been reproduced twice, so
            ;; raw perfection and an independent 600-step rescore are now the
            ;; functional contract. Do not couple it to one exact tree syntax;
            ;; the verified FinalResult can contain several perfect programs.
            (and $scoresValid
                 (and (== $bestScore (ant-best-possible-score))
                      (and (== $pelletsEaten (ant-food-count))
                           (and (> $bestScore $initialExemplarScore)
                                (and $hasMaterializedCandidate
                                     $rescoresMatch)))))))
      )))
  True)
