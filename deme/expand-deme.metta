;; Recursively optimizes each deme in a list using the provided optimizer function.
;; Params:
;;   (List Deme): The list of demes to optimize.
;;   $truthTableBScore: The scoring function or object.
;;   $inst: The initial instance for optimization.
;;   $optimize: The optimizer function to apply to each deme.
;;  Returns: (List Deme): A new list where each deme has been optimized.
(: optimizeDemes (-> (List Deme) (TruthTableBScore $a) Instance (-> Deme (TruthTableBScore $a) Instance (Instance Deme $state)) (List (Instance Deme $state))))
(= (optimizedDemes Nil $truthTableBScore $inst $optimize) Nil)
(= (optimizeDemes (Cons $deme $demes) $truthTableBScore $inst $optimize)
(Cons ($optimize $deme $truthTableBScore $inst) (optimizeDemes $demes $truthTableBScore $inst $optimize)))

;; Runs one deme-creation and optimization step, then merges the optimized deme into the metapopulation.
;; Params:
;;   $metaPop: The current metapopulation.
;;   $nExpansion: Expansion count or deme index.
;;   $nDeme: Number of demes to create.
;;   $truthTableBScore: TruthTableBScore
;;   $inst: Initial instance for optimization.
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
(: expandDeme (-> (OS (Exemplar $a)) Number Number (TruthTableBScore $a) Instance (-> Deme (TruthTableBScore $a) Instance (Instance Deme $state)) Number Number Number Number (ITable $a) Number Number Number (OS (Exemplar $a))))
(= (expandDeme $metaPop $nExpansion $nDeme $truthTableBScore $inst $optimize $nEval $maxCandsPerDeme $minPoolSize $complexityTemperature $itable $nToKeep $capCoef $genCount)
(let*
(
    (() (println! "Select exemplar"))
    ($exemplar (selectExemplar $metaPop))
    (() (println! $exemplar))
    (() (println! "createDeme"))
    ($deme (createDeme $exemplar $nExpansion $nDeme)) ;;createRepresentation and createDemeId are under this
    (() (println! $deme))
    (() (println! "optimizeDemes"))
    ((Cons $optimDeme $optimDemes) (optimizeDemes (Cons $deme Nil) $truthTableBScore $inst $optimize)) ;; the hillclimbing is called under this and it calls the neighborhood and stuff to first populate the deme with instances
    (() (println! $optimDeme))
    (() (println! "mergeDemes"))
    ($updatedMetaPop (mergeDemes $optimDeme $nEval $maxCandsPerDeme $minPoolSize $complexityTemperature $itable $metaPop $nToKeep $capCoef $genCount))
    (() (println! $updatedMetaPop))
)
$updatedMetaPop))

