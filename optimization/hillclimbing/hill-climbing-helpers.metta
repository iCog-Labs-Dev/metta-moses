;; Verbatim port of the Infromation theoretic bits function from c++
;; Params: $knobMap: A map of knobs with their multiplicities
;; Returns: Sum of the multiplicities of the knobs in the map
; (: informationTheoreticBits (-> (MultiMap (DiscSpec $knob)) Number))
(= (informationTheoreticBits $knobMap)
    (chain (MultiMap.values $knobMap) $knobs
      (chain (List.map getKnobMultip $knobs) $multips
        (chain (List.foldr add (mkMultip 0) $multips) $res
          (let (mkMultip $val) $res $val)))))

;; feature selection version of the informationTheoreticBits function
;; In the case of feature selection, the information theoretic bits is simply the number of features we have
; (: informationTheoreticBitsFs (-> (List Symbol) Number))
(= (informationTheoreticBitsFs $labels)
   (- (List.length $labels) 1))

;; Verbatim port of the Estimate neighborhood function from c++
;; Params: $distance: The hamming distance from the current knob
;;         $knobMap: A map of knobs with their multiplicities
;; Returns: 2 * Sum of the multiplicities of the knobs in the map
; (: estimateNeighborhood (-> Number (MultiMap (DiscSpec $knob)) Number))
(= (estimateNeighborhood $distance $knobMap)
   (if (== $distance 0)
       1
       (let $nnEstimate (informationTheoreticBits $knobMap) (* 2 $nnEstimate)))) ;; INFO: Could use a safe binomial coefficient here if the estiamte starts becoming very large.

;; similar to the above 'estimateNeighborhood' but this one uses the informationTheoreticBitsFs which is for feature selection
; (: estimateNeighborhoodFs (-> Number (List Symbol) Number))
(= (estimateNeighborhoodFs $distance $labels)
   (if (== $distance 0)
       1
       (let $nnEstimate (informationTheoreticBitsFs $labels) (* 2 $nnEstimate)))) ;; INFO: Could use a safe binomial coefficient here if the estiamte starts becoming very large.

;; Return an estimate of the number of new instances to search
(= (nNewInstances $distance $maxEvals $currentEvals $totalNeighbors)
   (if (== $distance 0)
       1
       (let*
           (
             ;; TODO: Most of the clamping logic here depens on the usage of number of evals and max number of evals. So best to do it after those are integrated into the system. For now we will be returning the total neighborhood clamped to the max_evals only.
             ;; ($_ (println! (Inside newInstances: $distance $maxEvals $currentEvals $totalNeighbors)))
             ($hc_params_fraction_of_nn 2.0) ;; Binomial coefficient has a combinatoric explosion to the power distance.
                                            ;; So throttle back by fraction raised to power dist.
             ($numberOfNewInstaces (int (* $totalNeighbors (pow-math $hc_params_fraction_of_nn $distance))))
             ($nLeft (- $maxEvals $currentEvals))
             ($minDemeSize 50) ;; This is also hardcoded in open cog classic so following the same number here. Classic is set to 100.
           )
           (if (< $numberOfNewInstaces $minDemeSize)
               (min $nLeft $minDemeSize)
               (if (< $nLeft $numberOfNewInstaces)
                   $nLeft
                   $numberOfNewInstaces)))))

;; Counts the number of instances at a specific distance from a given instance.
;; Params:
;;   $kbMap: Contains DiscKnobMap and DiscMap
;;   $inst: Reference instance
;;   $dist: Distance to measure
;;   $startIdx: Starting index
;;   $maxCount: Maximum count to return (e.g., 20).
;; Returns:
;;   Count of instances at distance $dist from $inst

