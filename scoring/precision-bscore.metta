;; Precision Scorer Implementation for Hill Climbing Feature Selection

;; IMPORTANT NOTE: This implementation focuses specifically on the 
;; best_possible_bscore() method from MOSES, which is used for feature
;; selection in hill climbing. The full precision_bscore class in MOSES
;; also includes functionality for scoring actual combo trees against
;; data tables, but that is not implemented here.


;; CountTable: It counts True Positives (pos) and False Positives (neg) for each unique input pattern
;; 
;; Input:
;;   $rowIndex: Current row index (0 .. rowCount-1)
;;   $inputCols: List of input feature columns
;;   $targetCol: Target column
;;   $acc: Accumulator Map storing results from previous rows
;; 
;; Output:
;;   Map from input pattern -> (pos_count neg_count)
;;   Example: (cons ((False False) (2 2)) (cons ((True False) (0 3)) (cons ((False True) (3 0)) ())))
; (: countTable (-> Number (List (List $a)) (List $a) (Map $k $v) (Map Expression (Number Number))))
(= (countTable $rowIndex $inputCols $targetCol $acc)
   (countTable $rowIndex $inputCols $targetCol () $acc))

(= (countTable $rowIndex $inputCols $targetCol $weights $acc)
   (let* (
         ($inputPattern (map-atom $inputCols $col (index-atom $col $rowIndex)))
         ($targetVal (index-atom $targetCol $rowIndex))
         ($w (if (== $weights ()) 1 (index-atom $weights $rowIndex)))

         (($pos $neg) (if (Map.contains $inputPattern $acc)
                        (Map.getByKey $inputPattern $acc)
                        (0 0)))

         ($newCounts (if $targetVal
                        ((+ $pos $w) $neg)
                        ($pos (+ $neg $w))))
         )
      (Map.insert ($inputPattern $newCounts) $acc == ==)
   )
)

;; Delete a column by name from a table, matching classic C++ ITable::delete_column
;; Reference: moses/comboreduct/table/table.cc#L274-L296 (ITable::delete_column)
;;            moses/moses/moses/main/table-problems.cc#L125-L130
;;
;; Input:
;;   $colName: Column label to delete
;;   $table:   (mkITable $columns $labels) OR ($columns $labels)
;; Output:
;;   Modified table with the column and its label removed.
;;   Throws Error if column name is unknown, matching classic C++ IndexErrorException.
(= (deleteColumn $colName $table)
   (let* (
          (($columns $labels $isMkITable)
           (case $table
             (
               ((mkITable $cols $labs) ($cols $labs True))
               (($cols $labs)          ($cols $labs False))
             )))
          ($idx (List.index $labels $colName))
         )
     (if (< $idx 0)
         (Error $colName "Can't delete, unknown column name")
         (let* (
                ($newCols (List.removeAtIdx $columns $idx))
                ($newLabels (List.removeAtIdx $labels $idx))
               )
           (if $isMkITable
               (mkITable $newCols $newLabels)
               ($newCols $newLabels))))))

;; Type constructor for compressed table (cTable), matching classic C++ CTable class
;; Classic C++ Reference: moses/comboreduct/table/table.h#L549-L578
;;
;; A CTable encapsulates:
;;   1. $map: Map from unique input_pattern -> (positive_weight negative_weight)
;;   2. $labels: Column labels for features and target (weight column removed)
;;   3. $totalWeight: Total weight of all samples (matching C++ CTable::uncompressed_size)
;;
;; (: CTable (-> $a Type))
;; (: mkCTable (-> (Map Expression (Number Number)) (List Symbol) Number (CTable $a)))

;; Accessors for CTable
(= (getCTableMap (mkCTable $map $labels $totalWeight)) $map)
(= (getCTableLabels (mkCTable $map $labels $totalWeight)) $labels)
(= (getCTableTotalWeight (mkCTable $map $labels $totalWeight)) $totalWeight)

(= (getctablemap $ctable) (getCTableMap $ctable))
(= (getctablelabels $ctable) (getCTableLabels $ctable))
(= (getctabletotalweight $ctable) (getCTableTotalWeight $ctable))

