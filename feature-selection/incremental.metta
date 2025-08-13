
;; This module implements an incremental feature selection algorithm that:
;; 1. Identifies relevant features based on mutual information threshold
;; 2. Removes redundant features to avoid information overlap
;; 3. Supports interaction terms (feature combinations) up to specified size
;; 4. Returns feature indices 
;;
;; ALGORITHM NOTES
;;
;; This implementation follows the incremental selection strategy:
;; 1. Start with all available features
;; 2. For interaction term size k = 1, 2, ..., max:
;;    a. Generate all k-combinations from remaining features
;;    b. Test each combination's mutual information against threshold
;;    c. Mark features in relevant combinations as selected (compute mutual information (MI) between the feature(s) and the target; if MI > threshold the combination is considered relevant)
;;    d. find and remove redundant features  (redundancy is decided by the difference fullScore - bestSubsetScore being less than a numeric redundancy threshold)
;;    e. Remove all tested features from remaining set
;; 3. Return union of all selected features across all term sizes
; todo add a caching used by calculateMutualInformation. This speeds both relevance and redundancy phases and makes adaptive binary search feasible.

;; Calculate mutual information between features and target variable
;; Supports both single features and feature combinations (interaction terms)
;; MI measures how much knowing the feature values reduces uncertainty about the target
;;
;; Parameters:
;;   $itable - ITable containing features and target
;;   $featureIndices - List of feature indices (single element for individual features)
;; Returns:
;;   Mutual information score (higher = more informative)
(= (calculateMutualInformation $itable $featureIndices)
   (let (mkITable $rows $labels) $itable
       (let $targetIndex (- (List.length $labels) 1)
           (chain (extractColumnByIndex $rows $targetIndex) $targetColumn
               (if (== (List.length $featureIndices) 1)
                   ;; Single feature MI calculation
                   (chain (extractColumnByIndex $rows (List.getByIdx $featureIndices 0)) $featureColumn
                            (mutualInformation $featureColumn $targetColumn)
                       )
                   ;; Joint feature MI calculation for interaction terms
                   (chain (combineFeatureColumns $itable $featureIndices) $jointColumn
                       (mutualInformation $jointColumn $targetColumn)))))))

;; Filter feature combinations that meet the mutual information threshold
;; This identifies which feature combinations provide sufficient information
;;
;; Parameters:
;;   $itable - ITable for MI calculation
;;   $indexCombinations - List of feature index combinations to test
;;   $threshold - Minimum MI threshold for relevance
;; Returns:
;;   List of individual feature indices from combinations exceeding threshold
(= (filterRelevantCombinations $itable $indexCombinations $threshold)
   (unify $indexCombinations Nil Nil
       (unify $indexCombinations (Cons $combo $rest)
           (chain (calculateMutualInformation $itable $combo) $mutualInfo
        ;    (chain  (() (println! (calculated MI  $mutualInfo $threshold  $combo))) $debug1
             (chain (filterRelevantCombinations $itable $rest $threshold) $restFiltered
                (if (> $mutualInfo $threshold)
                    (List.union $combo $restFiltered)
                    $restFiltered
                )
                )
            ; )
            ))))

;; Search for redundant subsets by testing subsets of increasing size
;; Finds the smallest subset that maintains most of the information
;;
;; Parameters:
;;   $itable - ITable for MI calculation
;;   $indices - Feature indices to analyze
;;   $threshold - Redundancy detection threshold
;;   $subsetSize - Current subset size being tested
;; Returns:
;;   List of redundant indices or Nil if none found
(= (findRedundantSubsets $itable $indices $threshold $subsetSize)
   (if (>= $subsetSize (List.length $indices))
       Nil  ;; No subset smaller than full set
       (chain (exprToList (generateCombinations (List.listToExpr $indices) $subsetSize)) $subsets
           (if (== $subsets Nil)
               ;; No subsets of this size, try larger
               (findRedundantSubsets $itable $indices $threshold (+ $subsetSize 1))
               ;; Test subsets for redundancy
               (chain (findBestSubset $itable $subsets) $bestResult
               (chain (List.getByIdx $bestResult 0) $bestSubset
               (chain (List.getByIdx $bestResult 1) $bestScore
               (chain (calculateMutualInformation $itable $indices) $fullScore
                   (if (< (- $fullScore $bestScore) $threshold)
                       ;; Best subset is almost as good as full set - others are redundant
                       (List.difference $indices $bestSubset)
                       ;; Try larger subsets
                       (findRedundantSubsets $itable $indices $threshold (+ $subsetSize 1)))))))))))


