;; WARN: This code might be generating knobs out of order. Check if the knob map returned from the representation building preserves the order of knob creation.
(= (createInitialInstance $dscMp)
   (let* (
          ($knobs (Map.values $dscMp))
          ($defaults (List.map getKnobDefault $knobs))
          ($finalDefaults (List.map second $defaults))
         )
         $finalDefaults))

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

;; Extracts default specification from a knob
; (: getKnobDefault (-> $knob Number))
;; (= (getKnobDefault (mkLSK (mkDiscKnob $multip $curr (mkDiscSpec $def) $dis))) $def)
;; (= (getKnobDefault (mkSSK (mkDiscKnob $knob $multip $curr (mkDiscSpec $def) $dis))) $def)

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

;; Ant action-domain expansion.
(= (expandDeme $metaPop $nExpansion $nDeme (mkAntContext $steps $complexityRatio $actions $perceptions) $optimize)
   (let*
      (
         ($context (mkAntContext $steps $complexityRatio $actions $perceptions))
         ($exemplar (trace! "Selecting Exemplar" (selectExemplar $metaPop)))
         ($tree (trace! "getting exemplar tree" (getExemplarTree $exemplar)))
         ($demeIds (trace! "creating deme IDs" (createDemeIds $nExpansion $nDeme)))
         ($demes (trace! "Creating Deme" (createDeme $nDeme $demeIds $tree $context)))
      )
      (map-atom $demes $deme (expandDemeHelper $deme $context $optimize))))

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
    ($lengthOfDscKbMp (Map.length $dscKbMp))
    ;; ($generatedList (List.generate $lengthOfDscKbMp 0))
    ($generatedList (createInitialInstance $dscKbMp))
    ($_ (println! (GeneratedList: $generatedList)))
    ($deme (mkDeme (mkRep (mkKbMap (mkDscMp $dscKbMp)) $updatedTree) $sInstList $demeId))
    ;; ($_ (println! (Rep: (mkRep (mkKbMap (mkDscKbMp $dscKbMp) (mkDscMp $dscMp)) $updatedTree))))
    ;; ($_ (println! "Optimizing Deme"))
    (($inst $optimDeme $state) (optimizeDemes $deme $context (mkInst $generatedList) $optimize))
)
$optimDeme
))

;; Ant search diagnostics materialize and clean each optimized instance before
;; counting it.  This reports distinct candidate programs, not merely sampled
;; knob vectors, because several vectors can reduce to the same action tree.
(= (antDiagnosticDemeTrees ()) ())
(= (antDiagnosticDemeTrees
      (cons (mkDeme $rep (mkSInstSet $instances) $demeId) $rest))
   (let* (
          ($trees (map-atom $instances $scoredInst
                    (cleanActionTree
                      (getCandidate $rep $demeId (getInst $scoredInst)))))
          ($restTrees (antDiagnosticDemeTrees $rest))
         )
     (append $trees $restTrees)))

;; Emit one compact record after each merge.  Raw and penalized maxima are
;; reported independently because the strongest food-eating program need not
;; be the program preferred by complexity-penalized hill climbing.
(= (antDiagnosticEvaluationCount ()) 0)
(= (antDiagnosticEvaluationCount
      (cons (mkDeme $rep (mkSInstSet $instances) $demeId) $rest))
   (+ (List.length $instances) (antDiagnosticEvaluationCount $rest)))

(= (printAntGenerationDiagnostics $remainingGen $nExpansion $selectedExemplar
                                  $visitCount $optimizedDemes $updatedMetaPop)
   (let* (
          ($candidateTrees (antDiagnosticDemeTrees $optimizedDemes))
          ($uniqueCandidates (length (unique-atom $candidateTrees)))
          ($actualEvaluations (antDiagnosticEvaluationCount $optimizedDemes))
          ($rawScores (map-atom $updatedMetaPop $exemplar
                       (getScore (getExemplarCscore $exemplar))))
          ($penScores (map-atom $updatedMetaPop $exemplar
                       (getPenScore (getExemplarCscore $exemplar))))
         )
     (println! (AntGenerationDiagnostics
                 (remaining $remainingGen)
                 (expansion $nExpansion)
                 (selected (preOrder (getExemplarTree $selectedExemplar)))
                 (visitCount $visitCount)
                 (actualNewEvaluations $actualEvaluations)
                 (cumulativeLocalEvaluations $actualEvaluations)
                 (uniqueCandidates $uniqueCandidates)
                 (retainedCandidates (OS.length $updatedMetaPop))
                 (bestRaw (List.max $rawScores))
                 (bestPenalized (List.max $penScores))))))

