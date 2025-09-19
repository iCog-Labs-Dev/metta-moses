;; ================================================================================
;; Univariate Optimization Implementation
;; ================================================================================
;;
;; This file implements the univariate optimizer that uses the EDA framework
;; for optimization in MOSES.
;;
;; Key Features:
;; - Uses EDA framework for population-based optimization
;; - Assumes no dependencies between variables (univariate)
;; - Compatible with run-moses integration
;; - Uses tournament selection and probability learning
;;
;; Entry Point: univariate(Deme, TruthTableBScore, Instance) -> (Instance, Deme, State)

;; ================================================================================
;; Main Univariate Optimization Function
;; ================================================================================

;; Entry point compatible with runMoses/expandDeme (same signature as hillClimbing)
; (: univariate (-> Deme (TruthTableBScore $a) Instance (Instance Deme $state)))
(= (univariate $deme $tTableBscorer $centerInst)
  (let* (
        (() (println! (univariate: $deme $tTableBscorer $centerInst)))
        ($edaParams (default-eda-parameters))
        ($result (univariate-with-eda $deme $tTableBscorer $centerInst $edaParams))
      )
      $result))

;; Helper to ensure we operate on a concrete Instance value
; (: unwrap-instance (-> Instance Instance))
(= (unwrap-instance $inst) $inst)

;; Univariate optimization using EDA framework
; (: univariate-with-eda (-> Deme (TruthTableBScore $a) Instance (EDAParameters) (Instance Deme $state)))
(= (univariate-with-eda $deme $tTableBscorer $centerInst $edaParams)
  (let* (
        (() (println! (Starting univariate-with-eda)))
        ((mkTruthTableBScore $cpxCoeff $size $iTable) $tTableBscorer)
        (() (println! (cpxCoeff: $cpxCoeff size: $size)))
        ((mkDeme $rep (mkSInstSet $instSet) $id) $deme)
        ($discMap (getDiscMap $rep))
        ($discMapLength (MultiMap.length $discMap))
        (() (println! (discMapLength: $discMapLength)))
        ($popSize (max 1 $discMapLength))
        (() (println! (popSize: $popSize)))
        ;; Pre-score population and seed diversity if needed
        ($scoredInit (transform (mkSInstSet $instSet) $rep $iTable $cpxCoeff))
        (() (println! (scoredInit: $scoredInit)))
        ((mkSInstSet $scoredList) $scoredInit)
        (() (println! (scoredList: $scoredList)))
        ($maybeSeed (if (<= (List.length $scoredList) 1)
                         (Cons (mkSInst (mkPair (sample-uniform-instance $rep) (worstCscore))) $scoredList)
                         $scoredList))
        ($deme0 (mkDeme $rep (mkSInstSet $maybeSeed) $id))
        (() (println! (deme0: $deme0)))
        ;; Calculate parameters
        ($maxGensTotal (min 3 (max 1 $discMapLength)))
        (() (println! (maxGensTotal: $maxGensTotal)))
        ($maxGensImprov 10)
        (() (println! (maxGensImprov: $maxGensImprov)))
        ($selection (getSelection $edaParams))
        (() (println! (selection: $selection)))
        ($selRatio (getSelectionRatio $edaParams))
        (() (println! (selRatio: $selRatio)))
        ($repRatio (getReplacementRatio $edaParams))
        (() (println! (repRatio: $repRatio)))
        ($nSelect (* $popSize $selRatio))
        (() (println! (nSelect: $nSelect)))
        ($nGenerate (* $popSize $repRatio))
        (() (println! (nGenerate: $nGenerate)))
        (() (println! (maxGensTotal: $maxGensTotal nSelect: $nSelect nGenerate: $nGenerate)))
      )
      (univariate-eda-loop $deme0 $cpxCoeff $iTable $centerInst $edaParams $nSelect $nGenerate 0 $maxGensTotal $maxGensImprov)))