;; Build compressed table (cTable) directly from the column-major ITable
; The structure of the CTable is referred from the below test file 
; Reference: https://github.com/opencog/moses/blob/master/tests/moses/precision2.ctable
;; Classic C++ Reference: moses/comboreduct/table/table.cc#L501-L554 (Table::compressed)
;;
;; Input:
;;   $columns: Column-major payload ((col0...) (col1...) ... (targetCol...))
;;   $labels: Column labels (features + target, and optional weight column)
;;   $weightCol (optional): Column label of weight feature, or ()/"" for unweighted
;; 
;; Output:
;;   (mkCTable $grouped $labels $totalWeight)
;;
;; Example:
;;    (mkCTable (cons ((False False) (2 2)) (cons ((True False) (0 3)) (cons ((False True) (3 0)) ()))) (v1 v2 target) 10)
;; (: cTable (-> (ITable $a) (CTable $a)))
;; (: cTable (-> (List (List $a)) (List Symbol) (CTable $a)))
;; (: cTable (-> (List (List $a)) (List Symbol) Symbol (CTable $a)))
(= (cTable (mkITable $columns $labels))
   (cTable $columns $labels ()))

(= (cTable $columns $labels)
   (cTable $columns $labels ()))

(= (cTable $columns $labels $weightCol)
   (let* (
          ($hasWeight (!= $weightCol ()))
          ($widx (if $hasWeight (List.index $labels $weightCol) -1))
         )
     (if (and $hasWeight (< $widx 0))
         (Error $weightCol "Unknown weight column")
         (let* (
                (($tableCols $tableLabels $weights $totalWeight)
                 (if $hasWeight
                     (let* (
                            ($extractedWeights (index-atom $columns $widx))
                            (($trimmedCols $trimmedLabels) (deleteColumn $weightCol ($columns $labels)))
                           )
                       ($trimmedCols $trimmedLabels $extractedWeights (sum $extractedWeights)))
                     ($columns $labels () (ITable.rowCount $columns))))
                ($targetIndex (- (List.length $tableLabels) 1))
                ($featIndices (genList (- $targetIndex 1)))
                ($inputCols (map-atom $featIndices $i (index-atom $tableCols $i)))
                ($targetCol (index-atom $tableCols $targetIndex))
                ($rowCount (ITable.rowCount $tableCols))
                ($rowIndices (genList (- $rowCount 1)))
                ($grouped (foldl-atom $rowIndices () $acc $rowIndex
                                    (countTable $rowIndex $inputCols $targetCol $weights $acc)))
               )
           (mkCTable $grouped $tableLabels $totalWeight)))))


