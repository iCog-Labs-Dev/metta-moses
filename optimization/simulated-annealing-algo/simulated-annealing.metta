;; Simulated Annealing
;; Params:
;;   deme: The current population of instances
;;   tTableBScorer: The truth table based bScore function
;;   initCenter: The initial instance to start the search from
;;   initial-temperature: Initial temperature for the algorithm
;;   cooling-rate: Rate at which the temperature decreases
;;   max-iterations: Maximum number of iterations to run the algorithm
;;   total-state: Total number of instances in the state space
;; Returns:
;;   instance: The best instance found
;;   deme: The final population of instances
;;   state: The state of the algorithm
;; Algorithm description:
;;   1. Checks if the temp == final temp or max iterations is reached, it any of these is true break and return the best cadidate and best score.
;;   2. If not, scores the current cadidate and generates a new candidate by using crossover.
;;   3. Scores the new candidate and calculates the energy of the new candidate and current candidate.
;;   4. Calculates the acceptance probability using the energy.
;;   5. Generates a random float between 0 and 1.
;;   6. Calculate the acceptance probability by comparing the energies of the two candidates (low energy==better cadidate), or by deviding the 
;;      difference of the two energies by the temprature and taking the exp of that value. The actual accpetance probability is the product of 
;;      the intensity and acceptance probability.
;;   7. If the actual acceptance probability is greater than the random float, accept the new candidate as the current candidate.
;;   8. Decrease the temperature by multiplying it with the cooling rate.
;;   9. Decrement the max iterations by 1.
;;   10. Repeat from step 1.   
;;

;; Calculates the difference between two composite scores.
(= (cDelta $c1 $c2)
  (let*
    (
      (($pl $pr $cl $cr) ((getPenScore $cs1) (getPenScore $cs2) (getComp $cs1) (getComp $cs2)))
      ($pD (- $pl $pr))
      ($cD (- $cl $cr))
      ($wD (+ (* 0.5 $pD) (* 0.5 $cD)))
    )
     $wD
  )
)

;; Calculates instance energy using the composite score of that instance 
;;  (this is based on the C++ version) the composite score is the sum of
;;  the bScore and the penalized score.
(: getEnergy (-> Cscore Number))
(= (getEnergy $cScore)
  (let ($pScore $bScore) ((getPenScore $cScore) (getScore $cScore)) (* -1 (+ $pScore $bScore)))
)

;; Acceptance probability which is based on the energy of the current and new instance, and the temperature.
(: acceptanceProb (-> Number Number Number Number))
(= (acceptanceProb $energy1 $energy2 $Temp)
  (if (< $energy2 $energy1)
    1.0
    (math-exp (/ (- $energy1 $energy2) $Temp))
  )
)

;; Actual acceptance probabitlity which is the product of the intensity and acceptance probability.
;;  (This is based on the C++ implementation)
(: actualAcceptanceProb (-> Number Number Number))
(= (actualAcceptanceProb $acceptanceProb $intensity)
  (* $intensity $acceptanceProb)
)


(: simulated-annealing (-> Deme (TruthTableBScore $a) Instance $hyperParams (Instance Deme $state)))
(= (simulated-annealing $deme $tTableBScorer $initCenter $hyperParams)
     (simulated-annealing $deme $tTableBScorer $initCenter (1 3 0) $hyperParams (False False $initCenter (worstCscore) (* -1 (pow-math 10 308)) 0 0 1)) 
)

