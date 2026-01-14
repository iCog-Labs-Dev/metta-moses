;; a helper to the transform method
;; Converts a list of Instances into a list of Scored Instances using the complexityBasedScorer
;; Params:
;;   $rep: The representation object
;;   (Cons $i $is): A list containing Instances
;;   $itable: The input table
;;   $complexityRatio: probability parameter
;;   $listOfScoredInst: accumulator containing the scoredInstances at each call
;; Returns:
;;   $listOfScoredInst: the final list containing scoredInstances
; (: applyComplexityBasedScore (-> Representation (List Instance) (ITable $a) Number (List (ScoredInstance Cscore)) (List (ScoredInstance Cscore))))
(= (applyComplexityBasedScore $rep Nil $itable $complexityRatio $listOfScoredInst) $listOfScoredInst)
(= (applyComplexityBasedScore $rep (Cons $i $is) $itable $complexityRatio $listOfScoredInst)
(let*
(
    ($score (eval (complexityBasedScorer $rep $i $itable $complexityRatio)))
    ($scoredInst (mkSInst (mkPair $i $score)))
    ($uListofScoredInst (Cons $scoredInst $listOfScoredInst))
)
(applyComplexityBasedScore $rep $is $itable $complexityRatio $uListofScoredInst)))

;; Scores each instance in an InstanceSet. 
;; Params:
;;   instanceSet: The unscored InstanceSet(or that of with an initial worst score)
;;   $rep: The representation object
;;   $itable: The input table
;;   $complexityRatio: probability parameter
;; Returns:
;;   instanceSet: Scored InstanceSet
; (: transform (-> (InstanceSet $a) Representation (ITable Bool) Number (InstanceSet Cscore)))
(= (transform (mkSInstSet $scoredInstList) $rep $itable $complexityRatio)
(let*
(
    ($instList (eval (List.map removeInstScore $scoredInstList)))
    ($cbsInstList (applyComplexityBasedScore $rep $instList $itable $complexityRatio Nil))
)
(mkSInstSet $cbsInstList)))  

;; Converts a list of bits (0s and 1s) to a tuple of indices where the bit is 1.
;; Params:
;;   $bits: List of bits (0 or 1).
;;   $index: Current index (starts at 0).
;;   $acc: Accumulator for indices where bit is 1.
;; Return: Indices as a tuple.
; (: bitsToIndices (-> (List Number) Number Tuple Tuple))
(= (bitsToIndices Nil $index $acc) $acc)
(= (bitsToIndices (Cons $bit $rest) $index $acc)
   (chain (bitsToIndices $rest (+ $index 1) $acc) $nextAcc     
         (if (== $bit 1)
             (cons-atom $index $nextAcc)
             $nextAcc)))

;; similar to the above 'applyComplexityBasedScore' but uses the mutualInformation based scoring for features selection
;; Applies mutual information based scoring to a list of Instances.
;; Params:
;;   (Cons (mkInst $i) $is): List of Instances.
;;   (mkITable $rows $labels): Input table with rows and labels.
;;   $listOfScoredInst: Accumulator for Scored Instances.
;; Returns:
;;   List of Scored Instances with mutual information based scores.
; (: applyMutualInformationBasedScore (-> (List Instance) (ITable $a) (List (ScoredInstance Cscore)) Number (List (ScoredInstance Cscore))))
(= (applyMutualInformationBasedScore Nil (mkITable $rows $labels) $miConfi $listOfScoredInst) (trace! (Returning $listOfScoredInst) $listOfScoredInst))
(= (applyMutualInformationBasedScore (Cons (mkInst $i) $is) (mkITable $rows $labels) $miConf $listOfScoredInst)
(let*
(
    ($targetColumn (eval (Table.getOutputColumn (mkITable $rows $labels))))
    ($indices (bitsToIndices $i 0 ()))
    ($zippedCols (eval (zipColumn $indices $rows)))
    ($score (eval (mutualInformation $zippedCols $targetColumn)))
    
    ; in the c++ it also calculates the confidence too
    ($confidence (eval (calculateConfidence (size-atom $indices) (List.length $rows) $miConf)))
    ($scoreConfi (* $score $confidence))
    ($scoredInst (mkSInst (mkPair (mkInst $i) $scoreConfi)))
    ($uListofScoredInst (Cons $scoredInst $listOfScoredInst))
)
(applyMutualInformationBasedScore $is (mkITable $rows $labels) $miConf $uListofScoredInst)))


