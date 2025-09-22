;; ================================================================================
;; Termination Policy
;; ================================================================================
;;
;; This file implements the termination policy for EDA.
;; Equivalent to termination.h in the C++ implementation.
;;
;; Key Components:
;; - Check if optimization should terminate
;; - Termination criteria based on score thresholds
;; - Termination criteria based on no improvement
;; - Extract best scores from populations
;;
;; Termination Strategies:
;; - Terminate if best score exceeds threshold
;; - Terminate if no improvement for specified generations
;; - Extract best penalized scores for evaluation

;; ================================================================================
;; Termination Policy
;; ================================================================================

;; Check if optimization should terminate
(: terminate-if-gte-or-no-improv (-> Number Number Deme Bool))
(= (terminate-if-gte-or-no-improv $threshold $maxGensNoImprovement $deme)
  (let* (
        (() (println! (Terminate if gte or no improv: threshold= $threshold maxGensNoImprovement= $maxGensNoImprovement deme= $deme)))
        ((mkDeme $rep $iset $id) $deme)
        (() (println! (Terminate if gte or no improv: iset= $iset)))
        ($best (get-best-penalized-score $iset))
        (() (println! (Terminate if gte or no improv: best= $best)))
      )
      (if (< $best $threshold) False True)))

;; Get the best penalized score from the instance set
(: get-best-penalized-score (-> (InstanceSet Cscore) Number))
(= (get-best-penalized-score (mkSInstSet $instances))
  (if (== (List.length $instances) 0)
      (getPenScore (worstCscore))
      (let* (
            ;; Extract penalized scores from scored instances via a named helper
            ($scores (List.map get-pen-score-from-sinst $instances))
            ;; Compute the maximum penalized score
            ($best (List.max $scores))
          )
          $best)))

;; Helper: extract penalized score from a ScoredInstance
(: get-pen-score-from-sinst (-> (ScoredInstance Cscore) Number))
(= (get-pen-score-from-sinst (mkSInst (mkPair $inst $cs))) (getPenScore $cs))

;; ================================================================================
;; Future Termination Policies
;; ================================================================================

;; Placeholder for additional termination criteria
;; These could be implemented for more sophisticated termination strategies

;; (: terminate-if-max-generations (-> Number Number Bool))
;; (= (terminate-if-max-generations $currentGen $maxGens)
;;    (>= $currentGen $maxGens))

;; (: terminate-if-convergence (-> Deme Number Bool))
;; (= (terminate-if-convergence $deme $tolerance)
;;    (let* (
;;          ($variance (compute-population-variance $deme))
;;        )
;;        (< $variance $tolerance)))

;; (: terminate-if-time-limit (-> Number Number Bool))
;; (= (terminate-if-time-limit $startTime $maxTime)
;;    (let* (
;;          ($currentTime (perf_counter))
;;          ($elapsed (- $currentTime $startTime))
;;        )
;;        (>= $elapsed $maxTime)))
