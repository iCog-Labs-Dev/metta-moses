;; ================================================================================
;; BDe Scoring System for Bayesian Optimization
;; ================================================================================
;;
;; This file implements the Bayesian-Derivative (BDe) scoring system for
;; multivariate optimization in the EDA framework.
;;
;; Key Components:
;; - BDe score types and constructors
;; - Binary-Binary scoring
;; - Discrete-Discrete scoring (2-way and n-way)
;; - Continuous-Discrete scoring
;; - Continuous-Continuous scoring
;; - Helper functions for logarithmic computations
;;
;; Based on the C++ Moses implementation's BDe scoring system.

;; ================================================================================
;; Type Definitions
;; ================================================================================

;; BDe Score type - represents a Bayesian-Derivative score
(: BDeScore Type)
(: mkBDeScore (-> Number BDeScore))

;; Split Type - represents different types of splits in decision trees
(: SplitType Type)
(: mkBinarySplit (-> Bool SplitType))
(: mkDiscreteSplit (-> (List Bool) SplitType))
(: mkContinuousSplit (-> Number SplitType))

!(bind! minusInf -999999)

;; ================================================================================
;; Core BDe Scoring Functions
;; ================================================================================

;; Binary-Binary scoring
;; Computes BDe score for binary variable splits
(: binaryBinaryScore (-> (List Bool) (List Bool) BDeScore))
(= (binaryBinaryScore $parentValues $childValues)
   (let* (
     ;; Count occurrences
     ($parentTrue (countTrue $parentValues))
     ($parentFalse (countFalse $parentValues))
     ($childTrue (countTrue $childValues))
     ($childFalse (countFalse $childValues))
     
     ;; Count joint occurrences
     ($bothTrue (countBothTrue $parentValues $childValues))
     ($parentTrueChildFalse (countParentTrueChildFalse $parentValues $childValues))
     ($parentFalseChildTrue (countParentFalseChildTrue $parentValues $childValues))
     ($bothFalse (countBothFalse $parentValues $childValues))
     ;; Compute BDe score using logarithmic computations
     ($score (computeBinaryBinaryBDeScore $parentTrue $parentFalse $childTrue $childFalse 
                                         $bothTrue $parentTrueChildFalse $parentFalseChildTrue $bothFalse))
   )
     (mkBDeScore $score)))

;; Discrete-Discrete scoring (2-way split)
;; Computes BDe score for discrete variable with 2-way split
(: discreteDiscrete2WayScore (-> (List Number) (List Number) Number Number BDeScore))
(= (discreteDiscrete2WayScore $parentValues $childValues $parentCardinality $childCardinality)
   (let* (
     ;; Count occurrences for each parent value
     ($parentCounts (countDiscreteValues $parentValues $parentCardinality))
     ($childCounts (countDiscreteValues $childValues $childCardinality))
     
     ;; Count joint occurrences
     ($jointCounts (countJointDiscreteValues $parentValues $childValues $parentCardinality $childCardinality))
     
     ;; Compute BDe score
     ($score (computeDiscreteDiscreteBDeScore $parentCounts $childCounts $jointCounts $parentCardinality $childCardinality))
   )
     (mkBDeScore $score)))

;; Discrete-Discrete scoring (n-way split)
;; Computes BDe score for discrete variable with n-way split
(: discreteDiscreteNWayScore (-> (List Number) (List Number) Number Number BDeScore))
(= (discreteDiscreteNWayScore $parentValues $childValues $parentCardinality $childCardinality)
   (let* (
     ;; Use the same computation as 2-way but with different cardinalities
     ($score (discreteDiscrete2WayScore $parentValues $childValues $parentCardinality $childCardinality))
   )
     $score))

;; Continuous-Discrete scoring (2-way split)
;; Computes BDe score for continuous parent and discrete child
(: continuousDiscrete2WayScore (-> (List Number) (List Number) Number BDeScore))
(= (continuousDiscrete2WayScore $parentValues $childValues $childCardinality)
   (let* (
     ;; Find optimal split point
     ($splitPoint (findOptimalContinuousSplit $parentValues $childValues))
     ;; Split parent values based on split point
     ($leftParentValues (filterLessThan $parentValues $splitPoint))
     ($rightParentValues (filterGreaterEqual $parentValues $splitPoint))
     ($leftChildValues (getCorrespondingChildValues $parentValues $childValues $splitPoint True))
     ($rightChildValues (getCorrespondingChildValues $parentValues $childValues $splitPoint False))
     ;; Count occurrences
     ($leftChildCounts (countDiscreteValues $leftChildValues $childCardinality))
     ($rightChildCounts (countDiscreteValues $rightChildValues $childCardinality))
     
     ;; Compute BDe score
     ($score (computeContinuousDiscreteBDeScore $leftChildCounts $rightChildCounts $childCardinality))
   )
     (mkBDeScore $score)))