;; sum_outputs = 0.5 * (pos - neg)
;;
;; Mathematical Significance:
;; - For True Positives: contributes +0.5 per instance
;; - For False Positives: contributes -0.5 per instance  
;; - Net effect: sum_outputs = 0.5 * (TP - FP)
;; (: sumOutputs (-> Number Number Number))
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
;;   Example : (cons (0.5 (1.5 3)) (cons (0.0 (0.0 4)) (cons (-0.5 (-1.5 3)) ())))
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
;;   Result: (cons (0.25 (1.0 4)) ())
;; The MultiMap automatically sorts by precision key (using > for descending order)
;; This ordering is crucial for the best possible score implementation which processes highest
;; precision patterns first.
;; (: makePrecisionRow (-> Expression Expression (Map Expression (Number Number))))
(= (makePrecisionRow $item $acc)
   (if (== $item ())
      ()
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
;; (: createPrecisionRows (-> (MultiMap (Number (Number Number))) Expression))
(= (createPrecisionRows $groupedData)
   (let* (
            ($items (Map.items $groupedData))
            ($precisionRows (foldl-atom $items () $acc $item (makePrecisionRow $item $acc)))
         )
        (MultiMap.items $precisionRows)))

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
;; (: getActivationPenalty (-> Number Number Number Number Number))
(= (getActivationPenalty $activation $minActivation $maxActivation $activationPressure)
   (if (<= $activationPressure 0)
       0.0
       (let $dst (if (< $activation $minActivation) ;; Calculate distance from acceptable range
                       (- 1.0 (/ $activation $minActivation))
                       (if (> $activation $maxActivation)
                           (/ (- $activation $maxActivation) (- 1.0 $maxActivation))
                           0.0))
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
;; (: bestPossibleBScore (-> Expression Number Number Number Number Number Number Number))
(= (bestPossibleBScore () $sao $active $totalWeight $minAct $maxAct $actPressure $bestScore)
   $bestScore)
(= (bestPossibleBScore (cons ($precKey ($sumo $total)) $rest) $sao $active $totalWeight $minAct $maxAct $actPressure $bestScore)
      (let* (
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
         ))

;; Main precision scoring orchestration function
;;
;; The function coordinates the entire precision scoring process:
;; 1. Compress raw data into CTable format (group identical input patterns)
;; 2. Calculate individual precision for each compressed pattern  
;; 3. Sort patterns by precision in descending order
;; 4. Run greedy best_possible_bscore algorithm to find optimal score
;;
;; Parameters:
;;   $columns (Expression): Column-major payload from the filtered ITable
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
(= (precisionBScore $columns $labels $activationPressure $minActivation $maxActivation $totalWeight $weightCol)
   (let* (
            ;; ($_ (println! (debug Inside Precision scoring)))
            ($groupedData (cTable $columns $labels $weightCol))
            
            ($precisionRows (createPrecisionRows (getCTableMap $groupedData)))
         )
     (bestPossibleBScore $precisionRows 0.0 0.0 $totalWeight $minActivation $maxActivation
                         $activationPressure -1.0000000000000001e308)))

;; Extract selected features plus target column from full dataset
;; Input:
;;   $featureIndices:  selected feature column indices
;;   $columns: Original column-major table data
;;   $labels: Column labels
;;   $weightCol: Optional column label of weight feature, or () for unweighted
;;
;; Output:
;;   Expression like (filtered_columns filtered_labels) containing only selected features + target (and optional weight col)
; (: extractTable (-> Expression (List (List $a)) (List Symbol) (Expression Expression)))
(= (extractTable $featureIndices $columns $labels $weightCol)
   (let* (
          ;; Target is always last column
          ($targetIndex (- (List.length $labels) 1))
          ;; Append weight column index to features if present
          ($ftsWithWeight (if (== $weightCol ())
                              $featureIndices
                              (let $widx (List.index $labels $weightCol)
                                (if (< $widx 0)
                                    $featureIndices
                                    (List.append $widx $featureIndices)))))
          ;; Combine features and weight with target index at the end
          ($exprIndices (List.append $targetIndex $ftsWithWeight))

          ;; Extract selected columns while preserving column-major layout
          ($filteredColumns (map-atom $exprIndices $i (index-atom $columns $i)))
          ;; Extract corresponding labels
          ($filteredLabels (map-atom $exprIndices $each (index-atom $labels $each))))
     ($filteredColumns $filteredLabels)
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
;;   $weightCol: Optional column name for sample weights, or () for unweighted
;;
;; Returns: (Number) Final weighted precision score for this feature set
;;
;; The returned score represents how good this feature combination is for
;; precision-based classification, accounting for both achievable precision
;; and the complexity cost of using multiple features.
;; (: preScorer (-> Expression (ITable $a) Number Number Number Bool Number Number))
(= (preScorer $featureIndices (mkITable $columns $labels) $penalty $minAct $maxAct $positive $confi $weightCol)
   (if (== $featureIndices ())
      0.0
      (let* (
               ;; Ensure activation bounds are valid
               ($clampedMinAct (clamp $minAct 0.0 1.0))
               ($clampedMaxAct (clamp $maxAct 0.0 1.0))
               
               ($hasWeight (!= $weightCol ()))
               ($widx (if $hasWeight (List.index $labels $weightCol) -1))
            )
        (if (and $hasWeight (< $widx 0))
            (Error $weightCol "Can't score, unknown weight column")
            (let* (
                   ($totalWeight (if $hasWeight
                                     (sum (index-atom $columns $widx))
                                     (ITable.rowCount $columns)))
                   (($filteredRows $filteredLabels) (extractTable $featureIndices $columns $labels $weightCol))
                   ($precision (precisionBScore $filteredRows $filteredLabels $penalty 
                                              $clampedMinAct $clampedMaxAct $totalWeight $weightCol))
                   ($confidence (calculateConfidence (size-atom $featureIndices) $totalWeight $confi))
                  )
              (* $precision $confidence))))))
