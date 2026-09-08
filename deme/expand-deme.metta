;; Disc maps are ordered multimaps whose action comparator deliberately appends
;; equal/unordered specs. Reading them through the matching MultiMap API makes
;; that coordinate-order guarantee explicit instead of relying on the generic
;; Map implementation having the same list representation.

;; Recursively optimizes each deme in a list using the provided optimizer function.
;; Params:
;;   (List Deme): The list of demes to optimize.
;;   $context: The scoring context - either TruthTableBScore or tuple ($nGames $opponentPolicy)
;;   $inst: The initial instance for optimization.
;;   $optimize: The optimizer function to apply to each deme.
;;  Returns: (List Deme): A new list where each deme has been optimized.
; (: optimizeDemes (-> (List Deme) $context Instance $optimize (Instance Deme $state)))
;; Action version - tagged context, dispatched BEFORE the all-variable
;; catch-all below. Packs the episode count and complexity ratio for
;; the hillClimbing applyActionBasedScore arm (the fitness itself binds
;; globally through (param fitness) -- nothing to thread here).
(= (optimizeDemes $deme (mkActionCtx $nTrials $complexityRatio $targetScore) $inst $optimize)
   ($optimize $deme $targetScore $inst (mkParams applyActionBasedScore ($nTrials $complexityRatio))))
;; Boolean version - passes context as-is
(= (optimizeDemes $deme $context $inst $optimize)
   ($optimize $deme $context $inst))

;; Extracts default specification from a knob
; (: getKnobDefault (-> $knob Number))
;; (= (getKnobDefault (mkLSK (mkDiscKnob $multip $curr (mkDiscSpec $def) $dis))) $def)

;; Runs one deme-creation and optimization step, then merges the optimized deme into the metapopulation.
;; Params:
;;   $metaPop: The current metapopulation.
;;   $nExpansion: Expansion count or deme index.
;;   $nDeme: Number of demes to create.
;;   $truthTableBScore: TruthTableBScore
;;   $optimize: Optimizer function (e.g., hill climbing).
;;   $nEval: Maximum number of evaluations.
;;   $maxCandsPerDeme: Maximum candidates per deme.
;;   $minPoolSize: Minimum deme size to retain.
;;   $complexityTemperature: Parameter for score range in trimming.
;;   $itable: The input table.
;;   $nToKeep: Target size for resized metapopulation.
;;   $capCoef: Capacity coefficient for resizing.
;;   $genCount: Generation count for resizing.
;; Returns:
   ;;   $updatedMetaPop: Updated metapopulation with the new optimized deme merged in.
; (: expandDeme (-> (OS (Exemplar $a)) Number Number Bool Symbol (TruthTableBScore $a) (-> Deme (TruthTableBScore $a) Instance $Scorer (Instance Deme $state)) $Scorer Number Number Number Number (ITable $a) Number Number Number (OS (Exemplar $a))))
(= (expandDeme $metaPop $nExpansion $nDeme $prune-exemplar $fs-algo $truthTableBScore $optimize $itable $scorerType)
(let*
   (
    ;; ($_ (println! ""))
    ;; ($_ (println! (MetaPop: $metaPop)))
    ;; ($_ (println! "Selecting Exemplar"))
    ($exemplar (selectExemplar $metaPop))
    ;; ($_ (println! $exemplar))
    ;; ($_ (println! "getting exemplar tree"))
    ($tree (getExemplarTree $exemplar)) 
    ($_ (println! (SelectedTree: (preOrder $tree))))
    ;; ($_ (println! "creating deme IDs"))
    ($demeIds (createDemeIds $nExpansion $nDeme))
    ;; ($_ (println! $demeIds))
    ; ($argLabels (getArgLabels $itable))
    ;; ($_ (println! "Creating Deme"))
    ($demes (createDeme $nDeme $demeIds $tree $itable $fs-algo $prune-exemplar () $scorerType))
    )
    (map-atom $demes $deme (expandDemeHelper $deme $truthTableBScore $optimize))
   ))