;; Continuous-Discrete scoring (n-way split)
;; Computes BDe score for continuous parent and discrete child with n-way split
(: continuousDiscreteNWayScore (-> (List Number) (List Number) Number BDeScore))
(= (continuousDiscreteNWayScore $parentValues $childValues $childCardinality)
   (let* (
     ;; Use 2-way scoring as base
     ($baseScore (continuousDiscrete2WayScore $parentValues $childValues $childCardinality))
     
     ;; Apply n-way penalty
     ($penalty (computeNWayPenalty $childCardinality))
     ($adjustedScore (- (getBDeScoreValue $baseScore) $penalty))
   )
     (mkBDeScore $adjustedScore)))

;; Continuous-Continuous scoring (2-way split)
;; Computes BDe score for continuous parent and continuous child
;; Returns both score and optimal split point
(: continuousContinuous2WayScore (-> (List Number) (List Number) (Pair BDeScore Number)))
(= (continuousContinuous2WayScore $parentValues $childValues)
   (let* (
     ;; Find optimal split point
     ($splitPoint (findOptimalContinuousContinuousSplit $parentValues $childValues))
     
     ;; Split values based on split point
     ($leftParentValues (filterLessThan $parentValues $splitPoint))
     ($rightParentValues (filterGreaterEqual $parentValues $splitPoint))
     ($leftChildValues (getCorrespondingChildValues $parentValues $childValues $splitPoint True))
     ($rightChildValues (getCorrespondingChildValues $parentValues $childValues $splitPoint False))
     
     ;; Compute statistics for each side
     ($leftStats (computeContinuousStats $leftChildValues))
     ($rightStats (computeContinuousStats $rightChildValues))
     
     ;; Compute BDe score
     ($score (computeContinuousContinuousBDeScore $leftStats $rightStats))
   )
     (mkPair (mkBDeScore $score) $splitPoint)))

;; ================================================================================
;; Helper Functions for Logarithmic Computations
;; ================================================================================

;; Logarithmic sum for numerical stability
(: log2Sum (-> Number Number Number))
(= (log2Sum $x $y)
   (let* (
     ($max (max $x $y))
     ($min (min $x $y))
     ($diff (- $min $max))
   )
     (if (> $diff -50)  ; Avoid underflow
         (+ $max (logMath 2 (+ 1.0 (exp2 $diff))))
         $max)))

;; Compute log2 sum of multiple values
(: computeLog2Sum (-> (List Number) Number))
(= (computeLog2Sum $values)
   (let* (
     ($sortedValues (sortDescending $values))
     ($result (foldLog2Sum $sortedValues))
   )
     $result))

;; Fold operation for logarithmic sum
(: foldLog2Sum (-> (List Number) Number))
(= (foldLog2Sum Nil) minusInf)
(= (foldLog2Sum (Cons $x Nil)) $x)
(= (foldLog2Sum (Cons $x (Cons $y $rest)))
   (foldLog2Sum (Cons (log2Sum $x $y) $rest)))

;; ================================================================================
;; Gain Calculation Utilities
;; ================================================================================

;; Compute gain between parent and child scores
(: computeGain (-> Number Number Number Number BDeScore))
(= (computeGain $parentScore $childScore $parentCount $childCount)
   (let* (
     ($gain (- $childScore $parentScore))
     ($penalty (computeComplexityPenalty $parentCount $childCount))
     ($adjustedGain (- $gain $penalty))
   )
     (mkBDeScore $adjustedGain)))

