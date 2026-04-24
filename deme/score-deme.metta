;; a helper to the transform method
;; Converts a list of Instances into a list of Scored Instances using the complexityBasedScorer
;; Params:
;;   $rep: The representation object
;;   (cons $i $is): A list containing Instances
;;   $itable: The input table
;;   $complexityRatio: probability parameter
;;   $listOfScoredInst: accumulator containing the scoredInstances at each call
;; Returns:
;;   $listOfScoredInst: the final list containing scoredInstances
; (: applyComplexityBasedScore (-> Representation (List Instance) (ITable $a) Number (List (ScoredInstance Cscore)) (List (ScoredInstance Cscore))))
(= (applyComplexityBasedScore $rep () $itable $complexityRatio) ())
(= (applyComplexityBasedScore $rep (cons $i $is) $itable $complexityRatio)
(let*
(
    ($score (complexityBasedScorer $rep $i $itable $complexityRatio))
    ($scoredInst (mkSInst (mkPair $i $score)))
)
(cons $scoredInst (applyComplexityBasedScore $rep $is $itable $complexityRatio))))

;; Strategy-based scoring helper for game strategies 
;; Params:
;;   $rep: The representation object
;;   $instList: List of instances to score
;;   $nGames: Number of games to play
;;   $opponentPolicy: Opponent strategy
;;   $complexityRatio: Complexity penalty ratio
;;   $listOfScoredInst: Accumulator for scored instances
;; Returns:
;;   List of scored instances with CScore
; (: applyStrategyBasedScore (-> Representation (List Instance) Number $opponentPolicy Number (List (ScoredInstance CScore)) (List (ScoredInstance CScore))))
(= (applyStrategyBasedScore $rep () $nGames $opponentPolicy $complexityRatio $listOfScoredInst) $listOfScoredInst)
(= (applyStrategyBasedScore $rep (cons $i $is) $nGames $opponentPolicy $complexityRatio $listOfScoredInst)
(let*
(
    ($strategyTree (getCandidate $rep $i))
    ;; ($_ (println! "[applyStrategyBasedScore] Got tree:"))
    ($_ (println! $strategyTree))
    ($cscore (getCscore $strategyTree $nGames $opponentPolicy $complexityRatio &strategyScoreCache))
    ($_ (println! "[applyStrategyBasedScore] Got cscore:"))
    ($_ (println! $cscore))
    ($scoredInst (mkSInst (mkPair $i $cscore)))
    ($uListofScoredInst (cons $scoredInst $listOfScoredInst))
)
(applyStrategyBasedScore $rep $is $nGames $opponentPolicy $complexityRatio $uListofScoredInst)))

;; Scores each instance in an InstanceSet. 
;; Params:
;;   instanceSet: The unscored InstanceSet(or that of with an initial worst score)
;;   $rep: The representation object
;;   $itable: The input table
;;   $complexityRatio: probability parameter
;; Returns:
;;   instanceSet: Scored InstanceSet
; (: transform (-> (InstanceSet $a) Representation (ITable Bool) Number (InstanceSet Cscore)))
(= (transform (mkSInstSet $scoredInstList) $rep $scoringContext $complexityRatio)
   (let* (
          ($instList (List.map removeInstScore $scoredInstList))
          ($scored (case $scoringContext
                        (
                          ((mkITable $rows $labels) (applyComplexityBasedScore $rep $instList $scoringContext $complexityRatio))
                          (($nGames $opponentPolicy) (applyStrategyBasedScore $rep $instList $nGames $opponentPolicy $complexityRatio ())))))
          )
  (mkSInstSet $scored)))

;; Converts a list of bits (0s and 1s) to a tuple of indices where the bit is 1.
;; Params:
;;   $bits: List of bits (0 or 1).
;;   $index: Current index (starts at 0).
;;   $acc: Accumulator for indices where bit is 1.
;; Return: Indices as a tuple.
; (: bitsToIndices (-> (List Number) Number Tuple Tuple))
(= (bitsToIndices () $index $acc) $acc)
(= (bitsToIndices (cons $bit $rest) $index $acc)
   (chain (bitsToIndices $rest (+ $index 1) $acc) $nextAcc     
         (if (== $bit 1)
             (cons-atom $index $nextAcc)
             $nextAcc)))

;; similar to the above 'applyComplexityBasedScore' but uses the mutualInformation based scoring for features selection
;; Applies mutual information based scoring to a list of Instances.
;; Params:
;;   (cons (mkInst $i) $is): List of Instances.
;;   (mkITable $rows $labels): Input table with rows and labels.
;;   $listOfScoredInst: Accumulator for Scored Instances.
;; Returns:
;;   List of Scored Instances with mutual information based scores.
; (: applyMutualInformationBasedScore (-> (List Instance) (ITable $a) (List (ScoredInstance Cscore)) Number (List (ScoredInstance Cscore))))
(= (applyMutualInformationBasedScore () (mkITable $rows $labels) $miConfi $listOfScoredInst) 
   ;; (trace! (Returning $listOfScoredInst)
           $listOfScoredInst
   ;; )
)
(= (applyMutualInformationBasedScore (cons (mkInst $i) $is) (mkITable $rows $labels) $miConf $listOfScoredInst)
(let*
(
    ($targetColumn (Table.getOutputColumn (mkITable $rows $labels)))
    ($indices (bitsToIndices $i 0 ()))
    ($zippedCols (zipColumn $indices $rows))
    ($score (mutualInformation $zippedCols $targetColumn))
    
    ; in the c++ it also calculates the confidence too
    ($confidence (calculateConfidence (size-atom $indices) (List.length $rows) $miConf))
    ($scoreConfi (* $score $confidence))
    ($scoredInst (mkSInst (mkPair (mkInst $i) $scoreConfi)))
    ($uListofScoredInst (cons $scoredInst $listOfScoredInst))
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
    ;; ($_ (println! "inside transformFs"))
    ($instList (List.map removeInstScore $scoredInstList))

    ;;**done call featureSetScorer
    ($cbsInstList (featureSetScorer $itable $scorerType $miConf  $prePenalty $preMinActivation $preMaxActivation $prePositive $instList))
    ;; ($_ (println! $cbsInstList))
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
(= (applyPrecisionBasedScore () $itable $confi $prePenalty $preMinActivation $preMaxActivation $prePositive $acc) $acc)
(= (applyPrecisionBasedScore (cons (mkInst $bits) $rest) $itable $confi $prePenalty $preMinActivation $preMaxActivation $prePositive $acc)
    (let* (
           ;; Convert bits to feature indices
           ($featureIndices (bitsToIndices $bits 0 ()))
           ;; Score this feature set using precision scorer
           ($score (preScorer $featureIndices $itable $prePenalty $preMinActivation $preMaxActivation $prePositive $confi))
           ;; Create scored instance
           ($scoredInst (mkSInst (mkPair (mkInst $bits) $score)))
           ($newAcc (cons $scoredInst $acc))
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
        ;; (trace! (Scoring with $scorerType for featureSelection $instList)
            (case $scorerType
                (
                    (mi
                        (applyMutualInformationBasedScore $instList $itable $miConf ())
                    )
                    (pre
                        (applyPrecisionBasedScore $instList $itable $miConf $prePenalty $preMinActivation $preMaxActivation $prePositive ())
                    )
                    ($else 
                        (applyMutualInformationBasedScore $instList $itable $miConf ())
                    ) 
                )
            )
        ;; )
    
)