;; Overloaded version for ACTION runs - 6 parameters, keyed by the tagged
;; (mkActionCtx $nTrials $complexityRatio) context runMoses passes, so it is
;; arity-correct end to end with its runMoses call site. This deme
;; boundary is where the knob vocabulary crosses from global params to
;; plain arguments: the ONE (param actions)/(param perceptions) read
;; happens here (already validated by moses-run-action's loud guard), and
;; createDeme/createRepresentation below receive the tuples as ordinary
;; parameters -- the representation layer never touches the params registry.
(= (expandDeme $metaPop $nExpansion $nDeme (mkActionCtx $nTrials $complexityRatio) $maxScore $optimize)
   (let* (($exemplar (selectExemplar $metaPop))
          ($tree (getExemplarTree $exemplar))
          ($_ (println! (SelectedTree: (preOrder $tree))))
          ($demeIds (createDemeIds $nExpansion $nDeme))
          ($actions (param actions))
          ($perceptions (param perceptions))
          ($demes (createDeme $nDeme $demeIds $tree $actions $perceptions))
          ($ctx (mkActionCtx $nTrials $complexityRatio $maxScore)))
     (map-atom $demes $deme (expandDemeHelper $deme $ctx $optimize))))

;; Invoke the shared optimizer with the argument shape required by the
;; domain scorer. Action scoring carries its raw target separately because
;; hill climbing optimizes the penalized score while terminating on raw score.
(= (optimizeDeme $deme $context $inst $optimize)
   (case $context
      (
        ((mkOptimizerContext (mkAntContext $steps $complexityRatio $actions $perceptions) $targetScore)
         ($optimize $deme $targetScore $inst (mkParams applyAntBasedScore (mkAntContext $steps $complexityRatio $actions $perceptions))))
        ((mkOptimizerContext (mkActionCtx $nTrials $complexityRatio) $targetScore)
         ($optimize $deme $targetScore $inst (mkParams applyActionBasedScore ($nTrials $complexityRatio))))
        (($nGames $complexityRatio $targetCScore)
         ($optimize $deme $targetCScore $inst (mkParams applyStrategyBasedScore ($nGames $complexityRatio))))
        ($other ($optimize $deme $context $inst))
      )))

;; Representation construction is the principal domain-specific expansion
;; operation. Deme IDs, budgeting, optimization, and merging remain shared.
(= (createSelectedDemes $exemplar $nExpansion $nDeme $context)
   (let* (
          ($tree (getExemplarTree $exemplar))
          ($demeIds (createDemeIds $nExpansion $nDeme))
         )
     (case $context
       (((mkAntContext $steps $ratio $actions $perceptions) (createDeme $nDeme $demeIds $tree $context))
        ((mkActionCtx $nTrials $cpxRatio) (createDeme $nDeme $demeIds $tree (param actions) (param perceptions)))
        (($prune $fsAlgo $truthTableBScore $itable) (createDeme $nDeme $demeIds $tree $itable $fsAlgo $prune () mi))
        (($nGames $opponentPolicy $ratio) (createDeme $nDeme $demeIds $tree))))))

;; Adapt the public problem context to the optimizer's existing input shape.
(= (optimizerContextFor $context $maxScore)
   (case $context
     (((mkAntContext $steps $ratio $actions $perceptions) (mkOptimizerContext $context $maxScore))
      ((mkActionCtx $nTrials $cpxRatio) (mkOptimizerContext $context $maxScore))
      (($prune $fsAlgo $truthTableBScore $itable) $truthTableBScore)
      (($nGames $opponentPolicy $ratio) ($nGames $ratio $maxScore)))) )

;; Adapt the public problem context to the candidate materializer used by
;; `demeToTrees` during the shared merge.
(= (mergeContextFor $context)
   (case $context
     (((mkAntContext $steps $ratio $actions $perceptions) $context)
      ((mkActionCtx $nTrials $cpxRatio) (mkActionCtx $nTrials))
      (($prune $fsAlgo $truthTableBScore $itable) $itable)
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
         (cacheCandidateScore $context (getExemplarTree $exemplar) (getExemplarCscore $exemplar))))
      ($other ()))))

