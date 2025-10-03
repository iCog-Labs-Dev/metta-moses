;; ================================================================================
;; Replacement Policy
;; ================================================================================
;;
;; This file implements the replacement policy for EDA.
;; Equivalent to replacement.h in the C++ implementation.
;;
;; Key Components:
;; - Replace the worst instances in the population with new instances
;; - Identify and remove worst instances
;; - Sort instances by score for replacement decisions
;;
;; Replacement Strategy:
;; - Replaces worst-performing individuals with new ones
;; - Maintains population size
;; - Preserves best individuals

;; ================================================================================
;; Replacement Policy
;; ================================================================================

;; Replace the worst instances in the population with new instances
(: replaceTheWorst (-> (InstanceSet $score) Deme Deme))
(= (replaceTheWorst $newInstances $deme)
  (let* (
        ((mkDeme $rep (mkSInstSet $instSet) $id) $deme)
        ((mkSInstSet $newList) $newInstances)
        ($numToReplace (min (coll.length $newList) (coll.length $instSet)))
        ((mkPair $worst $remaining) (getWorstAndRemaining $instSet $numToReplace))
        ($incoming (List.takeN $numToReplace $newList))
        ($updated (List.concat $remaining $incoming))
      )
      (mkDeme $rep (mkSInstSet $updated) $id)))

;; Optimized function to get both worst and remaining instances in one pass
(: getWorstAndRemaining (-> (List (ScoredInstance $score)) Number (Pair (List (ScoredInstance $score)) (List (ScoredInstance $score)))))
(= (getWorstAndRemaining $instances $n)
  (let* (
        ($sorted (sortByScore $instances))
        ($len (coll.length $sorted))
        ($keep (max 0 (- $len $n)))
        ($remaining (List.takeN $keep $sorted))
        ($worst (List.drop $keep $sorted))
      )
      (mkPair $worst $remaining)))

;; Get the worst n instances
(: getWorstInstances (-> (List (ScoredInstance $score)) Number (List (ScoredInstance $score))))
(= (getWorstInstances $instances $n)
  (let* (
        ((mkPair $worst $remaining) (getWorstAndRemaining $instances $n))
      )
      $worst))

;; Remove the worst n instances
(: removeWorstInstances (-> (List (ScoredInstance $score)) Number (List (ScoredInstance $score))))
(= (removeWorstInstances $instances $n)
  (let* (
        ((mkPair $worst $remaining) (getWorstAndRemaining $instances $n))
      )
      $remaining))

;; Sort instances by score (descending best first from sortDeme, tail are worst)
(: sortByScore (-> (List (ScoredInstance $score)) (List (ScoredInstance $score))))
(= (sortByScore $instances)
  (let* (
        ($set (mkSInstSet $instances))
        ($sortedSet (sortDeme $set))
      )
      (getScoredInstances $sortedSet)))


