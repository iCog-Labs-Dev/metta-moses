;; ================================================================================
;; Model Sampling
;; ================================================================================
;;
;; This file implements the model sampling policy for EDA.
;; Equivalent to sampling logic in optimize.h in the C++ implementation.
;;
;; Key Components:
;; - Sample new instances from the learned probability model
;; - Generate instances from probability distributions
;; - Sample knob values according to learned probabilities
;; - Create instances from sampled knob values
;;
;; Sampling Strategy:
;; - Uses learned probability distributions to generate new instances
;; - Samples each knob independently (univariate assumption)
;; - Creates valid instances compatible with the representation
;; ================================================================================
;; Model Sampling
;; ================================================================================


;; Sample new instances from the learned probability model
(: sample-from-model (-> (KnobProbabilityModel) Deme Number (InstanceSet $score)))
(= (sample-from-model $probModel $deme $nGenerate)
  (let* (
        ((mkDeme $rep (mkSInstSet $instSet) $id) $deme)
        ($newInstances (generate-instances $probModel $rep $nGenerate))
        ($wrapped (List.map initInstScore $newInstances))
      )
      (mkSInstSet $wrapped)))

;; Common helper: extract Representation from Deme
; (: getRep (-> Deme Representation))
(= (getRep (mkDeme $rep $instSet $id)) $rep)

;; Common helper: extract InstanceSet from Deme
; (: getInstanceSet (-> Deme (InstanceSet $score)))
(= (getInstanceSet (mkDeme $rep $instSet $id)) $instSet)

;; Common helper: unwrap list of ScoredInstances from InstanceSet
; (: getScoredInstances (-> (InstanceSet $score) (List (ScoredInstance $score))))
(= (getScoredInstances (mkSInstSet $instances)) $instances)

;; Generate new instances from the probability model
(: generate-instances (-> (KnobProbabilityModel) Representation Number (List Instance)))
(= (generate-instances $probModel $rep $nGenerate)
  (if (<= $nGenerate 0)
      Nil
      (let* (
            ($newInstance (sample-instance $probModel $rep))
            ($rest (generate-instances $probModel $rep (- $nGenerate 1)))
          )
          (Cons $newInstance $rest))))

;; Sample a single instance from the probability model
(: sample-instance (-> (KnobProbabilityModel) Representation Instance))
(= (sample-instance $probModel $rep)
   (let* (
         ($knobValues (sample-knob-values $probModel $rep))
         ($instance (create-instance $rep $knobValues))
       )
       $instance))

;; Sample knob values according to learned probabilities
; (: sample-knob-values (-> (KnobProbabilityModel) Representation (Map KnobId KnobValue)))
(= (sample-knob-values $probModel $rep)
  (let* (
        (() (println! (sample-knob-values: probModel= $probModel rep= $rep)))
        (() (println! (sample-knob-values: about to destructure rep)))
        ((mkRep (mkKbMap $discKbMp $discMp) $tree) $rep)
        (() (println! (sample-knob-values: discKbMp= $discKbMp discMp= $discMp tree= $tree)))
        (() (println! (sample-knob-values: about to destructure discKbMp)))
        ((mkDscKbMp $discKbMap) $discKbMp)
        (() (println! (sample-knob-values: discKbMap= $discKbMap)))
        ($knobIds (Map.keys $discKbMap))
        (() (println! (sample-knob-values: knobIds= $knobIds)))
        (() (println! (sample-knob-values: about to call sample-knob-values-acc)))
        ($knobValues (sample-knob-values-acc $probModel $knobIds NilMap))
        (() (println! (sample-knob-values: knobValues= $knobValues)))
      )
      $knobValues))

;; Helper to accumulate sampled knob values - build map manually to avoid comparison issues
(: sample-knob-values-acc (-> (KnobProbabilityModel) (List KnobId) (Map KnobId KnobValue) (Map KnobId KnobValue)))
(= (sample-knob-values-acc $probModel Nil $acc) 
  (let* (
        (() (println! (sample-knob-values-acc: base case, returning acc= $acc)))
      )
      $acc))
(= (sample-knob-values-acc $probModel (Cons $kid $rest) $acc)
  (let* (
        (() (println! (sample-knob-values-acc: processing kid= $kid rest= $rest acc= $acc)))
        ($val (sample-knob-value $probModel $kid))
        (() (println! (sample-knob-values-acc: got val= $val)))
        ($acc2 (ConsMap ($kid $val) $acc))
        (() (println! (sample-knob-values-acc: got acc2= $acc2)))
      )
      (sample-knob-values-acc $probModel $rest $acc2)))

;; Sample a single knob value
(: sample-knob-value (-> (KnobProbabilityModel) KnobId KnobValue))
(= (sample-knob-value $probModel $knobId)
   (let* (
         ($probabilities (get-knob-probabilities $probModel $knobId))
         ($randomValue (random-from-distribution $probabilities))
       )
       $randomValue))

;; Get knob probabilities from model
(: get-knob-probabilities (-> (KnobProbabilityModel) KnobId (Map KnobValue Number)))
(= (get-knob-probabilities (mkKnobProbabilityModel $probabilities) $knobId)
   (let* (
         ($idx (Map.find $probabilities $knobId))
       )
       (if (== $idx -1)
           NilMap
           (let ($k $v) (Map.getByIdx $probabilities $idx) $v))))

;; Random selection from distribution
(: random-from-distribution (-> (Map KnobValue Number) KnobValue))
(= (random-from-distribution $probabilities)
   (let* (
         ($random (randomFloat))
         ($items (Map.items $probabilities))
       )
       (select-from-cumulative-list $items $random 0.0)))

;; Select value based on cumulative probability
(: select-from-cumulative-list (-> (List (KnobValue Number)) Number Number KnobValue))
(= (select-from-cumulative-list Nil $target $cumulative) (mkKnobValue 0))
(= (select-from-cumulative-list (Cons ($value $prob) $tail) $target $cumulative)
   (let* (
         ($newCumulative (+ $cumulative $prob))
       )
       (if (>= $newCumulative $target)
           $value
           (select-from-cumulative-list $tail $target $newCumulative))))

;; Create instance from knob values
(: create-instance (-> Representation (Map KnobId KnobValue) Instance))
(= (create-instance (mkRep (mkKbMap (mkDscKbMp $discKbMap) (mkDscMp $discMap)) $tree) $knobValues)
   (let* (
         ($n (MultiMap.length $discMap))
         ($zeros (List.generate $n 0))
         ($filled (fill-instance-by-map $zeros $discKbMap $knobValues))
       )
       (mkInst $filled)))

(: fill-instance-by-map (-> (List Number) (Map (NodeId Number)) (Map KnobId KnobValue) (List Number)))
(= (fill-instance-by-map $vec $discKbMap NilMap) $vec)
(= (fill-instance-by-map $vec $discKbMap (ConsMap ($kid $val) $tail))
   (let* (
         ($idx (Map.getByKey $kid $discKbMap))
        ($valNum (getKnobValue $val))
        ($newVec (List.replaceAt $vec $idx $valNum))
      )
      (fill-instance-by-map $newVec $discKbMap $tail)))

;; ================================================================================
;; Helper Functions
;; ================================================================================

;; Extract number from KnobValue
(: getKnobValue (-> KnobValue Number))
(= (getKnobValue (mkKnobValue $n)) $n)