;; Tree materialization is keyed by deme ID and instance. Boolean subtree
;; scores are additionally keyed only by expression, so a new table run must
;; clear that domain cache before scoring starts.
(= (resetDomainRunCaches $context)
   (let $_trees (clearSpace &treeSpace)
     (case $context
       ((($prune $fsAlgo $truthTableBScore (mkITable $rows $labels)) (resetSubtreeCache))
        ($other True)))))

(= (createInitialInstance $dscMp)
   (let $knobs (MultiMap.values $dscMp) (map-atom $knobs $knob (second (getKnobDefault $knob)))))

;; The ninth hill-climbing state field is the number of actual scorer calls.
(= (hillStateEvaluationCount ($alreadyXover $lastChance $hasImproved $prevCenter $prevStart
       $prevSize $bestCscore $bestScore $actualEvaluations $distance $iteration))
   $actualEvaluations)

;; Optimize one deme under its fair share of the remaining complete-run
;; allowance. The temporary state is restored for direct optimizer callers.
(= (optimizeDemeCounted (mkDeme (mkRep (mkKbMap (mkDscMp $dscKbMp)) $tree) $scoredInstances $demeId) $optimizerContext $optimize $localLimit)
   (let* (
          ($generatedList (createInitialInstance $dscKbMp))
          ($_generated
            (if (param diagnostics)
                (println! (GeneratedList: $generatedList))
                ()))
          ($deme (mkDeme (mkRep (mkKbMap (mkDscMp $dscKbMp)) $tree) $scoredInstances $demeId))
          ($_setLocalLimit (change-state! &localEvalLimit $localLimit))
          (($inst $optimizedDeme $state) (optimizeDeme $deme $optimizerContext (mkInst $generatedList) $optimize))
          ($_restoreLocalLimit (change-state! &localEvalLimit -1))
         )
     ($optimizedDeme (hillStateEvaluationCount $state))))

;; Divide a finite allowance evenly, assigning remainder calls to the earliest
;; demes. The sum of local shares never exceeds the remaining global budget.
(= (expandDemesWithShares () $optimizerContext $optimize $baseLimit $extraSlots) (() 0))
(= (expandDemesWithShares (cons $deme $rest) $optimizerContext $optimize $baseLimit $extraSlots)
   (let* (
          ($hasExtra (> $extraSlots 0))
          ($localLimit (+ $baseLimit (if $hasExtra 1 0)))
          ($nextExtra (if $hasExtra (- $extraSlots 1) 0))
         )
     (if (<= $localLimit 0)
         (() 0)
         (let* (
                (($optimizedDeme $used) (optimizeDemeCounted $deme $optimizerContext $optimize $localLimit))
                (($optimizedRest $restUsed) (expandDemesWithShares $rest $optimizerContext $optimize $baseLimit $nextExtra))
               )
           ((cons $optimizedDeme $optimizedRest) (+ $used $restUsed))))))

;; Allocate the remaining complete-run budget across all demes in this
;; expansion. A negative budget represents unlimited evaluation.
(= (expandDemesCounted () $optimizerContext $optimize $remainingBudget) (() 0))
(= (expandDemesCounted (cons $firstDeme $restDemes) $optimizerContext $optimize $remainingBudget)
   (let* (
          ($demeCount (List.length (cons $firstDeme $restDemes)))
          ($baseLimit
            (if (< $remainingBudget 0)
                (pow-math 10 18)
                (floor-math (/ $remainingBudget $demeCount))))
          ($extraSlots
            (if (< $remainingBudget 0)
                0
                (% $remainingBudget $demeCount)))
         )
     (expandDemesWithShares (cons $firstDeme $restDemes) $optimizerContext $optimize $baseLimit $extraSlots)))

;; Build and optimize every deme for an already selected exemplar, returning
;; both the optimized demes and the number of actual scorer calls they used.
(= (expandSelectedExemplarCounted $exemplar $nExpansion $nDeme $context $maxScore $optimize $remainingBudget)
   (let* (
          ($_selected
            (if (param diagnostics)
                (println! (SelectedTree: (preOrder (getExemplarTree $exemplar))))
                ()))
          ($demes (createSelectedDemes $exemplar $nExpansion $nDeme $context))
          ($optimizerContext (optimizerContextFor $context $maxScore))
         )
     (expandDemesCounted $demes $optimizerContext $optimize $remainingBudget)))

