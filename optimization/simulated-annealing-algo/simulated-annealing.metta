; ;; Simulated Annealing
; ;; Params:
; ;;   deme: The current population of instances
; ;;   tTableBScorer: The truth table based bScore function
; ;;   initCenter: The initial instance to start the search from
; ;;   initial-temperature: Initial temperature for the algorithm
; ;;   cooling-rate: Rate at which the temperature decreases
; ;;   max-iterations: Maximum number of iterations to run the algorithm
; ;;   total-state: Total number of instances in the state space
; ;; Returns:
; ;;   instance: The best instance found
; ;;   deme: The final population of instances
; ;;   state: The state of the algorithm
; ;; Algorithm description:
; ;;   1. Checks if the temp <= final temp or max iterations <=0 is reached, if any of these is true break and return the best candidate and best score.
; ;;   2. If not, scores the current candidate and generates a new candidate by using crossover or sampling.
; ;;   3. Scores the new candidate and calculates the energy of the new candidate and current candidate.
; ;;   4. Calculates the acceptance probability using the energy.
; ;;   5. Generates a random float between 0 and 1.
; ;;   6. Calculate the acceptance probability by comparing the energies of the two candidates (low energy==better candidate), or by dividing the 
; ;;      difference of the two energies by the temperature and taking the exp of that value. The actual acceptance probability is the product of 
; ;;      the intensity and acceptance probability.
; ;;   7. If the actual acceptance probability is greater than the random float, accept the new candidate as the current candidate.
; ;;   8. Decrease the temperature by subtracting (cooling rate * temperature) from the current temperature. This is equivalent to Temp *= (1 - coolRate).
; ;;   9. Decrement the max iterations by 1.
; ;;   10. Repeat from step 1.   
; ;;

; ;;(: getEnergy (-> Cscore Number))
(= (getEnergy $score)
  (* -1 $score)
)

;;(: acceptanceProb (-> Number Number Number Number))
(= (acceptanceProb $energy1 $energy2 $Temp)
  (if (< $energy2 $energy1)
    1.0
    (exp (/ (- $energy1 $energy2) $Temp))
  )
)

;;(: simulated-annealing (-> Deme (TruthTableBScore $a) Instance (-> Deme (TruthTableBScore $a) Instance $Scorer (Instance Deme $state))))
(= (simulated-annealing $POASet $tTableBscorer $initCenter)
    (simulated-annealing $POASet $tTableBscorer $initCenter (mkParams applyComplexityBasedScore ())))

;;(: simulated-annealing (-> Deme (TruthTableBScore $a) Instance $Scorer (Instance Deme $state)))
(= (simulated-annealing $POASet $tTableBscorer $initCenter (mkParams $scorer $FsScorer))
  (case (mkParams $scorer)
    (((mkParams applyComplexityBasedScore)
        (let*
          (($disc (getDisk $POASet))
            (($cpxCoeff $size $iTable) (getTTableParams $tTableBscorer)))
          (simulated-annealing $POASet
                        ($disc $cpxCoeff $size $iTable)
                        $initCenter
                        (1 3 0) 
                        (20 0.01 0.1 True 5) ;; $hyperParams
                        ($FsScorer ()) ;; $FsParams
                        (False False $initCenter (worstCscore) (* -1 (pow-math 10 308)) 0 0 1)
                        estimateNeighborhood crossover 
                        sampleNewInstances transform)))
      ((mkParams applyMutualInformationBasedScore)
        (let*
          (
            ($_ (println! $tTableBscorer))
            (($rows $labels) (getITableParams $tTableBscorer))
            ($_ (println! (iTable: $tTableBscorer)))
            ($_ (println! (Rows: $rows)))
            ($_ (println! (Labels: $labels)))
          )
          (simulated-annealing $POASet
              ($labels $rows () ())
              $initCenter
              (3 3 1) 
              (20 0.01 0.1 True 5) ;; $hyperParams - keep original for FS mode since it works
              ($FsScorer (50.0 1.0 0.5 1.0 True)) ;; $FsParams
              (False False $initCenter 0 0 0 0 1) 
              estimateNeighborhoodFs crossoverFs 
              sampleNewInstancesFs transformFs
          ))))))

