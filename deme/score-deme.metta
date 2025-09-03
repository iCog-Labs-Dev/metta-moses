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
(: applyComplexityBasedScore (-> Representation (List Instance) (ITable $a) Number (List (ScoredInstance Cscore)) (List (ScoredInstance Cscore))))
(= (applyComplexityBasedScore $rep Nil $itable $complexityRatio $listOfScoredInst) $listOfScoredInst)
(= (applyComplexityBasedScore $rep (Cons $i $is) $itable $complexityRatio $listOfScoredInst)
(let*
(
    ($score (complexityBasedScorer $rep $i $itable $complexityRatio))
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
(: transform (-> (InstanceSet $a) Representation (ITable Bool) Number (InstanceSet Cscore)))
(= (transform (mkSInstSet $scoredInstList) $rep $itable $complexityRatio)
(let*
(
    ($instList (List.map removeInstScore $scoredInstList))
    ($cbsInstList (applyComplexityBasedScore $rep $instList $itable $complexityRatio Nil))
)
(mkSInstSet $cbsInstList)))  

;; Converts a list of bits (0s and 1s) to a tuple of indices where the bit is 1.
;; Params:
;;   $bits: List of bits (0 or 1).
;;   $index: Current index (starts at 0).
;;   $acc: Accumulator for indices where bit is 1.
;; Return: Indices as a tuple.
(: bitsToIndices (-> (List Number) Number Tuple Tuple))
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
(: applyMutualInformationBasedScore (-> (List Instance) (ITable $a) (List (ScoredInstance Cscore)) (List (ScoredInstance Cscore))))
(= (applyMutualInformationBasedScore Nil (mkITable $rows $labels) $listOfScoredInst) $listOfScoredInst)
(= (applyMutualInformationBasedScore (Cons (mkInst $i) $is) (mkITable $rows $labels) $listOfScoredInst)
(let*
(
    ($targetColumn (Table.getOutputColumn (mkITable $rows $labels)))
    ($indices (bitsToIndices $i 0 ()))
    ($zippedCols (zipColumn $indices $rows))
    ($score (mutualInformation $zippedCols $targetColumn))
    ($scoredInst (mkSInst (mkPair (mkInst $i) $score)))
    ($uListofScoredInst (Cons $scoredInst $listOfScoredInst))
)
(applyMutualInformationBasedScore $is (mkITable $rows $labels) $uListofScoredInst)))

;; similar to the above 'transform' but uses the mutualInformation based scoring for features selection
;; Scores each instance in an InstanceSet. 
;; Params:
;;   (mkSInstSet $scoredInstList): The unscored InstanceSet(or that of with an initial worst score)
;;   $itable: The input table
;; Returns: Scored InstanceSet
(: transformFs (-> (InstanceSet $a) (ITable Bool) (InstanceSet Cscore)))
(= (transformFs (mkSInstSet $scoredInstList) $itable)
(let*
(
    (() (println! "inside transformFs"))
    ($instList (List.map removeInstScore $scoredInstList))
    ($cbsInstList (applyMutualInformationBasedScore $instList $itable Nil))
)
(mkSInstSet $cbsInstList)))  