;; Diagnostics materialize each candidate once before treeSpace is cleared.
(= (diagnosticDemeTrees $demes)
   (List.flatten
     (map-atom $demes (mkDeme $rep (mkSInstSet $instances) $demeId)
         (map-atom $instances $scoredInst
           (getCandidate $rep $demeId (getInst $scoredInst))))))

;; Count retained instance rows across diagnostic demes without allocating an
;; intermediate list.
(= (diagnosticDemeRowCount $demes)
   (foldl-atom $demes 0 $count $deme
     (let (mkDeme $rep (mkSInstSet $instances) $demeId) $deme
       (+ $count (List.length $instances)))))

;; Breaks raw-score ties by lower complexity; an exact tie retains the earlier candidate.
(= (betterRawExemplar () $candidate) $candidate)
(= (betterRawExemplar $best ()) $best)
(= (betterRawExemplar $best $candidate)
   (bestRawExemplar ($best $candidate)))

;; Convert only a deme's raw-best scored row into an exemplar. This reuses its
;; attached score and does not invoke the problem scorer during diagnostics.
(= (rawBestExemplarFromDeme (mkDeme $rep $scoredInstances $demeId) $mergeContext)
   (let $rawBest (bestRawScoredInstance $scoredInstances)
     (if (== $rawBest ())
         ()
         (List.head (demeToTrees (mkDeme $rep (mkSInstSet ($rawBest)) $demeId) $mergeContext)))))

;; Fold the per-deme raw champions into one expansion-wide raw champion.
(= (bestRawExemplarFromDemes $demes $mergeContext)
   (foldl-atom $demes () $best $deme
     (betterRawExemplar $best (rawBestExemplarFromDeme $deme $mergeContext))))

;; Report raw and penalized archive leaders independently because complexity
;; penalties can make them different exemplars.
(= (metapopBestScores ()) ())
(= (metapopBestScores $metaPop)
   (let* (
          ($rawBest (bestRawExemplar $metaPop))
          ($penalizedBest (OS.getByIdx 0 $metaPop))
         )
     ((getScore (getExemplarCscore $rawBest)) (getExemplarPenScore $penalizedBest))))

;; Emit one generation record using already-computed selection, evaluation,
;; archive, raw-score, and penalized-score information.
(= (printGenerationDiagnostics
      $remainingGen $nExpansion $selectedExemplar $selectedVisitCount
      $optimizedDemes $updatedMetaPop ($bestRaw $bestPenalized)
      $actualEvaluations $cumulativeEvaluations)
   (let $candidateTrees (diagnosticDemeTrees $optimizedDemes)
     (println! (GenerationDiagnostics
                 (remaining $remainingGen)
                 (expansion $nExpansion)
                 (selected
                   (preOrder (getExemplarTree $selectedExemplar)))
                 (selectedVisits $selectedVisitCount)
                 (actualNewEvaluations $actualEvaluations)
                 (cumulativeEvaluations $cumulativeEvaluations)
                 (uniqueCandidates
                   (length (unique-atom $candidateTrees)))
                 (retainedCandidates (OS.length $updatedMetaPop))
                 (bestRaw $bestRaw)
                 (bestPenalized $bestPenalized)))))

;; Penalized order governs the selectable archive, while one output slot is
;; reserved for the independently tracked raw champion.
(= (metapopContainsTree $metaPop $tree)
   (foldl-atom $metaPop False $contains $candidate
     (or $contains (== (getExemplarTree $candidate) $tree))))

;; Limit final output by penalized order while ensuring the independently
;; tracked raw champion is not lost.
(= (finishMetapop $metaPop $rawBest)
   (let $limit (param maxCandOutput)
     (if (<= $limit 0)
         ()
         (let $topCandidates
                      (if (<= $limit (OS.length $metaPop))
                          (OS.getTopN $limit $metaPop)
                          $metaPop)
           (if (== $rawBest ())
               $topCandidates
               (let $rawTree (getExemplarTree $rawBest)
                 (if (metapopContainsTree $topCandidates $rawTree)
                     $topCandidates
                     (cons $rawBest (OS.takeN (- $limit 1) $topCandidates)))))))))

