;; Disc maps are ordered multimaps whose action comparator deliberately appends
;; equal/unordered specs. Reading them through the matching MultiMap API makes
;; that coordinate-order guarantee explicit instead of relying on the generic
;; Map implementation having the same list representation.
(= (createInitialInstance $dscMp)
   (let $knobs (MultiMap.values $dscMp)
     (map-atom $knobs $knob
       (second (getKnobDefault $knob)))))

;; The ninth hill-climbing state field is the number of actual scorer calls.
(= (hillStateEvaluationCount
      ($alreadyXover $lastChance $hasImproved $prevCenter $prevStart
       $prevSize $bestCscore $bestScore $actualEvaluations $distance $iteration))
   $actualEvaluations)

;; Optimize one deme under its fair share of the remaining complete-run
;; allowance. The temporary state is restored for direct optimizer callers.
(= (optimizeDemeCounted
      (mkDeme (mkRep (mkKbMap (mkDscMp $dscKbMp)) $tree)
              $scoredInstances $demeId)
      $optimizerContext $optimize $localLimit)
   (let* (
          ($generatedList (createInitialInstance $dscKbMp))
          ($_generated
            (if (param diagnostics)
                (println! (GeneratedList: $generatedList))
                ()))
          ($deme
            (mkDeme (mkRep (mkKbMap (mkDscMp $dscKbMp)) $tree)
                    $scoredInstances $demeId))
          ($_setLocalLimit (change-state! &localEvalLimit $localLimit))
          (($inst $optimizedDeme $state)
            (optimizeDeme $deme $optimizerContext
                          (mkInst $generatedList) $optimize))
          ($_restoreLocalLimit (change-state! &localEvalLimit -1))
         )
     ($optimizedDeme (hillStateEvaluationCount $state))))

;; Divide a finite allowance evenly, assigning remainder calls to the earliest
;; demes. The sum of local shares never exceeds the remaining global budget.
(= (expandDemesWithShares
      () $optimizerContext $optimize $baseLimit $extraSlots)
   (() 0))
(= (expandDemesWithShares
      (cons $deme $rest) $optimizerContext $optimize
      $baseLimit $extraSlots)
   (let* (
          ($hasExtra (> $extraSlots 0))
          ($localLimit (+ $baseLimit (if $hasExtra 1 0)))
          ($nextExtra (if $hasExtra (- $extraSlots 1) 0))
         )
     (if (<= $localLimit 0)
         (() 0)
         (let* (
                (($optimizedDeme $used)
                  (optimizeDemeCounted
                    $deme $optimizerContext $optimize $localLimit))
                (($optimizedRest $restUsed)
                  (expandDemesWithShares
                    $rest $optimizerContext $optimize
                    $baseLimit $nextExtra))
               )
           ((cons $optimizedDeme $optimizedRest)
            (+ $used $restUsed))))))

;; Allocate the remaining complete-run budget across all demes in this
;; expansion. A negative budget represents unlimited evaluation.
(= (expandDemesCounted
      () $optimizerContext $optimize $remainingBudget)
   (() 0))
(= (expandDemesCounted
      (cons $firstDeme $restDemes)
      $optimizerContext $optimize $remainingBudget)
   (let* (
          ($demes (cons $firstDeme $restDemes))
          ($demeCount (List.length $demes))
          ($baseLimit
            (if (< $remainingBudget 0)
                (pow-math 10 18)
                (floor-math (/ $remainingBudget $demeCount))))
          ($extraSlots
            (if (< $remainingBudget 0)
                0
                (% $remainingBudget $demeCount)))
         )
     (expandDemesWithShares
       $demes $optimizerContext $optimize $baseLimit $extraSlots)))

;; Build and optimize every deme for an already selected exemplar, returning
;; both the optimized demes and the number of actual scorer calls they used.
(= (expandSelectedExemplarCounted
      $exemplar $nExpansion $nDeme $context $maxScore
      $optimize $remainingBudget)
   (let* (
          ($_selected
            (if (param diagnostics)
                (println! (SelectedTree:
                            (preOrder (getExemplarTree $exemplar))))
                ()))
          ($demes
            (createSelectedDemes
              $exemplar $nExpansion $nDeme $context))
          ($optimizerContext (optimizerContextFor $context $maxScore))
         )
     (expandDemesCounted
       $demes $optimizerContext $optimize $remainingBudget)))

