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
;;
;; EDA Workflow Integration:
;; 1. Initialize population with existing instances
;; 2. Select promising individuals using tournament selection
;; 3. Learn probability model from selected individuals
;; 4. Sample new individuals from learned model
;; 5. Replace worst individuals with new ones
;; 6. Repeat until termination criteria met

;; ================================================================================
;; Main Univariate Optimization Function
;; ================================================================================

;; Entry point compatible with runMoses/expandDeme (same signature as hillClimbing)
;; This is the main entry point that sets up EDA parameters and delegates to the EDA-based implementation
; (: univariate (-> Deme (TruthTableBScore $a) Instance (Instance Deme $state)))
(= (univariate $deme $tTableBscorer $centerInst)
  (let* (
        ;; Entry log (keep concise)
        (() (println! (univariate: starting)))
        ($edaParams (defaultEdaParameters))
        ($result (univariateWithEda $deme $tTableBscorer $centerInst $edaParams))
      )
      $result))

;; ================================================================================
;; EDA-Based Univariate Optimization
;; ================================================================================

;; Univariate optimization using EDA framework
;; This function sets up the EDA parameters and initializes the population
;; before entering the main EDA optimization loop
; (: univariateWithEda (-> Deme (TruthTableBScore $a) Instance (EDAParameters) (Instance Deme $state)))
(= (univariateWithEda $deme $tTableBscorer $centerInst $edaParams)
  (let* (
        (() (println! (univariate-with-eda: start)))
        ;; Extract scoring parameters
        ((mkTruthTableBScore $cpxCoeff $size $iTable) $tTableBscorer)
        
        ;; Extract deme components
        ((mkDeme $rep (mkSInstSet $instSet) $id) $deme)
        ($discMap (getDiscMap $rep))
        ($discMapLength (MultiMap.length $discMap))
        
        ;; Calculate population size based on representation complexity
        ($popSize (max 1 $discMapLength))
        
        ;; Pre-score population and seed diversity if needed
        ($scoredInit (transform (mkSInstSet $instSet) $rep $iTable $cpxCoeff))
        ((mkSInstSet $scoredList) $scoredInit)
        
        ;; Add seed instance if population is too small
        ($maybeSeed (if (<= (List.length $scoredList) 1)
                         (Cons (mkSInst (mkPair (sampleUniformInstance $rep) (worstCscore))) $scoredList)
                         $scoredList))
        ($deme0 (mkDeme $rep (mkSInstSet $maybeSeed) $id))
        
        ;; Calculate EDA parameters
        ($maxGensTotal (min 3 (max 1 $discMapLength)))
        ($maxGensImprov 10)
        
        ;; Extract selection and replacement parameters
        ($selection (getSelection $edaParams))
        ($selRatio (getSelectionRatio $edaParams))
        ($repRatio (getReplacementRatio $edaParams))
        
        ;; Calculate selection and generation counts
        ($nSelect (* $popSize $selRatio))
        ($nGenerate (* $popSize $repRatio))
        (() (println! (params: popSize= $popSize maxGens= $maxGensTotal nSelect= $nSelect nGenerate= $nGenerate)))
      )
      ;; Enter the main EDA optimization loop
      (univariateEdaLoop $deme0 $cpxCoeff $iTable $centerInst $edaParams $nSelect $nGenerate 0 $maxGensTotal $maxGensImprov)))

;; ================================================================================
;; Main EDA Optimization Loop
;; ================================================================================

