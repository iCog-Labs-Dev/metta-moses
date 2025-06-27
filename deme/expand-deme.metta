;; Recursively optimizes each deme in a list using the provided optimizer function.
;; Params:
;;   (List Deme): The list of demes to optimize.
;;   $truthTableBScore: The scoring function or object.
;;   $inst: The initial instance for optimization.
;;   $optimize: The optimizer function to apply to each deme.
;;  Returns: (List Deme): A new list where each deme has been optimized.
(: optimizeDemes (-> (List Deme) (TruthTableBScore $a) Instance (-> Deme (TruthTableBScore $a) Instance (Instance Deme $state)) (List (Instance Deme $state))))
(= (optimizeDemes Nil $truthTableBScore $inst $optimize) Nil)
(= (optimizeDemes (Cons $deme $demes) $truthTableBScore $inst $optimize)
(Cons ($optimize $deme $truthTableBScore $inst) (optimizeDemes $demes $truthTableBScore $inst $optimize)))

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
(: expandDeme (-> (OS (Exemplar $a)) Number Number (TruthTableBScore $a) (-> Deme (TruthTableBScore $a) Instance (Instance Deme $state)) Number Number Number Number (ITable $a) Number Number Number (OS (Exemplar $a))))
(= (expandDeme $metaPop $nExpansion $nDeme $truthTableBScore $optimize $nEval $maxCandsPerDeme $minPoolSize $complexityTemperature $itable $nToKeep $capCoef $genCount)
(let*
(
    ($exemplar (trace! "Selecting Exemplar" (selectExemplar $metaPop)))
    (() (println! $exemplar))
    ($tree (getExemplarTree $exemplar))
    ($deme (trace! "Creating Deme" (createDeme $tree $nExpansion $nDeme))) ;;createRepresentation and createDemeId are under this
    (() (println! $deme))
    ((mkDeme (mkRep (mkKbMap (mkDscKbMp $dscKbMp) (mkDscMp $dscMp)) $updatedTree) $sInstList $demeId) $deme)
    ($lengthOfDscKbMp (Map.length $dscKbMp))
    ($generatedList (List.generate $lengthOfDscKbMp 0))
    ((Cons ($inst $optimDeme $state) Nil) (trace! "Optimizing Deme" (optimizeDemes (Cons $deme Nil) $truthTableBScore (mkInst $generatedList) $optimize))) ;; the hillclimbing is called under this and it calls the neighborhood and stuff to first populate the deme with instances
    (() (println! $optimDeme))
    ($updatedMetaPop (trace! "Merging Deme" (mergeDemes $optimDeme $nEval $maxCandsPerDeme $minPoolSize $complexityTemperature $itable $metaPop $nToKeep $capCoef $genCount)))
)
$updatedMetaPop))

;; The main loop 
;; Takes 2 termination criterias:
;;     - $maxGen : how many times we want the loop to run
;;     - $maxScore : the maximum score we want the top Examplar to have
;; It also takes:
;;     - $maxCandOutput : The number of candidates to be returned
;;     - other parameters required by the expandDeme method
(: runMoses (-> Number Cscore Number (OS (Exemplar $a)) Number Number (TruthTableBScore $a) (-> Deme (TruthTableBScore $a) Instance (Instance Deme $state)) Number Number Number Number (ITable $a) Number Number Number (OS (Exemplar $a))))
(= (runMoses $maxGen $maxScore $maxCandOutput $metaPop $nExpansion $nDeme $truthTableBScore $optimize $nEval $maxCandsPerDeme $minPoolSize $complexityTemperature $itable $nToKeep $capCoef $genCount)
(if (== $maxGen 0) 
    (let $topCandidates (OS.getTopN $maxCandOutput $metaPop) $topCandidates)
    (let* 
     (
       ($updatedMetaPop (expandDeme $metaPop $nExpansion $nDeme $truthTableBScore $optimize $nEval $maxCandsPerDeme $minPoolSize $complexityTemperature $itable $nToKeep $capCoef $genCount))
       ($top (OS.getByIdx 0 $metaPop))
       ($topScore (getExemplarCscore $top))
       ($topCandidates (OS.getTopN $maxCandOutput $metaPop)))
     (if (cScore>= $topScore $maxScore) 
         $topCandidates 
         (runMoses (- $maxGen 1) $maxScore $maxCandOutput $metaPop $nExpansion $nDeme $truthTableBScore $optimize $nEval $maxCandsPerDeme $minPoolSize $complexityTemperature $itable $nToKeep $capCoef $genCount)))))