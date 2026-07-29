;; Disc maps are ordered multimaps whose action comparator deliberately appends
;; equal/unordered specs. Reading them through the matching MultiMap API makes
;; that coordinate-order invariant explicit instead of relying on the generic
;; Map implementation having the same list representation.
(= (createInitialInstance $dscMp)
   (let $knobs (MultiMap.values $dscMp)
     (map-atom $knobs $knob
       (second (getKnobDefault $knob)))))

;; Recursively optimizes each deme in a list using the provided optimizer function.
;; Params:
;;   (List Deme): The list of demes to optimize.
;;   $context: The scoring context - either TruthTableBScore or tuple ($nGames $opponentPolicy)
;;   $inst: The initial instance for optimization.
;;   $optimize: The optimizer function to apply to each deme.
;;  Returns: (List Deme): A new list where each deme has been optimized.
; (: optimizeDemes (-> (List Deme) $context Instance $optimize (Instance Deme $state)))
(= (optimizeDemes $deme $context $inst $optimize)
   (case $context
      (
        ((mkAntContext $steps $complexityRatio $actions $perceptions)
         ($optimize $deme (ant-best-possible-score) $inst
                    (mkParams applyAntBasedScore $context)))
        (($nGames $complexityRatio $targetCScore)
         ($optimize $deme $targetCScore $inst
                    (mkParams applyStrategyBasedScore ($nGames $complexityRatio))))
        ($other
         ($optimize $deme $context $inst))
      )))

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

;; Overloaded version for game strategy domain - 8 parameters
(= (expandDeme $metaPop $nExpansion $nDeme $nGames $complexityRatio $targetCScore $optimize)
   (let*
      (
         ($exemplar (trace! "Selecting Exemplar" (selectExemplar $metaPop)))
         ($tree (trace! "getting exemplar tree" (getExemplarTree $exemplar)))
         ($demeIds (trace! "creating deme IDs" (createDemeIds $nExpansion $nDeme)))
         ($demes (trace! "Creating Deme" (createDeme $nDeme $demeIds $tree)))
         ($gameContext ($nGames $complexityRatio $targetCScore))
      )
      (map-atom $demes $deme (expandDemeHelper $deme $gameContext $optimize))))

;; Ant action-domain expansion. Generic/direct callers select here, while the
;; ant-specific outer loop passes its already selected exemplar to the helper.
(= (expandDeme $metaPop $nExpansion $nDeme (mkAntContext $steps $complexityRatio $actions $perceptions) $optimize)
   (let $exemplar (trace! "Selecting Exemplar" (selectExemplar $metaPop))
     (expandSelectedAntExemplar
       $exemplar $nExpansion $nDeme
       (mkAntContext $steps $complexityRatio $actions $perceptions)
       $optimize)))

;; The ant-specific outer loop selects and marks an exemplar before expansion,
;; then calls this helper so selection cannot accidentally happen a second time.
(= (expandSelectedAntExemplar $exemplar $nExpansion $nDeme
                             (mkAntContext $steps $complexityRatio $actions $perceptions)
                             $optimize)
   (let* (
          ($context (mkAntContext $steps $complexityRatio $actions $perceptions))
          ($tree (getExemplarTree $exemplar))
          ($_ (println! (SelectedTree: (preOrder $tree))))
          ($demeIds (createDemeIds $nExpansion $nDeme))
          ($demes (createDeme $nDeme $demeIds $tree $context))
         )
     (map-atom $demes $deme (expandDemeHelper $deme $context $optimize))))

