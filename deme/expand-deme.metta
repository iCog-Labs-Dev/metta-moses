;; Recursively optimizes each deme in a list using the provided optimizer function.
;; Params:
;;   (List Deme): The list of demes to optimize.
;;   $truthTableBScore: The scoring function or object.
;;   $inst: The initial instance for optimization.
;;   $optimize: The optimizer function to apply to each deme.
;;  Returns: (List Deme): A new list where each deme has been optimized.
(: optimizeDemes (-> (List Deme) (TruthTableBScore $a) Instance (-> Deme (TruthTableBScore $a) Instance $Scorer (Instance Deme $state)) $Scorer (List (Instance Deme $state))))
(= (optimizeDemes $deme $truthTableBScore $inst $optimize ($scorer $FsScorer))
($optimize $deme $truthTableBScore $inst ($scorer $FsScorer)))

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
(: expandDeme (-> (OS (Exemplar $a)) Number Number Bool Symbol (TruthTableBScore $a) (-> Deme (TruthTableBScore $a) Instance $Scorer (Instance Deme $state)) $Scorer Number Number Number Number (ITable $a) Number Number Number (OS (Exemplar $a))))
(= (expandDeme $metaPop $nExpansion $nDeme $prune-exemplar $fs-algo $truthTableBScore $optimize $optimScorer $nEval $maxCandsPerDeme $minPoolSize $complexityTemperature $itable $nToKeep $capCoef $genCount)
(collapse
  (let*
(
    ($exemplar (trace! "Selecting Exemplar" (selectExemplar $metaPop)))
    (() (println! $exemplar))
    ($tree (getExemplarTree $exemplar)) 
    ($demeIds (createDemeIds $nExpansion $nDeme))
    ; ($argLabels (getArgLabels $itable))
    ($demes (trace! "Creating Deme" (createDeme $nDeme $demeIds $tree $itable $fs-algo $prune-exemplar () $scorerType)))                   ;;createRepresentation and createDemeId are under this
    ((mkDeme (mkRep (mkKbMap (mkDscKbMp $dscKbMp) (mkDscMp $dscMp)) $updatedTree) $sInstList $demeId) (superpose $demes))
    ($lengthOfDscKbMp (Map.length $dscKbMp))
    ($generatedList (List.generate $lengthOfDscKbMp 0))
    ($deme (mkDeme (mkRep (mkKbMap (mkDscKbMp $dscKbMp) (mkDscMp $dscMp)) $updatedTree) $sInstList $demeId))
    (($inst $optimDeme $state) (trace! "Optimizing Deme" (optimizeDemes $deme $truthTableBScore (mkInst $generatedList) $optimize $optimScorer))) ;; the hillclimbing is called under this and it calls the neighborhood and stuff to first populate the deme with instances
)
$optimDeme)))

;; The main loop 
;; Takes 2 termination criterias:
;;     - $maxGen : how many times we want the loop to run
;;     - $maxScore : the maximum score we want the top Examplar to have
;; It also takes:
;;     - $maxCandOutput : The number of candidates to be returned
;;     - other parameters required by the expandDeme method
(: runMoses (-> Number Cscore Number (OS (Exemplar $a)) Number Number Bool Symbol (TruthTableBScore $a) (-> Deme (TruthTableBScore $a) Instance $Scorer (Instance Deme $state)) $Scorer Number Number Number Number (ITable $a) Number Number Number (OS (Exemplar $a))))
(= (runMoses $maxGen $maxScore $maxCandOutput $metaPop $nExpansion $nDeme $prune-exemplar $fs-algo $truthTableBScore $optimize $optimScorer $nEval $maxCandsPerDeme $minPoolSize $complexityTemperature $itable $nToKeep $capCoef $genCount)
(if (== $maxGen 0)
    (if (<= $maxCandOutput (OS.length $metaPop))
        (let $topCandidates (OS.getTopN $maxCandOutput $metaPop) $topCandidates)
        $metaPop
  )
    ; (trace! ($maxCandOutput $metaPop) (let $topCandidates (OS.getTopN $maxCandOutput $metaPop) $topCandidates))
    (let* 
     (
       ($optimizedDemes (expandDeme $metaPop $nExpansion $nDeme $prune-exemplar $fs-algo $truthTableBScore $optimize $optimScorer $nEval $maxCandsPerDeme $minPoolSize $complexityTemperature $itable $nToKeep $capCoef $genCount))
       ($updatedMetaPop (trace! "Merging Deme" (mergeDemes $optimizedDemes $nEval $maxCandsPerDeme $minPoolSize $complexityTemperature $itable $metaPop $nToKeep $capCoef $genCount)))
       ($top (OS.getByIdx 0 $metaPop))
       ($topScore (getExemplarCscore $top))
       ($topCandidates (OS.getTopN $maxCandOutput $metaPop)))
     (if (cScore>= $topScore $maxScore) 
         $topCandidates 
         (runMoses (- $maxGen 1) $maxScore $maxCandOutput $updatedMetaPop $nExpansion $nDeme $prune-exemplar $fs-algo $truthTableBScore $optimize $optimScorer $nEval $maxCandsPerDeme $minPoolSize $complexityTemperature $itable $nToKeep $capCoef $genCount)))))