;; Compatibility overload derives the raw champion from a non-empty archive.
(= (finishMetapop $metaPop)
   (if (== $metaPop ())
       ()
       (finishMetapop $metaPop (bestRawExemplar $metaPop))))

;; Advance generation and expansion counters after an exemplar produces no
;; optimizable representation, without charging an evaluation.
(= (emptyRepresentationRetryState $maxGen $nExpansion $updatedVisits $cumulativeEvaluations)
   ;; A failed representation consumes one bounded expansion attempt. Without
   ;; this transition, `revisit < 0` could select an intrinsically unexpandable
   ;; tree forever without spending either generation or evaluation budget.
   ((- $maxGen 1) (+ $nExpansion 1) $updatedVisits $cumulativeEvaluations))

;; Test whether the complete-run scorer-call allowance has been exhausted.
;; A negative configured allowance is unlimited.
(= (evaluationBudgetReached $actualEvaluations)
   (let $budget (param maxEvals) (if (< $budget 0) False (>= $actualEvaluations $budget))))

;; Return the unspent complete-run allowance, preserving -1 as the unlimited
;; sentinel expected by counted expansion.
(= (remainingEvaluationBudget $actualEvaluations)
   (let $budget (param maxEvals)
     (if (< $budget 0) -1 (max 0 (- $budget $actualEvaluations)))))

;; Termination uses raw fitness, not the complexity-penalized archive order.
(= (rawTargetReached () $maxScore) False)
(= (rawTargetReached (mkExemplar $tree $demeId
                      (mkCscore $raw $complexity $complexityPenalty
                            $diversityPenalty $penalizedScore)
                  $bscore)
      $maxScore)
   (>= $raw $maxScore))

;; A zero-deme configuration intentionally disables expansion.
(= (expansionEnabled $nDeme) (> $nDeme 0))

;; One shared loop handles visits, budgets, expansion, merging, raw-target
;; termination, and finalization for every problem family. The main public entry
;; keeps the init state inline and avoids any extra helper layer.
(= (runMoses $maxGen $maxScore $metaPop $nExpansion $nDeme $context $optimize)
(let* (
          ($_reset (resetCandidateScoreCache))
          ($_domainReset (resetDomainRunCaches $context))
          ($_seed (seedInitialCandidateCache $context $metaPop))
          ($initialEvaluations (initialEvaluationCount $context))
          ($rawChampion (if (== $metaPop ()) () (bestRawExemplar $metaPop)))
          ($initialVisits ())
         )
     (if (or (<= $maxGen 0)
           (or (rawTargetReached $rawChampion $maxScore)
             (or (not (expansionEnabled $nDeme))
               (evaluationBudgetReached $initialEvaluations))))
         (finishMetapop $metaPop $rawChampion)
         (let $eligible (eligibleExemplars $metaPop $initialVisits (param revisit))
           (if (== $eligible ())
               (finishMetapop $metaPop $rawChampion)
               (runMosesCountedWithBestSelected $maxGen $maxScore $metaPop $nExpansion $nDeme $context $optimize $initialVisits $initialEvaluations $rawChampion $eligible))))))

(= (runMosesCounted $maxGen $maxScore $metaPop $nExpansion $nDeme $context $optimize $visits $cumulativeEvaluations)
   (let $rawChampion (if (== $metaPop ()) () (bestRawExemplar $metaPop))
     (if (or (<= $maxGen 0)
           (or (rawTargetReached $rawChampion $maxScore)
             (or (not (expansionEnabled $nDeme))
               (evaluationBudgetReached $cumulativeEvaluations))))
         (finishMetapop $metaPop $rawChampion)
         (let $eligible (eligibleExemplars $metaPop $visits (param revisit))
           (if (== $eligible ())
               (finishMetapop $metaPop $rawChampion)
               (runMosesCountedWithBestSelected $maxGen $maxScore $metaPop $nExpansion $nDeme $context $optimize $visits $cumulativeEvaluations $rawChampion $eligible))))))

