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
;; This implements the full C++ logic: terminate if score >= threshold OR no improvement for maxGensNoImprovement generations
(: terminateIfGteOrNoImprov (-> Number Number Deme Number Number Number Bool))
(= (terminateIfGteOrNoImprov $threshold $maxGensNoImprovement $deme $bestSeenSoFar $generationsWithoutImprovement)
  (if (< $maxGensNoImprovement 0)
      False  ; Invalid maxGensNoImprovement - don't terminate
      (let* (
            ($currentBest (getBestPenalizedScore (getInstanceSet $deme)))
            ($hasImproved (> $currentBest $bestSeenSoFar))
          )
          ;; C++ logic: if improved, only check threshold; if no improvement, check both conditions
          (if $hasImproved
              (>= $currentBest $threshold)  ; Use type-safe >= from general-helpers
              (or (>= $generationsWithoutImprovement $maxGensNoImprovement)  ; Check OLD no-improvement count
                  (>= $bestSeenSoFar $threshold))))))  ; Use type-safe >= from general-helpers

;; Get the best penalized score from the instance set
(: getBestPenalizedScore (-> (InstanceSet Cscore) Number))
(= (getBestPenalizedScore (mkSInstSet $instances))
  (if (== (List.length $instances) 0)
      (getPenScore (worstCscore))
      (List.max (List.map getPenScoreFromSinst $instances))))

;; Helper: extract penalized score from a ScoredInstance
(: getPenScoreFromSinst (-> (ScoredInstance Cscore) Number))
(= (getPenScoreFromSinst (mkSInst (mkPair $inst $cs))) (getPenScore $cs))

;; ================================================================================
;; Future Termination Policies
;; ================================================================================

;; Placeholder for additional termination criteria
;; These could be implemented for more sophisticated termination strategies

;; (: terminateIfMaxGenerations (-> Number Number Bool))
;; (= (terminate-if-max-generations $currentGen $maxGens)
;;    (>= $currentGen $maxGens))

;; (: terminateIfConvergence (-> Deme Number Bool))
;; (= (terminateIfConvergence $deme $tolerance)
;;    (let* (
;;          ($variance (compute-population-variance $deme))
;;        )
;;        (< $variance $tolerance)))

;; (: terminateIfTimeLimit (-> Number Number Bool))
;; (= (terminateIfTimeLimit $startTime $maxTime)
;;    (let* (
;;          ($currentTime (perf_counter))
;;          ($elapsed (- $currentTime $startTime))
;;        )
;;        (>= $elapsed $maxTime)))
