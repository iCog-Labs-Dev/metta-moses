;; Precision Scorer Implementation for Hill Climbing Feature Selection

;; IMPORTANT NOTE: This implementation focuses specifically on the 
;; best_possible_bscore() method from MOSES, which is used for feature
;; selection in hill climbing. The full precision_bscore class in MOSES
;; also includes functionality for scoring actual combo trees against
;; data tables, but that is not implemented here.


;; CountTable: It counts True Positives (pos) and False Positives (neg) for each unique input pattern
;; 
;; Input:
;;   $rows: List of data rows, each containing feature values + target
;;          Example: ((True True True) (True False False) (False True False))
;;   $targetIndex: Index of the target column (usually last column)
;;                Example: If we have 3 columns [A, B, Output], targetIndex = 2
;;   $acc: Accumulator Map storing results from previous rows
;; 
;; Output:
;;   Map from input pattern -> (pos_count neg_count)
;;   Example: (ConsMap ((False False) (2 2)) (ConsMap ((True False) (0 3)) (ConsMap ((False True) (3 0)) NilMap)))
; (: countTable (-> Expression Number (Map $k $v) (Map Expression (Number Number))))
(= (countTable $row $targetIndex $acc)
   (if (== $row ())
      NilMap
      (let* (
            ($inputPart (takeN $targetIndex $row)) ;; Extract input features (all columns except target)
            ($targetVal (index-atom $row $targetIndex)) ;; Get target value (True/False)
            
            (($pos $neg) (if (Map.contains $inputPart $acc)
                           (Map.getByKey $inputPart $acc)
                           (0 0))) ;; Get existing counts for this input pattern, or initialize to (0,0)

            ($newCounts (if $targetVal ;; Update counts based on target value
                           ((+ $pos 1) $neg)       ;; True target: increment positive count
                           ($pos (+ $neg 1))))    ;; False target: increment negative count

            )   
      (Map.insert ($inputPart $newCounts) $acc == ==) ;; used == comparator since the ordering doesn't matter we just need unorderedMap not orderedMap
      )
   )
)

;; Build compressed table (CTable) by grouping identical input patterns
; The structure of the CTable is referred from the below test file 
; Reference: https://github.com/opencog/moses/blob/master/tests/moses/precision2.ctable
;;
;; Input:
;;   $rows: All data rows
;;   $labels: Column labels (features + target)
;; 
;; Output:
;;   Map from input_pattern -> (positive_count negative_count)
;;
;; Example:
;;    (ConsMap ((False False) (2 2)) (ConsMap ((True False) (0 3)) (ConsMap ((False True) (3 0)) NilMap)))
; (: cTable (-> Expression Expression (Map Expression (Number Number))))
(= (cTable $rows $labels)
   (let* (
          ($targetIndex (- (size-atom $labels) 1))
         
          ($grouped (foldl-atom $rows NilMap $acc $row
                              (countTable $row $targetIndex $acc)))
         )
     $grouped)
)

;; sum_outputs = 0.5 * (pos - neg)
;;
;; Mathematical Significance:
;; - For True Positives: contributes +0.5 per instance
;; - For False Positives: contributes -0.5 per instance  
;; - Net effect: sum_outputs = 0.5 * (TP - FP)
; (: sumOutputs (-> Number Number Number))
(= (sumOutputs $pos $neg)
   (* 0.5 (- $pos $neg)))



;; Create precision data for one compressed row and insert into existing MultiMap
;; This builds the precision-sorted structure needed for best Possible selection
;;
;; Input:
;;   $item: Map entry in form (input_pattern (pos_count neg_count))
;;   $acc: MultiMap accumulator for precision-sorted results
;;
;; Output:
;;   MultiMap sorted by precision (descending) containing (precision (sumo total))
;;   Example : (ConsMMap (0.5 (1.5 3)) (ConsMMap (0.0 (0.0 4)) (ConsMMap (-0.5 (-1.5 3)) NilMMap)))
;;
;; Mathematical derivation:
;; - total = pos + neg (total activations for this pattern)
;; - sumo = 0.5 * (pos - neg) (weighted contribution)  
;; - precision = sumo / total (individual precision for this pattern)

