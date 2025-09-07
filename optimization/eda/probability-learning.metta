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
;; - KnobProbabilityModel: mkKnobProbabilityModel (Map KnobId (Map KnobValue Number))
;; - KnobValue: mkKnobValue Number
;; - KnobId: NodeId

;; ================================================================================
;; Type Definitions
;; ================================================================================

;; Knob Value and Probability Model
(: KnobValue Type)
(: mkKnobValue (-> Number KnobValue))
(: KnobId Type)
(: KnobProbabilityModel Type)
(: mkKnobProbabilityModel (-> (Map KnobId (Map KnobValue Number)) (KnobProbabilityModel)))

;; ================================================================================
;; Probability Learning Policy
;; ================================================================================

;; Learn probability distributions from selected instances
; (: learn-probability-model (-> Deme (InstanceSet $score) (KnobProbabilityModel)))
(= (learn-probability-model $deme $selectedInstances)
  (let* (
        (() (println! (learn-probability-model: starting)))
        ((mkDeme $rep (mkSInstSet $instSet) $id) $deme)
        (() (println! (learn-probability-model: got rep $rep)))
        ($discMap (getDiscMap $rep))
        (() (println! (learn-probability-model: got discMap $discMap)))
        ($probModel (learn-knob-probabilities $discMap $selectedInstances))
        (() (println! (learn-probability-model: got probModel $probModel)))
      )
      $probModel))

;; Learn probability distributions for each knob from selected instances
; (: learn-knob-probabilities (-> (MultiMap (DiscSpec $knob)) (InstanceSet $score) (KnobProbabilityModel)))
(= (learn-knob-probabilities $discMap $selectedInstances)
  (let* (
        (() (println! (learn-knob-probabilities: starting)))
        (() (println! (learn-knob-probabilities: got discMap $discMap)))
        (() (println! (learn-knob-probabilities: got selectedInstances $selectedInstances)))
        ($knobCounts (count-knob-values $discMap $selectedInstances))
        (() (println! (learn-knob-probabilities: got knobCounts $knobCounts)))
        ($probabilities (compute-probabilities $knobCounts))
        (() (println! (learn-knob-probabilities: got probabilities $probabilities)))
      )
      (mkKnobProbabilityModel $probabilities)))

;; Count occurrences of each knob value in selected instances
; (: count-knob-values (-> (MultiMap (DiscSpec $knob)) (InstanceSet $score) (Map KnobId (Map KnobValue Number))))
(= (count-knob-values $discMap $selectedInstances)
  (let* (
        (() (println! (count-knob-values: starting)))
        (() (println! (count-knob-values: got discMap $discMap)))
        (() (println! (count-knob-values: got selectedInstances $selectedInstances)))
        ($dkmWrapped (crtDiscKnobMap (mkDscMp $discMap) (mkDscKbMp NilMap) 0))
        (() (println! (count-knob-values: got dkmWrapped $dkmWrapped)))
        ((mkDscKbMp $dkm) $dkmWrapped)
        (() (println! (count-knob-values: got dkm $dkm)))
        ((mkSInstSet $lst) $selectedInstances)
        (() (println! (count-knob-values: got lst $lst)))
      )
      (count-knob-values-over-instances $dkm $lst NilMap)))

;; Count knob values over all instances
; (: count-knob-values-over-instances (-> (Map (KnobId Number)) (List (ScoredInstance $score)) (Map KnobId (Map KnobValue Number)) (Map KnobId (Map KnobValue Number))))
(= (count-knob-values-over-instances $dkm Nil $acc) $acc)
(= (count-knob-values-over-instances $dkm (Cons $h $t) $acc)
  (let* (
        (() (println! (count-knob-values-over-instances: starting)))
        ($acc2 (count-knob-values-for-instance $dkm $acc $h))
      )
      (count-knob-values-over-instances $dkm $t $acc2)))

;; Count knob values for a single instance
; (: count-knob-values-for-instance (-> (Map (KnobId Number)) (Map KnobId (Map KnobValue Number)) (ScoredInstance $score) (Map KnobId (Map KnobValue Number))))
(= (count-knob-values-for-instance $dkm $counts (mkSInst (mkPair (mkInst $vals) $score)))
  (let* (
        (() (println! (count-knob-values-for-instance: starting)))
        ($n (Map.length $dkm))
        (() (println! (count-knob-values-for-instance: got n $n)))
      )
      (count-kv-by-idx $dkm $vals $counts 0 $n)))

