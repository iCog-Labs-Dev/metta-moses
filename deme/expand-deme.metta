;; Recursively optimizes each deme in a list using the provided optimizer function.
;; Params:
;;   (List Deme): The list of demes to optimize.
;;   $context: The scoring context - either TruthTableBScore or tuple ($nGames $opponentPolicy)
;;   $inst: The initial instance for optimization.
;;   $optimize: The optimizer function to apply to each deme.
;;  Returns: (List Deme): A new list where each deme has been optimized.
; (: optimizeDemes (-> (List Deme) $context Instance $optimize (Instance Deme $state)))
;; Game strategy version - unpacks tuple
(= (optimizeDemes $deme ($nGames $opponentPolicy) $inst $optimize)
   (eval ($optimize $deme $nGames $opponentPolicy $inst)))

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

(= (expandDemeHelper (mkDeme (mkRep (mkKbMap (mkDscKbMp $dscKbMp) (mkDscMp $dscMp)) $updatedTree) $sInstList $demeId) $truthTableBScore $optimize)
(let*
(
    ($lengthOfDscKbMp (eval (Map.length $dscKbMp)))
    ($generatedList (eval (createInitialInstance $dscMp)))
    ($deme (mkDeme (mkRep (mkKbMap (mkDscKbMp $dscKbMp) (mkDscMp $dscMp)) $updatedTree) $sInstList $demeId))
    (($inst $optimDeme $state) (trace! "Optimizing Deme" (eval (optimizeDemes $deme $truthTableBScore (mkInst $generatedList) $optimize))))
)
$optimDeme
)
)
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

;; Runs one deme-creation and optimization step for game strategies
;; Params:
;;   $metaPop: The current metapopulation
;;   $nExpansion: Expansion count or deme index
;;   $nDeme: Number of demes to create
;;   $nGames: Number of games to play for scoring
;;   $opponentPolicy: Opponent strategy (e.g., random-player)
;;   $optimize: Optimizer function (e.g., hillClimbingStrategy)
;; Returns:
;;   List of optimized demes
(= (expandDemeStrategy $metaPop $nExpansion $nDeme $nGames $opponentPolicy $optimize)
   (let*
      (
         ($exemplar (trace! "Selecting Exemplar" (eval (selectExemplar $metaPop))))
         ($tree (trace! "getting exemplar tree" (eval (getExemplarTree $exemplar))))
         ($demeIds (trace! "creating deme IDs" (eval (createDemeIds $nExpansion $nDeme))))
         ($demes (trace! "Creating Deme" (eval (createDeme $nDeme $demeIds $tree))))
         ($gameContext ($nGames $opponentPolicy))
         ($result (map-atom $demes $deme (expandDemeHelper $deme $gameContext $optimize)))
      )
      $result))

;; Main MOSES loop for game strategies
;; Params:
;;   $maxGen: Maximum number of generations
;;   $maxScore: Target BScore sum to achieve (e.g., $nGames * 1.0 for all wins)
;;   $maxCandOutput: Number of top candidates to return
;;   $metaPop: Current metapopulation
;;   $nExpansion: Expansion count
;;   $nDeme: Number of demes per expansion
;;   $nGames: Number of games to play for scoring
;;   $opponentPolicy: Opponent strategy
;;   $optimize: Optimizer function (e.g., hillClimbingStrategy)
;;   $nEval: Maximum evaluations (for mergeDemes)
;;   $maxCandsPerDeme: Maximum candidates per deme
;;   $minPoolSize: Minimum deme size
;;   $nToKeep: Target metapop size
;; Returns:
;;   Final metapopulation with best strategies
(= (runMosesStrategy $maxGen $maxScore $maxCandOutput $metaPop $nExpansion $nDeme $nGames $opponentPolicy $optimize $nEval $maxCandsPerDeme $minPoolSize $nToKeep)
   (if (== $maxGen 0)
       (if (<= $maxCandOutput (eval (OS.length $metaPop)))
           (let $topCandidates (eval (OS.getTopN $maxCandOutput $metaPop)) $topCandidates)
           $metaPop)
       (let*
          (
             ($optimizedDemes (trace! "expand deme return" (eval (expandDemeStrategy $metaPop $nExpansion $nDeme $nGames $opponentPolicy $optimize))))
             ($updatedMetaPop (trace! "Merging Deme" (eval (mergeDemesStrategy $optimizedDemes $nEval $maxCandsPerDeme $minPoolSize $nGames $opponentPolicy $metaPop $nToKeep))))
             ($_ (println! (Updated MetaPop: $updatedMetaPop)))
             ($top (eval (OS.getByIdx 0 $metaPop)))
             ($_ (println! (Top Exemplar before expansion: $top)))
             ($topBScore (eval (getExemplarBScore $top)))
             ($topScore (eval (sumBScore $topBScore)))
             ($_ (println! (topscore: $topScore)))
             ($resultCandi (if (<= $maxCandOutput (eval (OS.length $metaPop))) (eval (OS.getTopN $maxCandOutput $metaPop)) $metaPop))
             ($_ (cut))
          )
          (if (>= $topScore $maxScore)
              $resultCandi
              (eval (runMosesStrategy (- $maxGen 1) $maxScore $maxCandOutput $updatedMetaPop $nExpansion $nDeme $nGames $opponentPolicy $optimize $nEval $maxCandsPerDeme $minPoolSize $nToKeep))))))