;; Diagnostics materialize each candidate once before treeSpace is cleared.
(= (diagnosticDemeTrees $demes)
   (List.flatten
     (map-atom $demes $deme
       (let (mkDeme $rep (mkSInstSet $instances) $demeId) $deme
         (map-atom $instances $scoredInst
           (getCandidate $rep $demeId (getInst $scoredInst)))))))

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
(= (rawBestExemplarFromDeme
      (mkDeme $rep $scoredInstances $demeId) $mergeContext)
   (let $rawBest (bestRawScoredInstance $scoredInstances)
     (if (== $rawBest ())
         ()
         (List.head
           (demeToTrees
             (mkDeme $rep (mkSInstSet ($rawBest)) $demeId)
             $mergeContext)))))

;; Fold the per-deme raw champions into one expansion-wide raw champion.
(= (bestRawExemplarFromDemes $demes $mergeContext)
   (foldl-atom $demes () $best $deme
     (betterRawExemplar
       $best (rawBestExemplarFromDeme $deme $mergeContext))))

;; Report raw and penalized archive leaders independently because complexity
;; penalties can make them different exemplars.
(= (metapopBestScores ()) ())
(= (metapopBestScores $metaPop)
   (let* (
          ($rawBest (bestRawExemplar $metaPop))
          ($penalizedBest (OS.getByIdx 0 $metaPop))
         )
     ((getScore (getExemplarCscore $rawBest))
      (getExemplarPenScore $penalizedBest))))

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
                     (cons $rawBest
                           (OS.takeN (- $limit 1)
                                     $topCandidates)))))))))

;; Compatibility overload derives the raw champion from a non-empty archive.
(= (finishMetapop $metaPop)
   (if (== $metaPop ())
       ()
       (finishMetapop $metaPop (bestRawExemplar $metaPop))))

;; Advance generation and expansion counters after an exemplar produces no
;; optimizable representation, without charging an evaluation.
(= (emptyRepresentationRetryState
      $maxGen $nExpansion $updatedVisits $cumulativeEvaluations)
   ;; A failed representation consumes one bounded expansion attempt. Without
   ;; this transition, `revisit < 0` could select an intrinsically unexpandable
   ;; tree forever without spending either generation or evaluation budget.
   ((- $maxGen 1) (+ $nExpansion 1)
    $updatedVisits $cumulativeEvaluations))

;; Test whether the complete-run scorer-call allowance has been exhausted.
;; A negative configured allowance is unlimited.
(= (evaluationBudgetReached $actualEvaluations)
   (let $budget (param maxEvals)
     (if (< $budget 0) False (>= $actualEvaluations $budget))))

;; Return the unspent complete-run allowance, preserving -1 as the unlimited
;; sentinel expected by counted expansion.
(= (remainingEvaluationBudget $actualEvaluations)
   (let $budget (param maxEvals)
     (if (< $budget 0) -1 (max 0 (- $budget $actualEvaluations)))))

;; Termination uses raw fitness, not the complexity-penalized archive order.
(= (rawTargetReached () $maxScore) False)
(= (rawTargetReached
      (mkExemplar $tree $demeId
                  (mkCscore $raw $complexity $complexityPenalty
                            $diversityPenalty $penalizedScore)
                  $bscore)
      $maxScore)
   (>= $raw $maxScore))

;; A zero-deme configuration intentionally disables expansion.
(= (expansionEnabled $nDeme) (> $nDeme 0))

;; One shared loop handles visits, budgets, expansion, merging, raw-target
;; termination, and finalization for every problem family.
(= (runMoses $maxGen $maxScore $metaPop $nExpansion $nDeme
             $context $optimize)
   (let* (
          ($_reset (resetCandidateScoreCache))
          ($_domainReset (resetDomainRunCaches $context))
          ($_seed (seedInitialCandidateCache $context $metaPop))
         )
     (runMosesCounted
       $maxGen $maxScore $metaPop $nExpansion $nDeme
       $context $optimize ()
       (initialEvaluationCount $context))))

;; Initialize the raw champion before entering the recursive counted loop.
(= (runMosesCounted $maxGen $maxScore $metaPop $nExpansion $nDeme
                    $context $optimize $visits $cumulativeEvaluations)
   (let $initialRawBest
        (if (== $metaPop ()) () (bestRawExemplar $metaPop))
     (runMosesCountedWithBest
       $maxGen $maxScore $metaPop $nExpansion $nDeme
       $context $optimize $visits $cumulativeEvaluations $initialRawBest)))