;; Example calculation:
;;   Input: ((True False) (3 1)) 
;;   total = 3 + 1 = 4
;;   sumo = 0.5 * (3 - 1) = 1.0
;;   precision = 1.0 / 4 = 0.25
;;   Result: (ConsMMap (0.25 (1.0 4)) NilMMap)
;; The MultiMap automatically sorts by precision key (using > for descending order)
;; This ordering is crucial for the best possible score implementation which processes highest
;; precision patterns first.
; (: makePrecisionRow (-> Expression Expression (Map Expression (Number Number))))
(= (makePrecisionRow $item $acc)
   (if (== $item ())
      NilMMap
      (let* (
            (($labels ($pos $neg)) $item)  ;; Extract positive and negative counts
            
            ($total (+ $pos $neg)) ;; Calculate totals and precision metrics
            ($sumo (sumOutputs $pos $neg))
            ($precision (if (== $total 0) 0.0 (/ $sumo $total)))
            )
         (MultiMap.insert ($precision ($sumo $total)) $acc >) ;; for descending sort
         )
      )
)
;       (if-decons-expr $item $inputPattern $rest
;          (let* (
;             (($pos $neg) $count)  ;; Extract positive and negative counts
            
;             ($total (+ $pos $neg)) ;; Calculate totals and precision metrics
;             ($sumo (sumOutputs $pos $neg))
;             ($precision (if (== $total 0) 0.0 (/ $sumo $total)))
;             )
;          (MultiMap.insert ($precision ($sumo $total)) $acc >) ;; for descending sort
;          ) 
;          NilMMap
;       )
; )

;; Convert Map of compressed data to precision-sorted MultiMap
;; This prepares data for the greedy best_possible_bscore algorithm
;;
;; Input:
;;   $groupedData: Map from input_pattern -> (pos_count neg_count)
;;
;; Output:
;;   Expression containing precision-sorted list: ((precision (sumo total)) ...)
;;
;; The sorting by precision (descending) is crucial for the best_possible_bscore
;; which processes rows from highest to lowest individual precision
; (: createPrecisionRows (-> (MultiMap (Number (Number Number))) Expression))
(= (createPrecisionRows $groupedData)
   (let* (
            ($items (Map.items $groupedData))
            ($itemsExpr (List.listToExpr $items))
            ($precisionRows (foldl-atom $itemsExpr NilMMap $acc $item (makePrecisionRow $item $acc)))
            ($precisionItems (MultiMap.items $precisionRows))
         )
        (List.listToExpr $precisionItems)
   )
)

;; Calculate activation penalty using logarithmic penalty function
;; Mathematical explanation:
;; The penalty prevents solutions with activation outside [min_activation, max_activation]
;; Uses logarithmic penalty: penalty = activation_pressure * log(1 - distance_from_boundary)
;; 
;; The logarithmic penalty creates a "soft constraint" that:
;; - Allows small violations with moderate penalties
;; - Creates steep penalties near boundary violations  
;; - Approaches -infinity as violations become extreme
;; Parameters:
;;   $activation: Current activation ratio (0.0 to 1.0)
;;                        activation = (TP + FP) / total_dataset_size
;;   $minActivation : Minimum acceptable activation (e.g., 0.5)
;;   $maxActivation : Maximum acceptable activation (e.g., 1.0)  
;;   $activationPressure : Penalty scaling factor (e.g., 1.0)
; (: getActivationPenalty (-> Number Number Number Number Number))
(= (getActivationPenalty $activation $minActivation $maxActivation $activationPressure)
   (if (<= $activationPressure 0)
       0.0
       (let* (
             ($dst (if (< $activation $minActivation) ;; Calculate distance from acceptable range
                       (- 1.0 (/ $activation $minActivation))
                       (if (> $activation $maxActivation)
                           (/ (- $activation $maxActivation) (- 1.0 $maxActivation))
                           0.0)))
               )
         (if (== $dst 0.0)
             0.0
             (* $activationPressure (log-math 2.718 (- 1.0 $dst))))))) ;; Apply logarithmic penalty