;; Unified helper for both Boolean and Strategy domains
;; Optimizes each deme in the list using the provided optimizer and context
;; Params:
;;   $deme: Deme to optimize
;;   $context: Scoring context (ITable for Boolean, tuple for Strategy)
;;   $optimize: Optimizer function
;; Returns: Optimized deme with scored instances
(= (expandDemeHelper (mkDeme (mkRep (mkKbMap (mkDscMp $dscKbMp)) $updatedTree) $sInstList $demeId) $context $optimize)
(let*
(
    ($generatedList (createInitialInstance $dscKbMp))
    ($_ (println! (GeneratedList: $generatedList)))
    ($deme (mkDeme (mkRep (mkKbMap (mkDscMp $dscKbMp)) $updatedTree) $sInstList $demeId))
    ;; ($_ (println! (Rep: (mkRep (mkKbMap (mkDscKbMp $dscKbMp) (mkDscMp $dscMp)) $updatedTree))))
    ;; ($_ (println! "Optimizing Deme"))
    (($inst $optimDeme $state) (optimizeDemes $deme $context (mkInst $generatedList) $optimize))
)
$optimDeme
))

;; The ant hill-climbing state carries the count of actual scorer invocations
;; in its ninth field.  Extracting that field lets the outer search enforce a
;; real evaluation budget instead of estimating work from the deme length.
(= (antHillStateEvaluationCount
      ($alreadyXover $lastChance $hasImproved $prevCenter $prevStart
       $prevSize $bestCscore $bestScore $actualEvaluations $distance $iteration))
   $actualEvaluations)

;; Optimize one ant deme under an explicit remaining-call limit.  The local
;; limit state is reset immediately afterward so direct/generic callers retain
;; the configured hcMaxEvalsAnt behavior.
(= (expandAntDemeHelperCounted
      (mkDeme (mkRep (mkKbMap (mkDscMp $dscKbMp)) $updatedTree)
              $sInstList $demeId)
      $context $optimize $localLimit)
   (let* (
          ($generatedList (createInitialInstance $dscKbMp))
          ($_generatedDiagnostics
            (if (param antDiagnostics)
                (println! (GeneratedList: $generatedList))
                ()))
          ($deme
            (mkDeme (mkRep (mkKbMap (mkDscMp $dscKbMp)) $updatedTree)
                    $sInstList $demeId))
          ($_setLocalLimit (change-state! &antLocalEvalLimit $localLimit))
          (($inst $optimizedDeme $state)
            (optimizeDemes $deme $context (mkInst $generatedList) $optimize))
          ($_restoreLocalLimit (change-state! &antLocalEvalLimit -1))
         )
     ($optimizedDeme (antHillStateEvaluationCount $state))))

;; Optimize with a fixed fair share. C++ divides the expansion allowance by
;; deme count; MeTTa distributes the integer remainder across the earliest
;; demes as one extra call so a small positive global remainder still makes
;; progress. The sum of local limits never exceeds the outer allowance.
(= (expandAntDemesWithShares
      () $context $optimize $baseLimit $extraSlots)
   (() 0))
(= (expandAntDemesWithShares
      (cons $deme $rest) $context $optimize $baseLimit $extraSlots)
   (let* (
          ($hasExtra (> $extraSlots 0))
          ($localLimit (+ $baseLimit (if $hasExtra 1 0)))
          ($nextExtra (if $hasExtra (- $extraSlots 1) 0))
         )
     (if (<= $localLimit 0)
         (() 0)
         (let* (
                (($optimizedDeme $used)
                  (expandAntDemeHelperCounted
                    $deme $context $optimize $localLimit))
                (($optimizedRest $restUsed)
                  (expandAntDemesWithShares
                    $rest $context $optimize $baseLimit $nextExtra))
               )
           ((cons $optimizedDeme $optimizedRest)
            (+ $used $restUsed))))))

(= (expandAntDemesCounted () $context $optimize $remainingBudget) (() 0))
(= (expandAntDemesCounted (cons $firstDeme $restDemes)
                           $context $optimize $remainingBudget)
   (let* (
          ($demes (cons $firstDeme $restDemes))
          ($demeCount (List.length $demes))
          ($configuredLocalLimit (param hcMaxEvalsAnt))
          ($capacity
            (if (< $remainingBudget 0)
                (* $configuredLocalLimit $demeCount)
                (min $remainingBudget
                     (* $configuredLocalLimit $demeCount))))
          ($baseLimit (floor-math (/ $capacity $demeCount)))
          ($extraSlots (% $capacity $demeCount))
         )
     (expandAntDemesWithShares
       $demes $context $optimize $baseLimit $extraSlots)))