;; similar to the above 'transform' but uses the mutualInformation based scoring for features selection
;; Scores each instance in an InstanceSet. 
;; Params:
;;   (mkSInstSet $scoredInstList): The unscored InstanceSet(or that of with an initial worst score)
;;   $itable: The input table
;; Returns: Scored InstanceSet
; (: transformFs (-> (InstanceSet $a) (ITable Bool) Number Number Number Number Bool Symbol (InstanceSet Cscore)))
(= (transformFs (mkSInstSet $scoredInstList) $itable $miConf $prePenalty $preMinActivation $preMaxActivation $prePositive $scorerType)
(let*
(
    ($_ (println! "inside transformFs"))
    ($instList (eval (List.map removeInstScore $scoredInstList)))

    ;;**done call featureSetScorer
    ($cbsInstList (featureSetScorer $itable $scorerType $miConf  $prePenalty $preMinActivation $preMaxActivation $prePositive $instList))
    ($_ (println! $cbsInstList))
)
(mkSInstSet $cbsInstList)))  



;; Purpose: Apply precision-based scoring to a list of instances recursively
;; This mirrors applyMutualInformationBasedScore but uses precision scoring
;; Parameters:
;;   $instList (List Instance) → List of instances to score
;;   $itable (ITable) → Input table with data and labels  
    ; $confi            ;; confidence intensity
    ; $prePenalty          ;; activation Penalty: Penalizes “over-activation” — selecting too many rows from the compressed table.
    ; $preMinActivation   ;; ensures we always select enough rows to have a meaningful precision estimate.
    ; $preMaxActivation   ;; limits how many rows can be selected.
    ; $prePositive        ;; determines which output value is considered the “positive class” in precision_bscore.
    ; $scorerType         ;; can MI or precision_bscore
;;   $acc (List ScoredInstance) → Accumulator for results
;; Returns: (List ScoredInstance) → List of instances with precision scores
; (: applyPrecisionBasedScore (-> (List Instance) ITable Number Number Number Number Bool (List (ScoredInstance Number)) (List (ScoredInstance Number))))
(= (applyPrecisionBasedScore Nil $itable $confi $prePenalty $preMinActivation $preMaxActivation $prePositive $acc) $acc)
(= (applyPrecisionBasedScore (Cons (mkInst $bits) $rest) $itable $confi $prePenalty $preMinActivation $preMaxActivation $prePositive $acc)
    (let* (
           ;; Convert bits to feature indices
           ($featureIndices (bitsToIndices $bits 0 ()))
           ;; Score this feature set using precision scorer
           ($score (eval (preScorer $featureIndices $itable $prePenalty $preMinActivation $preMaxActivation $prePositive $confi)))
           ;; Create scored instance
           ($scoredInst (mkSInst (mkPair (mkInst $bits) $score)))
           ($newAcc (Cons $scoredInst $acc))
        )
        ;; Recurse on remaining instances
        (applyPrecisionBasedScore $rest $itable $confi $prePenalty $preMinActivation $preMaxActivation $prePositive $newAcc)
    )
)


;; Purpose: Score a feature set using the specified scorer type
;; Parameters:
    ; iTable        - our table reperesenation
    ; $miConfi            ;; confidence intensity
    ; $prePenalty          ;; activation Penalty: Penalizes “over-activation” — selecting too many rows from the compressed table.
    ; $preMinActivation   ;; ensures we always select enough rows to have a meaningful precision estimate.
    ; $preMaxActivation   ;; limits how many rows can be selected.
    ; $prePositive        ;; determines which output value is considered the “positive class” in precision_bscore.
    ; $scorerType         ;; can MI or precision_bscore
    ; $instList        - List of Instances
;; Returns: List of Scored Instances
; (: featureSetScorer (-> ITable Symbol Number Number Number Number Bool (List Instance) (List (ScoredInstance Number))))
(= (featureSetScorer $itable $scorerType $miConf  $prePenalty $preMinActivation $preMaxActivation $prePositive $instList)
        (trace! (Scoring with $scorerType for featureSelection $instList)
            (case $scorerType
                (
                    (mi
                        (applyMutualInformationBasedScore $instList $itable $miConf Nil)
                    )
                    (pre
                        (applyPrecisionBasedScore $instList $itable $miConf $prePenalty $preMinActivation $preMaxActivation $prePositive Nil)
                    )
                    ($else 
                        (applyMutualInformationBasedScore $instList $itable $miConf Nil)
                    ) 
                )
            )
        )
    
)