;; This finds the theoretical maximum precision score achievable by any
;; classifier that uses only the selected features
;;
;; The algorithm implements the greedy strategy from precision_bscore::best_possible_bscore():
;; 1. Process precision-sorted patterns from highest to lowest individual precision
;; 2. For each cumulative prefix, calculate: precision_part + activation_penalty
;; 3. Track the best score seen across all prefixes
;; 4. Stop early when minimum activation threshold is reached 
;;
;; Parameters:
;;   $rows (Expression): Precision-sorted Expression ((precision (sumo total)) ...)
;;   $sao (Number): Sum of accumulated outputs (cumulative sumo values)
;;   $active (Number): Count of accumulated instances (cumulative total values)  
;;   $totalWeight (Number): Total dataset size (for activation calculation)
;;   $minAct (Number): Minimum activation threshold (early stopping condition)
;;   $maxAct (Number): Maximum activation threshold (for penalty calculation)
;;   $actPressure (Number): Activation penalty scaling factor
;;   $bestScore (Number): Best score found so far (typically starts at -infinity)

;; Returns: (Number) Best achievable precision score for this feature set
;;
;; Some formulas:
;;   For each prefix of patterns (sorted by decreasing individual precision):
;;   - cumulative_precision = (cumulative_sumo / cumulative_active) + 0.5
;;   - activation_ratio = cumulative_active / total_dataset_size
;;   - activation_penalty = logarithmic penalty if outside [minAct, maxAct]
;;   - prefix_score = cumulative_precision + activation_penalty
;;   - best_score = max(best_score, prefix_score)
;;
;; The +0.5 offset correction accounts for MOSES behavioral score representation
;; where the precision formula 0.5*(TP-FP)/(TP+FP) equals precision - 0.5
;;
; (: bestPossibleBScore (-> Expression Number Number Number Number Number Number Number))
(= (bestPossibleBScore $rows $sao $active $totalWeight $minAct $maxAct $actPressure $bestScore)
   (if (== $rows ())
      $bestScore
      (let* (
               (($row $rest) (decons-atom $rows)) ;; Extract current row data
               (($precKey ($sumo $total)) $row)
               
               ($newSao (+ $sao $sumo))
               ($newActive (+ $active $total))
               
               ;; Calculate precision part with +0.5 offset correction
               ($precisionPart (if (== $newActive 0)
                                 0.5
                                 (+ (/ $newSao $newActive) 0.5)))
               
               ;; Calculate activation and penalty
               ($currentActivation (/ $newActive $totalWeight))
               ($penalty (getActivationPenalty $currentActivation $minAct $maxAct $actPressure))
               
               ;; Compute total score and update best
               ($currentScore (+ $precisionPart $penalty))
               ($updatedBest (if (> $currentScore $bestScore) $currentScore $bestScore))
            )
      
             (if (>= $newActive (* $totalWeight $minAct)) ;; break when min_activation is reached
               $updatedBest
               (bestPossibleBScore $rest $newSao $newActive $totalWeight $minAct $maxAct $actPressure $updatedBest)
             )
         )
   )
)

;; Main precision scoring orchestration function
;;
;; The function coordinates the entire precision scoring process:
;; 1. Compress raw data into CTable format (group identical input patterns)
;; 2. Calculate individual precision for each compressed pattern  
;; 3. Sort patterns by precision in descending order
;; 4. Run greedy best_possible_bscore algorithm to find optimal score
;;
;; Parameters:
;;   $rows (Expression): Raw data rows from filtered table
;;   $labels (Expression): Column labels for the filtered table
;;   $activationPressure (Number): Penalty scaling for activation constraints
;;   $minActivation (Number): Minimum acceptable activation ratio (early stopping condition)
;;   $maxActivation (Number): Maximum acceptable activation ratio  (for penalty calculation)
;;   $totalWeight (Number): Total dataset size (for activation calculations)
;;
;; Returns: (Number) Best achievable precision score using these features
;;
;; This represents the theoretical upper bound on precision that any classifier
;; could achieve using only the selected features while respecting activation
;; constraints. It's used by hill climbing to evaluate feature set quality.
; (: precisionBScore (-> Expression Expression Number Number Number Number Number Number Number))
(= (precisionBScore $rows $labels $activationPressure $minActivation $maxActivation $totalWeight)
   (let* (
            ($_ (println! (debug Inside Precision scoring)))
            ($groupedData (cTable $rows $labels))
            
            ($precisionRows (createPrecisionRows $groupedData))
            
            ($bestPreScore (bestPossibleBScore $precisionRows 0.0 0.0 $totalWeight $minActivation $maxActivation 
                                         $activationPressure -1.0000000000000001e308))
         )
     $bestPreScore
   )
)

