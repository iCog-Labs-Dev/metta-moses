;; This module implements an incremental feature selection algorithm that:
;; 1. Identifies relevant features based on mutual information threshold
;; 2. Removes redundant features to avoid information overlap
;; 3. Supports interaction terms (feature combinations) up to specified size
;; 4. Returns non-redundant feature indices 

;; ALGORITHM NOTES

;; This implementation follows the incremental selection strategy:
;; 1. Start with all available features
;; 2. For interaction term size k = 1, 2, ..., max:
;;    a. Generate all k-combinations from remaining features
;;    b. Test each combination's mutual information against threshold
;;    c. Mark features in relevant combinations as selected (compute mutual information (MI) between the feature(s) and the target; if MI > threshold the combination is considered relevant)
;;    d. find and remove redundant features  (redundancy is decided by the difference fullScore - bestSubsetScore being less than a numeric redundancy threshold)
;;    e. Remove all tested features from remaining set
;; 3. Return union of all selected features across all term sizes

;; Purpose: Calculate mutual information for feature indices
;; Parameters:
;;   $itable (ITable) → Input table
;;   $featureIndices (OS Number) → OrderedSet of feature indices
;; Returns: (Number) → Mutual information score
;; Example: (calculateMutualInformation xorTable (cons 0 (cons 1 ()))) → 1.0

; (: calculateMutualInformation (-> (ITable $a) Expression Number))
;** Implement caching for the mutual Information
;; Purpose: Filter relevant combinations based on MI threshold
;; Parameters:
;;   $itable (ITable) → Input table
;;   $combinations (OS Expression) → OrderedSet of combinations to test
;;   $threshold (Number) → MI threshold
;;   $resultSet (OS Number) → Accumulator for relevant indices
;; Returns: (OS Number) → OrderedSet of relevant feature indices
; (: filterRelevantCombinations (-> (ITable $a) (OS Expression) Number (OS Number) (OS Number)))
(= (filterRelevantCombinations $itable () $threshold $resultSet)
   $resultSet)
(= (filterRelevantCombinations $itable (cons $combo $rest) $threshold $resultSet)
   (chain (cachedMutualInformation $itable $combo) $mutualInfo
     ;; Convert the simple list to OrderedSet for union
     (chain (expressionToOS $combo ()) $comboOS
       (if (> $mutualInfo $threshold)
           (chain (OS.union $resultSet $comboOS) $newResultSet
             (filterRelevantCombinations $itable $rest $threshold $newResultSet))
           (filterRelevantCombinations $itable $rest $threshold $resultSet)
       )
     )
   )
)
    ; (let*
    ;     (
    ;         ($comboOs (expressionToOS $combo ()))
    ;         (() (println! (Combo $comboOs)))
    ;         ($mutualInfo (cachedMutualInformation $itable $comboOs))
    ;         (() (println! (MutualInfo $mutualInfo)))
    ;         ($newResultSet (if (> $mutualInfo $threshold) (let $oldResultSet (OS.union $resultSet $comboOs) 
    ;                                                             (filterRelevantCombinations $itable $rest $threshold $oldResultSet)) 
    ;                                                         (filterRelevantCombinations $itable $rest $threshold $resultSet)))
    ;         (() (println! (Final result: $newResultSet)))
    ;     )
    ;     $newResultSet
    ; )
 
;; Purpose: Find best subset with highest MI score
;; Parameters:
;;   $itable (ITable) → Input table
;;   $subsetCombinations (OS Expression) → OrderedSet of subset combinations
;;   $currentBest (Expression) → Current best subset
;;   $currentScore (Number) → Current best score
;; Returns: (List Expression) → (best-subset best-score)
;(: findBestSubset (-> (ITable $a) (OS Expression) Expression Number (List Expression)))
(= (findBestSubset $itable () $currentBest $currentScore)
   (cons $currentBest (cons $currentScore ())))