;; Recursive shared lifecycle: select an eligible exemplar, spend only the
;; remaining real-evaluation budget, merge results, and retain both leaders.
(= (runMosesCountedWithBest
      $maxGen $maxScore $metaPop $nExpansion $nDeme
      $context $optimize $visits $cumulativeEvaluations $rawChampion)
   (if (<= $maxGen 0)
       (finishMetapop $metaPop $rawChampion)
       (if (rawTargetReached $rawChampion $maxScore)
           (finishMetapop $metaPop $rawChampion)
           (if (not (expansionEnabled $nDeme))
               (finishMetapop $metaPop $rawChampion)
               (if (evaluationBudgetReached $cumulativeEvaluations)
                   (finishMetapop $metaPop $rawChampion)
                   (let $eligible
                        (eligibleExemplars
                          $metaPop $visits (param revisit))
                     (if (== $eligible ())
                         (finishMetapop $metaPop $rawChampion)
                         (let* (
                                ($exemplar (selectExemplar $eligible))
                                ($tree (getExemplarTree $exemplar))
                                ($updatedVisits (recordVisit $tree $visits))
                                ($selectedVisitCount (visitCount $tree $updatedVisits))
                                ($_selection
                                  (if (param diagnostics)
                                      (println! (ExemplarSelection
                                        (expansion $nExpansion)
                                        (selectedRaw
                                          (getScore
                                            (getExemplarCscore
                                              $exemplar)))
                                        (selectedPenalized
                                          (getExemplarPenScore
                                            $exemplar))
                                        (eligibleCandidates
                                          (List.length $eligible))))
                                      ()))
                                (($optimizedDemes $actualEvaluations)
                                  (expandSelectedExemplarCounted
                                    $exemplar $nExpansion $nDeme
                                    $context $maxScore $optimize
                                    (remainingEvaluationBudget
                                      $cumulativeEvaluations)))
                               )
                           (if (== $optimizedDemes ())
                               (let* (
                                      ($_skipped
                                        (if (param diagnostics)
                                            (println!
                                              (RepresentationSkipped
                                                (expansion $nExpansion)
                                                (selected (preOrder $tree))
                                                (reason emptyKnobMap)))
                                            ()))
                                      ($_clear (clearSpace &treeSpace))
                                      ($_cut (cut))
                                     )
                                 (let ($retryGen $retryExpansion
                                       $retryVisits $retryEvaluations)
                                      (emptyRepresentationRetryState
                                        $maxGen $nExpansion
                                        $updatedVisits
                                        $cumulativeEvaluations)
                                   (runMosesCountedWithBest
                                     $retryGen $maxScore $metaPop
                                     $retryExpansion $nDeme
                                     $context $optimize $retryVisits
                                     $retryEvaluations
                                     $rawChampion)))
                               (let* (
                                      ($updatedEvaluations
                                        (+ $cumulativeEvaluations
                                           $actualEvaluations))
                                      ($mergeContext
                                        (mergeContextFor $context))
                                      ($generationRawBest
                                        (bestRawExemplarFromDemes
                                          $optimizedDemes
                                          $mergeContext))
                                      ($updatedRawBest
                                        (betterRawExemplar
                                          $rawChampion
                                          $generationRawBest))
                                      ($updatedMetaPop
                                        (mergeDemes
                                          $optimizedDemes
                                          $mergeContext $metaPop))
                                      ($bestRaw
                                        (getScore
                                          (getExemplarCscore
                                            $updatedRawBest)))
                                      ($bestPenalized
                                        (if (== $updatedMetaPop ())
                                            ()
                                            (getExemplarPenScore
                                              (OS.getByIdx
                                                0 $updatedMetaPop))))
                                      ($_diagnostics
                                        (if (param diagnostics)
                                            (printGenerationDiagnostics
                                              $maxGen $nExpansion
                                              $exemplar
                                              $selectedVisitCount
                                              $optimizedDemes
                                              $updatedMetaPop
                                              ($bestRaw $bestPenalized)
                                              $actualEvaluations
                                              $updatedEvaluations)
                                            ()))
                                      ($_clear (clearSpace &treeSpace))
                                      ($_cut (cut))
                                     )
                                 (if (or (>= $bestRaw $maxScore)
                                         (evaluationBudgetReached
                                           $updatedEvaluations))
                                     (finishMetapop
                                       $updatedMetaPop
                                       $updatedRawBest)
                                     (runMosesCountedWithBest
                                       (- $maxGen 1) $maxScore
                                       $updatedMetaPop
                                       (+ $nExpansion 1) $nDeme
                                       $context $optimize
                                       $updatedVisits
                                       $updatedEvaluations
                                       $updatedRawBest))))))))))))


;; Final-result conversion helpers.
(= (mapG $f $xs) (map-atom $xs $f))

(= (cleanedExemplar (mkExemplar $tree $demeId $cscore (mkBScore $bscore))) ((preOrder $tree) (List.sum $bscore)))
