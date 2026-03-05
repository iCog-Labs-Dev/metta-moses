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
   (eval ($optimize $deme $targetCScore $inst (mkParams applyStrategyBasedScore ($nGames $opponentPolicy $complexityRatio)))))
;; Boolean version - passes context as-is
(= (optimizeDemes $deme $context $inst $optimize)
   (eval ($optimize $deme $context $inst)))

;; Creates initial instance from knob map by extracting default specifications
;; Params: $dscMp - MultiMap of (DiscSpec, Knob)
;; Returns: List of default spec values
; (: createInitialInstance (-> (MultiMap (DiscSpec $knob)) (List Number)))
(= (createInitialInstance $dscMp)
   (let* (
     ($knobs (eval (MultiMap.values $dscMp)))
     ($defaults (eval (List.map getKnobDefault $knobs)))
   )
   $defaults))

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
    ($exemplar (trace! "Selecting Exemplar" (eval (selectExemplar $metaPop))))
    ($_ (println! $exemplar))
    ($tree (trace! "getting exemplar tree" (eval (getExemplarTree $exemplar)))) 
    ($_ (println! $tree))
    ($demeIds (trace! "creating deme IDs" (eval (createDemeIds $nExpansion $nDeme))))
    ($_ (println! $demeIds))
    ; ($argLabels (getArgLabels $itable))
    ($demes (trace! "Creating Deme" (eval (createDeme $nDeme $demeIds $tree $itable $fs-algo $prune-exemplar () $scorerType))))     
    )
    (map-atom $demes $deme (expandDemeHelper $deme $truthTableBScore $optimize))
   ))

;; Overloaded version for game strategy domain - 8 parameters
(= (expandDeme $metaPop $nExpansion $nDeme $nGames $opponentPolicy $complexityRatio $targetCScore $optimize)
   (let*
      (
         ($exemplar (trace! "Selecting Exemplar" (eval (selectExemplar $metaPop))))
         ($tree (trace! "getting exemplar tree" (eval (getExemplarTree $exemplar))))
         ($demeIds (trace! "creating deme IDs" (eval (createDemeIds $nExpansion $nDeme))))
         ($demes (trace! "Creating Deme" (eval (createDeme $nDeme $demeIds $tree))))
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
    ($generatedList (eval (createInitialInstance $dscMp)))
    ($deme (mkDeme (mkRep (mkKbMap (mkDscKbMp $dscKbMp) (mkDscMp $dscMp)) $updatedTree) $sInstList $demeId))
    (($inst $optimDeme $state) (trace! "Optimizing Deme" (eval (optimizeDemes $deme $context (mkInst $generatedList) $optimize))))
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
(= (runMoses $maxGen $maxScore $maxCandOutput $metaPop $nExpansion $nDeme $prune-exemplar $fs-algo $truthTableBScore $optimize $nEval $maxCandsPerDeme $minPoolSize $complexityTemperature $itable $nToKeep $capCoef $genCount)
(if (== $maxGen 0)
    (if (<= $maxCandOutput (eval (OS.length $metaPop)))
        (let $topCandidates (eval (OS.getTopN $maxCandOutput $metaPop)) $topCandidates)
        $metaPop
  )
    (let* 
     (
       ($optimizedDemes (trace! "expand deme returnn" (eval (expandDeme $metaPop $nExpansion $nDeme $prune-exemplar $fs-algo $truthTableBScore $optimize $itable mi))))
       ($updatedMetaPop (trace! "Merging Deme" (eval (mergeDemes $optimizedDemes $nEval $maxCandsPerDeme $minPoolSize $complexityTemperature $itable $metaPop $nToKeep $capCoef $genCount))))
       ($_ (println! (Updated MetaPop: $updatedMetaPop)))
       ($top (eval (OS.getByIdx 0 $metaPop)))
       ($_ (println! (Top Exemplar before expansion: $top)))
       ($topScore (eval (getExemplarCscore $top)))
       ($_ (println! (topscore: $topScore)))
       ($resultCandi (if (<= $maxCandOutput (eval (OS.length $metaPop))) (eval (OS.getTopN $maxCandOutput $metaPop)) $metaPop))
       ($_ (cut))
      )
 (if (eval (cScore>= $topScore $maxScore))
         $resultCandi 
         (eval (runMoses (- $maxGen 1) $maxScore $maxCandOutput $updatedMetaPop $nExpansion $nDeme $prune-exemplar $fs-algo $truthTableBScore $optimize $nEval $maxCandsPerDeme $minPoolSize $complexityTemperature $itable $nToKeep $capCoef $genCount))))))

;; Main MOSES loop for game strategy evolution
;; Evolves strategies through multiple generations using game-based scoring
(= (runMosesStrategy $maxGen $maxCScore $maxCandOutput $metaPop $nExpansion $nDeme $nGames $opponentPolicy $complexityRatio $optimize $nEval $maxCandsPerDeme $minPoolSize $complexityTemperature $nToKeep $capCoef $genCount)
   (if (== $maxGen 0)
       (if (<= $maxCandOutput (eval (OS.length $metaPop)))
           (let $topCandidates (eval (OS.getTopN $maxCandOutput $metaPop)) $topCandidates)
           $metaPop)
       (let*
          (
             ($_ (println! ("Generation: " $maxGen)))
             ($optimizedDemes (trace! "expand deme return" (eval (expandDeme $metaPop $nExpansion $nDeme $nGames $opponentPolicy $complexityRatio $maxCScore $optimize))))
             ($updatedMetaPop (trace! "Merging Deme" (eval (mergeDemes $optimizedDemes $nEval $maxCandsPerDeme $minPoolSize $complexityTemperature ($nGames $opponentPolicy) $metaPop $nToKeep $capCoef $genCount))))
             ($updatedSize (eval (OS.length $updatedMetaPop)))
             ($_ (println! ("Updated metapop size: " $updatedSize)))
             ($_ (println! "Getting top exemplar..."))
             ($top (eval (OS.getByIdx 0 $updatedMetaPop)))
             ($_ (println! ("Top exemplar retrieved: " $top)))
             ($topScore (eval (getExemplarCscore $top)))
             ($_ (println! ("Top score: " $topScore)))
             ($resultCandi (if (<= $maxCandOutput (eval (OS.length $updatedMetaPop))) (eval (OS.getTopN $maxCandOutput $updatedMetaPop)) $updatedMetaPop))
             ($_ (cut))
          )
          (if (eval (cScore>= $topScore $maxCScore))
              $resultCandi
              (eval (runMosesStrategy (- $maxGen 1) $maxCScore $maxCandOutput $updatedMetaPop $nExpansion $nDeme $nGames $opponentPolicy $complexityRatio $optimize $nEval $maxCandsPerDeme $minPoolSize $complexityTemperature $nToKeep $capCoef $genCount))))))