;; Evaluate transfer between variables
(: evaluateTransfer (-> (List Number) (List Number) Number Number BDeScore))
(= (evaluateTransfer $parentValues $childValues $parentCardinality $childCardinality)
   (let* (
     ;; Compute base scores
     ($parentScore (computeUnivariateScore $parentValues $parentCardinality))
     ($childScore (computeUnivariateScore $childValues $childCardinality))
     
     ;; Compute joint score
     ($jointScore (discreteDiscrete2WayScore $parentValues $childValues $parentCardinality $childCardinality))
     
     ;; Compute gain
     ($gain (computeGain $parentScore $childScore (len $parentValues) (len $childValues)))
   )
     $gain))

;; ================================================================================
;; Accessor Functions
;; ================================================================================

;; Get the numeric value from a BDeScore
(: getBDeScoreValue (-> BDeScore Number))
(= (getBDeScoreValue (mkBDeScore $value)) $value)

;; Check split constructor via non-overlapping heads (no car-atom)
(: isBinarySplit (-> SplitType Bool))
(= (isBinarySplit (mkBinarySplit $v)) True)
(= (isBinarySplit (mkDiscreteSplit $vs)) False)
(= (isBinarySplit (mkContinuousSplit $x)) False)

(: isDiscreteSplit (-> SplitType Bool))
(= (isDiscreteSplit (mkDiscreteSplit $vs)) True)
(= (isDiscreteSplit (mkBinarySplit $v)) False)
(= (isDiscreteSplit (mkContinuousSplit $x)) False)

(: isContinuousSplit (-> SplitType Bool))
(= (isContinuousSplit (mkContinuousSplit $x)) True)
(= (isContinuousSplit (mkBinarySplit $v)) False)
(= (isContinuousSplit (mkDiscreteSplit $vs)) False)

;; ================================================================================
;; Helper Functions Implementation
;; ================================================================================

;; Count true values in a boolean list (pattern matching, deterministic)
(: countTrue (-> (List Bool) Number))
(= (countTrue Nil) 0)
(= (countTrue (Cons True $rest)) (+ 1 (countTrue $rest)))
(= (countTrue (Cons False $rest)) (countTrue $rest))

;; Count false values in a boolean list (pattern matching, deterministic)
(: countFalse (-> (List Bool) Number))
(= (countFalse Nil) 0)
(= (countFalse (Cons False $rest)) (+ 1 (countFalse $rest)))
(= (countFalse (Cons True $rest)) (countFalse $rest))

;; Count cases where both parent and child are true
(: countBothTrue (-> (List Bool) (List Bool) Number))
(= (countBothTrue Nil Nil) 0)
(= (countBothTrue (Cons $pH $pT) (Cons $cH $cT))
     (let $bool (if (and (== $pH True) (== $cH True)) 1 0) (+ $bool (countBothTrue $pT $cT))))

;; Count cases where parent is true and child is false
(: countParentTrueChildFalse (-> (List Bool) (List Bool) Number))
(= (countParentTrueChildFalse Nil Nil) 0)
(= (countParentTrueChildFalse (Cons $pH $pT) (Cons $cH $cT))
   (+ (if (and (== $pH True) (== $cH False)) 1 0)
      (countParentTrueChildFalse $pT $cT)))

;; Count cases where parent is false and child is true
(: countParentFalseChildTrue (-> (List Bool) (List Bool) Number))
(= (countParentFalseChildTrue Nil Nil) 0)
(= (countParentFalseChildTrue (Cons $pH $pT) (Cons $cH $cT))
   (+ (if (and (== $pH False) (== $cH True)) 1 0)
      (countParentFalseChildTrue $pT $cT)))

;; Count cases where both parent and child are false
(: countBothFalse (-> (List Bool) (List Bool) Number))
(= (countBothFalse Nil Nil) 0)
(= (countBothFalse (Cons $pH $pT) (Cons $cH $cT))
   (+ (if (and (== $pH False) (== $cH False)) 1 0)
      (countBothFalse $pT $cT)))