;; The counted helper returns both optimized demes and actual scorer calls.
;; The uncounted helper remains available to generic and direct callers.
(= (expandSelectedAntExemplarCounted
      $exemplar $nExpansion $nDeme
      (mkAntContext $steps $complexityRatio $actions $perceptions)
      $optimize $remainingBudget)
   (let* (
          ($context (mkAntContext $steps $complexityRatio $actions $perceptions))
          ($tree (getExemplarTree $exemplar))
          ($_selectedDiagnostics
            (if (param antDiagnostics)
                (println! (SelectedTree: (preOrder $tree)))
                ()))
          ($demeIds (createDemeIds $nExpansion $nDeme))
          ($demes (createDeme $nDeme $demeIds $tree $context))
         )
     (expandAntDemesCounted
       $demes $context $optimize $remainingBudget)))

;; Ant search diagnostics materialize and clean each optimized instance before
;; counting it.  This reports distinct candidate programs, not merely sampled
;; knob vectors, because several vectors can reduce to the same action tree.
(= (antDiagnosticDemeTrees $demes)
   (List.flatten
     (map-atom $demes $deme
       (let (mkDeme $rep (mkSInstSet $instances) $demeId) $deme
         (map-atom $instances $scoredInst
           (cleanActionTree
             (getCandidate $rep $demeId (getInst $scoredInst))))))))

;; Emit one compact record after each merge.  Raw and penalized maxima are
;; reported independently because the strongest food-eating program need not
;; be the program preferred by complexity-penalized hill climbing.
(= (antDiagnosticEvaluationCount $demes)
   (foldl-atom $demes 0 $count $deme
     (let (mkDeme $rep (mkSInstSet $instances) $demeId) $deme
       (+ $count (List.length $instances)))))

;; Select the stronger of two independently stored raw champions.  C++ breaks
;; raw-score ties by lower complexity; an exact tie keeps the earlier result.
;; This helper remains beside the specialized ant outer loop; moving it into
;; exemplar-selection causes PeTTa to leave that specialized call unresolved.
(= (betterRawAntExemplar () $candidate) $candidate)
(= (betterRawAntExemplar $best ()) $best)
(= (betterRawAntExemplar $best $candidate)
   (let* (
          ($bestCscore (getExemplarCscore $best))
          ($candidateCscore (getExemplarCscore $candidate))
          ($bestRaw (getScore $bestCscore))
          ($candidateRaw (getScore $candidateCscore))
         )
     (if (> $candidateRaw $bestRaw)
         $candidate
         (if (< $candidateRaw $bestRaw)
             $best
             (if (< (getComp $candidateCscore)
                    (getComp $bestCscore))
                 $candidate
                 $best)))))

;; Materialize only the raw-best row from a completed deme.  demeToTrees uses
;; its stored Cscore to reconstruct the ant BScore, so this does not invoke the
;; simulator and does not alter the actual-evaluation count.
(= (rawBestAntExemplarFromDeme
      (mkDeme $rep $scoredInstances $demeId) $context)
   (let $rawBest (bestRawAntScoredInstance $scoredInstances)
     (if (== $rawBest ())
         ()
         (List.head
           (demeToTrees
             (mkDeme $rep (mkSInstSet ($rawBest)) $demeId)
             $context)))))

;; Fold all independently randomized demes without inserting their raw
;; champions into the penalized metapopulation used for future selection.
(= (bestRawAntExemplarFromDemes $demes $context)
   (foldl-atom $demes () $best $deme
     (betterRawAntExemplar
       $best (rawBestAntExemplarFromDeme $deme $context))))