;; Compatibility overload for direct callers of generic runMoses with an ant
;; context; the normal ant dispatcher uses the richer explicit form above.
(= (printAntGenerationDiagnostics $remainingGen $optimizedDemes $updatedMetaPop)
   (printAntGenerationDiagnostics $remainingGen 0
     (OS.getByIdx 0 $updatedMetaPop) 0 $optimizedDemes $updatedMetaPop))

;; Select the raw-best ant exemplar independently of penalized metapopulation
;; order.  This prevents a strong but complex food-eater from disappearing at
;; final conversion merely because it falls outside the penalized top-N.
(= (bestRawAntExemplar (cons $exemplar ())) $exemplar)
(= (bestRawAntExemplar (cons $exemplar $rest))
   (let $restBest (bestRawAntExemplar $rest)
     (if (>= (getScore (getExemplarCscore $exemplar))
             (getScore (getExemplarCscore $restBest)))
         $exemplar
         $restBest)))

;; Common ant-loop finish and raw-score helpers. Penalized order governs most
;; output slots, but one slot is reserved for the raw-best search result.
(= (finishAntMetapop $metaPop)
   (if (<= (param maxCandOutput) (OS.length $metaPop))
       (let* (
              ($topCandidates (OS.getTopN (param maxCandOutput) $metaPop))
              ($rawBest (bestRawAntExemplar $metaPop))
             )
         (if (OS.contains $topCandidates $rawBest)
             $topCandidates
             (cons $rawBest
                   (OS.takeN (- (param maxCandOutput) 1) $topCandidates))))
       $metaPop))

(= (bestAntMetapopRawScore $metaPop)
   (List.max (map-atom $metaPop $exemplar
               (getScore (getExemplarCscore $exemplar)))))

;; Ant-only outer MOSES loop.  It preserves stepping stones, expands each tree
;; according to antRevisit, increments expansion IDs, and checks the newly
;; merged population rather than the pre-expansion one.
(= (runAntMoses $maxGen $maxScore $metaPop $nExpansion $nDeme $context
                $optimize $visits)
   (if (== $maxGen 0)
       (finishAntMetapop $metaPop)
       (let $selected (selectAntExemplar $metaPop $visits (param antRevisit))
         (case $selected
           (((Error $payload $message)
              (trace! (Ant search exhausted eligible exemplars)
                      (finishAntMetapop $metaPop)))
            ($exemplar
              (let* (
                     ($tree (getExemplarTree $exemplar))
                     ($updatedVisits (recordAntVisit $tree $visits))
                     ($visitCount (antVisitCount $tree $updatedVisits))
                     ($_ (println! (Generation $maxGen)))
                     ($optimizedDemes
                       (expandSelectedAntExemplar $exemplar $nExpansion $nDeme
                                                  $context $optimize))
                     ($updatedMetaPop
                       (mergeDemes $optimizedDemes $context $metaPop))
                     ($_antDiagnostics
                       (if (param antDiagnostics)
                           (printAntGenerationDiagnostics
                             $maxGen $nExpansion $exemplar $visitCount
                             $optimizedDemes $updatedMetaPop)
                           ()))
                     ($bestRaw (bestAntMetapopRawScore $updatedMetaPop))
                     ($_ (clearSpace &treeSpace))
                     ($_ (cut))
                    )
                (if (>= $bestRaw $maxScore)
                    (finishAntMetapop $updatedMetaPop)
                    (runAntMoses (- $maxGen 1) $maxScore $updatedMetaPop
                                 (+ $nExpansion 1) $nDeme $context $optimize
                                 $updatedVisits)))))))))

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


;; Some helpers specific to final testing
(= (mapG $f $xs) (map-atom $xs $f))

(= (printExemplar (mkExemplar $tree $demeId $cscore $bscore)) (println! (Tree: (preOrder $tree) CScore: $cscore Bscore: $bscore)))
(= (cleanedExemplar (mkExemplar $tree $demeId $cscore (mkBScore $bscore))) ((preOrder $tree) (List.sum $bscore)))

(= (printInstance (mkInst $inst)) (println! (List.listToExpr $inst)))
