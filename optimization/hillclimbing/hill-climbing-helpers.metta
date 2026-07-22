;; A negative value means that a direct hill-climbing caller has not supplied
;; an outer ant evaluation allowance. expandAntDemeHelperCounted temporarily
;; replaces it with the budget remaining in the complete ant run.
!(bind! &antLocalEvalLimit (new-state -1))

;; Verbatim port of the Information theoretic bits function from C++.
;; Params: $knobMap: A map of knobs with their multiplicities
;; Returns: Sum of log2(multiplicity) for the knobs in the map.
; (: informationTheoreticBits (-> (MultiMap (DiscSpec $knob)) Number))
;; C++ measures the information carried by a discrete field, rather than the
;; number of values in that field.  A seven-way ant action knob therefore adds
;; log2(7) bits, not seven bits.
(= (knobInformationBits $knob)
   (let (mkMultip $multiplicity) (getKnobMultip $knob)
     (log-math 2 $multiplicity)))

;; A native fold remains compositional when the estimator consumes the result
;; as a nested expression under PeTTa.
(= (informationTheoreticBits $knobMap)
   (foldl-atom (MultiMap.values $knobMap) 0 $bits $knob
     (+ $bits (knobInformationBits $knob))))

;; feature selection version of the informationTheoreticBits function
;; In the case of feature selection, the information theoretic bits is simply the number of features we have
; (: informationTheoreticBitsFs (-> (List Symbol) Number))
(= (informationTheoreticBitsFs $labels)
   (- (List.length $labels) 1))

;; Verbatim port of the Estimate neighborhood function from c++
;; Params: $distance: The hamming distance from the current knob
;;         $knobMap: A map of knobs with their multiplicities
;; Returns: twice the truncated information-bit estimate at distance one, or
;;          its binomial coefficient at greater distances.
; (: estimateNeighborhood (-> Number (MultiMap (DiscSpec $knob)) Number))
(= (estimateNeighborhood $distance $knobMap)
   (if (== $distance 0)
       1
       ;; C++ stores the floating-point information sum in size_t before using
       ;; it as a neighborhood dimension. `floor-math` is the exact
       ;; nonnegative truncation and remains grounded inside this `let`.
       (let $nnEstimate (floor-math (informationTheoreticBits $knobMap))
         ;; Match hill_climbing::estimate_neighborhood: an approximate field
         ;; dimension smaller than the requested Hamming distance still has
         ;; one maximally distant combination; it is not an empty neighborhood.
         (let $clampedDistance (min $distance $nnEstimate)
          (if (== $clampedDistance 1)
              (* 2 $nnEstimate)
              (binomial $nnEstimate $clampedDistance)))))) ;; INFO: Could use a safe binomial coefficient here if the estiamte starts becoming very large.

;; similar to the above 'estimateNeighborhood' but this one uses the informationTheoreticBitsFs which is for feature selection
; (: estimateNeighborhoodFs (-> Number (List Symbol) Number))
(= (estimateNeighborhoodFs $distance $labels)
   (if (== $distance 0)
       1
       (let $nnEstimate (informationTheoreticBitsFs $labels)
        (if (== $distance 1)
             (* 2 $nnEstimate)
             (binomial $nnEstimate $distance))))) ;; INFO: Could use a safe binomial coefficient here if the estiamte starts becoming very large.