(: simulated-annealing (-> Deme (TruthTableBScore $a) Instance $constParams $hyperParams $params (Instance Deme $state)))
(= (simulated-annealing (mkDeme (mkRep (mkKbMap (mkDscKbMp $idxMp) (mkDscMp $disc)) $tree) $instSet $id) ;; $deme)
                         (mkTruthTableBScore $cpxCoeff $size $iTable) ;; $table
                         $initCenter
                         ($maxDist $minXoverNeighbors $bestPossibleScore) ;; $constParams
                         ($Temp $finalTemp $coolRate $isInit $maxIter) ;; $hyperParams
                         ($alreadyXover $lastChance $prevCenter $bestCScore $bestScore $currentNInstances $d $i) ;; $params
                         )
    (if (or (<= $Temp $finalTemp) (<= $maxIter 0))
          ($prevCenter (mkDeme (mkRep (mkKbMap (mkDscKbMp $idxMp) (mkDscMp $disc)) $tree) $instSet $id) ($prevCenter $bestCScore $bestScore $currentNInstances $d $i))
          (let*
            (
              ;; Estimate Neighborhood
              (() (println! (Iteration: $i , Temperature: $Temp)))
              (() (println! ""))
              ; (() (println! $hyper))

              ($deme (mkDeme (mkRep (mkKbMap (mkDscKbMp $idxMp) (mkDscMp $disc)) $tree) $instSet $id))
              ($table (mkTruthTableBScore $cpxCoeff $size $iTable))
              ($totalNNeighbors (estimateNeighborhood $d $disc))
              ; (($alreadyXover $lastchance) (False False))

              (() (println! (Estimated neighbors: $totalNNeighbors)))
              (() (println! ""))

              ($nNewNeighbors (min $totalNNeighbors 2))

              ($largeNbh (>= $totalNNeighbors $minXoverNeighbors))

              ($xOver (and (> $i 2) (and (not $alreadyXover) (or $largeNbh $lastChance))))
            
              ;; Generate a new instance using crossover
              (((mkDeme $rep $updatedInstSet $id) $newInstances) (if $xOver
                                                              (crossover $currentNInstances $nNewNeighbors $prevCenter $deme)
                                                              (sampleNewInstances $totalNNeighbors $nNewNeighbors $prevCenter $deme $d)))

              (() (println! (Newinstances: $updatedInstSet)))
              (() (println! ""))

              ;; Score the new instance
              ((mkSInstSet $scoredInstances) (transform $updatedInstSet $rep $iTable $cpxCoeff))
              
              ($updatedDeme (mkDeme $rep (mkSInstSet $scoredInstances) $id))

              (() (println! (Scored instances: $scoredInstances)))
              (() (println! ""))

              ((mkSInst $newBestInstPair) (List.foldl ((curry2 returnBest) cScore<) (mkSInst (mkPair $initCenter $bestCscore)) $scoredInstances))

              ($newBestScore (getPenScore (Pair.second $newBestInstPair))) ;; This could be the original best candidate or a new one.
              ($hasImproved (> $newBestScore (+ $bestScore 0.5))) ;; Hard coded the score_improved function for now. This is automated in the C++ version.

              (() (println! (Best instance: $newBestInstPair)))
              (() (println! (New best score: $newBestScore)))
              (() (println! (Has Improved: $hasImproved)))
              (() (println! ""))

              ;; Calculate the energy of the current and new instance, and the acceptanceProb
              ($energy (getEnergy $bestCScore))
              ($newEnergy (getEnergy (Pair.second $newBestInstPair)))
              ($acceptanceProb (acceptanceProb $energy $newEnergy $Temp))
              ($randomFloat (rand-random)) ;; using random.random instead of numpy.random.rand
              ($actualAcceptanceProb (actualAcceptanceProb $acceptanceProb 0.85)) ;; Using the default value of 0.5 for intensity

              (() (println! (Energy: $energy)))
              (() (println! (New energy: $newEnergy)))
              (() (println! (Acceptance probability: $acceptanceProb)))
              (() (println! (Random float: $randomFloat)))
              (() (println! (Actual acceptance probability: $actualAcceptanceProb)))
              (() (println! ""))

              ;; Check for acceptance
              ($isAccepted (> $actualAcceptanceProb $randomFloat))
              ; ($isAccepted (or (< $newEnergy $energy) (< $randomFloat $acceptanceProb)))
              
              (() (println! (Is accepted: $isAccepted)))
              (() (println! ($newInstances)))
              (() (println! ""))
              
              ($newDeme (if $isAccepted $updatedDeme $deme))
              ($newCenter (if $isAccepted (Pair.first $newBestInstPair) $prevCenter))
              ($newDistance (if $hasImproved 1 (if (not $xOver) (+ 1 $d) $d)))
              ($newBestCScore (if $isAccepted (Pair.second $newBestInstPair) $bestCScore))
              ($newBestScore (if $isAccepted $newBestScore $bestScore))
              ($updatedNumInstances (+ $currentNInstances $newInstances))
              ($newTemp (- $Temp (* $coolRate $Temp)))
              ($newIterCount (- $maxIter 1))

                          
            )

            (simulated-annealing $newDeme $table ;; $table
                         $initCenter
                         ($maxDist $minXoverNeighbors $bestPossibleScore) ;; $constParams
                         ($newTemp $finalTemp $coolRate False $newIterCount) ;; $hyperParams
                         ((and $xOver (not $hasImproved)) $lastChance $newCenter $newBestCScore $newBestScore $updatedNumInstances $newDistance (+ 1 $i))) ;; $params
            ; (println! ("it worked"))
          )
          )
)