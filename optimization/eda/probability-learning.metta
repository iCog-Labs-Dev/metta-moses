;; ================================================================================
;; Probability Learning Policy for EDA (Estimation of Distribution Algorithm)
;; ================================================================================
;;
;; This file implements the probability learning policy for EDA, which is equivalent
;; to the model building logic in local_structure.h/cc in the C++ implementation.
;;
;; MATHEMATICAL FOUNDATION:
;; The probability learning process follows these steps:
;;
;; 1. COUNTING PHASE:
;;    - Count occurrences of each knob value in selected instances
;;    - For each knob k and value v: count[k][v] = number of times v appears for knob k
;;
;; 2. LAPLACE SMOOTHING PHASE:
;;    - Apply Laplace smoothing to prevent zero probabilities
;;    - Formula: smoothed_count[k][v] = count[k][v] + α
;;    - Where α = 1 (smoothing parameter)
;;
;; 3. NORMALIZATION PHASE:
;;    - Convert counts to probabilities by normalization
;;    - Formula: P(k,v) = smoothed_count[k][v] / Σ(smoothed_count[k][v'] for all v')
;;    - This ensures Σ P(k,v) = 1 for each knob k
;;
;; PROBABILITY MODEL STRUCTURE:
;; - KnobProbabilityModel: Map<NodeId, Map<KnobValue, Probability>>
;; - Each knob (NodeId) has a probability distribution over its possible values
;; - Probabilities sum to 1.0 for each knob
;;
;; EXAMPLE CALCULATION:
;; Given knob values: [0,1,0,1,1] for knob k
;; - Raw counts: count[k][0] = 2, count[k][1] = 3
;; - Laplace smoothing: smoothed[k][0] = 3, smoothed[k][1] = 4
;; - Normalization: P(k,0) = 3/7, P(k,1) = 4/7
;;
;; ================================================================================
;; Type Definitions
;; ================================================================================

;; Knob Value and Probability Model
(: KnobValue Type)
(: mkKnobValue (-> Number KnobValue))
(: KnobProbabilityModel Type)
(: mkKnobProbabilityModel (-> (Map NodeId (Map KnobValue Number)) KnobProbabilityModel))

;; ================================================================================
;; Main Probability Learning Functions
;; ================================================================================

;; Learn probability distributions from selected instances
;; This is the main entry point for probability learning in EDA
(: learnProbabilityModel (-> Deme (InstanceSet $score) KnobProbabilityModel))
(= (learnProbabilityModel $deme $selectedInstances)
  (let* (
        ((mkDeme $rep (mkSInstSet $instSet) $id) $deme)
        ($discMap (getDiscMap $rep))
        ($probModel (learnKnobProbabilities $discMap $selectedInstances))
      )
      $probModel))

;; Learn probability distributions for each knob from selected instances
;; This function orchestrates the three-phase process: count → smooth → normalize
(: learnKnobProbabilities (-> (MultiMap (DiscSpec $knob)) (InstanceSet $score) KnobProbabilityModel))
(= (learnKnobProbabilities $discMap $selectedInstances)
  (let* (
        ($knobCounts (countKnobValues $discMap $selectedInstances))
        ($probabilities (computeProbabilities $knobCounts))
      )
      (mkKnobProbabilityModel $probabilities)))

;; ================================================================================
;; Phase 1: Counting Knob Values
;; ================================================================================

;; Count occurrences of each knob value in selected instances
;; Returns: Map<NodeId, Map<KnobValue, Count>>
(: countKnobValues (-> (MultiMap (DiscSpec $knob)) (InstanceSet $score) (Map NodeId (Map KnobValue Number))))
(= (countKnobValues $discMap $selectedInstances)
  (let* (
        ($dkmWrapped (crtDiscKnobMap (mkDscMp $discMap) (mkDscKbMp NilMap) 0))
        ((mkDscKbMp $dkm) $dkmWrapped)
        ((mkSInstSet $instances) $selectedInstances)
      )
      (countKnobValuesOverInstances $dkm $instances NilMap)))

;; Count knob values over all instances using fold pattern
(: countKnobValuesOverInstances (-> (Map (NodeId Number)) (List (ScoredInstance $score)) (Map NodeId (Map KnobValue Number)) (Map NodeId (Map KnobValue Number))))
(= (countKnobValuesOverInstances $dkm Nil $acc) $acc)
(= (countKnobValuesOverInstances $dkm (Cons $instance $rest) $acc)
  (let* (
        ($updatedAcc (countKnobValuesForInstance $dkm $acc $instance))
      )
      (countKnobValuesOverInstances $dkm $rest $updatedAcc)))

;; Count knob values for a single instance
(: countKnobValuesForInstance (-> (Map (NodeId Number)) (Map NodeId (Map KnobValue Number)) (ScoredInstance $score) (Map NodeId (Map KnobValue Number))))
(= (countKnobValuesForInstance $dkm $counts (mkSInst (mkPair (mkInst $values) $score)))
  (let* (
        ($n (Map.length $dkm))
      )
      (countKnobValuesByIndex $dkm $values $counts 0 $n)))

;; Count knob values by index using iterative approach
(: countKnobValuesByIndex (-> (Map (NodeId Number)) (List Number) (Map NodeId (Map KnobValue Number)) Number Number (Map NodeId (Map KnobValue Number))))
(= (countKnobValuesByIndex $dkm $values $counts $i $n)
  (if (>= $i $n)
      $counts
      (let* (
            ($pair (Map.getByIdx $dkm $i))
            (($knobId $idx) $pair)
            ($knobValueNum (List.getByIdx $values $idx))
            ($existingIdx (Map.find $counts $knobId))
            ($existing (if (== $existingIdx -1)
                           NilMap
                           (let ($k $v) (Map.getByIdx $counts $existingIdx) $v)))
            ($updatedInner (incrementKnobValueCount $knobValueNum $existing))
            ($updated (Map.insert ($knobId $updatedInner) $counts == nodeId<))
          )
          (countKnobValuesByIndex $dkm $values $updated (+ $i 1) $n))))

;; Increment count for a specific knob value
(: incrementKnobValueCount (-> Number (Map KnobValue Number) (Map KnobValue Number)))
(= (incrementKnobValueCount $knobValueNum $existing)
   (let* (
        ($knobValue (mkKnobValue $knobValueNum))
        ($existingIdx (Map.find $existing $knobValue))
        ($currentCount (if (== $existingIdx -1)
                           0
                           (let ($k $v) (Map.getByIdx $existing $existingIdx) $v)))
        ($newCount (+ $currentCount 1))
      )
      (Map.insert ($knobValue $newCount) $existing knobValueEq knobValueLt)))

;; ================================================================================
;; Phase 2: Laplace Smoothing
;; ================================================================================

;; Compute probabilities from counts with Laplace smoothing
;; This applies the formula: smoothed_count = count + α, where α = 1
(: computeProbabilities (-> (Map NodeId (Map KnobValue Number)) (Map NodeId (Map KnobValue Number))))
(= (computeProbabilities $counts)
  (let* (
        ($smoothed (applyLaplaceSmoothing $counts 1))
        ($normalized (normalizeProbabilityDistributions $smoothed))
      )
      $normalized))

;; Apply Laplace smoothing to all knob distributions
;; Formula: smoothed[k][v] = count[k][v] + α
(: applyLaplaceSmoothing (-> (Map NodeId (Map KnobValue Number)) Number (Map NodeId (Map KnobValue Number))))
(= (applyLaplaceSmoothing $counts $alpha)
  (let* (
        ($n (Map.length $counts))
      )
      (applyLaplaceSmoothingByIndex $counts $alpha 0 $n NilMap)))

;; Apply Laplace smoothing using index-based iteration
(: applyLaplaceSmoothingByIndex (-> (Map NodeId (Map KnobValue Number)) Number Number Number (Map NodeId (Map KnobValue Number)) (Map NodeId (Map KnobValue Number))))
(= (applyLaplaceSmoothingByIndex $counts $alpha $i $n $acc)
  (if (>= $i $n)
      $acc
      (let* (
            ($pair (Map.getByIdx $counts $i))
            (($knobId $innerCounts) $pair)
            ($smoothedInner (applyLaplaceSmoothingToInner $innerCounts $alpha))
            ($updatedAcc (Map.insert ($knobId $smoothedInner) $acc == nodeId<))
          )
          (applyLaplaceSmoothingByIndex $counts $alpha (+ $i 1) $n $updatedAcc))))

;; Apply Laplace smoothing to a single knob's value counts
(: applyLaplaceSmoothingToInner (-> (Map KnobValue Number) Number (Map KnobValue Number)))
(= (applyLaplaceSmoothingToInner $innerCounts $alpha)
  (let* (
        ($len (Map.length $innerCounts))
      )
      (applyLaplaceSmoothingToInnerByIndex $innerCounts $alpha 0 $len NilMap)))

;; Apply Laplace smoothing to inner map using index-based iteration
(: applyLaplaceSmoothingToInnerByIndex (-> (Map KnobValue Number) Number Number Number (Map KnobValue Number) (Map KnobValue Number)))
(= (applyLaplaceSmoothingToInnerByIndex $innerCounts $alpha $i $n $acc)
  (if (>= $i $n)
      $acc
      (let* (
            ($pair (Map.getByIdx $innerCounts $i))
            (($knobValue $count) $pair)
            ($smoothedCount (+ $count $alpha))
            ($updatedAcc (Map.insert ($knobValue $smoothedCount) $acc knobValueEq knobValueLt))
          )
          (applyLaplaceSmoothingToInnerByIndex $innerCounts $alpha (+ $i 1) $n $updatedAcc))))

;; ================================================================================
;; Phase 3: Probability Normalization
;; ================================================================================

;; Normalize probability distributions for all knobs
;; This ensures that probabilities sum to 1.0 for each knob
(: normalizeProbabilityDistributions (-> (Map NodeId (Map KnobValue Number)) (Map NodeId (Map KnobValue Number))))
(= (normalizeProbabilityDistributions $smoothedCounts)
  (let* (
        ($n (Map.length $smoothedCounts))
      )
      (normalizeProbabilityDistributionsByIndex $smoothedCounts 0 $n NilMap)))

;; Normalize probability distributions using index-based iteration
(: normalizeProbabilityDistributionsByIndex (-> (Map NodeId (Map KnobValue Number)) Number Number (Map NodeId (Map KnobValue Number)) (Map NodeId (Map KnobValue Number))))
(= (normalizeProbabilityDistributionsByIndex $smoothedCounts $i $n $acc)
  (if (>= $i $n)
      $acc
      (let* (
            ($pair (Map.getByIdx $smoothedCounts $i))
            (($knobId $innerCounts) $pair)
            ($normalizedInner (normalizeSingleKnobDistribution $innerCounts))
            ($updatedAcc (Map.insert ($knobId $normalizedInner) $acc == nodeId<))
          )
          (normalizeProbabilityDistributionsByIndex $smoothedCounts (+ $i 1) $n $updatedAcc))))

;; Normalize a single knob's distribution to probabilities
;; Formula: P(k,v) = count[k][v] / Σ(count[k][v'] for all v')
(: normalizeSingleKnobDistribution (-> (Map KnobValue Number) (Map KnobValue Number)))
(= (normalizeSingleKnobDistribution $counts)
   (let* (
         ($n (Map.length $counts))
         ($total (calculateTotalCount $counts 0 $n 0))
       )
       (buildNormalizedProbabilities $counts 0 $n $total NilMap)))

;; Calculate total count for normalization
(: calculateTotalCount (-> (Map KnobValue Number) Number Number Number Number))
(= (calculateTotalCount $counts $i $n $acc)
   (if (>= $i $n)
       $acc
       (let* (
             ($pair (Map.getByIdx $counts $i))
             (($knobValue $count) $pair)
           )
           (calculateTotalCount $counts (+ $i 1) $n (+ $acc $count)))))

;; Build normalized probabilities from counts
(: buildNormalizedProbabilities (-> (Map KnobValue Number) Number Number Number (Map KnobValue Number) (Map KnobValue Number)))
(= (buildNormalizedProbabilities $counts $i $n $total $acc)
  (if (>= $i $n)
      $acc
      (let* (
            ($pair (Map.getByIdx $counts $i))
            (($knobValue $count) $pair)
            ($probability (if (== $total 0) 0 (/ $count $total)))
            ($updatedAcc (Map.insert ($knobValue $probability) $acc knobValueEq knobValueLt))
          )
          (buildNormalizedProbabilities $counts (+ $i 1) $n $total $updatedAcc))))

;; ================================================================================
;; Helper Functions
;; ================================================================================

;; Get discrete map from representation
(: getDiscMap (-> Representation (MultiMap (DiscSpec $knob))))
(= (getDiscMap (mkRep (mkKbMap $dscKbMp $dscMp) $tree)) (extractMultiMap $dscMp))

;; Extract MultiMap from DiscMap
(: extractMultiMap (-> DiscMap (MultiMap (DiscSpec $knob))))
(= (extractMultiMap (mkDscMp $multiMap)) $multiMap)

;; Comparison functions for KnobValue
(: knobValueEq (-> KnobValue KnobValue Bool))
(= (knobValueEq (mkKnobValue $n1) (mkKnobValue $n2)) (== $n1 $n2))

(: knobValueLt (-> KnobValue KnobValue Bool))
(= (knobValueLt (mkKnobValue $n1) (mkKnobValue $n2)) (< $n1 $n2))