;; Find the best subset (highest MI) from a list of subsets
;; Used in redundancy detection to identify the most informative subset
;;
;; Parameters:
;;   $itable - ITable for MI calculation
;;   $subsets - List of feature index subsets to evaluate
;; Returns:
;;   List containing (best-subset best-MI-score)
(= (findBestSubset $itable $subsets)
   (findBestSubsetHelper $itable $subsets Nil -1))
;; Helper function for finding best subset recursively
(= (findBestSubsetHelper $itable $subsets $currentBest $currentScore)
   (unify $subsets Nil (Cons $currentBest (Cons $currentScore Nil))
       (unify $subsets (Cons $subset $rest)
           (chain (calculateMutualInformation $itable $subset) $score
               (if (> $score $currentScore)
                   (findBestSubsetHelper $itable $rest $subset $score)
                   (findBestSubsetHelper $itable $rest $currentBest $currentScore))))))

;; Find feature indices to remove as redundant using subset analysis
;; Redundant features are those whose removal doesn't significantly reduce information
;; Uses the subset search approach from the original algorithm
;;
;; Parameters:
;;   $itable - ITable for analysis
;;   $indices - List of feature indices to analyze
;;   $redundancyThreshold - Threshold for redundancy detection
;; Returns:
;;   List of indices that can be removed as redundant
(= (findRedundantFeatures $itable $indices $redundancyThreshold)
   (if (<= (List.length $indices) 1)
       Nil  ;; Can't have redundancy with 1 or fewer features
       (findRedundantSubsets $itable $indices $redundancyThreshold 1)))




;; Process interaction terms of each size iteratively
;; This is the core loop that implements the incremental selection strategy
;;
;; Parameters:
;;   $itable - ITable for analysis
;;   $remainingIndices - Feature indices not yet processed
;;   $threshold - Relevance threshold
;;   $maxTerms - Maximum interaction term size
;;   $redundancyThreshold - Redundancy detection threshold
;;   $currentTermSize - Current term size being processed (1, 2, 3, ...)
;;   $selectedIndices - Indices selected in previous iterations
;; Returns:
;;   Final list of selected feature indices
(= (incrementalIterator $itable $remainingIndices $threshold $maxTerms $redundancyThreshold $currentTermSize $selectedIndices)
   (if (or (> $currentTermSize $maxTerms) (== (List.length $remainingIndices) 0))
       $selectedIndices  ;; Termination condition
       ;; Process current term size
       (chain (generateCombinations (List.listToExpr $remainingIndices) $currentTermSize) $combinations
       (chain (exprToList $combinations) $combinationList
       (chain (filterRelevantCombinations $itable $combinationList $threshold) $relevantIndices
        (chain (if (> $redundancyThreshold 0)
                  (findRedundantFeatures $itable $relevantIndices (* $redundancyThreshold $threshold))
                  Nil) $redundantIndices
    ;   (chain  (() (println! (releavent redundant  $relevantIndices $redundantIndices ))) $debug1
         (chain (List.difference $relevantIndices $redundantIndices) $nonRedundantIndices
       (chain (List.union $selectedIndices $nonRedundantIndices) $newSelectedIndices
       (chain (List.difference $remainingIndices $relevantIndices) $updatedRemainingIndices
           ;; Recurse to next term size
           (incrementalIterator $itable $updatedRemainingIndices $threshold $maxTerms 
                                  $redundancyThreshold (+ $currentTermSize 1) $newSelectedIndices))))
    ; )
            )
                                  
          )
        )
                                  )))

;; Main incremental feature selection algorithm
;; Iteratively processes interaction terms of increasing size (1-way, 2-way, 3-way, etc.)
;; For each term size: find relevant features, remove redundant ones, continue with remainder
;;
;; Parameters:
;;   $itable - ITable containing features and target variable
;;   $threshold - MI threshold for feature relevance (0.0 to 1.0)
;;   $maxInteractionTerms - Maximum size of feature combinations to consider
;;   $redundancyThreshold - Multiplier for redundancy detection (0 = no redundancy removal)
;; Returns:
;;   List of selected feature indices
(= (incrementalFeatureSelection $itable $threshold $maxInteractionTerms $redundancyThreshold)
   (let (mkITable $rows $labels) $itable
       (let $allFeatureIndices (List.range 0 (- (List.length $labels) 1))
           (incrementalIterator $itable $allFeatureIndices $threshold 
                                  (if (<= $maxInteractionTerms 0) 1 $maxInteractionTerms) 
                                  $redundancyThreshold 1 Nil))))

