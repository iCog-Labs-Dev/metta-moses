(= (createInitialInstance $dscMp)
   (let* (
     ($knobs (MultiMap.values $dscMp))
     ($defaults (List.map getKnobDefault $knobs))
   )
   $defaults))

;; Recursively optimizes each deme in a list using the provided optimizer function.
;; Params:
;;   (List Deme): The list of demes to optimize.
;;   $context: The scoring context - either TruthTableBScore or tuple ($nGames $opponentPolicy)
;;   $inst: The initial instance for optimization.
;;   $optimize: The optimizer function to apply to each deme.
;;  Returns: (List Deme): A new list where each deme has been optimized.
; (: optimizeDemes (-> (List Deme) $context Instance $optimize (Instance Deme $state)))
;; Game strategy version - unpacks tuple with target score
;; Strategy version - unpacks game parameters and calls hillClimbing with mkParams
(= (optimizeDemes $deme ($nGames $opponentPolicy $complexityRatio $targetCScore) $inst $optimize)
   ($optimize $deme $targetCScore $inst (mkParams applyStrategyBasedScore ($nGames $opponentPolicy $complexityRatio))))
;; Boolean version - passes context as-is
(= (optimizeDemes $deme $context $inst $optimize)
   ($optimize $deme $context $inst))

;; Extracts default specification from a knob
; (: getKnobDefault (-> $knob Number))
(= (getKnobDefault (mkLSK (mkDiscKnob $knob $multip $curr (mkDiscSpec $def) $dis))) $def)
(= (getKnobDefault (mkSSK (mkDiscKnob $knob $multip $curr (mkDiscSpec $def) $dis))) $def)

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
(= (expandDeme $metaPop $nExpansion $nDeme $nGames $opponentPolicy $complexityRatio $targetCScore $optimize)
   (let*
      (
         ($exemplar (trace! "Selecting Exemplar" (selectExemplar $metaPop)))
         ($tree (trace! "getting exemplar tree" (getExemplarTree $exemplar)))
         ($demeIds (trace! "creating deme IDs" (createDemeIds $nExpansion $nDeme)))
         ($demes (trace! "Creating Deme" (createDeme $nDeme $demeIds $tree)))
         ($gameContext ($nGames $opponentPolicy $complexityRatio $targetCScore))
      )
      (map-atom $demes $deme (expandDemeHelper $deme $gameContext $optimize))))