;; Return an estimate of the number of new instances to search
(= (nNewInstances $distance $maxEvals $currentEvals $totalNeighbors)
   (if (== $distance 0)
       1
       (let*
           (
             ;; TODO: Most of the clamping logic here depens on the usage of number of evals and max number of evals. So best to do it after those are integrated into the system. For now we will be returning the total neighborhood clamped to the max_evals only.
             ;; ($_ (println! (Inside newInstances: $distance $maxEvals $currentEvals $totalNeighbors)))
             ($hc_params_fraction_of_nn (param hcFractionOfNN))
             ($numberOfNewInstaces (int (* $totalNeighbors (pow-math $hc_params_fraction_of_nn $distance))))
             ($nLeft (- $maxEvals $currentEvals))
             ($minDemeSize (param hcMinDemeSize))
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
(= (countNeighborhoodFromIdx (mkKbMap (mkDscMp $dscMp)) $inst $dist $startIdx $maxCount)
(if (== $dist 0)
    1
    (if (>= $startIdx (MultiMap.length $dscMp))
        0
        (let $updatedNumInstances (countNeighborhoodFromIdx (mkKbMap (mkDscMp $dscMp)) $inst $dist (+ $startIdx 1) $maxCount)
          (if  (> $updatedNumInstances $maxCount)
               $updatedNumInstances
               (let*
                 (
                    (($kbSpec $knob) (MultiMap.getByIdx $startIdx $dscMp))
                    ((mkMultip $multip) (getKnobMultip $knob))
                    ($uUpdatedNumInstances (+ $updatedNumInstances (* (- $multip 1) (countNeighborhoodFromIdx (mkKbMap (mkDscMp $dscMp)) $inst (- $dist 1) (+ $startIdx 1) $maxCount))))
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
  
;; merge3Demes
;; Combines offspring instances produced by the three crossover operators,
;; removes duplicates, appends unique offspring after the original deme,
;; and returns the updated deme together with the number of new instances added.
(= (merge3Demes $origDeme $newInstances1 $newInstances2 $newInstances3)

   (let*
      (
       ((mkDeme $rep (mkSInstSet $origSet) $demeId) $origDeme)

       ;; List.appendList(a, b) is implemented as append(b, a). Reverse the
       ;; helper arguments so first-occurrence deduplication sees
       ;; the same one-, two-, then three-simplex order as the C++ driver.
       ($temp (List.appendList $newInstances2 $newInstances1))
       ($allNewInstances (List.appendList $newInstances3 $temp))

       ($uniqueNewInstances (unique-atom $allNewInstances))
       ;; Crossover can rediscover a vector that is already in the scored
       ;; prefix.  Comparing the complete mkSInst row misses that duplicate
       ;; because the rediscovered row carries worstCscore while the existing
       ;; row carries its real score.  Filter by the instance payload so an
       ;; already evaluated vector is neither appended nor charged again.
       ($origInstances
         (map-atom $origSet $row
           (let (mkSInst (mkPair $inst $_score)) $row $inst)))
       ($freshNewInstances
         (filter-atom $uniqueNewInstances $row
           (let (mkSInst (mkPair $inst $_score)) $row
             (not (is-member $inst $origInstances)))))

       ($finalSet (List.appendList $freshNewInstances $origSet))

       ($nNewAdded (List.length $freshNewInstances))
      )
     ((mkDeme $rep (mkSInstSet $finalSet) $demeId) $nNewAdded)
))

;; crossover
;; Main crossover driver.
;; Distributes the crossover budget across 1-, 2-, and 3-simplex operators,
;; collects their offspring, merges the results, removes duplicates,
;; and returns the updated deme and count of newly added instances.
;; (: crossover (-> Number Number Instance Deme (Deme Number)))
(= (crossover $demeSize $nNewInstances $sampleStart $sampleSize $centerInst $deme)

   ;; Keep the crossover population configurable; 120 is the C++ default.
    (let*
      (
       ($nToMake (min $nNewInstances (param hcCrossoverPopSize)))
   
       ($newInstances1 (crossTopOne $deme (+ (/ $nToMake 3) (% $nToMake 3)) $sampleStart $sampleSize $centerInst))
       ($newInstances2 (crossTopTwo $deme (/ $nToMake 3) $sampleStart $sampleSize $centerInst))
       ($newInstances3 (crossTopThree $deme (/ $nToMake 3) $sampleStart $sampleSize $centerInst))
      )
      (merge3Demes $deme $newInstances1 $newInstances2 $newInstances3)
)
 )

;; Raw ant fitness is tracked independently from the penalized center score.
(= (bestRawAntScore $scoredInstances)
   (foldl-atom $scoredInstances () $bestRaw $scoredInst
     (let (mkSInst (mkPair $inst $score)) $scoredInst
       (let $raw (getScore $score)
         (if (== $bestRaw ()) $raw (max $bestRaw $raw))))))

(= (bestRawAntDeme (mkDeme $rep (mkSInstSet $scoredInstances) $id))
   (bestRawAntScore $scoredInstances))

;; Ant-only incremental scoring lives beside hill climbing so the optimizer's
;; compiled call sees it directly. New samples carry worstCscore; old samples
;; retain their scores and do not invoke the simulator again. Distinct knob
;; vectors that reduce to the same action tree share a batch-local score.

;; Look up the composite score of an already evaluated cleaned tree in the
;; current scoring batch. `()` is safe as the miss marker because a Cscore is
;; always represented by mkCscore, never by the empty expression.
(= (antCachedScoreForTree $tree ()) ())
(= (antCachedScoreForTree
      $tree
      (cons (mkAntTreeScore $cachedTree $cachedScore) $rest))
   (if (== $tree $cachedTree)
       $cachedScore
       (antCachedScoreForTree $tree $rest)))

;; Score an already materialized and reduced action tree without reconstructing
;; it a second time through antBasedScorer.
(= (scoreCleanedAntTree
      $cleanedTree
      (mkAntContext $steps $complexityRatio $actions $perceptions))
   (getAntCscore $cleanedTree $complexityRatio $steps))

;; Thread a small, scoring-batch-local tree->score cache from left to right. This
;; preserves input order, leaves every previously scored row byte-for-byte
;; unchanged, and counts only the first simulation of each newly materialized
;; cleaned tree. The cache is intentionally not seeded from old rows: those
;; rows stay completely untouched and this helper measures new batch work.
(= (scoreNewAntInstancesCachedCounted
      () $rep $id $context $treeScoreCache)
   (() 0 $treeScoreCache))
(= (scoreNewAntInstancesCachedCounted
      (cons (mkSInst (mkPair $inst $score)) $rest)
      $rep $id $context $treeScoreCache)
   (if (< (getScore $score) (* -1 (pow-math 10 90)))
       (let* (
              ($materializedTree (getCandidate $rep $id $inst))
              ($cleanedTree (cleanActionTree $materializedTree))
              ($cachedScore
                (antCachedScoreForTree $cleanedTree $treeScoreCache))
              (($resolvedScore $didEvaluate $updatedCache)
                (if (== $cachedScore ())
                    (let $newScore (scoreCleanedAntTree $cleanedTree $context)
                      ($newScore
                       1
                       (cons (mkAntTreeScore $cleanedTree $newScore)
                             $treeScoreCache)))
                    ($cachedScore 0 $treeScoreCache)))
              (($scoredRest $restCount $finalCache)
                (scoreNewAntInstancesCachedCounted
                  $rest $rep $id $context $updatedCache))
             )
         ((cons (mkSInst (mkPair $inst $resolvedScore)) $scoredRest)
          (+ $didEvaluate $restCount)
          $finalCache))
       (let ($scoredRest $restCount $finalCache)
            (scoreNewAntInstancesCachedCounted
              $rest $rep $id $context $treeScoreCache)
         ((cons (mkSInst (mkPair $inst $score)) $scoredRest)
          $restCount
          $finalCache))))

(= (scoreNewAntInstancesCounted $instances $rep $id $context)
   (let ($scored $count $finalCache)
        (scoreNewAntInstancesCachedCounted
          $instances $rep $id $context ())
     ($scored $count)))

(= (transformAntIncremental (mkSInstSet $instances) $rep $id $context)
   (let ($scored $count)
        (scoreNewAntInstancesCounted $instances $rep $id $context)
     ((mkSInstSet $scored) $count)))
 ;; )
    ;; WARN: The $nNewInstances might not be the actual number of instances created.
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

(= (getDisk (mkDeme (mkRep (mkKbMap $kbMap (mkDscMp $disc)) $tree) $instSet $id)) $disc)
(= (getDisk (mkDeme (mkRep (mkKbMap (mkDscMp $disc)) $tree) $instSet $id)) $disc)

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
;; ($optimize $deme $targetCScore $inst (mkParams applyStrategyBasedScore ($nGames $complexityRatio)))
(= (hillClimbing $POASet $tTableBscorer $centerInst (mkParams $scorer $FsScorer))
  (case (mkParams $scorer)
    (
      ((mkParams applyComplexityBasedScore)
        (let*
          (
            ($disc (getDisk $POASet))
            (($cpxCoeff $size $iTable) (getTTableParams $tTableBscorer))
          )
          (hillClimbing ((min (param hcMaxDistBoolean) (List.length (second $centerInst))) (param hcMinXoverNeighborsBoolean) 0) (False False False $centerInst 0 0 (worstCscore) (* -1 (pow-math 10 308)) 0 0 1)
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
          (hillClimbing ((min (param hcMaxDistFs) (List.length (second $centerInst))) (param hcMinXoverNeighborsFs) 0) (False False False $centerInst 0 0 0 0 0 0 1)
              $POASet 
              ($labels $rows () ())
              $centerInst
              (50.0 1.0 0.5 1.0 True $FsScorerType)
              estimateNeighborhoodFs crossoverFs 
              sampleNewInstancesFs transformFs
          )))
      ((mkParams applyStrategyBasedScore)
        (let*
          (
            ($disc (getDisk $POASet))
            (($nGames $complexityRatio) $FsScorer)
            ;; $tTableBscorer is the scalar `$maxScore` for the strategy path
            ;; (was a Cscore struct before the termination switched to scalar).
            ($targetPenScore $tTableBscorer)
            ;; Keep a non-empty sentinel in the third slot so the recursive
            ;; strategy path still follows the non-feature-selection branches.
          )
          (hillClimbing ((param hcMaxDistStrategy) (param hcMinXoverNeighborsStrategy) $targetPenScore)
                        (False False False $centerInst 0 0 (worstCscore) (* -1 (pow-math 10 308)) 0 0 1)
                        $POASet
                        ($disc $nGames strategy $complexityRatio) ;; INFO: `strategy` is used only as a non-empty marker so this recursive call follows the normal strategy branch instead of the feature-selection branch that is selected when the third slot is ().
                        $centerInst
                        ()
                        estimateNeighborhood crossover
                        sampleNewInstances transform)))
      ((mkParams applyAntBasedScore)
        ;; Ant has its own C++-matched distance and crossover threshold.  It
        ;; must not inherit the smaller strategy-search values.
        (let*
          (
            ($disc (getDisk $POASet))
            ((mkAntContext $steps $complexityRatio $actions $perceptions) $FsScorer)
            ($targetPenScore $tTableBscorer)
          )
          (hillClimbing ((param hcMaxDistAnt) (param hcMinXoverNeighborsAnt) $targetPenScore)
                        (False False False $centerInst 0 0 (worstCscore) (* -1 (pow-math 10 308)) 0 0 1)
                        $POASet
                        ($disc ant ant $FsScorer)
                        $centerInst
                        ()
                        estimateNeighborhood crossover
                        ;; Preserve sampling RNG order while appending and
                        ;; counting only unique, previously unseen ant vectors.
                        sampleNewAntInstances transform)))
    )))

(= (hillClimbing ($maxDist $minXoverNeighbors $bestPossibleScore) ;; Constant parameters
                 ($alreadyXover $lastChance $__ $prevCenter $prevStart $prevSize $bestSscore $bestScore $currentNInstances $d $i)
                 $POASet
                 ($neighborhood $rowOCoeff $size $iTable)
                 $centerInst
                 $hyperparamsfs
                 $estimateFunction $crossoverFunction $samplingFunction $transformFunction) ;; Helper functions
   (let*
      (
        ;; Preserve generic HC logging, but keep ant output opt-in because a
        ;; convergence run can execute thousands of iterations.
        ($progressEnabled
          (if (== $size ant) (param antDiagnostics) True))
        ($_blank
          (if $progressEnabled (println! "") ()))
        ($_iteration
          (if $progressEnabled (println! (Iteration $i running)) ()))

        ($totalNNeighbors ($estimateFunction $d $neighborhood))
        ($_antNeighborhoodEstimate
          (if (and (== $size ant) (param antDiagnostics))
              (println! (AntHillClimbingNeighborhoodEstimate
                           (distance $d) (neighbors $totalNNeighbors)))
              ()))

        ;; Use the deliberately smaller MeTTa ant budget documented in
        ;; defaults; other domains retain the existing generic HC budget. The
        ;; outer allowance prevents multiple demes from overspending the
        ;; complete-run budget.
        ($configuredMaxEvals
          (if (== $size ant) (param hcMaxEvalsAnt) (param hcMaxEvals)))
        ($outerAntLimit (if (== $size ant) (get-state &antLocalEvalLimit) -1))
        ($maxEvals
          (if (and (== $size ant) (>= $outerAntLimit 0))
              (min $configuredMaxEvals $outerAntLimit)
              $configuredMaxEvals))
        ($nNewNeighbors (nNewInstances $d $maxEvals $currentNInstances $totalNNeighbors))

        ;; Ant's evaluation counter is no longer also used as its population
        ;; index.  The latter is derived from the retained scored instances.
        ($currentDemeSize
          (if (== $size ant)
              (let (mkDeme $_rep (mkSInstSet $currentInstances) $_id) $POASet
                (List.length $currentInstances))
              $currentNInstances))

        ($largeNbh (>= $totalNNeighbors $minXoverNeighbors))
        ;; Honor the C++ crossover switch.
        ($xOver (and (param hcCrossover)
                     (and (> $i 2)
                          (and (or (not (== $size ant))
                                   (>= $currentDemeSize 3))
                               (and (not $alreadyXover) (or $largeNbh $lastChance)))))) ;; INFO: Has to be greater than 2 minimum.
        ($_crossover
          (if $progressEnabled (println! (Crossover: $xOver)) ()))
        ($_center
          (if $progressEnabled
              (println! (CenterInst: (second $centerInst)))
              ()))
        ($_size
          (if $progressEnabled (println! (size: $size)) ()))
        ($_neighborhood
          (if $progressEnabled
              (println! ($totalNNeighbors : $nNewNeighbors : $d))
              ()))
        ( 
          ; $newPOA
          ((mkDeme $rep $updatedInstSet $id) $newInstances)
                                                            (case ($xOver $size)
                                                              (
                                                                ((True ()) (let ($updatedInstSet $newInstances) ($crossoverFunction $currentDemeSize $nNewNeighbors $prevStart $prevSize $prevCenter $POASet)
                                                                              ((mkDeme () $updatedInstSet ()) $newInstances)))
                                                                ;; Cross the previous sample relative to the center from which it was generated.
                                                                ((True $notEmpty)  ($crossoverFunction $currentDemeSize $nNewNeighbors $prevStart $prevSize $prevCenter $POASet))
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
        ;; ($_ (println! (New Inst: $newInstances at Distance: $d)))
        ;; ($exprList (let (mkSInstSet $list) $updatedInstSet (List.listToExpr $list)))
        ;; ($bmr (map-atom $exprList $inst (let (mkSInst $x) $inst (println! (Inst: (List.listToExpr (second (Pair.first $x))) Tree: (preOrder (getCandidate $rep (Pair.first $x))))))))
        ;; ($_ (println! ""))
        ;; ($_ (println! (Newinstances: $updatedInstSet)))
        ;; ($_ (println! ""))
        ;; deconstruct the hyper params for fs function
        (($miConfi $prePenalty $preMinActivation $preMaxActivation $prePositive $scorerType) (if (== () $hyperparamsfs) (() () () () () ()) $hyperparamsfs))

        ($scoreBatch
          (if (== $size ant)
              (transformAntIncremental $updatedInstSet $rep $id $iTable)
              ((if (or (== $rep ()) (== $id ()))
                    ($transformFunction
                                                                $updatedInstSet
                                                                (mkITable $rowOCoeff $neighborhood)
                                                                $miConfi $prePenalty
                                                                $preMinActivation $preMaxActivation
                                                                $prePositive $scorerType)
                    (case $iTable
                      (
                        ((mkITable $rows $labels) ($transformFunction $updatedInstSet $rep $id (mkITable $rows $labels) $rowOCoeff))
                        ((mkAntContext $steps $complexityRatio $actions $perceptions)
                         ($transformFunction $updatedInstSet $rep $id $iTable $complexityRatio))
                        ($ComplexityRatio ($transformFunction $updatedInstSet $rep $id ($rowOCoeff $size) $ComplexityRatio)))))
               $newInstances)))
        (($scoredSet $actualNewEvals) $scoreBatch)
        ((mkSInstSet $scoredInstances) $scoredSet)
        ($updatedEvalCount (+ $currentNInstances $actualNewEvals))
        ($_antEvalDiagnostics
          (if (and (== $size ant) (param antDiagnostics))
              (println! (AntHillClimbingEvaluations
                           (actualNew $actualNewEvals)
                           (cumulativeLocal $updatedEvalCount)))
              ()))

        ($updatedDeme (if (or (== $rep ()) (== $id ())) 
                          (mkSInstSet $scoredInstances) 
                          (mkDeme $rep (mkSInstSet $scoredInstances) $id)))
        
        ;; ($sExprList (List.listToExpr $scoredInstances))
        ;; ($amr (map-atom $sExprList $inst (let (mkSInst $x) $inst (println! (Inst: (List.listToExpr (second (Pair.first $x))) Tree: (preOrder (getCandidate $rep $id (Pair.first $x))) Score: (getPenScore (Pair.second $x)))))))
        ;; ($_ (println! ""))
        ;; ($_ (println! (Scored instances: $scoredInstances)))
        ;; ($_ (println! (Scored instances....)))
        ;; ($_ (println! ""))

        ((mkSInst $newBestInstPair) (List.foldl hillScoreHelper (mkSInst (mkPair $centerInst $bestSscore)) $scoredInstances))
        ($newBestScore (if (or (== $rep ()) (== $id ())) 
                          (Pair.second $newBestInstPair)
                          (getPenScore (Pair.second $newBestInstPair)))) ;; This could be the original best candidate or a new one.
        ($hasImproved (> $newBestScore (+ $bestScore (param hcScoreImprovedThreshold))))
        
        ;; ($_ (println! (Best instance: (Pair.first $newBestInstPair))))
        ;; ($_ (println! (Best candidate: (preOrder (getCandidate $rep (Pair.first $newBestInstPair))))))
        ($_best
          (if $progressEnabled
              (println! (New best score: $newBestScore))
              ()))
        ;; ($_ (println! ""))

        ($nextCenterInst (if $hasImproved (Pair.first $newBestInstPair) $centerInst))
        ($nextBestScore (if $hasImproved $newBestScore $bestScore))
        ($nextBestSscore (if $hasImproved (Pair.second $newBestInstPair) $bestSscore))
        ($nextDistance (if $hasImproved 1 (if (not $xOver) (+ 1 $d) $d)))
        
        ;; ($_ (println! (NextDistance: $nextDistance)))

        ($hillStepResult (if (and (== $totalNNeighbors 1) (== $nextDistance 1))
                                  (hillClimbing ($maxDist $minXoverNeighbors $bestPossibleScore)
                                                ((and $xOver (not $hasImproved)) $lastChance $hasImproved $centerInst $prevStart $prevSize $nextBestSscore $nextBestScore $updatedEvalCount $nextDistance (+ 1 $i)) ;; Updated state
                                                $updatedDeme
                                                ($neighborhood $rowOCoeff $size $iTable)
                                                $nextCenterInst
                                                $hyperparamsfs
                                                $estimateFunction $crossoverFunction $samplingFunction $transformFunction)
                                  ($nextCenterInst $updatedDeme ((and $xOver (not $hasImproved)) $lastChance $hasImproved $centerInst $currentDemeSize $newInstances $nextBestSscore $nextBestScore $updatedEvalCount $nextDistance $i))))
        (($newCenter $newDeme ($newXover $newLastChance $newHasImproved $newPrevCenter $newPrevStart $newPrevSize $newBestSscore $nextNewBestScore $newCurrentNInstance $newDistance $newI)) $hillStepResult)
        
        ;; Termination check compares against the scalar `$bestPossibleScore`,
        ;; which carries the *raw* best score (matching classic MOSES). So we
        ;; must extract the raw-score field from the candidate's Cscore here,
        ;; not the penalty-adjusted one -- comparing penScore against a raw
        ;; target would mix the complexity penalty into the threshold.
        ($scoreToCompareBelow
          (if (== $size ant)
              (bestRawAntDeme $newDeme)
              (if (or (== $rep ()) (== $id ())) $newBestSscore (getScore $newBestSscore))))
        ($_antBestDiagnostics
          (if (and (== $size ant) (param antDiagnostics))
              (println! (AntHillClimbingBest
                           (bestRaw $scoreToCompareBelow)
                           (bestPenalized $newBestScore)))
              ()))
        ;; ($_ (println! (Found newBestSscore After (+ 1 $i) iteration is: $newBestSscore $scoreToCompareBelow)))
        ;; ($_ (println! ""))
        ($_ (cut)) ;; Commit choice points before tail-recursing — mirrors runMoses pattern. This gives few extra seconds of speed
    )
    (if (<= (- $maxEvals $newCurrentNInstance) 0)
        (trace! (Terminating because of maxEval ending) ($newCenter $newDeme ($newXover $newLastChance $newHasImproved $newPrevCenter $newPrevStart $newPrevSize $newBestSscore $nextNewBestScore $newCurrentNInstance $newDistance $newI)))
        (if (<= $bestPossibleScore $scoreToCompareBelow)
                  (trace! (Terminating because of best possible score: $bestPossibleScore found $scoreToCompareBelow)
            ($newCenter $newDeme ($newXover $newLastChance $newHasImproved $newPrevCenter $newPrevStart $newPrevSize $newBestSscore $nextNewBestScore $newCurrentNInstance $newDistance $newI))
                  )
            (let ($finalCenter $finalDeme ($finalXover $finalLastChance $finalHasImproved $finalPrevCenter $finalPrevStart $finalPrevSize $finalBestCscore $finalNewBestScore $finalCurrentNInstance $finalDistance $finalI))
              ;; Match the C++ "last chance" rule: simplex crossover is tried
              ;; after a stalled nearest-neighbor scan when widening is off,
              ;; or only after widened search has exhausted maxDist.
              (if (and (param hcCrossover)
                       (and (and (not $newHasImproved) (not $newLastChance))
                            (and (not $newXover)
                                 (or (not (param hcWidenSearch))
                                     (< $maxDist $newDistance)))))
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
                  ;; With widening disabled, stop at the local optimum exactly
                  ;; as C++ does.  When enabled, continue at the wider distance.
                  (if (and (not $finalHasImproved) (not (param hcWidenSearch)))
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

(= (hillScoreHelper $inst1 $inst2) (returnBest < $inst1 $inst2))

;; Helper to get initial disc spec from a knob
(= (getInitDiscSpec (mkLSK (mkDiscKnob $k $m (mkDiscSpec $init) $cur $opts)))
   (if (== $opts ()) $init 0))
(= (getInitDiscSpec (mkSSK (mkDiscKnob $k $m (mkDiscSpec $init) $cur $opts))) $init)

;; Helper to initialize center instance from deme
;; Creates an instance with knobs set to their initial disc specs
(= (initCenterInst (mkDeme (mkRep (mkKbMap $kbMp (mkDscMp $disc)) $tree) $instSet $id))
   (let $knobList (MultiMap.values $disc)
     (let $initSpecs (List.map getInitDiscSpec $knobList)
       (mkInst $initSpecs))))