; a helper function to the countNeighborhood method
;; (: countNeighborhoodFromIdx (-> KnobMap Instance Number Number Number Number))
(= (countNeighborhoodFromIdx (mkKbMap $dscKbMp (mkDscMp $dscMp)) $inst $dist $startIdx $maxCount)
(if (== $dist 0) 
    1 
    (if (>= $startIdx (MultiMap.length $dscMp)) 
        0
        (let $updatedNumInstances (countNeighborhoodFromIdx (mkKbMap $dscKbMp (mkDscMp $dscMp)) $inst $dist (+ $startIdx 1) $maxCount)
          (if  (> $updatedNumInstances $maxCount) 
               $updatedNumInstances
               (let*
                 (
                    (($kbSpec $knob) (MultiMap.getByIdx $startIdx $dscMp))
                    ((mkMultip $multip) (getKnobMultip $knob))
                    ($uUpdatedNumInstances (+ $updatedNumInstances (* (- $multip 1) (countNeighborhoodFromIdx (mkKbMap $dscKbMp (mkDscMp $dscMp)) $inst (- $dist 1) (+ $startIdx 1) $maxCount))))
                 )
                 $uUpdatedNumInstances))))))

; countNeighborhood
;; (: countNeighborhood (-> KnobMap Instance Number Number Number))
(= (countNeighborhood $kbMap $inst $dist $maxCount)
(countNeighborhoodFromIdx $kbMap $inst $dist 0 $maxCount))

;; factorial
; (: factorial (-> Number Number))
(= (factorial $n)
   (if (<= $n 1) 1 (* $n (factorial (- $n 1)))))

;; binomial coefficient
; (: binomial (-> Number Number Number))
(= (binomial $n $k)
   (if (or (< $k 0) (> $k $n))
       0
       (/ (factorial $n) (* (factorial $k) (factorial (- $n $k))))))

;; Feature selection version of countNeighborhoodFromIdx
;; uses the BInomial coefficient to count the number of instances at a specific distance from a given instance.
; (: countNeighborhoodFromIdxFs (-> Instance Number Number Number Number))
(= (countNeighborhoodFromIdxFs (mkInst $instance) $dist $startIdx $maxCount)
(if (== $dist 0) 1 
(let*
  (
    ($n (- (List.length $instance) $startIdx))
    ($count (binomial $n $dist))
  )
  (if (> $dist $n) 0 (if (> $count $maxCount) $maxCount $count))
))
)

;; Feature selection version of countNeighborhood
;; uses the countNeighborhoodFromIdxFs
; (: countNeighborhoodFs (-> Instance Number Number Number))
(= (countNeighborhoodFs $instance $dist $maxCount)
   (countNeighborhoodFromIdxFs $instance $dist 0 $maxCount))

;; Crossover function.
;; (: crossTopOne (-> Deme Number Number Number Instance Deme))
; (: crossover (-> Number Number Instance Deme (Deme Number)))
(= (crossover $demeSize $nNewInstances $sampleStart $sampleSize $centerInst $deme)
   ;; (trace! (Running crossover to make: (min $nNewInstances 120) instances)
   ;; INFO: The 120 is crossover_pop_size parameter that should come from hillClimbing
           ((crossTopOne $deme (min $nNewInstances 120) $sampleStart $sampleSize $centerInst) (if (< (- $sampleSize 1) $nNewInstances) (- $sampleSize 1) $nNewInstances))
   ;; )
   ) ;; WARN: The $nNewInstances might not be the actual number of instances created.

;; crossover for feature selection
; (: crossoverFs (-> Number Number Instance (InstanceSet $a) ((InstanceSet $a) Number)))
(= (crossoverFs $size $nNewInstances $sampleStart $sampleSize $centerInst $scoredInstSet)
   ;; (trace! (Running cross over for $centerInst)
           ((crossTopOneFs $scoredInstSet $nNewInstances $sampleStart $sampleSize $centerInst) (if (< (- $sampleSize 1) $nNewInstances) (- $sampleSize 1) $nNewInstances))
           ;; )
   ) ;; WARN: The $nNewInstances might not be the actual number of instances created.