(= (printAntGenerationDiagnostics $remainingGen $nExpansion $selectedExemplar
                                  $visitCount $optimizedDemes $updatedMetaPop
                                  ($bestRaw $bestPenalized)
                                  $actualEvaluations $cumulativeEvaluations)
   (let* (
          ($candidateTrees (antDiagnosticDemeTrees $optimizedDemes))
          ($uniqueCandidates (length (unique-atom $candidateTrees)))
         )
     (println! (AntGenerationDiagnostics
                 (remaining $remainingGen)
                 (expansion $nExpansion)
                 (selected (preOrder (getExemplarTree $selectedExemplar)))
                 (visitCount $visitCount)
                 (actualNewEvaluations $actualEvaluations)
                 (cumulativeEvaluations $cumulativeEvaluations)
                 (uniqueCandidates $uniqueCandidates)
                 (retainedCandidates (OS.length $updatedMetaPop))
                 (bestRaw $bestRaw)
                 (bestPenalized $bestPenalized)))))

;; Compatibility overload for direct callers of generic runMoses with an ant
;; context; the normal ant dispatcher uses the richer explicit form above.
(= (printAntGenerationDiagnostics $remainingGen $optimizedDemes $updatedMetaPop)
   (let $legacyCount (antDiagnosticEvaluationCount $optimizedDemes)
     (printAntGenerationDiagnostics $remainingGen 0
       (OS.getByIdx 0 $updatedMetaPop) 0 $optimizedDemes $updatedMetaPop
       (antMetapopBestScores $updatedMetaPop) $legacyCount $legacyCount)))

;; The metapopulation is already ordered by penalized score, so only raw score
;; needs a full traversal.
(= (antMetapopBestScores $metaPop)
   (let* (
          ($rawBest (bestRawAntExemplar $metaPop))
          ($rawCscore (getExemplarCscore $rawBest))
          ($penalizedBest (OS.getByIdx 0 $metaPop))
         )
     ((getScore $rawCscore) (getExemplarPenScore $penalizedBest))))

;; Common ant-loop finish helper. Penalized order governs the selectable
;; metapopulation, while one output slot is reserved for the separately tracked
;; raw champion.  That candidate never feeds back into roulette selection.
;; Tree membership is a stateless collection reduction. Reuse the Exemplar
;; accessor instead of recursively duplicating its constructor shape.
(= (antMetapopContainsTree $metaPop $tree)
   (foldl-atom $metaPop False $contains $candidate
     (or $contains (== (getExemplarTree $candidate) $tree))))

(= (finishAntMetapop $metaPop $rawBest)
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
                 ;; Deduplicate by tree because rediscovery can change deme ID.
                 (if (antMetapopContainsTree $topCandidates $rawTree)
                     $topCandidates
                     (cons $rawBest
                           (OS.takeN (- $limit 1) $topCandidates)))))))))

;; Compatibility overload for callers that have only a metapopulation.  The
;; counted ant loop always calls the explicit two-argument form.
(= (finishAntMetapop $metaPop)
   (if (== $metaPop ())
       ()
       (finishAntMetapop $metaPop (bestRawAntExemplar $metaPop))))

;; Make the no-charge retry transition explicit and directly testable.  The
;; selected exemplar is already recorded in $updatedVisits; every generation,
;; expansion, and evaluation counter is deliberately unchanged.
(= (antEmptyRepresentationRetryState
      $maxGen $nExpansion $updatedVisits $cumulativeEvaluations)
   ($maxGen $nExpansion $updatedVisits $cumulativeEvaluations))

;; Ant-only outer MOSES loop.  It preserves stepping stones, expands each tree
;; according to antRevisit, increments expansion IDs, and checks the newly
;; merged population rather than the pre-expansion one.
(= (runAntMoses $maxGen $maxScore $metaPop $nExpansion $nDeme $context
                $optimize $visits)
   ;; Compatibility semantics start counting new expansion scores at zero;
   ;; callers that need a complete-run total must use runAntMosesCounted and
   ;; include whatever scorer calls produced their supplied metapopulation.
   (runAntMosesCounted $maxGen $maxScore $metaPop $nExpansion $nDeme
                       $context $optimize $visits 0))

