;; Recursively optimizes each deme in a list using the provided optimizer function.
;; Params:
;;   (List Deme): The list of demes to optimize.
;;   $truthTableBScore: The scoring function or object.
;;   $inst: The initial instance for optimization.
;;   $optimize: The optimizer function to apply to each deme.
;;  Returns: (List Deme): A new list where each deme has been optimized.
; (: optimizeDemes (-> (List Deme) (TruthTableBScore $a) Instance (-> Deme (TruthTableBScore $a) Instance $Scorer (Instance Deme $state)) $Scorer (List (Instance Deme $state))))
(= (optimizeDemes $deme $truthTableBScore $inst $optimize)
(eval ($optimize $deme $truthTableBScore $inst)))

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
    ($_ (println! ""))
    ;; ($_ (println! (MetaPop: $metaPop)))
    ;; ($_ (println! "Selecting Exemplar"))
    ($exemplar (eval (selectExemplar $metaPop)))
    ;; ($_ (println! $exemplar))
    ;; ($_ (println! "getting exemplar tree"))
    ($tree (eval (getExemplarTree $exemplar))) 
    ;; ($_ (println! $tree))
    ;; ($_ (println! "creating deme IDs"))
    ($demeIds (eval (createDemeIds $nExpansion $nDeme)))
    ;; ($_ (println! $demeIds))
    ; ($argLabels (getArgLabels $itable))
    ;; ($_ (println! "Creating Deme"))
    ($demes (eval (createDeme $nDeme $demeIds $tree $itable $fs-algo $prune-exemplar () $scorerType)))     
    )
    (map-atom $demes $deme (expandDemeHelper $deme $truthTableBScore $optimize))
   ))

(= (expandDemeHelper (mkDeme (mkRep (mkKbMap (mkDscKbMp $dscKbMp) (mkDscMp $dscMp)) $updatedTree) $sInstList $demeId) $truthTableBScore $optimize)
(let*
(
    ($lengthOfDscKbMp (eval (Map.length $dscKbMp)))
    ($generatedList (eval (List.generate $lengthOfDscKbMp 0)))
    ($deme (mkDeme (mkRep (mkKbMap (mkDscKbMp $dscKbMp) (mkDscMp $dscMp)) $updatedTree) $sInstList $demeId))
    ($_ (println! "Optimizing Deme"))
    (($inst $optimDeme $state) (eval (optimizeDemes $deme $truthTableBScore (mkInst $generatedList) $optimize)))
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
       ;; ($_ (println! "expand deme returnn"))
       ($optimizedDemes (eval (expandDeme $metaPop $nExpansion $nDeme $prune-exemplar $fs-algo $truthTableBScore $optimize $itable mi)))
       ;; ($_ (println! "Merging Deme"))
       ($updatedMetaPop (eval (mergeDemes $optimizedDemes $nEval $maxCandsPerDeme $minPoolSize $complexityTemperature $itable $metaPop $nToKeep $capCoef $genCount)))
       ;; ($_ (println! (Updated MetaPop: $updatedMetaPop)))
       ($top (eval (OS.getByIdx 0 $metaPop)))
       ;; ($_ (println! (Top Exemplar before expansion: $top)))
       ($topScore (eval (getExemplarCscore $top)))
       ;; ($_ (println! (topscore: $topScore)))
       ($resultCandi (if (<= $maxCandOutput (eval (OS.length $metaPop))) (eval (OS.getTopN $maxCandOutput $metaPop)) $metaPop))
       ($_ (cut))
      )
 (if (eval (cScore>= $topScore $maxScore))
         $resultCandi 
         (eval (runMoses (- $maxGen 1) $maxScore $maxCandOutput $updatedMetaPop $nExpansion $nDeme $prune-exemplar $fs-algo $truthTableBScore $optimize $nEval $maxCandsPerDeme $minPoolSize $complexityTemperature $itable $nToKeep $capCoef $genCount))))))