;; ADAPTIVE INCREMENTAL SELECTION LIKE BINARY SEARCH
;; Adaptive feature selection that finds threshold to achieve target number of features
;; Uses binary search to efficiently find the right threshold value
;;
;; Parameters:
;;   $itable - ITable for analysis
;;   $targetSize - Desired number of features to select
;;   $maxTerms - Maximum interaction term size
;;   $redundancyThreshold - Redundancy detection threshold
;;   $minThreshold - Lower bound for threshold search
;;   $maxThreshold - Upper bound for threshold search
;;   $epsilon - Convergence tolerance for binary search
;; Returns:
;;   List of feature indices with length close to target size
(= (adaptiveThresholdSearch $itable $targetSize $maxTerms $redundancyThreshold $minThreshold $maxThreshold $epsilon)
   (chain (/ (+ $minThreshold $maxThreshold) 2) $meanThreshold
   (chain (incrementalFeatureSelection $itable $meanThreshold $maxTerms $redundancyThreshold) $resultIndices
   (chain (List.length $resultIndices) $resultSize
       (if (or (isWithin $minThreshold $maxThreshold $epsilon) (== $resultSize $targetSize))
           $resultIndices  ;; Found solution or converged
           (if (< $resultSize $targetSize)
               ;; Need more features - lower threshold
               (adaptiveThresholdSearch $itable $targetSize $maxTerms $redundancyThreshold 
                                      $minThreshold $meanThreshold $epsilon)
               ;; Too many features - raise threshold  
               (adaptiveThresholdSearch $itable $targetSize $maxTerms $redundancyThreshold 
                                      $meanThreshold $maxThreshold $epsilon)))))))
;; Main entry point for adaptive selection
(= (adaptiveFeatureSelection $itable $targetSize $maxTerms $redundancyThreshold)
   (if (<= $targetSize 0)
       Nil
       (adaptiveThresholdSearch $itable $targetSize $maxTerms $redundancyThreshold 0.0 1.0 0.01)))

;; Primary interface for incremental feature selection
;; Returns both the mutual information score and selected feature indices
;; Supports both threshold-based and target-size-based selection
;;
;; Parameters:
;;   $itable - ITable containing features (columns) and target (last column)
;;   $threshold - MI threshold for relevance (use 0 for target-size-based selection)
;;   $targetSize - Target number of features (use 0 for threshold-based selection)
;;   $maxInteractionTerms - Maximum size of feature combinations (1=individual, 2=pairs, etc.)
;;   $redundancyThreshold - Intensity of redundancy removal (0=none, 0.5=moderate, 1=aggressive)
;;
;; Returns:
;;   Tuple: (mutual-information-score (selected-feature-indices))
;;   Example: (0.85 (0 2 4)) means features at indices 0, 2, 4 with MI score 0.85
;;
;; Usage Examples:
;;   !(incrementalFeatureSelection tableXor 0.1 0 2 0.5)    # Threshold-based selection
;;   !(incrementalFeatureSelection table1 0 5 3 0.4)        # Select exactly 5 features
(= (incrementalFeatureSelection $itable $threshold $targetSize $maxInteractionTerms $redundancyThreshold)
   (if (and (<= $threshold 0) (<= $targetSize 0))
       ;; Default behavior: return all features with their combined MI score
       (let (mkITable $rows $labels) $itable
           (let $allIndices (List.range 0 (- (List.length $labels) 1))
               (chain (calculateMutualInformation $itable $allIndices) $score
                   ($score (List.listToExpr $allIndices)))))
       ;; Perform feature selection
       (chain (if (> $targetSize 0)
                  (adaptiveFeatureSelection $itable $targetSize $maxInteractionTerms $redundancyThreshold)
                  (incrementalFeatureSelection $itable $threshold $maxInteractionTerms $redundancyThreshold)) $selectedIndices
           (chain (if (== (List.length $selectedIndices) 0)
                      0
                      (calculateMutualInformation $itable $selectedIndices)) $finalScore
               ($finalScore (List.listToExpr $selectedIndices))))))