;; Compute BDe score for binary-binary case
(: computeBinaryBinaryBDeScore (-> Number Number Number Number Number Number Number Number Number))
(= (computeBinaryBinaryBDeScore $pt $pf $ct $cf $bt $ptcf $pftc $bf)
   (let* (
     ;; Prior parameters (pseudo-counts)
     ($alpha 1.0)
     ($beta 1.0)
     
     ;; Compute log-gamma terms for numerical stability
     ($logGammaAlpha (logGamma $alpha))
     ($logGammaBeta (logGamma $beta))
     ($logGammaAlphaPlusBeta (logGamma (+ $alpha $beta)))
     
     ;; Parent terms
     ($logGammaAlphaPlusPT (logGamma (+ $alpha $pt)))

     ($logGammaBetaPlusPF (logGamma (+ $beta $pf)))

     ($logGammaAlphaPlusBetaPlusPTPlusPF (logGamma (+ $alpha (+ $beta (+ $pt $pf)))))
     
     ;; Child terms
     ($logGammaAlphaPlusCT (logGamma (+ $alpha $ct)))
     ($logGammaBetaPlusCF (logGamma (+ $beta $cf)))
     ($logGammaAlphaPlusBetaPlusCTPlusCF (logGamma (+ $alpha (+ $beta (+ $ct $cf)))))
     
     ;; Joint terms
     ($logGammaAlphaPlusBT (logGamma (+ $alpha $bt)))
     ($logGammaBetaPlusPTCF (logGamma (+ $beta $ptcf)))
     ($logGammaAlphaPlusPFTC (logGamma (+ $alpha $pftc)))
     ($logGammaBetaPlusBF (logGamma (+ $beta $bf)))
     ;; Compute BDe score
     ($score
      (+ 
        (+ 
          (+ 
            (+ (- $logGammaAlphaPlusBetaPlusPTPlusPF $logGammaAlphaPlusBeta)
               (- $logGammaAlphaPlusPT $logGammaAlpha))
            (+ (- $logGammaBetaPlusPF $logGammaBeta)
               (- $logGammaAlphaPlusBetaPlusCTPlusCF $logGammaAlphaPlusBeta))
          )
          (+ 
            (+ (- $logGammaAlphaPlusCT $logGammaAlpha)
               (- $logGammaBetaPlusCF $logGammaBeta))
            (+ (- $logGammaAlphaPlusBT $logGammaAlpha)
               (- $logGammaBetaPlusPTCF $logGammaBeta))
          )
        )
        (+ (- $logGammaAlphaPlusPFTC $logGammaAlpha)
           (- $logGammaBetaPlusBF $logGammaBeta))
      )
    )
    
   )
     $score))

;; Count discrete values up to cardinality
(: countDiscreteValues (-> (List Number) Number (List Number)))
(= (countDiscreteValues $values $cardinality)
   (let* (
     ($counts (createCountList $cardinality))
     ($result (countDiscreteValuesStrict $values $counts $cardinality))
   )
     $result))

(: countDiscreteValuesStrict (-> (List Number) (List Number) Number (List Number)))
(= (countDiscreteValuesStrict Nil $counts $card) $counts)
(= (countDiscreteValuesStrict (Cons $val $rest) $counts $card)
   (let* (
     ($i (round $val 0))
   )
     (if (or (< $i 0) (>= $i $card))
         $counts
         (countDiscreteValuesStrict $rest (incrementCountAtIndex $counts $i) $card))))

;; Helper to create initial count list
(: createCountList (-> Number (List Number)))
(= (createCountList 0) Nil)
(= (createCountList $n) (Cons 0 (createCountList (- $n 1))))

;; Helper to count discrete values
(: countDiscreteValuesHelper (-> (List Number) (List Number) (List Number)))
(= (countDiscreteValuesHelper Nil $counts) $counts)
(= (countDiscreteValuesHelper (Cons $val $rest) $counts)
   (let* (
     ;; Round to nearest integer index to avoid 0.0 vs 0 mismatches
     ($index (round $val 0))
     ($updatedCounts (incrementCountAtIndex $counts $index))
   )
     (countDiscreteValuesHelper $rest $updatedCounts)))

;; Increment count at specific index
(: incrementCountAtIndex (-> (List Number) Number (List Number)))
(= (incrementCountAtIndex Nil $index) Nil)
(= (incrementCountAtIndex (Cons $count $rest) $index)
   (let* (
     ($i (round $index 0))
   )
     (if (== $i 0)
         (Cons (+ $count 1) $rest)
         (Cons $count (incrementCountAtIndex $rest (- $i 1))))))

;; Count joint discrete values
(: countJointDiscreteValues (-> (List Number) (List Number) Number Number (List (List Number))))
(= (countJointDiscreteValues $parentValues $childValues $parentCardinality $childCardinality)
   (let* (
     ($jointCounts (createJointCountMatrix $parentCardinality $childCardinality))
     ($result (countJointDiscreteValuesHelper $parentValues $childValues $jointCounts))
   )
     $result))

