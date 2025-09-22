;; ================================================================================
;; Probability Learning Policy
;; ================================================================================
;;
;; This file implements the probability learning policy for EDA.
;; Equivalent to the model building logic in local_structure.h/cc in the C++ implementation.
;;
;; Key Components:
;; - Learn probability distributions from selected instances
;; - Count knob value occurrences
;; - Compute probabilities with Laplace smoothing
;; - Normalize probability distributions
;;
;; Data Structures:
;; - KnobProbabilityModel: mkKnobProbabilityModel (Map NodeId (Map KnobValue Number))
;; - KnobValue: mkKnobValue Number
;; - KnobId: NodeId

;; ================================================================================
;; Type Definitions
;; ================================================================================

;; Knob Value and Probability Model
(: KnobValue Type)
(: mkKnobValue (-> Number KnobValue))
(: KnobProbabilityModel Type)
(: mkKnobProbabilityModel (-> (Map NodeId (Map KnobValue Number)) KnobProbabilityModel))

;; ================================================================================
;; Probability Learning Policy
;; ================================================================================

;; Learn probability distributions from selected instances
(: learn-probability-model (-> Deme (InstanceSet $score) KnobProbabilityModel))
(= (learn-probability-model $deme $selectedInstances)
  (let* (
        ((mkDeme $rep (mkSInstSet $instSet) $id) $deme)
        ($discMap (getDiscMap $rep))
        ($probModel (learn-knob-probabilities $discMap $selectedInstances))
      )
      $probModel))

;; Learn probability distributions for each knob from selected instances
; (: learn-knob-probabilities (-> (MultiMap (DiscSpec $knob)) (InstanceSet $score) KnobProbabilityModel))
(= (learn-knob-probabilities $discMap $selectedInstances)
  (let* (
        ($knobCounts (count-knob-values $discMap $selectedInstances))
        ($probabilities (compute-probabilities $knobCounts))
      )
      (mkKnobProbabilityModel $probabilities)))

;; Count occurrences of each knob value in selected instances
; (: count-knob-values (-> (MultiMap (DiscSpec $knob)) (InstanceSet $score) (Map NodeId (Map KnobValue Number))))
(= (count-knob-values $discMap $selectedInstances)
  (let* (
        ($dkmWrapped (crtDiscKnobMap (mkDscMp $discMap) (mkDscKbMp NilMap) 0))
        ((mkDscKbMp $dkm) $dkmWrapped)
        ((mkSInstSet $lst) $selectedInstances)
      )
      (count-knob-values-over-instances $dkm $lst NilMap)))

;; Count knob values over all instances
; (: count-knob-values-over-instances (-> (Map (NodeId Number)) (List (ScoredInstance $score)) (Map NodeId (Map KnobValue Number)) (Map NodeId (Map KnobValue Number))))
(= (count-knob-values-over-instances $dkm Nil $acc) $acc)
(= (count-knob-values-over-instances $dkm (Cons $h $t) $acc)
  (let* (
        ($acc2 (count-knob-values-for-instance $dkm $acc $h))
      )
      (count-knob-values-over-instances $dkm $t $acc2)))

;; Count knob values for a single instance
; (: count-knob-values-for-instance (-> (Map (NodeId Number)) (Map NodeId (Map KnobValue Number)) (ScoredInstance $score) (Map NodeId (Map KnobValue Number))))
(= (count-knob-values-for-instance $dkm $counts (mkSInst (mkPair (mkInst $vals) $score)))
  (let* (
        ($n (Map.length $dkm))
      )
      (count-kv-by-idx $dkm $vals $counts 0 $n)))

;; Count knob values by index
; (: count-kv-by-idx (-> (Map (NodeId Number)) (List Number) (Map NodeId (Map KnobValue Number)) Number Number (Map NodeId (Map KnobValue Number))))
(= (count-kv-by-idx $dkm $vals $counts $i $n)
  (if (>= $i $n)
      $counts
      (let* (
            ($pair (Map.getByIdx $dkm $i))
            (($knobId $idx) $pair)
            ($knobValueNum (List.getByIdx $vals $idx))
            ($existingIdx (Map.find $counts $knobId))
            ($existing (if (== $existingIdx -1)
                           NilMap
                           (let ($k $v) (Map.getByIdx $counts $existingIdx) $v)))
            ($updatedInner (increment-knob-value-count $knobValueNum $existing))
            ($updated (Map.insert ($knobId $updatedInner) $counts == nodeId<))
          )
          (count-kv-by-idx $dkm $vals $updated (+ $i 1) $n))))

;; Increment knob value count
(: increment-knob-value-count (-> Number (Map KnobValue Number) (Map KnobValue Number)))
(= (increment-knob-value-count $knobValueNum $existing)
   (let* (
        ($knobValue (mkKnobValue $knobValueNum))
        ($existingIdx (Map.find $existing $knobValue))
        ($currentCount (if (== $existingIdx -1)
                           0
                           (let ($k $v) (Map.getByIdx $existing $existingIdx) $v)))
        ($newCount (+ $currentCount 1))
      )
      (Map.insert ($knobValue $newCount) $existing knobValueEq knobValueLt)))

;; Compute probabilities from counts with Laplace smoothing
(: compute-probabilities (-> (Map NodeId (Map KnobValue Number)) (Map NodeId (Map KnobValue Number))))
(= (compute-probabilities $counts)
  (let* (
        ($smoothed (laplace-smooth-outer $counts 1))
        ($normalized (normalize-outer $smoothed))
      )
      $normalized))

