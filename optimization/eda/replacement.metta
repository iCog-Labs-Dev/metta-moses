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
; (: replace-the-worst (-> (InstanceSet $score) Deme Deme))
(= (replace-the-worst $newInstances $deme)
  (let* (
        (() (println! (Replace-the-worst with $newInstances $deme)))
        ((mkDeme $rep (mkSInstSet $instSet) $id) $deme)
        (() (println! (GOT $rep $instSet)))
        ((mkSInstSet $newList) $newInstances)
        (() (println! (newList: $newList)))
        ($scoredInstances $instSet)
        ($nReplace (min (List.length $newList) (List.length $scoredInstances)))
        (() (println! (N : $nReplace)))
        ($worst (get-worst-instances $scoredInstances $nReplace))
        (() (println! (worst : $worst)))
        ($remaining (remove-worst-instances $scoredInstances $nReplace))
        (() (println! (remaining : $remaining)))
        ($updated (List.concat $remaining $newList))
        (() (println! (updated : $updated)))
      )
      (mkDeme $rep (mkSInstSet $updated) $id)))

;; Get the worst n instances
; (: get-worst-instances (-> (List (ScoredInstance Cscore)) Number (List (ScoredInstance Cscore))))
(= (get-worst-instances $instances $n)
  (let* (
        (() (println! (Get worst instances: instances= $instances)))
        ($sorted (sort-by-score $instances))
        (() (println! (Get worst instances: sorted= $sorted)))
        ($len (List.length $sorted))
        (() (println! (Get worst instances: len= $len)))
        ($start (max 0 (- $len $n)))
      )
      (List.drop $start $sorted)))

;; Remove the worst n instances
; (: remove-worst-instances (-> (List (ScoredInstance Cscore)) Number (List (ScoredInstance Cscore))))
(= (remove-worst-instances $instances $n)
  (let* (
        ($sorted (sort-by-score $instances))
        ($len (List.length $sorted))
        ($keep (max 0 (- $len $n)))
      )
      (List.takeN $keep $sorted)))

;; Sort instances by score (worst first)
; (: sort-by-score (-> (List (ScoredInstance Cscore)) (List (ScoredInstance Cscore))))
(= (sort-by-score $instances)
  (let* (
        (() (println! (Sort by score: instances= $instances)))
        ($set (mkSInstSet $instances))
        (() (println! (Sort by score: set= $set)))
        ($sortedSet (sortDeme $set))
        (() (println! (Sort by score: sortedSet= $sortedSet)))
      )
      (getScoredInstances $sortedSet)))