;; Create joint count matrix
(: createJointCountMatrix (-> Number Number (List (List Number))))
(= (createJointCountMatrix 0 $childCardinality) Nil)
(= (createJointCountMatrix $parentCardinality $childCardinality)
   (Cons (createCountList $childCardinality) 
         (createJointCountMatrix (- $parentCardinality 1) $childCardinality)))

;; Helper to count joint discrete values
(: countJointDiscreteValuesHelper (-> (List Number) (List Number) (List (List Number)) (List (List Number))))
(= (countJointDiscreteValuesHelper Nil Nil $matrix) $matrix)
(= (countJointDiscreteValuesHelper (Cons $pVal $pRest) (Cons $cVal $cRest) $matrix)
   (let* (
     ;; Round to nearest integer to align with index expectations
     ($pIndex (round $pVal 0))
     ($cIndex (round $cVal 0))
     ($updatedMatrix (incrementJointCountAtIndex $matrix $pIndex $cIndex))
   )
     (countJointDiscreteValuesHelper $pRest $cRest $updatedMatrix)))

;; Increment joint count at specific indices
(: incrementJointCountAtIndex (-> (List (List Number)) Number Number (List (List Number))))
(= (incrementJointCountAtIndex Nil $pIndex $cIndex) Nil)
(= (incrementJointCountAtIndex (Cons $row $rest) $pIndex $cIndex)
   (if (== $pIndex 0)
       (Cons (incrementCountAtIndex $row $cIndex) $rest)
       (Cons $row (incrementJointCountAtIndex $rest (- $pIndex 1) $cIndex))))

;; Compute BDe score for discrete-discrete case
(: computeDiscreteDiscreteBDeScore (-> (List Number) (List Number) (List (List Number)) Number Number Number))
(= (computeDiscreteDiscreteBDeScore $parentCounts $childCounts $jointCounts $parentCardinality $childCardinality)
   (let* (
     ;; Prior parameters
     ($alpha 1.0)
     
     ;; Compute log-gamma terms
     ($logGammaAlpha (logGamma $alpha))
     ($logGammaAlphaTimesParentCard (logGamma (* $alpha $parentCardinality)))
     ($logGammaAlphaTimesChildCard (logGamma (* $alpha $childCardinality)))
     
     ;; Parent score
     ($parentScore (computeDiscreteScore $parentCounts $alpha $parentCardinality))
     
     ;; Child score
     ($childScore (computeDiscreteScore $childCounts $alpha $childCardinality))
     
     ;; Joint score
     ($jointScore (computeJointDiscreteScore $jointCounts $alpha $parentCardinality $childCardinality))
     
     ;; Total BDe score
     ($score (+ $parentScore (+ $childScore $jointScore)))
   )
     $score))

;; Compute score for discrete variables
(: computeDiscreteScore (-> (List Number) Number Number Number))
(= (computeDiscreteScore Nil $alpha $cardinality) 0.0)
(= (computeDiscreteScore (Cons $count $rest) $alpha $cardinality)
   (let* (
     ($logGammaAlphaPlusCount (logGamma (+ $alpha $count)))
     ($logGammaAlpha (logGamma $alpha))
     ($restScore (computeDiscreteScore $rest $alpha $cardinality))
   )
     (+ (- $logGammaAlphaPlusCount $logGammaAlpha) $restScore)))

;; Compute joint score for discrete variables
(: computeJointDiscreteScore (-> (List (List Number)) Number Number Number Number))
(= (computeJointDiscreteScore Nil $alpha $parentCardinality $childCardinality) 0.0)
(= (computeJointDiscreteScore (Cons $row $rest) $alpha $parentCardinality $childCardinality)
   (let* (
     ($rowScore (computeDiscreteScore $row $alpha $childCardinality))
     ($restScore (computeJointDiscreteScore $rest $alpha $parentCardinality $childCardinality))
   )
     (+ $rowScore $restScore)))

;; Find optimal continuous split point
(: findOptimalContinuousSplit (-> (List Number) (List Number) Number))
(= (findOptimalContinuousSplit $parentValues $childValues)
   (let* (
     ($sortedValues (sortContinuousValues $parentValues))
     ($splitPoints (generateSplitPoints $sortedValues))
     ($bestSplit (findBestSplitPoint $splitPoints $parentValues $childValues))
   )
     $bestSplit))