;; A negative antMaxEvals remains available as an explicit unlimited mode.
(= (antEvaluationBudgetReached $actualEvaluations)
   (let $budget (param antMaxEvals)
     (if (< $budget 0) False (>= $actualEvaluations $budget))))

(= (antRemainingEvaluationBudget $actualEvaluations)
   (let $budget (param antMaxEvals)
     (if (< $budget 0) -1 (max 0 (- $budget $actualEvaluations)))))

;; Check the separately tracked raw champion before starting another
;; generation. This matters for direct/resumed callers whose input population
;; already meets the target; the ordinary dispatcher starts from the empty seed.
(= (antRawTargetReached () $maxScore) False)
(= (antRawTargetReached
      (mkExemplar $tree $demeId
                  (mkCscore $raw $complexity $complexityPenalty
                            $diversityPenalty $penalizedScore)
                  $bscore)
      $maxScore)
   (>= $raw $maxScore))

;; Zero demes or a nonpositive local optimizer allowance cannot produce a
;; scored candidate. Stop explicitly instead of treating that configuration as
;; an empty-representation retry (which is unbounded when antRevisit is negative).
(= (antExpansionEnabled $nDeme)
   (and (> $nDeme 0) (> (param hcMaxEvalsAnt) 0)))

(= (runAntMosesCounted $maxGen $maxScore $metaPop $nExpansion $nDeme
                       $context $optimize $visits $cumulativeEvaluations)
   (let $initialRawBest
        (if (== $metaPop ()) () (bestRawAntExemplar $metaPop))
     (runAntMosesCountedWithBest
       $maxGen $maxScore $metaPop $nExpansion $nDeme
       $context $optimize $visits $cumulativeEvaluations $initialRawBest)))

