;; ============================================================
;;  Domain adapter for the shared MOSES lifecycle.
;;
;;  `expand-deme.metta` owns only domain-neutral search mechanics. This file
;;  is the single boundary that translates a problem's scoring context into
;;  the representation constructor, optimizer arguments, merge context, and
;;  run-initialization behavior required by that problem.
;;
;;  Adding another problem family should extend these adapter operations
;;  instead of adding another expansion or outer-search loop.
;; ============================================================

;; Invoke the shared optimizer with the argument shape required by the
;; domain scorer. Action scoring carries its raw target separately because
;; hill climbing optimizes the penalized score while terminating on raw score.
(= (optimizeDeme $deme $context $inst $optimize)
   (case $context
      (
        ((mkOptimizerContext
           (mkAntContext $steps $complexityRatio $actions $perceptions)
           $targetScore)
         ($optimize
           $deme $targetScore $inst
           (mkParams applyAntBasedScore
             (mkAntContext
               $steps $complexityRatio $actions $perceptions))))
        (($nGames $complexityRatio $targetCScore)
         ($optimize $deme $targetCScore $inst
                    (mkParams applyStrategyBasedScore
                              ($nGames $complexityRatio))))
        ($other
         ($optimize $deme $context $inst))
      )))

;; Representation construction is the principal domain-specific expansion
;; operation. Deme IDs, budgeting, optimization, and merging remain shared.
(= (createSelectedDemes $exemplar $nExpansion $nDeme $context)
   (let* (
          ($tree (getExemplarTree $exemplar))
          ($demeIds (createDemeIds $nExpansion $nDeme))
         )
     (case $context
       (((mkAntContext $steps $ratio $actions $perceptions)
          (createDeme $nDeme $demeIds $tree $context))
        (($prune $fsAlgo $truthTableBScore $itable)
          (createDeme $nDeme $demeIds $tree $itable
                      $fsAlgo $prune () mi))
        (($nGames $opponentPolicy $ratio)
          (createDeme $nDeme $demeIds $tree))))))

;; Adapt the public problem context to the optimizer's existing input shape.
(= (optimizerContextFor $context $maxScore)
   (case $context
     (((mkAntContext $steps $ratio $actions $perceptions)
       (mkOptimizerContext $context $maxScore))
      (($prune $fsAlgo $truthTableBScore $itable) $truthTableBScore)
      (($nGames $opponentPolicy $ratio)
       ($nGames $ratio $maxScore)))))

;; Adapt the public problem context to the candidate materializer used by
;; `demeToTrees` during the shared merge.
(= (mergeContextFor $context)
   (case $context
     (((mkAntContext $steps $ratio $actions $perceptions) $context)
      (($prune $fsAlgo $truthTableBScore $itable) $itable)
      ;; Strategy merge historically scores against the game-count scalar.
      (($nGames $opponentPolicy $ratio) $nGames))))

;; Stateful action setup evaluates its seed once. Boolean and strategy setup
;; use synthetic known-worst scores and therefore spend no scorer call.
(= (initialEvaluationCount $context)
   (case $context
     (((mkAntContext $steps $ratio $actions $perceptions) 1)
      ($other 0))))

;; Only a seed that was genuinely evaluated belongs in the run-wide candidate
;; cache. Other domains will cache their first materialized candidate normally.
(= (seedInitialCandidateCache $context $metaPop)
   (case $context
     (((mkAntContext $steps $ratio $actions $perceptions)
       (map-atom $metaPop $exemplar
         (cacheCandidateScore
           $context
           (getExemplarTree $exemplar)
           (getExemplarCscore $exemplar))))
      ($other ()))))

;; Tree materialization is keyed by deme ID and instance. Boolean subtree
;; scores are additionally keyed only by expression, so a new table run must
;; clear that domain cache before scoring starts.
(= (resetDomainRunCaches $context)
   (let $_trees (clearSpace &treeSpace)
     (case $context
       ((($prune $fsAlgo $truthTableBScore
          (mkITable $rows $labels))
         (resetSubtreeCache))
        ($other True)))))