;; Sort continuous values
(: sortContinuousValues (-> (List Number) (List Number)))
(= (sortContinuousValues $values) (List.sort $values))

;; Generate split points from sorted values
(: generateSplitPoints (-> (List Number) (List Number)))
(= (generateSplitPoints Nil) Nil)
(= (generateSplitPoints (Cons $val Nil)) Nil)
(= (generateSplitPoints (Cons $val1 (Cons $val2 $rest)))
   (Cons (/ (+ $val1 $val2) 2.0) (generateSplitPoints (Cons $val2 $rest))))

;; Find best split point
(: findBestSplitPoint (-> (List Number) (List Number) (List Number) Number))
(= (findBestSplitPoint Nil $parent $child) 0.0)
(= (findBestSplitPoint (Cons $split $rest) $parent $child)
   (let* (
     ($leftCount (List.length (filterLessThan $parent $split)))
     ($rightCount (List.length (filterGreaterEqual $parent $split)))
     ($isValidSplit (and (> $leftCount 0) (> $rightCount 0)))
     ($currentScore (if $isValidSplit (evaluateSplitScore $split $parent $child) minusInf))
     ($bestRest (findBestSplitPoint $rest $parent $child))
     ($bestRestScore (if (== $bestRest 0.0) minusInf (evaluateSplitScore $bestRest $parent $child)))
   )
     (if (> $currentScore $bestRestScore) $split $bestRest)))

;; Evaluate split score
(: evaluateSplitScore (-> Number (List Number) (List Number) Number))
(= (evaluateSplitScore $split $parent $child)
   (if (== $split 0.0)
       minusInf
       (let* (
         ($leftChild (getCorrespondingChildValues $parent $child $split True))
         ($rightChild (getCorrespondingChildValues $parent $child $split False))
         ($leftCounts (countDiscreteValues $leftChild 2))  ; Assuming binary child
         ($rightCounts (countDiscreteValues $rightChild 2))
         ($score (computeContinuousDiscreteBDeScore $leftCounts $rightCounts 2))
       )
         $score)))

;; Filter values less than threshold
(: filterLessThan (-> (List Number) Number (List Number)))
(= (filterLessThan Nil $threshold) Nil)
(= (filterLessThan (Cons $val $rest) $threshold)
   (if (< $val $threshold)
       (Cons $val (filterLessThan $rest $threshold))
       (filterLessThan $rest $threshold)))

;; Filter values greater than or equal to threshold
(: filterGreaterEqual (-> (List Number) Number (List Number)))
(= (filterGreaterEqual Nil $threshold) Nil)
(= (filterGreaterEqual (Cons $val $rest) $threshold)
   (if (>= $val $threshold)
       (Cons $val (filterGreaterEqual $rest $threshold))
       (filterGreaterEqual $rest $threshold)))

;; Get corresponding child values based on parent split
(: getCorrespondingChildValues (-> (List Number) (List Number) Number Bool (List Number)))
(= (getCorrespondingChildValues Nil Nil $split $isLeft) Nil)
(= (getCorrespondingChildValues (Cons $pVal $pRest) (Cons $cVal $cRest) $split $isLeft)
   (let* (
     ($leftVal (< $pVal $split))
     ($rightVal (>= $pVal $split))
     ($include (if $isLeft  $leftVal $rightVal))
     ($restResult (getCorrespondingChildValues $pRest $cRest $split $isLeft))
   )
     (if $include
         (Cons $cVal $restResult)
         $restResult)))

;; Compute BDe score for continuous-discrete case
(: computeContinuousDiscreteBDeScore (-> (List Number) (List Number) Number Number))
(= (computeContinuousDiscreteBDeScore $leftCounts $rightCounts $cardinality)
   (let* (
     ($leftScore (computeDiscreteScore $leftCounts 1.0 $cardinality))
     ($rightScore (computeDiscreteScore $rightCounts 1.0 $cardinality))
     ($totalScore (+ $leftScore $rightScore))
   )
     $totalScore))

;; Compute n-way penalty
(: computeNWayPenalty (-> Number Number))
(= (computeNWayPenalty $cardinality)
   (* (logMath 2 $cardinality) 0.5))  ; Logarithmic penalty