(= (simulated-annealing $POASet 
                         ($neighborhood $rowOCoeff $size $iTable)
                         $initCenter
                         ($maxDist $minXoverNeighbors $bestPossibleScore) ;; $constParams
                         ($Temp $finalTemp $coolRate $isInit $maxIter) ;; $hyperParams
                         ($FsScorerType $FsHyperParams) ;; Fs ScorerType and Fs hyperparams
                         ($alreadyXover $lastChance $prevCenter $bestSscore $bestScore $currentNInstances $d $i) ;; $params
                         $estimateFunction $crossoverFunction $samplingFunction $transformFunction
                         )
    (if (or (<= $Temp $finalTemp) (<= $maxIter 0))
          ($prevCenter $POASet ($prevCenter $bestSscore $bestScore $currentNInstances $d $i))
          (let*
            (
              ;; Estimate Neighborhood
              ($_ (println! (Iteration: $i , Temperature: $Temp)))
              ($_ (println! (maxIter: $maxIter)))
          
              ($_ (println! ""))
              ; ($_ (println! $hyper))
              ; ($_ (println! ($rows $labels)))
              ($totalNNeighbors ($estimateFunction $d $neighborhood))

              ($_ (println! (Estimated neighbors: $totalNNeighbors)))
              ($_ (println! ""))
              ($nNewNeighbors (min $totalNNeighbors 2))

              ($largeNbh (>= $totalNNeighbors $minXoverNeighbors))

              ($xOver (and (> $i 2) (and (not $alreadyXover) (or $largeNbh $lastChance))))
              ($_ (println! (Crossover: $xOver)))
              ;; Generate a new instance using crossover
              
              (((mkDeme $rep $updatedInstSet $id) $newInstances) (case ($xOver $size)
                                                                   (
                                                                ((True ()) (let ($updatedInstSet $newInstances) (eval ($crossoverFunction $currentNInstances $nNewNeighbors $prevCenter $POASet))
                                                                              ((mkDeme () $updatedInstSet ()) $newInstances)))
                                                                ((True $notEmpty)  (eval ($crossoverFunction $currentNInstances $nNewNeighbors $prevCenter $POASet)))
                                                                ((False ()) (let ($updatedInstSet $newInstances) (eval ($samplingFunction $totalNNeighbors $nNewNeighbors $prevCenter (mkITable $rowOCoeff $neighborhood) $POASet $d))
                                                                              ((mkDeme () $updatedInstSet ()) $newInstances)))
                                                                ((False $notEmpty) 
                                                                        (let $result (eval ($samplingFunction $totalNNeighbors $nNewNeighbors $prevCenter $POASet $d))
                                                                        (trace! ("Result: " $result) $result)))
                                                              )
                                                                    ))
              ($_ (println! (Newinstances: $updatedInstSet)))
              ($_ (println! ""))
              
              ($scorerType (if (== () $FsScorerType) mi $FsScorerType))
              (($miConfi $prePenalty $preMinActivation $preMaxActivation $prePositive) (if (== () $FsHyperParams) (() () () () ()) $FsHyperParams))
              ;; Score the new instance
              ((mkSInstSet $scoredInstances) (if (or (== $rep ()) (== $id ())) 
                                                (eval ($transformFunction $updatedInstSet 
                                                                  (mkITable $rowOCoeff $neighborhood)
                                                                  $miConfi $prePenalty
                                                                  $preMinActivation $preMaxActivation
                                                                  $prePositive $scorerType
                                                                  ))
                                                (eval ($transformFunction $updatedInstSet $rep $iTable $rowOCoeff))))

              ($updatedPOASet (if (or (== $rep ()) (== $id ())) 
                          (mkSInstSet $scoredInstances) 
                          (mkDeme $rep (mkSInstSet $scoredInstances) $id)))
        

              ($_ (println! (Scored instances: $scoredInstances)))
              ($_ (println! ""))

              ((mkSInst $newBestInstPair) (List.foldl ((curry2 returnBest) <) (mkSInst (mkPair $prevCenter  $bestSscore)) $scoredInstances))
              ($newBestScore (if (or (== $rep ()) (== $id ())) 
                                (Pair.second $newBestInstPair)
                                (eval (getPenScore (Pair.second $newBestInstPair))))) ;; This could be the original best candidate or a new one.
              ($hasImproved (> $newBestScore (+ $bestScore 0.5))) ;; Hard coded the score_improved function for now. This is automated in the C++ version.
        
              ($_ (println! (Best instance: $newBestInstPair)))
              ($_ (println! (New best score: $newBestScore)))
              ($_ (println! (Has Improved: $hasImproved)))
              ($_ (println! ""))

              ; ;; Calculate the energy of the current and new instance, and the acceptanceProb
              ($pScore (if (== $rep ()) $bestSscore (getPenScore $bestSscore)))
              ($energy (getEnergy $pScore))
              ($newEnergy (getEnergy $newBestScore))
              ($acceptanceProb (acceptanceProb $energy $newEnergy $Temp))
              ($randomFloat (rand-random)) ;; using random.random instead of numpy.random.rand
              ; ;; Actual acceptance probabitlity which is the product of the intensity and acceptance probability.
              ($actualAcceptanceProb (* $acceptanceProb 0.85))

              ($_ (println! (Energy: $energy)))
              ($_ (println! (New energy: $newEnergy)))
              ($_ (println! (Acceptance probability: $acceptanceProb)))
              ($_ (println! (Random float: $randomFloat)))
              ($_ (println! (Actual acceptance probability: $actualAcceptanceProb)))
              ($_ (println! ""))

              ; ;; Check for acceptance
              ($isAccepted (> $actualAcceptanceProb $randomFloat))
              
              ($_ (println! (Is accepted: $isAccepted)))
              ($_ (println! (New instances: $newInstances)))
              ($_ (println! ""))
              
              ($newPOASet (if $isAccepted $updatedPOASet $POASet))
              ($newCenter (if $isAccepted (Pair.first $newBestInstPair) $prevCenter))
              ($newDistance (if $hasImproved 1 (if (not $xOver) (+ 1 $d) $d)))
              ($newBestSscore (if $isAccepted (Pair.second $newBestInstPair) $bestSscore))
              ($newBestScore (if $isAccepted $newBestScore $bestScore))
              ($updatedNumInstances (+ $currentNInstances $newInstances))
              ($newTemp (- $Temp (* $coolRate $Temp)))
              ($newIterCount (- $maxIter 1))
              

              ($_ (cut))

                          
            )
            (simulated-annealing $newPOASet 
                                ($neighborhood $rowOCoeff $size $iTable)
                                $initCenter
                                ($maxDist $minXoverNeighbors $bestPossibleScore) ;; $constParams
                                ($newTemp $finalTemp $coolRate False $newIterCount) ;; $hyperParams
                                ($FsScorerType $FsHyperParams) ;; Fs ScorerType and Fs hyperparams
                                ((and $xOver (not $hasImproved)) $lastChance $newCenter $newBestSscore $newBestScore $updatedNumInstances $newDistance (+ 1 $i)) ;; $params
                                $estimateFunction $crossoverFunction $samplingFunction $transformFunction)
          
          )
          )
)