(= (findBestSubset $itable (cons $subset $rest) $currentBest $currentScore)
     (chain (cachedMutualInformation $itable $subset) $score  
       (if (> $score $currentScore)
           (findBestSubset $itable $rest $subset $score)
           (findBestSubset $itable $rest $currentBest $currentScore)
       )
     )
)
;; Purpose: Find redundant features using subset search
;; Parameters:
;;   $itable (ITable) → Input table
;;   $indices (OS Number) → Feature indices to analyze
;;   $threshold (Number) → Redundancy threshold
;;   $subsetSize (Number) → Current subset size being tested
;; Returns: (OS Number) → OrderedSet of redundant indices
;(: findRedundantSubsets (-> (ITable $a) (OS Number) Number Number (OS Number)))
(= (findRedundantSubsets $itable $indices $threshold $subsetSize)
    (if (<= (OS.length $indices) 1)
        ()
        (if (>= $subsetSize (OS.length $indices))
            ()
            (chain (osToExpression $indices ()) $indicesExpr
                (chain (powerSet $indicesExpr $subsetSize True) $combinations
                    (chain (expressionToOS $combinations ()) $subsetCombinations
                            (if (== (OS.length $subsetCombinations) 0)
                                (findRedundantSubsets $itable $indices $threshold (+ $subsetSize 1))
                                (chain (findBestSubset $itable $subsetCombinations () -1) $bestResult
                                    (chain (List.getByIdx $bestResult 0) $bestSubsetExpr
                                        (chain (List.getByIdx $bestResult 1) $bestScore
                                            (chain (cachedMutualInformation $itable $indicesExpr) $fullScore
                                                (if (< (- $fullScore $bestScore) $threshold)
                                                    (chain (expressionToOS $bestSubsetExpr ()) $bestSubset
                                                        (chain (OS.difference $indices $bestSubset ()) $redundant
                                                            $redundant
                                                        )
                                                    )
                                                    (findRedundantSubsets $itable $indices $threshold (+ $subsetSize 1))
                                                )
                                            )
                                        )
                                    )
                                )
                            )
                    )
                )
            )
        )
    )
)