;; Count knob values by index
; (: count-kv-by-idx (-> (Map (KnobId Number)) (List Number) (Map KnobId (Map KnobValue Number)) Number Number (Map KnobId (Map KnobValue Number))))
(= (count-kv-by-idx $dkm $vals $counts $i $n)
  (if (>= $i $n)
      (let* (
            (() (println! (count-kv-by-idx: startingif)))
          )
          $counts
        )
      (let* (
            (() (println! (count-kv-by-idx: starting)))
            ($pair (Map.getByIdx $dkm $i))
            (() (println! (count-kv-by-idx: got pair $pair)))
            (($knobId $idx) $pair)
            (() (println! (count-kv-by-idx: got knobId $knobId)))
            ($knobValueNum (List.getByIdx $vals $idx))
            (() (println! (count-kv-by-idx: got knobValueNum $knobValueNum)))
            ($existingIdx (Map.find $counts $knobId))
            (() (println! (count-kv-by-idx: got existingIdx $existingIdx)))
            ($existing (if (== $existingIdx -1)
                           NilMap
                           (let ($k $v) (Map.getByIdx $counts $existingIdx) $v)))
            (() (println! (count-kv-by-idx: got existing $existing)))
            ($knobValue (mkKnobValue $knobValueNum))
            (() (println! (count-kv-by-idx: got knobValue $knobValue)))
            ($updatedInner (increment-knob-value-count $knobValueNum $existing))
            (() (println! (count-kv-by-idx: got updatedInner $updatedInner)))
            ($updated (Map.insert ($knobId $updatedInner) $counts == nodeId<))
            (() (println! (count-kv-by-idx: got updated $updated)))
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
(: compute-probabilities (-> (Map KnobId (Map KnobValue Number)) (Map KnobId (Map KnobValue Number))))
(= (compute-probabilities $counts)
  (let* 
    (
      (() (println! (compute-probabilities: starting)))
      ($smoothed (laplace-smooth-outer $counts 1))
      (() (println! (compute-probabilities: got smoothed $smoothed)))
      ($normalized (normalize-outer $smoothed))
      (() (println! (compute-probabilities: got normalized $normalized)))
    )
    $normalized
    )
  )

;; Normalize outer map (normalize each inner map)
(: normalize-outer (-> (Map KnobId (Map KnobValue Number)) (Map KnobId (Map KnobValue Number))))
(= (normalize-outer $m)
  (let* (
        (() (println! (normalize-outer: starting)))
        ($n (Map.length $m))
        (() (println! (normalize-outer: got n $n)))
      )
      (normalize-outer-idx $m 0 $n NilMap)))

(: normalize-outer-idx (-> (Map KnobId (Map KnobValue Number)) Number Number (Map KnobId (Map KnobValue Number)) (Map KnobId (Map KnobValue Number))))
(= (normalize-outer-idx $m $i $n $acc)
  (if (>= $i $n)
      (let* (
            (() (println! (normalize-outer-idx: startingif)))
          )
          $acc)
          
      (let* (
            (() (println! (normalize-outer-idx: starting)))
            ($pair (Map.getByIdx $m $i))
            (() (println! (normalize-outer-idx: got pair $pair)))
            (($kid $inner) $pair)
            (() (println! (normalize-outer-idx: got kid $kid)))
            ($innerNormalized (normalize-counts $inner))
            (() (println! (normalize-outer-idx: got innerNormalized $innerNormalized)))
            ($acc2 (Map.insert ($kid $innerNormalized) $acc == nodeId<))
            (() (println! (normalize-outer-idx: got acc2 $acc2)))
          )
          (normalize-outer-idx $m (+ $i 1) $n $acc2))))

;; Laplace smoothing for outer map
(: laplace-smooth-outer (-> (Map KnobId (Map KnobValue Number)) Number (Map KnobId (Map KnobValue Number))))
(= (laplace-smooth-outer $m $alpha)
  (let* (
        (() (println! (laplace-smooth-outer: starting)))
        ($n (Map.length $m))
        (() (println! (laplace-smooth-outer: got n $n)))
      )
      (laplace-smooth-outer-idx $m $alpha 0 $n NilMap)))

(: laplace-smooth-outer-idx (-> (Map KnobId (Map KnobValue Number)) Number Number Number (Map KnobId (Map KnobValue Number)) (Map KnobId (Map KnobValue Number))))
(= (laplace-smooth-outer-idx $m $alpha $i $n $acc)
  (if (>= $i $n)
      $acc
      (let* (
            (() (println! (laplace-smooth-outer-idx: starting)))
            ($pair (Map.getByIdx $m $i))
            (() (println! (laplace-smooth-outer-idx: got pair $pair)))
            (($kid $inner) $pair)
            (() (println! (laplace-smooth-outer-idx: got kid $kid)))
            ($innerSmoothed (laplace-smooth-inner $inner $alpha))
            (() (println! (laplace-smooth-outer-idx: got innerSmoothed $innerSmoothed)))
            ($acc2 (Map.insert ($kid $innerSmoothed) $acc == nodeId<))
            (() (println! (laplace-smooth-outer-idx: got acc2 $acc2)))
          )
          (laplace-smooth-outer-idx $m $alpha (+ $i 1) $n $acc2))))

;; Laplace smoothing for inner map
(: laplace-smooth-inner (-> (Map KnobValue Number) Number (Map KnobValue Number)))
(= (laplace-smooth-inner $inner $alpha)
  (let* (
        (() (println! (laplace-smooth-inner: starting)))
        (() (println! (laplace-smooth-inner: got inner $inner)))
        (() (println! (laplace-smooth-inner: got alpha $alpha)))
        ($len (Map.length $inner))
        (() (println! (laplace-smooth-inner: got len $len)))
      )
      (laplace-smooth-inner-idx $inner $alpha 0 $len NilMap)))

(: laplace-smooth-inner-idx (-> (Map KnobValue Number) Number Number Number (Map KnobValue Number) (Map KnobValue Number)))
(= (laplace-smooth-inner-idx $m $alpha $i $n $acc)
  (if (>= $i $n)
      $acc
      (let* (
            (() (println! (laplace-smooth-inner-idx: starting)))
            ($pair (Map.getByIdx $m $i))
            (() (println! (laplace-smooth-inner-idx: got pair $pair)))
            (($kv $cnt) $pair)
            (() (println! (laplace-smooth-inner-idx: got kv $kv)))
            ($acc2 (Map.insert ($kv (+ $cnt $alpha)) $acc knobValueEq knobValueLt))
            (() (println! (laplace-smooth-inner-idx: got acc2 $acc2)))
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