;; Main EDA loop for univariate optimization
;; This implements the core EDA workflow: selection → model learning → sampling → replacement
;; The loop continues until termination criteria are met (max generations reached)
; (: univariate-eda-loop (-> Deme Number (ITable $a) Instance (EDAParameters) Number Number Number Number Number (Instance Deme $state)))
(= (univariateEdaLoop $deme $cpxCoeff $iTable $centerInst $edaParams $nSelect $nGenerate $gen $maxGens $maxGensImprov)
  (let* (
        (() (println! (eda-loop: gen= $gen maxGens= $maxGens)))
        ;; Recompute simple scalar params inside the loop frame to avoid any unevaluated symbols
        ($selection2 (getSelection $edaParams))
      )
      ;; Check termination condition
      (if (>= $gen $maxGens)
          ;; Termination: return best result found
          (let* (
            (() (println! (termination: reached max generations)))
            ($result (makeResult $centerInst $deme))
          )
          $result)
          ;; Continue optimization: execute EDA workflow
          (let* (
                (() (println! (step: selection)))
                
                ;; Step 1: Selection - select promising individuals using tournament selection
                ($selectedInstances (tournamentSelection $selection2 $deme $nSelect))
                (() (println! (step: structure-learning)))
                
                ;; Step 2: Structure Learning - explicit no-op for univariate (clarity and parity)
                (() (univariate-structure-learning $deme $selectedInstances))
                (() (println! (step: probability-learning)))
                
                ;; Step 3: Model Learning - learn probability distributions from selected instances
                ($probModel (learnProbabilityModel $deme $selectedInstances))
                (() (println! (step: sampling)))
                
                ;; Step 4: Sampling - generate new instances from learned probability model
                ($newInstances (sampleFromModel $probModel $deme $nGenerate))
                (() (println! (step: scoring)))
                
                ;; Step 5: Scoring - evaluate new instances using the scoring function
                ($scoredNewInstances (transform $newInstances (getRep $deme) $iTable $cpxCoeff))
                (() (println! (step: replacement)))
                
                ;; Step 6: Replacement - replace worst instances with new ones
                ($updatedDeme (replaceTheWorst $scoredNewInstances $deme))
                (() (println! (step: update-center)))
                
                ;; Step 6: Update center - find best instance for next iteration
                ((mkSInstSet $allInstances) (getInstanceSet $updatedDeme))
                ($bestSInst (selectBest $allInstances))
                ($nextCenterRaw (getInst $bestSInst))
                ($nextCenter $nextCenterRaw)
                (() (println! (center: updated)))
              )
              ;; Recursive call to continue optimization
              (univariateEdaLoop $updatedDeme $cpxCoeff $iTable $nextCenter $edaParams $nSelect $nGenerate (+ $gen 1) $maxGens $maxGensImprov)))))

;; Convenience wrapper to match test signature: (univariateEdaLoop Deme TruthTableBScore Instance EDAParameters)
;; Delegates to the full univariate EDA flow with parameter calculation
(= (univariateEdaLoop $deme $tTableBscorer $centerInst $edaParams)
  (univariateWithEda $deme $tTableBscorer $centerInst $edaParams))

;; ================================================================================
;; Information Theoretic Calculations
;; ================================================================================

;; Information theoretic bits calculation (from C++ version)
;; This calculates the total number of bits needed to represent all knob values
;; in the representation, which is used for population sizing
; (: informationTheoreticBits (-> Representation Number))
(= (informationTheoreticBits $rep)
   (let* (
         ($discMap (getDiscMap $rep))
         ($specs (MultiMap.values $discMap))
         ($mults (List.map discSpecMultiplicity $specs))
         ($bitsEach (List.map ilog2ceil $mults))
         ($totalBits (List.foldl + 0 $bitsEach))
       )
       (max 1 $totalBits)))

;; Get multiplicity from DiscSpec
; (: discSpecMultiplicity (-> (DiscSpec $knob) Number))
(= (discSpecMultiplicity (mkDiscSpec $m)) $m)

;; Ceil(log2(n)) using shared logMath implementation
; (: ilog2ceil (-> Number Number))
(= (ilog2ceil $n)
   (let* (
         ($x (logMath 2 $n))
         ($f (floor-math $x))
       )
       (if (< $f $x) (+ $f 1) $f)))

;; ================================================================================
;; Result Construction
;; ================================================================================

;; Make result tuple for compatibility with runMoses/expandDeme interface
;; Returns a tuple of (Instance, Deme, State) where State is empty
(: makeResult (-> Instance Deme Expression))
(= (makeResult $inst $deme) ($inst $deme ()))

;; ================================================================================
;; Helper Functions
;; ================================================================================

; (: getDemeId (-> Deme DemeId))
(= (getDemeId (mkDeme $rep $instSet $id)) $id)