;; (: returnBest (-> (ScoredInstance Number) (ScoredInstance Number) (ScoredInstance Number)))
(= (returnBest (mkSInst $inst1) (mkSInst $inst2)) (returnBest < (mkSInst $inst1) (mkSInst $inst2)) )

;; (: returnBest (-> (-> $score $score Bool) (ScoredInstance $score) (ScoredInstance $score) (ScoredInstance $score)))
(= (returnBest $lessFn (mkSInst $inst1) (mkSInst $inst2))
   (if (apply $lessFn (Pair.second $inst1) (Pair.second $inst2))
       (mkSInst $inst2)
       (mkSInst $inst1)))


(= (getDisk (mkDeme (mkRep (mkKbMap (mkDscKbMp $idxMp) (mkDscMp $disc)) $tree) $instSet $id))
    $disc
)
(= (getTTableParams (mkTruthTableBScore $cpxCoeff $size $iTable))
    ($cpxCoeff $size $iTable)
)
(= (getITableParams (mkITable $rows $labels))
    ($rows $labels)
)

;; Hillclimbing implementation
;;
;; Algorihtm:
;; Takes the maximum distance and best possible scores.
;; Takes the number of iteration under consideration.
;; Tracks the best score found so far as well.
;; Start with center instance and previous center as the same instance
;; Iterates until a certain critera is met.
;;    Criteria: If either the best possible score is found or the maximum distance has reached.
;;    Steps:
;;      Estimate neighborhood
;;      Number of new instances
;;      Cross over if iteration is > 1 and (either minimum in a deme is greater than 3 or last chance) and not already crossed over. Set the already cross over as true.
;;      Sample new instances if not cross over
;;      Change the prevCenter with centerInstance
;;      Score every instance in the deme using the scorer
;;      Get the best instance in the deme and make sure it is greater than the best instance so far.
;;      Check if the score has improve, if so update the center instance by the best instance found. Set the distance to 1. and change already xover to false.
;;      If not, check if no crossover was made and if so increase the distance by 1.
;;      If it is the first time through the loop, we should not exit but we should set the distance to 1 and retry the iteration.

;; (: hillClimbing (-> Deme (TruthTableBScore $a) Instance (-> Deme (TruthTableBScore $a) Instance $Scorer (Instance Deme $state))))
(= (hillClimbing $POASet $tTableBscorer $centerInst) 
    (hillClimbing $POASet $tTableBscorer $centerInst (mkParams applyComplexityBasedScore ())))
    
;; (: hillClimbing (-> Deme (TruthTableBScore $a) Instance $Scorer (Instance Deme $state)))
;; $FsScorer should be passed using a `mkScorer` constructor other wise it will cause an error in PeTTa.
(= (hillClimbing $POASet $tTableBscorer $centerInst (mkParams $scorer $FsScorer))
  (case (mkParams $scorer)
    (((mkParams applyComplexityBasedScore)
        (let*
          (
            ($disc (getDisk $POASet))
            (($cpxCoeff $size $iTable) (getTTableParams $tTableBscorer))
          )
          (hillClimbing ((min 4 (List.length (second $centerInst))) 400 0) (False False False $centerInst 0 0 (worstCscore) (* -1 (pow-math 10 308)) 0 0 1)
                        $POASet
                        ($disc $cpxCoeff $size $iTable)
                        $centerInst
                        ()
                        estimateNeighborhood crossover
                        sampleNewInstances transform)))
      ((mkParams applyMutualInformationBasedScore)
        (let*
          (
            ;; ($_ (println! $tTableBscorer))
            (($rows $labels) (getITableParams $tTableBscorer))
            ;; ($_ (println! (iTable: $tTableBscorer)))
            ;; ($_ (println! (Rows: $rows)))
            ;; ($_ (println! (Labels: $labels)))
            ($FsScorerType (if (== $FsScorer ()) mi $FsScorer))
          )
          (hillClimbing ((min 3 (List.length (second $centerInst))) 5 0) (False False False $centerInst 0 0 0 0 0 0 1) 
              $POASet 
              ($labels $rows () ())
              $centerInst
              (50.0 1.0 0.5 1.0 True $FsScorerType)
              estimateNeighborhoodFs crossoverFs 
              sampleNewInstancesFs transformFs
          ))))))