;; Main EDA loop for univariate optimization
; (: univariate-eda-loop (-> Deme Number (ITable $a) Instance (EDAParameters) Number Number Number Number Number (Instance Deme $state)))
(= (univariate-eda-loop $deme $cpxCoeff $iTable $centerInst $edaParams $nSelect $nGenerate $gen $maxGens $maxGensImprov)
  (let* (
        (() (println! (EDA Loop: gen= $gen maxGens= $maxGens)))
        ;; Recompute simple scalar params inside the loop frame to avoid any unevaluated symbols
        ($selection2 (getSelection $edaParams))
      )
      (if (>= $gen $maxGens)
          (let* (
            (() (println! (Reached max generations: $gen)))
            ($finalCenter (unwrap-instance $centerInst))
            ($result (make-result $finalCenter $deme))
          )
          $result)
          (let* (
                (() (println! (Starting EDA step: selection)))
                ;; Selection step
                ($selectedInstances (tournament-selection $selection2 $deme $nSelect))
                (() (println! (Selection done, learning model)))
                
                ;; Model learning step
                ($probModel (learn-probability-model $deme $selectedInstances))
                (() (println! (Model learning done, sampling)))
                
                ;; Sampling step
                ($newInstances (sample-from-model $probModel $deme $nGenerate))
                (() (println! (Sampling done, scoring)))
                
                ;; Scoring step
                ($scoredNewInstances (transform $newInstances (getRep $deme) $iTable $cpxCoeff))
                (() (println! (Scoring done, replacing)))
                
                ;; Replacement step
                ($updatedDeme (replace-the-worst $scoredNewInstances $deme))
                (() (println! (Replacement done, updating center)))
                
                ;; Update center
                ((mkSInstSet $allInstances) (getInstanceSet $updatedDeme))
                ($bestSInst (select-best $allInstances))
                ($nextCenterRaw (getInst $bestSInst))
                ($nextCenter (unwrap-instance $nextCenterRaw))
                (() (println! (Center updated, continuing loop)))
              )
              (univariate-eda-loop $updatedDeme $cpxCoeff $iTable $nextCenter $edaParams $nSelect $nGenerate (+ $gen 1) $maxGens $maxGensImprov)))))

;; ================================================================================
;; Information Theoretic Calculations
;; ================================================================================

;; Information theoretic bits calculation (from C++ version)
; (: information-theoretic-bits (-> Representation Number))
(= (information-theoretic-bits $rep)
   (let* (
         ($discMap (getDiscMap $rep))
         ($specs (MultiMap.values $discMap))
         ($mults (List.map disc-spec-multiplicity $specs))
         ($bitsEach (List.map ilog2ceil $mults))
         ($totalBits (List.foldl + 0 $bitsEach))
       )
       (max 1 $totalBits)))

;; Get multiplicity from DiscSpec
; (: disc-spec-multiplicity (-> (DiscSpec $knob) Number))
(= (disc-spec-multiplicity (mkDiscSpec $m)) $m)

;; Integer ceil(log2(n)) without floating math
; (: ilog2ceil (-> Number Number))
(= (ilog2ceil $n)
   (ilog2ceil-acc $n 1 0))

; (: ilog2ceil-acc (-> Number Number Number Number))
(= (ilog2ceil-acc $n $v $k)
   (if (< $v $n)
       (ilog2ceil-acc $n (* $v 2) (+ $k 1))
       $k))

;; ================================================================================
;; Result Construction
;; ================================================================================

;; Make result tuple for compatibility
(: make-result (-> Instance Deme Expression))
(= (make-result $inst $deme) ($inst $deme ()))

;; ================================================================================
;; Legacy Simple Implementation (for comparison)
;; ================================================================================

;; Simple univariate function without EDA (kept for backward compatibility)
; (: univariate-simple (-> Deme (TruthTableBScore $a) Instance (Instance Deme $state)))
(= (univariate-simple $deme $tTableBscorer $centerInst)
   (let* (
         ((mkTruthTableBScore $cpxCoeff $size $iTable) $tTableBscorer)
         ((mkDeme $rep (mkSInstSet $instSet) $id) $deme)
         ($discMap (getDiscMap $rep))
         ($discMapLength (MultiMap.length $discMap))
         ($maxGens (max 1 $discMapLength))
       )
       (univariate-simple-loop $deme $cpxCoeff $iTable $centerInst 0 $maxGens)))

;; Simple loop without EDA
; (: univariate-simple-loop (-> Deme Number (ITable $a) Instance Number Number (Instance Deme $state)))
(= (univariate-simple-loop (mkDeme $rep (mkSInstSet $instSet) $id)
                    $cpxCoeff $iTable $centerInst $gen $maxGens)
   (if (>= $gen $maxGens)
       (let* (
         ($result ($centerInst (mkDeme $rep (mkSInstSet $instSet) $id) ()))
       )
       $result)
       (let* (
             ;; Simple neighborhood sampling
             ($totalNeighbors (estimateNeighborhood 1 (getDiscMap $rep)))
             ($nNew (min $totalNeighbors 3))
             (($demeWithNewInsts $added) (sampleNewInstances $totalNeighbors $nNew $centerInst (mkDeme $rep (mkSInstSet $instSet) $id) 1))
             ((mkSInstSet $scored) (transform (getInstanceSet $demeWithNewInsts) (getRep $demeWithNewInsts) $iTable $cpxCoeff))
             ($demeScored (mkDeme (getRep $demeWithNewInsts) (mkSInstSet $scored) (getDemeId $demeWithNewInsts)))
             ((mkSInst $bestPair) (List.foldl ((curry2 returnBest) <) (mkSInst (mkPair $centerInst (worstCscore))) $scored))
             ($nextCenter (Pair.first $bestPair))
           )
           (univariate-simple-loop $demeScored $cpxCoeff $iTable $nextCenter (+ $gen 1) $maxGens))))

;; Helper function to get deme ID
; (: getDemeId (-> Deme DemeId))
(= (getDemeId (mkDeme $rep $instSet $id)) $id)