;; Purpose: Core incremental iterator
;; Parameters:
;;   $itable (ITable) → Input table
;;   $remainingIndices (OS Number) → Remaining feature indices
;;   $threshold (Number) → Relevance threshold
;;   $maxTerms (Number) → Maximum interaction terms
;;   $redundancyThreshold (Number) → Redundancy threshold
;;   $currentTermSize (Number) → Current term size
;;   $selectedIndices (OS Number) → Previously selected indices
;; Returns: (OS Number) → Final selected indices
;(: incrementalIterator (-> (ITable $a) (OS Number) Number Number Number Number (OS Number) (OS Number)))
( = (incrementalIterator $itable $remainingIndices $threshold $maxTerms $redundancyThreshold $currentTermSize $selectedIndices)
        (if (or (> $currentTermSize $maxTerms) (== (OS.length $remainingIndices) 0))
            $selectedIndices
            (chain (osToExpression $remainingIndices ()) $remainingExpr
                (chain (powerSet $remainingExpr $currentTermSize True) $generatedCombo
                    (chain (expressionToOS $generatedCombo ()) $combinations
                        (chain (filterRelevantCombinations $itable $combinations $threshold ()) $relevantIndices
                            (chain (if (> $redundancyThreshold 0)
                                (findRedundantSubsets $itable $relevantIndices (* $redundancyThreshold $threshold) 1)
                                ()) $redundantIndices 
                                (chain (OS.difference $relevantIndices $redundantIndices ()) $nonRedundantIndices
                                    (chain (OS.union $selectedIndices $nonRedundantIndices) $newSelectedIndices
                                        (chain (OS.difference $remainingIndices $relevantIndices ()) $updatedRemainingIndices
                                            ;; recurse to the next term size
                                            (incrementalIterator $itable $updatedRemainingIndices $threshold $maxTerms $redundancyThreshold (+ $currentTermSize 1) $newSelectedIndices)
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )
)
;; Purpose: Adaptive selection using binary search
;; Parameters:
;;   (mkITable $rows $labels) → Input table
;;   $targetSize (Number) → Target number of features
;;   $maxTerms (Number) → Maximum interaction terms
;;   $redundancyThreshold (Number) → Redundancy threshold
;;   $minThreshold (Number) → Lower threshold bound
;;   $maxThreshold (Number) → Upper threshold bound
;;   $epsilon (Number) → Convergence tolerance
;; Returns: (OS Number) → OrderedSet of selected indices
;(: adaptiveSelection (-> (ITable $a) Number Number Number Number Number Number (OS Number)))
(= (adaptiveSelection (mkITable $rows $labels) $targetSize $maxTerms $redundancyThreshold $minThreshold $maxThreshold $epsilon)
    (if (<= $targetSize 0)
        ()
        (chain (/ (+ $minThreshold $maxThreshold) 2) $meanThreshold
            (chain (- (List.length $labels) 1) $numFeatures
                (chain (OS.range 0 $numFeatures ()) $allIndices
                    (chain (incrementalIterator (mkITable $rows $labels) $allIndices $meanThreshold $maxTerms $redundancyThreshold 1 ()) $resultIndices
                        (chain (OS.length $resultIndices) $resultSize
                            (if (or (isWithin $minThreshold $maxThreshold $epsilon) (== $resultSize $targetSize))
                                $resultIndices
                                (if (< $resultSize $targetSize)
                                    ;; need more features lower the threshold
                                    (adaptiveSelection (mkITable $rows $labels) $targetSize $maxTerms $redundancyThreshold $minThreshold $meanThreshold $epsilon)
                                    ;; too many features raise the threshold
                                    (adaptiveSelection (mkITable $rows $labels) $targetSize $maxTerms $redundancyThreshold $meanThreshold $maxThreshold $epsilon)
                                )
                            )
                        )
                    )
                )
            )
        )
    )
)
;; Purpose: Main incremental feature selection interface
;; Parameters:
;;   (mkITable $rows $labels) → Input table
;;   $threshold (Number) → MI threshold (use 0 for adaptive)
;;   $targetSize (Number) → Target number of features (use 0 for threshold-based)
;;   $maxInteractionTerms (Number) → Maximum interaction term size
;;   $redundancyThreshold (Number) → Redundancy removal intensity
;; Returns: (Expression) → (score selected-indices-expression)
;(: incrementalSelection (-> (ITable $a) Number Number Number Number Expression))
(= (incrementalSelection (mkITable $rows $labels) $threshold $targetSize $maxInteractionTerms $redundancyThreshold)
    (if (and (<= $threshold 0) (<= $targetSize 0))
        ;; return all the features with their score
        (let*
          (
           ($numFeatures (- (List.length $labels) 1))
           ($allIndices (range 0 1 $numFeatures))
           ($score (cachedMutualInformation (mkITable $rows $labels) $allIndices))
           ($_ (println! (Score: $score)))
          )
          (($score $allIndices))
       )
        ;; do incremental feature selection 
        (chain (if (> $targetSize 0)
                ; do binary search 
                (adaptiveSelection (mkITable $rows $labels) $targetSize $maxInteractionTerms $redundancyThreshold 0.0 1.0 0.01)
                ; just do incrementalInteration
                (chain (- (List.length $labels) 1) $numFeatures
                    (chain (OS.range 0 $numFeatures ()) $allIndices
                        (incrementalIterator (mkITable $rows $labels) $allIndices $threshold $maxInteractionTerms $redundancyThreshold 1 ())
                    )
                )
                ) $selectedIndices
            (chain (osToExpression $selectedIndices ()) $indicesExpr
                (chain (if (== (OS.length $selectedIndices) 0)
                        0
                        (cachedMutualInformation (mkITable $rows $labels) $indicesExpr)
                    ) $finalScore
                    (($finalScore $indicesExpr))
                )
            )
        )
    )
)
