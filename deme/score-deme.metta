;; A helper of transform.
;; Converts a list of Instances into a list of Scored Instances using the complexityBasedScorer
;; Params:
;;   $rep: The representation object
;;   $id: The deme id
;;   $instances: A list of Instances
;;   $itable: The input table
;;   $complexityRatio: The complexity penalty ratio
;; Returns:
;;   The list of scored instances, in input order
;; (: applyComplexityBasedScore (-> Representation DemeId (List Instance) (ITable $a) Number (List (ScoredInstance Cscore))))
(= (applyComplexityBasedScore $rep $id $instances $itable $complexityRatio)
    (map-atom $instances $i (mkSInst (mkPair $i (complexityBasedScorer $rep $id $i $itable $complexityRatio)))))

;; Action scoring helper: instance -> candidate tree -> episodes -> Cscore.
;; Scores through the generic action evaluator (getActionCscore,
;; scoring/action-score.metta) against the fitness configured in
;; (param fitness). Uses the 3-arg getCandidate:
;; action reps carry embedded mkASK knobs in a 1-field (mkKbMap (mkDscMp ...))
;; -- the 4-arg findDiscKnob path requires the 2-field mkDscKbMp shape.
;; Params:
;;   $rep: The representation object
;;   $id: The deme id
;;   $instances: List of instances to score
;;   $nTrials: Number of episodes per evaluation
;;   $complexityRatio: Complexity penalty ratio
;;   $listOfScoredInst: Not used
;; Returns:
;;   List of scored instances with CScore
;; (: applyActionBasedScore (-> Representation DemeId (List Instance) Number Number (List (ScoredInstance CScore)) (List (ScoredInstance CScore))))
(= (applyActionBasedScore $rep $id $instances $nTrials $complexityRatio $listOfScoredInst)
   (map-atom $instances $i
    (let* (($actionTree (getCandidateHelper $i (getRepTree $rep)))
           ($cscore (getActionCscore $actionTree (mkActionCtx $nTrials) $complexityRatio &actionScoreCache)))
    (mkSInst (mkPair $i $cscore)))))

;; Scores each instance in an InstanceSet.
;; Params:
;;   instanceSet: The unscored InstanceSet (or one with an initial worst score)
;;   $rep: The representation object
;;   $id: The deme id
;;   $scoringContext: The input table (mkITable ...) or an action context
;;   $complexityRatio: The complexity penalty ratio
;; Returns:
;;   instanceSet: Scored InstanceSet
;; (: transform (-> (InstanceSet $a) Representation DemeId $scoringContext Number (InstanceSet Cscore)))
(= (transform (mkSInstSet $scoredInstList) $rep $id $scoringContext $complexityRatio)
   (let* (
          ($instList (List.map removeInstScore $scoredInstList))
          ($scored (case $scoringContext
                        (
                          ;; Two disjoint tagged contexts: (mkActionCtx ...) drives
                          ;; the action path, (mkITable ...) the boolean path.
                          ((mkActionCtx $nTrials $complexityRatio $targetScore) (applyActionBasedScore $rep $id $instList $nTrials $complexityRatio ()))
                          ((mkActionCtx $nTrials) (applyActionBasedScore $rep $id $instList $nTrials $complexityRatio ()))
                          (($complexityRatio $nTrials) (applyActionBasedScore $rep $id $instList $nTrials $complexityRatio ()))
                          ((mkITable $rows $labels) (applyComplexityBasedScore $rep $id $instList $scoringContext $complexityRatio)))))
          )
  (mkSInstSet $scored)))

;; Similar to applyComplexityBasedScore, but uses mutual information scoring for feature selection.
;; Params:
;;   (cons (mkInst $i) $is): List of Instances.
;;   (mkITable $table $labels): Input table with columns and labels.
;;   $miConf: Confidence intensity.
;;   $listOfScoredInst: Accumulator for Scored Instances.
;; Returns:
;;   List of Scored Instances with mutual information based scores, in reverse input order.
;; (: applyMutualInformationBasedScore (-> (List Instance) (ITable $a) Number (List (ScoredInstance Number)) (List (ScoredInstance Number))))
(= (applyMutualInformationBasedScore () (mkITable $table $labels) $miConfi $listOfScoredInst)
   $listOfScoredInst)
   
(= (applyMutualInformationBasedScore (cons (mkInst $i) $is) (mkITable $table $labels) $miConf $listOfScoredInst)
(let*
(
    ($targetColumn (Table.getOutputColumn (mkITable $table $labels)))
    ($indices (bitsToIndices $i 0 ()))
    ($zippedCols (zipColumn $indices $table))

    ($score (mutualInformation $zippedCols $targetColumn))

    ;; number of samples = length of any column
    ($confidence (calculateConfidence (size-atom $indices) (ITable.rowCount $table) $miConf))
    ($scoreConfi (* $score $confidence))
    ($scoredInst (mkSInst (mkPair (mkInst $i) $scoreConfi)))
    ($uListofScoredInst (cons $scoredInst $listOfScoredInst))
)
(applyMutualInformationBasedScore $is (mkITable $table $labels) $miConf $uListofScoredInst)))

;; Similar to transform, but uses the feature-set scorer for feature selection.
;; Scores each instance in an InstanceSet.
;; Params:
;;   (mkSInstSet $scoredInstList): The unscored InstanceSet (or one with an initial worst score)
;;   $itable: The input table
;;   the other parameters: see featureSetScorer
;; Returns: Scored InstanceSet
;; (: transformFs (-> (InstanceSet $a) (ITable Bool) Number Number Number Number Bool Symbol (InstanceSet Cscore)))
(= (transformFs (mkSInstSet $scoredInstList) $itable $miConf $prePenalty $preMinActivation $preMaxActivation $prePositive $scorerType)
(let*
(
    ;; ($_ (println! "inside transformFs"))
    ($instList (List.map removeInstScore $scoredInstList))

    ($cbsInstList (featureSetScorer $itable $scorerType $miConf  $prePenalty $preMinActivation $preMaxActivation $prePositive $instList))
    ;; ($_ (println! $cbsInstList))
)
(mkSInstSet $cbsInstList)))  



;; Applies precision-based scoring to a list of instances.
;; This mirrors applyMutualInformationBasedScore but uses precision scoring.
;; Parameters:
;;   $instList (List Instance): List of instances to score
;;   $itable (ITable): Input table with data and labels
;;   $confi: Confidence intensity
;;   $prePenalty: Activation penalty. Penalizes over-activation (too many rows selected from the compressed table).
;;   $preMinActivation: The minimum activation, so that the precision estimate is meaningful.
;;   $preMaxActivation: The maximum number of rows that can be selected.
;;   $prePositive: The output value that is the positive class in precision_bscore.
;;   $acc (List ScoredInstance): Accumulator for results
;; Returns: (List ScoredInstance): Instances with precision scores, in reverse input order
;; (: applyPrecisionBasedScore (-> (List Instance) ITable Number Number Number Number Bool (List (ScoredInstance Number)) (List (ScoredInstance Number))))
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


;; Scores a feature set with the specified scorer type.
;; Parameters:
;;   $itable: The input table
;;   $scorerType: mi (mutual information) or pre (precision_bscore); any other value uses mi
;;   $miConf: Confidence intensity
;;   $prePenalty, $preMinActivation, $preMaxActivation, $prePositive: see applyPrecisionBasedScore
;;   $instList: List of Instances
;; Returns: List of Scored Instances
;; (: featureSetScorer (-> ITable Symbol Number Number Number Number Bool (List Instance) (List (ScoredInstance Number))))
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