(= (runMosesCountedWithBestSelected $maxGen $maxScore $metaPop $nExpansion $nDeme
                                    $context $optimize $visits $cumulativeEvaluations $rawChampion
                                    $eligible)
   (let* (
          ($exemplar (selectExemplar $eligible))
          ($tree (getExemplarTree $exemplar))
          ($updatedVisits (recordVisit $tree $visits))
          ($selectedVisitCount (visitCount $tree $updatedVisits))
          ($_selection
            (if (param diagnostics)
                (println! (ExemplarSelection
                  (expansion $nExpansion)
                  (selectedRaw (getScore (getExemplarCscore $exemplar)))
                  (selectedPenalized (getExemplarPenScore $exemplar))
                  (eligibleCandidates (List.length $eligible))))
                ()))
          (($optimizedDemes $actualEvaluations)
            (expandSelectedExemplarCounted $exemplar $nExpansion $nDeme $context $maxScore $optimize (remainingEvaluationBudget $cumulativeEvaluations)))
          )
      (if (== $optimizedDemes ())
          (let* (
                ($_skipped
                  (if (param diagnostics)
                      (println! (RepresentationSkipped (expansion $nExpansion) (selected (preOrder $tree)) (reason emptyKnobMap)))
                      ()))
                ($_clear (clearSpace &treeSpace))
                ($_cut (cut))
                )
            (let ($retryGen $retryExpansion $retryVisits $retryEvaluations)
                    (emptyRepresentationRetryState $maxGen $nExpansion $updatedVisits $cumulativeEvaluations)
              (runMosesCounted $retryGen $maxScore $metaPop $retryExpansion $nDeme $context $optimize $retryVisits $retryEvaluations)))
          (let* (
                ($updatedEvaluations (+ $cumulativeEvaluations $actualEvaluations))
                ($mergeContext (mergeContextFor $context))
                ($generationRawBest (bestRawExemplarFromDemes $optimizedDemes $mergeContext))
                ($updatedRawBest (betterRawExemplar $rawChampion $generationRawBest))
                ($updatedMetaPop (mergeDemes $optimizedDemes $mergeContext $metaPop))
                ($bestRaw (getScore (getExemplarCscore $updatedRawBest)))
                ($bestPenalized
                  (if (== $updatedMetaPop ())
                      ()
                      (getExemplarPenScore (OS.getByIdx 0 $updatedMetaPop))))
                ($_diagnostics
                  (if (param diagnostics)
                      (printGenerationDiagnostics $maxGen $nExpansion $exemplar $selectedVisitCount $optimizedDemes $updatedMetaPop ($bestRaw $bestPenalized) $actualEvaluations $updatedEvaluations)
                      ()))
                ($_clear (clearSpace &treeSpace))
                ($_cut (cut))
                )
            (if (or (>= $bestRaw $maxScore) (evaluationBudgetReached $updatedEvaluations))
                (finishMetapop $updatedMetaPop $updatedRawBest)
                (runMosesCounted (- $maxGen 1) $maxScore $updatedMetaPop (+ $nExpansion 1) $nDeme $context $optimize $updatedVisits $updatedEvaluations))))))
;; Final-result conversion helpers.
(= (mapG $f $xs) (map-atom $xs $f))

(= (printExemplar (mkExemplar $tree $demeId $cscore $bscore)) (println! (Tree: (preOrder $tree) CScore: $cscore Bscore: $bscore)))
;; The (tree score) pair is quote-built: preOrder of a childless exemplar
;; is a bare operator symbol (e.g. and_seq), and an unquoted ($p $s) pair
;; headed by it would curry into a partial term now that action operators
;; are bare clause heads. quote substitutes the bound values and strips
;; once, yielding the plain pair.
(= (cleanedExemplar (mkExemplar $tree $demeId $cscore (mkBScore $bscore)))
   (let* (($p (preOrder $tree))
          ($s (List.sum $bscore)))
     (quote ($p $s))))

(= (printInstance (mkInst $inst)) (println! (List.listToExpr $inst)))