;; Internal C++-parity loop. $bestRawExemplar is the single-result analogue of
;; metapopulation's `_best_candidates`: it is updated independently from the
;; selectable, penalized-score-ordered archive.
(= (runAntMosesCountedWithBest
      $maxGen $maxScore $metaPop $nExpansion $nDeme
      $context $optimize $visits $cumulativeEvaluations $bestRawExemplar)
   (if (== $maxGen 0)
       (finishAntMetapop $metaPop $bestRawExemplar)
       (if (antRawTargetReached $bestRawExemplar $maxScore)
           ;; A resumed population that already meets the target needs no work.
           (finishAntMetapop $metaPop $bestRawExemplar)
           (if (not (antExpansionEnabled $nDeme))
               (trace! (Ant search has no positive deme/evaluation allowance
                         (nDeme $nDeme)
                         (hcMaxEvalsAnt (param hcMaxEvalsAnt)))
                       (finishAntMetapop $metaPop $bestRawExemplar))
               (if (antEvaluationBudgetReached $cumulativeEvaluations)
                   (trace! (Ant evaluation budget exhausted
                             (actualEvaluations $cumulativeEvaluations))
                           (finishAntMetapop $metaPop $bestRawExemplar))
           ;; Materialize the eligible pool once. Selection and diagnostics
           ;; share it, avoiding another full metapopulation traversal.
           (let $eligible
             (antEligibleExemplars $metaPop $visits (param antRevisit))
             (if (== $eligible ())
                 (trace! (Ant search exhausted eligible exemplars)
                         (finishAntMetapop $metaPop $bestRawExemplar))
                 (let* (
                        ;; C++ selects from the hot penalized Boltzmann
                        ;; distribution; the raw champion remains diagnostic.
                        ($exemplar (selectExemplar $eligible))
                        ($tree (getExemplarTree $exemplar))
                        ($updatedVisits (recordAntVisit $tree $visits))
                        ($visitCount (antVisitCount $tree $updatedVisits))
                        ($_generationDiagnostics
                          (if (param antDiagnostics)
                              (println! (Generation $maxGen))
                              ()))
                        ($_antSelectionDiagnostics
                          (if (param antDiagnostics)
                              (println! (AntExemplarSelection
                                (expansion $nExpansion)
                                (mode boltzmann)
                                (selectedRaw (getScore (getExemplarCscore $exemplar)))
                                (selectedPenalized (getPenScore (getExemplarCscore $exemplar)))
                                (eligibleCandidates (List.length $eligible))))
                              ()))
                        (($optimizedDemes $actualEvaluations)
                          (expandSelectedAntExemplarCounted
                            $exemplar $nExpansion $nDeme $context $optimize
                            (antRemainingEvaluationBudget
                              $cumulativeEvaluations)))
                       )
                   ;; Match C++ `expand_deme`: an empty representation leaves
                   ;; the exemplar visited and retries without charging a
                   ;; generation, expansion ID, or evaluator call.
                   (if (== $optimizedDemes ())
                       (let* (
                              ($_antEmptyRepDiagnostics
                                (if (param antDiagnostics)
                                    (println! (AntRepresentationSkipped
                                      (expansion $nExpansion)
                                      (selected (preOrder $tree))
                                      (reason emptyKnobMap)))
                                    ()))
                              ($_ (clearSpace &treeSpace))
                              ($_ (cut))
                             )
                         (let ($retryMaxGen $retryExpansion $retryVisits
                               $retryEvaluations)
                              (antEmptyRepresentationRetryState
                                $maxGen $nExpansion $updatedVisits
                                $cumulativeEvaluations)
                           (runAntMosesCountedWithBest
                             $retryMaxGen $maxScore $metaPop
                             $retryExpansion $nDeme $context $optimize
                             $retryVisits $retryEvaluations
                             $bestRawExemplar)))
                       (let* (
                              ($updatedCumulativeEvaluations (+ $cumulativeEvaluations $actualEvaluations))
                              ($generationRawBest (bestRawAntExemplarFromDemes $optimizedDemes $context))
                              ($updatedRawBest (betterRawAntExemplar $bestRawExemplar $generationRawBest))
                              ($updatedMetaPop (mergeDemes $optimizedDemes $context $metaPop))
                              ($bestRaw (getScore (getExemplarCscore $updatedRawBest)))
                              ($bestPenalized (getExemplarPenScore (OS.getByIdx 0 $updatedMetaPop)))
                              ($_antDiagnostics
                                (if (param antDiagnostics)
                                    (printAntGenerationDiagnostics
                                      $maxGen $nExpansion $exemplar $visitCount
                                      $optimizedDemes $updatedMetaPop
                                      ($bestRaw $bestPenalized)
                                      $actualEvaluations
                                      $updatedCumulativeEvaluations)
                                    ()))
                              ($_ (clearSpace &treeSpace))
                              ($_ (cut))
                         )
                         (if (>= $bestRaw $maxScore)
                             (finishAntMetapop
                               $updatedMetaPop $updatedRawBest)
                             (if (antEvaluationBudgetReached $updatedCumulativeEvaluations)
                                 (finishAntMetapop
                                   $updatedMetaPop $updatedRawBest)
                                 (runAntMosesCountedWithBest
                                   (- $maxGen 1) $maxScore $updatedMetaPop
                                   (+ $nExpansion 1) $nDeme $context $optimize
                                   $updatedVisits
                                   $updatedCumulativeEvaluations
                                   $updatedRawBest)))))))))))))