;; Find optimal continuous-continuous split
(: findOptimalContinuousContinuousSplit (-> (List Number) (List Number) Number))
(= (findOptimalContinuousContinuousSplit $parentValues $childValues)
   (findOptimalContinuousSplit $parentValues $childValues))  ; Same as discrete case

;; Compute continuous statistics
(: computeContinuousStats (-> (List Number) (List Number)))
(= (computeContinuousStats $values)
   (let* (
     ($mean (computeMean $values))
     ($variance (computeVariance $values $mean))
     ($count (List.length $values))
   )
     (Cons $mean (Cons $variance (Cons $count Nil)))))

;; Compute mean of values
(: computeMean (-> (List Number) Number))
(= (computeMean Nil) 0.0)
(= (computeMean $values) (/ (List.sum $values) (List.length $values)))

;; Compute variance of values
(: computeVariance (-> (List Number) Number Number))
(= (computeVariance Nil $mean) 0.0)
(= (computeVariance $values $mean)
   (let* (
     ($squaredDiffs (computeSquaredDiffsForMean $values $mean))
     ($sumSquaredDiffs (List.sum $squaredDiffs))
     ($count (List.length $values))
   )
     (if (> $count 1)
         (/ $sumSquaredDiffs (- $count 1))
         0.0)))

;; Compute squared differences for a list with given mean
(: computeSquaredDiffsForMean (-> (List Number) Number (List Number)))
(= (computeSquaredDiffsForMean Nil $mean) Nil)
(= (computeSquaredDiffsForMean (Cons $val $rest) $mean)
   (Cons (* (- $val $mean) (- $val $mean)) (computeSquaredDiffsForMean $rest $mean)))

;; Compute squared difference
(: computeSquaredDiff (-> Number Number Number))
(= (computeSquaredDiff $mean $value) (* (- $value $mean) (- $value $mean)))

;; Compute BDe score for continuous-continuous case
(: computeContinuousContinuousBDeScore (-> (List Number) (List Number) Number))
(= (computeContinuousContinuousBDeScore $leftStats $rightStats)
   (let* (
     ;; Extract statistics
     ($leftMean (List.getByIdx $leftStats 0))
     ($leftVar (List.getByIdx $leftStats 1))
     ($leftCount (List.getByIdx $leftStats 2))
     ($rightMean (List.getByIdx $rightStats 0))
     ($rightVar (List.getByIdx $rightStats 1))
     ($rightCount (List.getByIdx $rightStats 2))
     
     ;; Compute log-likelihood for normal distributions
     ($leftLogLik (computeNormalLogLikelihood $leftMean $leftVar $leftCount))
     ($rightLogLik (computeNormalLogLikelihood $rightMean $rightVar $rightCount))
     
     ($totalScore (+ $leftLogLik $rightLogLik))
   )
     $totalScore))

;; Compute log-likelihood for normal distribution
(: computeNormalLogLikelihood (-> Number Number Number Number))
(= (computeNormalLogLikelihood $mean $variance $count)
   (if (or (== $count 0) (<= $variance 0))
       minusInf
       (let* (
         ($logVar (logMath 2.71828 $variance))  ; Natural logarithm using logMath
         ($negCount (- 0 $count))  ; Negate count properly
         ($logLik (- (* $negCount 0.5) (* $count (* 0.5 $logVar))))
       )
         $logLik)))

;; Sort values in descending order
(: sortDescending (-> (List Number) (List Number)))
(= (sortDescending $values) (List.sort $values >))

;; Compute complexity penalty
(: computeComplexityPenalty (-> Number Number Number))
(= (computeComplexityPenalty $parentCount $childCount)
   (* (logMath 2 (+ $parentCount $childCount)) 0.5))

;; Compute univariate score
(: computeUnivariateScore (-> (List Number) Number Number))
(= (computeUnivariateScore $values $cardinality)
   (let* (
     ($counts (countDiscreteValues $values $cardinality))
     ($score (computeDiscreteScore $counts 1.0 $cardinality))
   )
     $score))

;; ================================================================================
;; Mathematical Helper Functions
;; ================================================================================

;; Python binding for log-gamma (math.lgamma)
!(bind! logGamma (py-atom math.lgamma))

;; Exponential base 2 using pow-math
(: exp2 (-> Number Number))
(= (exp2 $x) (pow-math 2 $x))