;; Unified helper for both Boolean and Strategy domains
;; Optimizes each deme in the list using the provided optimizer and context
;; Params:
;;   $deme: Deme to optimize
;;   $context: Scoring context (ITable for Boolean, tuple for Strategy)
;;   $optimize: Optimizer function
;; Returns: Optimized deme with scored instances
(= (expandDemeHelper (mkDeme (mkRep (mkKbMap (mkDscKbMp $dscKbMp) (mkDscMp $dscMp)) $updatedTree) $sInstList $demeId) $context $optimize)
(let*
(
    ($lengthOfDscKbMp (Map.length $dscKbMp))
    ;; ($generatedList (List.generate $lengthOfDscKbMp 0))
    ($generatedList (createInitialInstance $dscMp))
    ($deme (mkDeme (mkRep (mkKbMap (mkDscKbMp $dscKbMp) (mkDscMp $dscMp)) $updatedTree) $sInstList $demeId))
    ;; ($_ (println! (Rep: (mkRep (mkKbMap (mkDscKbMp $dscKbMp) (mkDscMp $dscMp)) $updatedTree))))
    ;; ($_ (println! "Optimizing Deme"))
    (($inst $optimDeme $state) (optimizeDemes $deme $context (mkInst $generatedList) $optimize))
)
$optimDeme
))
;; The main loop 
;; Takes 2 termination criterias:
;;     - $maxGen : how many times we want the loop to run
;;     - $maxScore : the maximum score we want the top Examplar to have
;; It also takes:
;;     - $maxCandOutput : The number of candidates to be returned
;;     - other parameters required by the expandDeme method
; (: runMoses (-> Number Cscore Number (OS (Exemplar $a)) Number Number Bool Symbol (TruthTableBScore $a) (-> Deme (TruthTableBScore $a) Instance $Scorer (Instance Deme $state)) $Scorer Number Number Number Number (ITable $a) Number Number Number (OS (Exemplar $a))))
;; TODO: $nEval isn't being used. Increase it so that it works as expected. 
;; To enable that, we may need to change our termination condition so that the generation is equivalent to the number of expansion as well.
;; The number of expansions in the open cog classic is equivalent to the number of deme expansions. That looks like the same thing we are doing here but not sure.
(= (runMoses $maxGen $maxScore $maxCandOutput $metaPop $nExpansion $nDeme $context $optimize $nEval $maxCandsPerDeme $minPoolSize $complexityTemperature $nToKeep $capCoef $genCount)
(if (== $maxGen 0)
    (if (<= $maxCandOutput (OS.length $metaPop))
        (let $topCandidates (OS.getTopN $maxCandOutput $metaPop) $topCandidates)
        $metaPop
  )
    (let*
     (
       ($_ (println! (Generation $maxGen)))
       ($optimizedDemes (case $context
                        ((($prune-exemplar $fs-algo $truthTableBScore $itable) (trace! "expand  deme returnn" (expandDeme $metaPop $nExpansion $nDeme $prune-exemplar $fs-algo $truthTableBScore $optimize $itable mi)))
                        (($nGames $opponentPolicy $complexityRatio) (trace! "expand deme return" (expandDeme $metaPop $nExpansion $nDeme $nGames $opponentPolicy $complexityRatio $maxScore $optimize))))))
       (((mkDeme $rep $sInst $demeId)) $optimizedDemes)
       ($_ (println! (OptimizedDeme: (List.length (second $sInst)))))
       ($updatedMetaPop (case $context 
                        ((($prune-exemplar $fs-algo $truthTableBScore $itable) (trace! "Merging Deme" (mergeDemes $optimizedDemes $nEval $maxCandsPerDeme $minPoolSize $complexityTemperature $itable $metaPop $nToKeep $capCoef $genCount)))
                        (($nGames $opponentPolicy $complexityRatio) (trace! "Merging Deme" (mergeDemes $optimizedDemes $nEval $maxCandsPerDeme $minPoolSize $complexityTemperature ($nGames $opponentPolicy) $metaPop $nToKeep $capCoef $genCount))))))
       ;; ($_ (println! (Updated MetaPop: $updatedMetaPop)))
       ($top (OS.getByIdx 0 $metaPop))
       ;; ($_ (println! (Top Exemplar before expansion: $top)))
       ($topScore (getExemplarCscore $top))
       ;; ($_ (println! (topscore: $topScore)))
       ($resultCandi (if (<= $maxCandOutput (OS.length $updatedMetaPop)) (OS.getTopN $maxCandOutput $updatedMetaPop) $updatedMetaPop))
       ;; ($_ (println! (Top: $topScore Max: $maxScore (cScore>= $topScore $maxScore))))
       ($_ (cut))
       ($_ (println! ""))
      )
 (if (== $topScore $maxScore)
         $resultCandi
         (runMoses (- $maxGen 1) $maxScore $maxCandOutput $updatedMetaPop $nExpansion $nDeme $context $optimize $nEval $maxCandsPerDeme $minPoolSize $complexityTemperature $nToKeep $capCoef $genCount)))))


;; Some helpers specific to final testing
(= (mapG $f $xs) (map-atom $xs $f))

(= (printExemplar (mkExemplar $tree $demeId $cscore $bscore)) (println! (Tree: (preOrder $tree) CScore: $cscore Bscore: $bscore)))
(= (cleanedExemplar (mkExemplar $tree $demeId $cscore (mkBScore $bscore))) ((preOrder $tree) (List.sum $bscore)))

(= (printInstance (mkInst $inst)) (println! (List.listToExpr $inst)))
