;; Verbatim port of the Infromation theoretic bits function from c++
;; Params: $knobMap: A map of knobs with their multiplicities
;; Returns: Sum of the multiplicities of the knobs in the map
(: informationTheoreticBits (-> (MultiMap (DiscSpec $knob)) Number))
(= (informationTheoreticBits $knobMap)
    (chain (MultiMap.values $knobMap) $knobs
      (chain (List.map getKnobMultip $knobs) $multips
        (chain (List.foldr add (mkMultip 0) $multips) $res
          (let (mkMultip $val) $res $val)))))

;; Verbatim port of the Estimate neighborhood function from c++
;; Params: $distance: The hamming distance from the current knob
;;         $knobMap: A map of knobs with their multiplicities
;; Returns: 2 * Sum of the multiplicities of the knobs in the map
(: estimateNeighborhood (-> Number (MultiMap (DiscSpec $knob)) Number))
(= (estimateNeighborhood $distance $knobMap)
   (if (== $distance 0)
       1
       (let $nnEstimate (informationTheoreticBits $knobMap) (* 2 $nnEstimate)))) ;; INFO: Could use a safe binomial coefficient here if the estiamte starts becoming very large.

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
(: countNeighborhoodFromIdx (-> KnobMap Instance Number Number Number Number))
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
(: countNeighborhood (-> KnobMap Instance Number Number Number))
(= (countNeighborhood $kbMap $inst $dist $maxCount)
(countNeighborhoodFromIdx $kbMap $inst $dist 0 $maxCount))

;; Crossover function.
;; (: crossTopOne (-> Deme Number Number Number Instance Deme))
(: crossover (-> Number Number Instance Deme (Deme Number)))
(= (crossover $demeSize $nNewInstances $centerInst $deme) (trace! (Running cross over for $centerInst) ((crossTopOne $deme $nNewInstances 0 $demeSize $centerInst) $nNewInstances))) ;; WARN: The $nNewInstances might not be the actual number of instances created.

(: returnBest (-> (ScoredInstance Number) (ScoredInstance Number) (ScoredInstance Number)))
(= (returnBest (mkSInst $inst1) (mkSInst $inst2)) (returnBest < (mkSInst $inst1) (mkSInst $inst2)) )

(: returnBest (-> (-> $score $score Bool) (ScoredInstance $score) (ScoredInstance $score) (ScoredInstance $score)))
(= (returnBest $lessFn (mkSInst $inst1) (mkSInst $inst2))
   (if ($lessFn (Pair.second $inst1) (Pair.second $inst2))
       (mkSInst $inst2)
       (mkSInst $inst1)))

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
(: hillClimbing (-> Deme (TruthTableBScore $a) Instance (Instance Deme $state)))
(= (hillClimbing $deme $tTableBscorer $centerInst) (hillClimbing (1 3 0) (False False False $centerInst (worstCscore) (* -1 (pow-math 10 308)) 0 0 1) $deme $tTableBscorer $centerInst))