;; The main loop
;; Takes 2 termination criterias:
;;     - $maxGen : how many times we want the loop to run
;;     - $maxScore : the maximum *raw* score we want the top Examplar to reach.
;;                   This is a scalar (Number), matching classic MOSES'
;;                   `score_t target_score = c_scorer.best_possible_score()`.
;;                   For clean boolean tables it's 0. The complexity penalty
;;                   is applied per-candidate during scoring, separate from
;;                   this termination check.
; (: runMoses (-> Number Number (OS (Exemplar $a)) Number Number $Context $Optimize (OS (Exemplar $a))))
;; TODO: $nEval isn't being used. Increase it so that it works as expected.
;; To enable that, we may need to change our termination condition so that the generation is equivalent to the number of expansion as well.
;; The number of expansions in the open cog classic is equivalent to the number of deme expansions. That looks like the same thing we are doing here but not sure.
(= (runMoses $maxGen $maxScore $metaPop $nExpansion $nDeme $context $optimize)
(if (== $maxGen 0)
    (if (<= (param maxCandOutput) (OS.length $metaPop))
        (let $topCandidates (OS.getTopN (param maxCandOutput) $metaPop) $topCandidates)
        $metaPop
  )
    (let*
     (
       ($_ (println! (Generation $maxGen)))
       ($optimizedDemes (case $context
                        (
                         ((mkAntContext $steps $complexityRatio $actions $perceptions)
                          (trace! "expand ant deme return" (expandDeme $metaPop $nExpansion $nDeme $context $optimize)))
                         (($prune-exemplar $fs-algo $truthTableBScore $itable)
                          (trace! "expand  deme returnn" (expandDeme $metaPop $nExpansion $nDeme $prune-exemplar $fs-algo $truthTableBScore $optimize $itable mi)))
                         (($nGames $opponentPolicy $complexityRatio)
                          (trace! "expand deme return" (expandDeme $metaPop $nExpansion $nDeme $nGames $opponentPolicy $complexityRatio $maxScore $optimize))))))
       (((mkDeme $rep $sInst $demeId)) $optimizedDemes)
       ($_ (println! (OptimizedDeme: (List.length (second $sInst)))))
       ($updatedMetaPop (case $context
                        (
                         ((mkAntContext $steps $complexityRatio $actions $perceptions)
                          (trace! "Merging Ant Deme" (mergeDemes $optimizedDemes $context $metaPop)))
                         (($prune-exemplar $fs-algo $truthTableBScore $itable)
                          (trace! "Merging Deme" (mergeDemes $optimizedDemes $itable $metaPop)))
                         (($nGames $opponentPolicy $complexityRatio)
                          (trace! "Merging Deme" (mergeDemes $optimizedDemes ($nGames $opponentPolicy) $metaPop))))))
       ;; Keep telemetry opt-in and ant-specific; it deliberately runs before
       ;; treeSpace is cleared so materialized candidates remain available.
       ($_antDiagnostics
         (case $context
           (((mkAntContext $steps $complexityRatio $actions $perceptions)
             (if (param antDiagnostics)
                 (printAntGenerationDiagnostics $maxGen $optimizedDemes $updatedMetaPop)
                 ()))
            ($other ()))))
       ;; ($_ (println! (Updated MetaPop: $updatedMetaPop)))
       ($top (OS.getByIdx 0 $metaPop))
       ;; ($_ (println! (Top Exemplar before expansion: $top)))
       ($topScore (getExemplarCscore $top))
       ;; ($_ (println! (topscore: $topScore)))
       ;; ($_ (println! (Top: $topScore Max: $maxScore (cScore>= $topScore $maxScore))))
       ($nothing (clearSpace &treeSpace))
       ($_ (cut)) ;; INFO: This cut speeds things up. Don't remove it.
       ($_ (println! ""))
      )
 ;; Match classic semantics: compare the raw behavioural score against the
 ;; scalar `$maxScore`. The Cscore's complexity / penalty fields are
 ;; consulted elsewhere when ranking candidates but not at termination.
 (if (>= (getScore $topScore) $maxScore)
         (if (<= (param maxCandOutput) (OS.length $updatedMetaPop))
             (OS.getTopN (param maxCandOutput) $updatedMetaPop)
             $updatedMetaPop)
         (runMoses (- $maxGen 1) $maxScore $updatedMetaPop $nExpansion $nDeme $context $optimize)))))


;; Final-result conversion helpers.
(= (mapG $f $xs) (map-atom $xs $f))

(= (cleanedExemplar (mkExemplar $tree $demeId $cscore (mkBScore $bscore))) ((preOrder $tree) (List.sum $bscore)))
