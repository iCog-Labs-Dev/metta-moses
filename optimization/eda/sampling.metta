;; ================================================================================
;; Model Sampling (EDA)
;; ================================================================================
;;
;; Purpose
;; - Sample new instances from a learned univariate KnobProbabilityModel.
;; - Create valid Instance values compatible with a Representation.
;;
;; Notes
;; - Univariate assumption: each knob is sampled independently.
;; - Deterministic tests assert helper behavior; random sampling is not asserted.


;; Sample new instances from the learned probability model
(: sampleFromModel (-> (KnobProbabilityModel) Deme Number (InstanceSet $score)))
(= (sampleFromModel $probModel $deme $nGenerate)
  (if (<= $nGenerate 0)
      (mkSInstSet Nil)  ; Return empty set for invalid nGenerate
      (let* (
            ((mkDeme $rep (mkSInstSet $instSet) $id) $deme)
            ($newInstances (generateInstances $probModel $rep $nGenerate))
            ($wrapped (List.map initInstScore $newInstances))
          )
          (mkSInstSet $wrapped))))

;; Helper functions moved to their appropriate files:
;; - getRep and getInstanceSet moved to deme/create-deme.metta
;; - getScoredInstances moved to representation/instance.metta

;; Generate new instances from the probability model
(: generateInstances (-> (KnobProbabilityModel) Representation Number (List Instance)))
(= (generateInstances $probModel $rep $nGenerate)
  (if (<= $nGenerate 0)
      Nil
      (let* (
            ($newInstance (sampleInstance $probModel $rep))
            ($rest (generateInstances $probModel $rep (- $nGenerate 1)))
          )
          (Cons $newInstance $rest))))

;; Sample a single instance from the probability model
(: sampleInstance (-> (KnobProbabilityModel) Representation Instance))
(= (sampleInstance $probModel $rep)
   (let* (
         ($knobValues (sampleKnobValues $probModel $rep))
         ($instance (createInstance $rep $knobValues))
       )
       $instance))

;; Sample knob values according to learned probabilities
; (: sampleKnobValues (-> (KnobProbabilityModel) Representation (Map NodeId KnobValue)))
(= (sampleKnobValues $probModel $rep)
  (let* (
        ((mkRep (mkKbMap $discKbMp $discMp) $tree) $rep)
        ((mkDscKbMp $discKbMap) $discKbMp)
        ($knobIds (Map.keys $discKbMap))
        ($knobValues (sampleKnobValuesAcc $probModel $knobIds NilMap))
      )
      $knobValues))

;; Helper to accumulate sampled knob values - build map manually to avoid comparison issues
(: sampleKnobValuesAcc (-> (KnobProbabilityModel) (List NodeId) (Map NodeId KnobValue) (Map NodeId KnobValue)))
(= (sampleKnobValuesAcc $probModel Nil $acc) $acc)
(= (sampleKnobValuesAcc $probModel (Cons $kid $rest) $acc)
  (let* (
        ($val (sampleKnobValue $probModel $kid))
        ($acc2 (ConsMap ($kid $val) $acc))
      )
      (sampleKnobValuesAcc $probModel $rest $acc2)))

;; Sample a single knob value
(: sampleKnobValue (-> (KnobProbabilityModel) NodeId KnobValue))
(= (sampleKnobValue $probModel $knobId)
   (let* (
         ($probabilities (getKnobProbabilities $probModel $knobId))
         ($randomValue (randomFromDistribution $probabilities))
       )
       $randomValue))

;; Get knob probabilities from model
(: getKnobProbabilities (-> (KnobProbabilityModel) NodeId (Map KnobValue Number)))
(= (getKnobProbabilities (mkKnobProbabilityModel $probabilities) $knobId)
   (let* (
         ($idx (Map.find $probabilities $knobId))
       )
       (if (== $idx -1)
           NilMap
           (let ($k $v) (Map.getByIdx $probabilities $idx) $v))))

;; Random selection from distribution
(: randomFromDistribution (-> (Map KnobValue Number) KnobValue))
(= (randomFromDistribution $probabilities)
   (if (== (Map.length $probabilities) 0)
       (mkKnobValue 0)  ; Return default value for empty distribution
       (let* (
             ($random (randomFloat))
             ($items (Map.items $probabilities))
           )
           (selectFromCumulativeList $items $random 0.0))))

;; Select value based on cumulative probability
(: selectFromCumulativeList (-> (List (KnobValue Number)) Number Number KnobValue))
(= (selectFromCumulativeList Nil $target $cumulative) (mkKnobValue 0))
(= (selectFromCumulativeList (Cons ($value $prob) $tail) $target $cumulative)
   (let* (
         ($newCumulative (+ $cumulative $prob))
       )
       (if (>= $newCumulative $target)
           $value
           (selectFromCumulativeList $tail $target $newCumulative))))

;; Create instance from knob values
(: createInstance (-> Representation (Map NodeId KnobValue) Instance))
(= (createInstance (mkRep (mkKbMap (mkDscKbMp $discKbMap) (mkDscMp $discMap)) $tree) $knobValues)
   (let* (
         ($n (MultiMap.length $discMap))
         ($zeros (List.generate $n 0))
         ($filled (fillInstanceByMap $zeros $discKbMap $knobValues))
       )
       (mkInst $filled)))

(: fillInstanceByMap (-> (List Number) (Map (NodeId Number)) (Map NodeId KnobValue) (List Number)))
(= (fillInstanceByMap $vec $discKbMap NilMap) $vec)
(= (fillInstanceByMap $vec $discKbMap (ConsMap ($kid $val) $tail))
   (let* (
         ($idx (Map.getByKey $kid $discKbMap))
        ($valNum (getKnobValue $val))
        ($newVec (List.replaceAt $vec $idx $valNum))
      )
      (fillInstanceByMap $newVec $discKbMap $tail)))

;; ================================================================================
;; Helper Functions
;; ================================================================================

;; Extract number from KnobValue
(: getKnobValue (-> KnobValue Number))
(= (getKnobValue (mkKnobValue $n)) $n)

