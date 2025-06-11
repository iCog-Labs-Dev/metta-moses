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