;; Extract selected features plus target column from full dataset
;; Input:
;;   $featureIndices:  selected feature column indices
;;   $rows: Original table data
;;   $labels: Column labels
;;
;; Output:
;;   Expression like (filtered_rows filtered_labels) containing only selected features + target
; (: extractTable (-> Expression (List (List $a)) (List Symbol) (Expression Expression)))
(= (extractTable $featureIndices $rows $labels)
   (let* (
          ;; Target is always last column
          ($targetIndex (- (List.length $labels) 1))
          ;; Combine selected features with target index
          ($exprIndices (appendAtom $targetIndex $featureIndices))

          ;; Extract selected columns from each row
          ($filteredRows (zipColumn $exprIndices $rows))
          ;; Extract corresponding labels
          ($filteredLabels (map-atom $exprIndices $each (List.at $each $labels)))
          ($filteredExpr (List.listToExpr $filteredRows))
          )
     ($filteredExpr $filteredLabels)
   )
)

;; Main pre_scorer implementation 
;; This is the top-level function called by hill climbing for feature selection
;; Reference: https://github.com/opencog/moses/blob/f88ccd3279f3dd853e8c23103be5376a0e7eafc1/moses/feature-selection/scorers/moses_matrix.h#L48
;;
;; 1. Validate and clamp activation parameters to [0,1] range
;; 2. Filter dataset to selected features plus target column  
;; 3. Run precision_bscore analysis on filtered data
;; 4. Apply confidence weighting based on feature set size
;; 5. Return final score for hill climbing optimization
;;
;; Parameters:
;;   $featureIndices (Expression): Selected feature indices, e.g., (0 2 5)
;;   $itable (ITable): Complete input table with all features and target
;;   $penalty (Number): Activation penalty pressure (typically 1.0)
;;   $minAct (Number): Minimum activation threshold (e.g., 0.5)  
;;   $maxAct (Number): Maximum activation threshold (e.g., 1.0)
;;   $positive (Bool): Whether to target positive/negative outcomes
;;   $confi (Number): Confidence scaling parameter (e.g., 100.0)
;;
;; Returns: (Number) Final weighted precision score for this feature set
;;
;; The returned score represents how good this feature combination is for
;; precision-based classification, accounting for both achievable precision
;; and the complexity cost of using multiple features.
; (: preScorer (-> Expression (ITable $a) Number Number Number Bool Number Number))
(= (preScorer $featureIndices (mkITable $rows $labels) $penalty $minAct $maxAct $positive $confi)
   (if (== $featureIndices ())
      0.0
      (let* (
               ;; Ensure activation bounds are valid
               ($clampedMinAct (clamp $minAct 0.0 1.0))
               ($clampedMaxAct (clamp $maxAct 0.0 1.0))
               
               (($filteredRows $filteredLabels)  (extractTable $featureIndices $rows $labels))
               
               ($totalWeight (List.length $rows))
               
               ($precision (precisionBScore $filteredRows $filteredLabels $penalty 
                                          $clampedMinAct $clampedMaxAct $totalWeight))
               
               ;; Apply confidence weighting
               ($confidence (calculateConfidence (size-atom $featureIndices) $totalWeight $confi))
               
               ;; Final score for hill climbing feature selection
               ($finalScore (* $precision $confidence))
            )
      $finalScore
      )
   )
)