;; Normalize outer map (normalize each inner map)
(: normalize-outer (-> (Map NodeId (Map KnobValue Number)) (Map NodeId (Map KnobValue Number))))
(= (normalize-outer $m)
  (let* (
        ($n (Map.length $m))
      )
      (normalize-outer-idx $m 0 $n NilMap)))

(: normalize-outer-idx (-> (Map NodeId (Map KnobValue Number)) Number Number (Map NodeId (Map KnobValue Number)) (Map NodeId (Map KnobValue Number))))
(= (normalize-outer-idx $m $i $n $acc)
  (if (>= $i $n)
      $acc
      (let* (
            ($pair (Map.getByIdx $m $i))
            (($kid $inner) $pair)
            ($innerNormalized (normalize-counts $inner))
            ($acc2 (Map.insert ($kid $innerNormalized) $acc == nodeId<))
          )
          (normalize-outer-idx $m (+ $i 1) $n $acc2))))

;; Laplace smoothing for outer map
(: laplace-smooth-outer (-> (Map NodeId (Map KnobValue Number)) Number (Map NodeId (Map KnobValue Number))))
(= (laplace-smooth-outer $m $alpha)
  (let* (
        ($n (Map.length $m))
      )
      (laplace-smooth-outer-idx $m $alpha 0 $n NilMap)))

(: laplace-smooth-outer-idx (-> (Map NodeId (Map KnobValue Number)) Number Number Number (Map NodeId (Map KnobValue Number)) (Map NodeId (Map KnobValue Number))))
(= (laplace-smooth-outer-idx $m $alpha $i $n $acc)
  (if (>= $i $n)
      $acc
      (let* (
            ($pair (Map.getByIdx $m $i))
            (($kid $inner) $pair)
            ($innerSmoothed (laplace-smooth-inner $inner $alpha))
            ($acc2 (Map.insert ($kid $innerSmoothed) $acc == nodeId<))
          )
          (laplace-smooth-outer-idx $m $alpha (+ $i 1) $n $acc2))))

;; Laplace smoothing for inner map
(: laplace-smooth-inner (-> (Map KnobValue Number) Number (Map KnobValue Number)))
(= (laplace-smooth-inner $inner $alpha)
  (let* (
        ($len (Map.length $inner))
      )
      (laplace-smooth-inner-idx $inner $alpha 0 $len NilMap)))

(: laplace-smooth-inner-idx (-> (Map KnobValue Number) Number Number Number (Map KnobValue Number) (Map KnobValue Number)))
(= (laplace-smooth-inner-idx $m $alpha $i $n $acc)
  (if (>= $i $n)
      $acc
      (let* (
            ($pair (Map.getByIdx $m $i))
            (($kv $cnt) $pair)
            ($acc2 (Map.insert ($kv (+ $cnt $alpha)) $acc knobValueEq knobValueLt))
          )
          (laplace-smooth-inner-idx $m $alpha (+ $i 1) $n $acc2))))

;; Normalize counts to probabilities
(: normalize-counts (-> (Map KnobValue Number) (Map KnobValue Number)))
(= (normalize-counts $counts)
   (let* (
         ($n (Map.length $counts))
         ($total (normalize-counts-sum $counts 0 $n 0))
       )
       (normalize-counts-build $counts 0 $n $total NilMap)))

(: normalize-counts-sum (-> (Map KnobValue Number) Number Number Number Number))
(= (normalize-counts-sum $m $i $n $acc)
   (if (>= $i $n)
       $acc
       (let* (
             ($pair (Map.getByIdx $m $i))
             (($k $cnt) $pair)
           )
           (normalize-counts-sum $m (+ $i 1) $n (+ $acc $cnt)))))

(: normalize-counts-build (-> (Map KnobValue Number) Number Number Number (Map KnobValue Number) (Map KnobValue Number)))
(= (normalize-counts-build $m $i $n $total $acc)
  (if (>= $i $n)
      $acc
      (let* (
            ($pair (Map.getByIdx $m $i))
            (($kv $cnt) $pair)
            ($p (if (== $total 0) 0 (/ $cnt $total)))
            ($acc2 (Map.insert ($kv $p) $acc knobValueEq knobValueLt))
          )
          (normalize-counts-build $m (+ $i 1) $n $total $acc2))))

;; ================================================================================
;; Helper Functions
;; ================================================================================

;; Get discrete map from representation
; (: getDiscMap (-> Representation (MultiMap (DiscSpec $knob))))
(= (getDiscMap (mkRep (mkKbMap $dscKbMp $dscMp) $tree)) (extractMultiMap $dscMp))

;; Extract MultiMap from DiscMap
; (: extractMultiMap (-> DiscMap (MultiMap (DiscSpec $knob))))
(= (extractMultiMap (mkDscMp $multiMap)) $multiMap)

;; Comparison functions for KnobValue
(: knobValueEq (-> KnobValue KnobValue Bool))
(= (knobValueEq (mkKnobValue $n1) (mkKnobValue $n2)) (== $n1 $n2))

(: knobValueLt (-> KnobValue KnobValue Bool))
(= (knobValueLt (mkKnobValue $n1) (mkKnobValue $n2)) (< $n1 $n2))