(: hillClimbing (-> $params $state Deme (TruthTableBScore $a) Instance (Instance Deme $state)))
(= (hillClimbing ($maxDist $minXoverNeighbors $bestPossibleScore) ;; Constant parameters
                 ($alreadyXover $lastChance $_ $prevCenter $bestCscore $bestScore $currentNInstances $d $i) ;; Mutable states
                 (mkDeme (mkRep (mkKbMap (mkDscKbMp $idxMp) (mkDscMp $disc)) $tree) $instSet $id) ;; Deme
                 (mkTruthTableBScore $cpxCoeff $size $iTable) ;; Input table scorer
                 $centerInst) ;; Center instance or init instance
   (let*
      (
        (() (println! (Iteration $i running)))
        (() (println! ""))

        ($deme (mkDeme (mkRep (mkKbMap (mkDscKbMp $idxMp) (mkDscMp $disc)) $tree) $instSet $id))
        ($totalNNeighbors (estimateNeighborhood $d $disc))

        (() (println! (Estimated neighbors: $totalNNeighbors)))
        (() (println! ""))

        ($nNewNeighbors (min $totalNNeighbors 2))

        ;; INFO: Since our neighborhood size is chosen to be small,
        ;; we don't need to limit the new neighbors with another function like the C++ (At least for now).

        ($largeNbh (>= $totalNNeighbors $minXoverNeighbors))

        ;; Cross over if iteration is > 1 and either neighborhood is large or last chance. Also if not already crossed over.
        ($xOver (and (> $i 2) (and (not $alreadyXover) (or $largeNbh $lastChance)))) ;; INFO: Has to be greater than 2 minimum.
        (() (println! (Crossover: $xOver)))
        (((mkDeme $rep $updatedInstSet $id) $newInstances) (if $xOver
                                                               (crossover $currentNInstances $nNewNeighbors $prevCenter $deme)
                                                               (sampleNewInstances $totalNNeighbors $nNewNeighbors $prevCenter $deme $d)))
        (() (println! (Newinstances: $updatedInstSet)))
        (() (println! ""))

        ;; Score all demes in the instance set.
        ((mkSInstSet $scoredInstances) (transform $updatedInstSet $rep $iTable $cpxCoeff))

        ($updatedDeme (mkDeme $rep (mkSInstSet $scoredInstances) $id))

        (() (println! (Scored instances: $scoredInstances)))
        (() (println! ""))

        ;; Check if there's an instance in the deme
        ;;  better than the best candidate so far.
        ((mkSInst $newBestInstPair) (List.foldl ((curry2 returnBest) cScore<) (mkSInst (mkPair $centerInst $bestCscore)) $scoredInstances))

        ($newBestScore (getPenScore (Pair.second $newBestInstPair))) ;; This could be the original best candidate or a new one.
        ($hasImproved (> $newBestScore (+ $bestScore 0.5))) ;; Hard coded the score_improved function for now. This is automated in the C++ version.

        (() (println! (Best instance: $newBestInstPair)))
        (() (println! (New best score: $newBestScore)))
        (() (println! ""))

        ($nextCenterInst (if $hasImproved (Pair.first $newBestInstPair) $centerInst))
        ($nextDistance (if $hasImproved 1 (if (not $xOver) (+ 1 $d) $d)))

        (() (println! (NextDistance: $nextDistance)))

        ;; If this is the first time throught the iteration,
        ;;  then distance was zero, there was only one instance
        ;;  at dist=0, and we just scored it. Be sure to go
        ;;  around and do at leat the distance == 1 nearest-neighbor
        ;;  exploration. Note that it is possible that to have only 1
        ;;  neighbor with a distance greater than 0 (when the distance
        ;;  has reached the deme dimension), which is why we check that
        ;;  distance == 1 as well.
        (($newCenter $newDeme ($newXover $newLastChance $newHasImproved $newPrevCenter $newBestCscore $nextNewBestScore $newCurrentNInstance $newDistance $newI))
                              (if (and (== $totalNNeighbors 1) (== $nextDistance 1))
                                  (hillClimbing ($maxDist $minXoverNeighbors $bestPossibleScore)
                                                ((and $xOver (not $hasImproved)) $lastChance $hasImproved $centerInst (Pair.second $newBestInstPair) $newBestScore (+ $currentNInstances $newInstances) $nextDistance (+ 1 $i)) ;; Updated state
                                                $updatedDeme
                                                (mkTruthTableBScore $cpxCoeff $size $iTable)
                                                $nextCenterInst)
                                  ($nextCenterInst $updatedDeme ((and $xOver (not $hasImproved)) $lastChance $hasImproved $centerInst (Pair.second $newBestInstPair) $newBestScore (+ $currentNInstances $newInstances) $nextDistance $i))))

        ($scoreToCompareBelow (getScore $newBestCscore))
        (() (println! (Found NewBestCscore After (+ 1 $i) iteration is: $newBestCscore $scoreToCompareBelow)))
        (() (println! ""))
        )

      (if (<= $bestPossibleScore $scoreToCompareBelow)
          (trace! (Terminating because of best possible score: $bestPossibleScore found $scoreToCompareBelow) ($newCenter $newDeme ($newXover $newLastChance $newHasImproved $newPrevCenter $newBestCscore $nextNewBestScore $newCurrentNInstance $newDistance $newI)))
          (let ($finalCenter $finalDeme ($finalXover $finalLastChance $finalHasImproved $finalPrevCenter $finalBestCscore $finalNewBestScore $finalCurrentNInstance $finalDistance $finalI))
            ;; TODO: The C++ version checks the hyper parameter hc_params.crossover before getting here.
            ;; TODO: The C++ version checks for the hc_params.widen_search too. For now, we're assuming it is always true. 
            ;;       Hence the omission of the distance check from the C++ Hence the omission of the distance check from the C++
            (if (and (and (not $newHasImproved) (not $newLastChance)) (not $newXover))
                ;; If we just did the nearest neighbors and found no improvement,
                ;;  then try again one last time, we may get lucky.
                (hillClimbing ($maxDist $minXoverNeighbors $bestPossibleScore)
                              ($newXover True $newHasImproved $newPrevCenter $newBestCscore $nextNewBestScore $newCurrentNInstance $newDistance (+ 1 $newI)) ;; Updated state
                              $newDeme
                              (mkTruthTableBScore $cpxCoeff $size $iTable)
                              $newCenter)
                (trace! (Continue to next iteration because of no more last chance) ($newCenter $newDeme ($newXover $newLastChance $newHasImproved $newPrevCenter $newBestCscore $nextNewBestScore $newCurrentNInstance $newDistance $newI))) )

            (if (< $maxDist $finalDistance)
                (trace! (Terminating because of maximum distance reached) ($finalCenter $finalDeme ($finalXover False $hasImproved $finalPrevCenter $finalBestCscore $finalNewBestScore $finalCurrentNInstance $finalDistance $finalI))) ;; I don't know why I didn't do this earlier but incrementing is needed here.
                (hillClimbing ($maxDist $minXoverNeighbors $bestPossibleScore)
                              ($finalXover False $hasImproved $finalPrevCenter $finalBestCscore $finalNewBestScore $finalCurrentNInstance $finalDistance (+ 1 $finalI)) ;; Updated state
                              $finalDeme
                              (mkTruthTableBScore $cpxCoeff $size $iTable)
                              $finalCenter))))))