(= (hillClimbing ($maxDist $minXoverNeighbors $bestPossibleScore) ;; Constant parameters
                 ($alreadyXover $lastChance $__ $prevCenter $prevStart $prevSize $bestSscore $bestScore $currentNInstances $d $i)
                 $POASet
                 ($neighborhood $rowOCoeff $size $iTable)
                 $centerInst
                 $hyperparamsfs
                 $estimateFunction $crossoverFunction $samplingFunction $transformFunction) ;; Helper functions
   (let*
      (
        ($_ (println! ""))
        ($_ (println! (Iteration $i running)))

        ($totalNNeighbors ($estimateFunction $d $neighborhood))

        ;; ($_ (println! (Estimated neighbors: $totalNNeighbors)))
        ;; ($_ (println! ""))

        ($maxEvals 1000)
        ($nNewNeighbors (nNewInstances $d $maxEvals $currentNInstances $totalNNeighbors)) ;; TODO: MaxEvals is hardcoded here, but should be changed. This is set to 20K by default in OpenCog Classic.

        ($largeNbh (>= $totalNNeighbors $minXoverNeighbors))
        ($xOver (and (> $i 2) (and (not $alreadyXover) (or $largeNbh $lastChance)))) ;; INFO: Has to be greater than 2 minimum.
        ($_ (println! (Crossover: $xOver)))
        ($_ (println! (CenterInst: (List.listToExpr (second $centerInst)) )))
        ;; ($_ (println! (size: $size)))
        ;; ($_ (println! ($totalNNeighbors : $nNewNeighbors : $prevCenter : $POASet : $d)))
        ;; ($_ (println! ($totalNNeighbors : $nNewNeighbors : $d)))
        ( 
          ; $newPOA
          ((mkDeme $rep $updatedInstSet $id) $newInstances)
                                                            (case ($xOver $size)
                                                              (
                                                                ((True ()) (let ($updatedInstSet $newInstances) ($crossoverFunction $currentNInstances $nNewNeighbors $prevStart $prevSize $prevCenter $POASet)
                                                                              ((mkDeme () $updatedInstSet ()) $newInstances)))
                                                                ((True $notEmpty)  ($crossoverFunction $currentNInstances $nNewNeighbors $prevStart $prevSize $centerInst $POASet))
                                                                ((False ()) (let ($updatedInstSet $newInstances) ($samplingFunction $totalNNeighbors $nNewNeighbors $centerInst (mkITable $rowOCoeff $neighborhood) $POASet $d)
                                                                              ((mkDeme () $updatedInstSet ()) $newInstances)))
                                                                ((False $notEmpty)
                                                                        (let $result ($samplingFunction $totalNNeighbors $nNewNeighbors $centerInst $POASet $d)
                                                                        ;; (trace! ("Result: " $result)
                                                                                $result
                                                                        ;; )
                                                                        ))
                                                              )
                                                          ))
        ; ($_ (println! (New POASet: $newPOA)))
        ; (((mkDeme $rep $upInstSet $id) $newInstances) $newPOA)
        ; ($_ (println! (New rep: $rep)))
        ($_ (println! (New Inst: $newInstances at Distance: $d)))
        ;; ($exprList (let (mkSInstSet $list) $updatedInstSet (List.listToExpr $list)))
        ;; ($bmr (map-atom $exprList $inst (let (mkSInst $x) $inst (println! (Inst: (List.listToExpr (second (Pair.first $x))) Tree: (preOrder (getCandidate $rep (Pair.first $x))))))))
        ;; ($_ (println! ""))
        ;; ($_ (println! (Newinstances: $updatedInstSet)))
        ;; ($_ (println! ""))
        ;; deconstruct the hyper params for fs function
        (($miConfi $prePenalty $preMinActivation $preMaxActivation $prePositive $scorerType) (if (== () $hyperparamsfs) (() () () () () ()) $hyperparamsfs))

        ((mkSInstSet $scoredInstances) (if (or (== $rep ()) (== $id ())) 
                                          ($transformFunction 
                                                              $updatedInstSet
                                                              (mkITable $rowOCoeff $neighborhood)
                                                              $miConfi $prePenalty
                                                              $preMinActivation $preMaxActivation
                                                              $prePositive $scorerType)
                                          ($transformFunction $updatedInstSet $rep $iTable $rowOCoeff)))

        ($updatedDeme (if (or (== $rep ()) (== $id ())) 
                          (mkSInstSet $scoredInstances) 
                          (mkDeme $rep (mkSInstSet $scoredInstances) $id)))
        
        ;; ($sExprList (List.listToExpr $scoredInstances))
        ;; ($amr (map-atom $sExprList $inst (let (mkSInst $x) $inst (println! (Inst: (List.listToExpr (second (Pair.first $x))) Tree: (preOrder (getCandidate $rep (Pair.first $x))) Score: (getPenScore (Pair.second $x)))))))
        ;; ($_ (println! ""))
        ;; ($_ (println! (Scored instances: $scoredInstances)))
        ;; ($_ (println! (Scored instances....)))
        ;; ($_ (println! ""))

        ((mkSInst $newBestInstPair) (eval (List.foldl ((eval (curry2 returnBest)) <) (mkSInst (mkPair $centerInst $bestSscore)) $scoredInstances)))
        ($newBestScore (if (or (== $rep ()) (== $id ())) 
                          (Pair.second $newBestInstPair)
                          (getPenScore (Pair.second $newBestInstPair)))) ;; This could be the original best candidate or a new one.
        ($hasImproved (> $newBestScore (+ $bestScore 0.5))) ;; Hard coded the score_improved function for now. This is automated in the C++ version.
        
        ;; ($_ (println! (Best instance: (Pair.first $newBestInstPair))))
        ($_ (println! (Best candidate: (preOrder (getCandidate $rep (Pair.first $newBestInstPair))))))
        ($_ (println! (New best score: $newBestScore)))
        ;; ($_ (println! ""))

        ($nextCenterInst (if $hasImproved (Pair.first $newBestInstPair) $centerInst))
        ($nextDistance (if $hasImproved 1 (if (not $xOver) (+ 1 $d) $d)))
        
        ;; ($_ (println! (NextDistance: $nextDistance)))

        (($newCenter $newDeme ($newXover $newLastChance $newHasImproved $newPrevCenter $newPrevStart $newPrevSize $newBestSscore $nextNewBestScore $newCurrentNInstance $newDistance $newI))
                              (if (and (== $totalNNeighbors 1) (== $nextDistance 1))
                                  (hillClimbing ($maxDist $minXoverNeighbors $bestPossibleScore)
                                                ((and $xOver (not $hasImproved)) $lastChance $hasImproved $centerInst $prevStart $prevSize (Pair.second $newBestInstPair) $newBestScore (+ $currentNInstances $newInstances) $nextDistance (+ 1 $i)) ;; Updated state
                                                $updatedDeme
                                                ($neighborhood $rowOCoeff $size $iTable)
                                                $nextCenterInst
                                                $hyperparamsfs
                                                $estimateFunction $crossoverFunction $samplingFunction $transformFunction)
                                  ($nextCenterInst $updatedDeme ((and $xOver (not $hasImproved)) $lastChance $hasImproved $centerInst $currentNInstances $newInstances (Pair.second $newBestInstPair) $newBestScore (+ $currentNInstances $newInstances) $nextDistance $i))))
        
        ($scoreToCompareBelow (if (or (== $rep ()) (== $id ())) $newBestSscore (getScore $newBestSscore)))
        ;; ($_ (println! (Found newBestSscore After (+ 1 $i) iteration is: $newBestSscore $scoreToCompareBelow)))
        ;; ($_ (println! ""))
        ($_ (cut))
    )
    (if (<= (- $maxEvals $newCurrentNInstance) 0)
        (trace! (Terminating because of maxEval ending) ($newCenter $newDeme ($newXover $newLastChance $newHasImproved $newPrevCenter $newPrevStart $newPrevSize $newBestSscore $nextNewBestScore $newCurrentNInstance $newDistance $newI)))
        (if (<= $bestPossibleScore $scoreToCompareBelow)
                  (trace! (Terminating because of best possible score: $bestPossibleScore found $scoreToCompareBelow)
            ($newCenter $newDeme ($newXover $newLastChance $newHasImproved $newPrevCenter $newPrevStart $newPrevSize $newBestSscore $nextNewBestScore $newCurrentNInstance $newDistance $newI))
                  )
            (let ($finalCenter $finalDeme ($finalXover $finalLastChance $finalHasImproved $finalPrevCenter $finalPrevStart $finalPrevSize $finalBestCscore $finalNewBestScore $finalCurrentNInstance $finalDistance $finalI))
              ;; TODO: The C++ version checks the hyper parameter hc_params.crossover before getting here.
              ;; TODO: The C++ version checks for the hc_params.widen_search too. For now, we're assuming it is always true. 
              ;;       Hence the omission of the distance check from the C++ Hence the omission of the distance check from the C++
              (if (and (and (not $newHasImproved) (not $newLastChance)) (not $newXover))
                  ;; If we just did the nearest neighbors and found no improvement,
                  ;;  then try again one last time, we may get lucky.
                  (hillClimbing ($maxDist $minXoverNeighbors $bestPossibleScore)
                                ($newXover True $newHasImproved $newPrevCenter $newPrevStart $newPrevSize $newBestSscore $nextNewBestScore $newCurrentNInstance $newDistance (+ 1 $newI)) ;; Updated state
                                $newDeme
                                ($neighborhood $rowOCoeff $size $iTable)
                                $newCenter
                                $hyperparamsfs
                                $estimateFunction $crossoverFunction $samplingFunction $transformFunction)
                  ;; (trace! (Continue to next iteration because of no more last chance)
                          ($newCenter $newDeme ($newXover $newLastChance $newHasImproved $newPrevCenter $newPrevStart $newPrevSize $newBestSscore $nextNewBestScore $newCurrentNInstance $newDistance $newI))
                  ;; )
                  )
  
              (if (< $maxDist $finalDistance)
                  (trace! (Terminating because of maximum distance reached)
                  ($finalCenter $finalDeme ($finalXover False $finalHasImproved $finalPrevCenter $finalPrevStart $finalPrevSize $finalBestCscore $finalNewBestScore $finalCurrentNInstance $finalDistance $finalI))
                  ) ;; I don't know why I didn't do this earlier but incrementing is needed here.
                  (if (not $finalHasImproved)
                      (trace! (Terminating because score hasn't improved) ($finalCenter $finalDeme ($finalXover False $finalHasImproved $finalPrevCenter $finalPrevStart $finalPrevSize $finalBestCscore $finalNewBestScore $finalCurrentNInstance $finalDistance $finalI)))
                      (hillClimbing ($maxDist $minXoverNeighbors $bestPossibleScore)
                                ($finalXover False $finalHasImproved $finalPrevCenter $finalPrevStart $finalPrevSize $finalBestCscore $finalNewBestScore $finalCurrentNInstance $finalDistance (+ 1 $finalI)) ;; Updated state
                                $finalDeme
                                ($neighborhood $rowOCoeff $size $iTable)
                                $finalCenter
                                $hyperparamsfs
                                $estimateFunction $crossoverFunction $samplingFunction $transformFunction)
                    )
                  )
            )
            )
    
                    )

     
    )          
)

