; ;; Implementing simulated annealing for a simple optimization problem
; !(register-module! ../../../../metta-moses)


; ; !(bind! np-rand (py-atom numpy.random))
; !(bind! math-exp (py-atom math.exp))
; !(bind! rand-random (py-atom random.random))
; ; !(bind! np-rand-randint (py-atom numpy.random.randint))
; ; !(bind! np-rand (py-atom numpy.random.rand))
; ; !(bind! np-arange (py-atom numpy.arange))
; ; !(bind! np-linalg-norm (py-atom numpy.linalg.norm))
; ; !(bind! np-exp (py-atom numpy.exp))


; (= (initTour2)
; (19 18 17 16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0)
; )
;; Simulated Annealing
;; TODO: Their is a weird bug that makes the main loop get stuck on infinite loop,
;;       but when the program is stoped and re-run again it works fine.
;; Params:
;;   initial-temperature: Initial temperature for the algorithm
;;   cooling-rate: Rate at which the temperature decreases
;;   max-iterations: Maximum number of iterations to run the algorithm
;;   total-state: Total number of instances in the state space
;; Algorithm:
;;   Get the total distance of the current solution
;;   Initialize the current solution as the best solution
;;   while the Temperature is greater than a threshold and max iterations is not reached:
;;     Generate a new solution by swaping two instances in the current solution
;;     Calculate the distance of the new solution
;;     Calculate the difference between the new and current solution
;;     if the new solution is better, accept it based on the acceptance probability
;;        Accept if F(x_new) < F(x_current) ;; lower value Better score in this case
;;        else, exp[-[F(x_new) - F(x_current)] / T] ;; Accept if this value is greated than a randomly generated number from [0,1]
;;        Get the distance of the new solution and compare it with the best solution
;;        if the new solution is better than the best solution, update the best solution
;;     Decrease the temperature
;;     increement the iteration count   
;;   return the best solution


; (= (index $list $ctr $index)
;     (if (== $list ())
;         ()
;         (let* (
;                 ($head (car-atom $list))
;                 ($tail (cdr-atom $list))
;                 ($rest (index $tail (+ 1 $ctr) $index))
;             )
;         (if (== $ctr $index)
;             $head
;             $rest
;         )
; )
; )
; )


; (= (reverseExp $exp $i)
;   (if (== $exp ())
;     $i
;     (let*
;       (
;         (($h $t) (decons-atom $exp))
;         ; ($s (if (isSymbol $h) (cons-atom $h $i) (++ ($h) $i)))
;         ($s (cons-atom $h $i))
;       )
;       (reverseExp $t $s)
;     )))

; (= (lenTour $tour)
;      (if (== $tour ())
;           0
;           (let* 
;                (
;                     ($h (car-atom $tour))
;                     ($t (cdr-atom $tour))
;                     ($len (lenTour $t))
;                )
;                (+ 1 $len)
;           )
;      )
; )

; (= (Eq $x $y $z) (if (== $x $y) $z $y))

; (= (findAndReplace $x $y $list)
;     (reverseExp (collapse (Eq $x (superpose $list) $y)) ())
; )

; (: isSymbol (-> Expression Bool))
; (= (isSymbol $expr) (== (get-metatype $expr) Symbol))

; (: foldr (-> (-> $a $b $b) $d $c $d)) ;; changed the parameterized type of second argument from $b to $d
; (= (foldr $f $i $xs)
;    (if (== $xs ())
;        $i
;        (let* (($h  (car-atom $xs)) ; added isSymbol checks not to encounter any errors
;               ($t (cdr-atom $xs)) ; added isSymbol checks not to encounter any errors
;               ($ft (foldr $f $i $t)))
;          ($f $h $ft))))

; (: appendAtom (-> Atom Atom Atom))
; (= (appendAtom $a $atom) (foldr cons-atom ($a) $atom))

; (: ++ (-> Expression Expression Expression))
; (= (++ $x $y)
;    (case ((isSymbol $x) (isSymbol $y))
;       (
;         ((True True)  ($x $y))
;         ((True False) (cons-atom $x $y))
;         ((False True) (appendAtom $y $x))
;         ((False False)  (foldr cons-atom $y $x)))))

; (= (flatten ()) (empty))
; (= (flatten ($x $xs))
;     (let*
;         (
;             ($y (if (== $xs ()) () (flatten $xs)))
;         )
;         (cons-atom $x $y)
;     )
; )

; (= (findAndReplaceAt $num1 $index $list $ctrl)
;      (if (== () $list)
;           ()
;           (let ($h $t) (decons-atom $list)
;                (if (== $ctrl $index)
;                     ($num1 (findAndReplaceAt $num1 $index $t (+ 1 $ctrl)))
;                     ($h (findAndReplaceAt $num1 $index $t (+ 1 $ctrl)))
;                )
;           )
;      )
; )

; (= (selectByIndex $expr $index)
;     (if (== $expr ())
;         (Error (Index out of range) ())
;         (if (== $index 0)
;             (car-atom $expr)
;             (let $tail (cdr-atom $expr)
;                 (selectByIndex $tail (- $index 1))
;             ))))


; (= (euclideanDist ($x $y))
;      (sqrt-math (+ (pow-math $x 2) (pow-math $y 2)))
; )

; (= (coordinateDiff ($x1 $y1) ($x2 $y2))
;      ((- $x1 $x2) (- $y1 $y2))
; )

; (= (swap $tour $lenTour)
;      (let*
;           (
;                ; (() (println! "Inside Swap"))
;                ; ($i (generate-randint $lenTour))
;                ($i (random-int &rng 0 $lenTour)) ;; using random.randint instead of numpy.random.randint
;                ; ($j (generate-randint $lenTour $i))
;                ($j (random-int &rng $i $lenTour)) ;; using random.randint instead of numpy.random.randint
;                ; (() (println! ($i $j)))
;                ($num1 (index $tour 0 $i))
;                ($num2 (index $tour 0 $j))
;                ; (() (println! ($num1 $num2)))
;                ($tour1 (flatten (findAndReplaceAt $num1 $j $tour 0)))
;                ($tour2 (flatten (findAndReplaceAt $num2 $i $tour1 0)))
;                ; (() (println! $tour))
;                ; (() (println! $tour1))
;                ; (() (println! $tour2))
;           )
;           $tour2
;      )
; )
; ; !(swap (5 3 4 1 2 6 7 8 9 10) 10)
; ; !(random-int &rng 0 10)


; (= (total-distance $tour $state $lenTour $iterCount $dist)
;      (if (== (- $lenTour 1) $iterCount)
;           $dist
;           (let*
;                (
;                     ; (() (if (== $iterCount 0) (println! $state) ()))
;                     ; (() (println! ($lenTour $iterCount)))
;                     ; ($idxA (index $tour 0 $iterCount))
;                     ($idxA (selectByIndex $tour $iterCount))
;                     ; (() (println! ("index A:" $idxA)))
;                     ; ($stateA (index $state 0 $idxA ))
;                     ($stateA (selectByIndex $state $idxA))
;                     ; (() (println! ("StateA: " $stateA)))
;                     ; ($idxB (index $tour 0 (% (+ $iterCount 1) $lenTour)))
;                     ($idxB (selectByIndex $tour (% (+ $iterCount 1) $lenTour)))
;                     ; (() (println! ("index B: " $idxB)))
;                     ; ($stateB (index $state 0 $idxB))
;                     ($stateB (selectByIndex $state $idxB))
;                     ; (() (println! ("StateB: " $stateB)))
;                     ($diff (coordinateDiff $stateA $stateB))
;                     ($newDist (+ $dist (euclideanDist $diff)))
;                     ($newIterCount (+ 1 $iterCount))
;                )
;                (total-distance $tour $state $lenTour $newIterCount $newDist)
;           )
;      )
; )

; (= (recusriveSwap $tour $lenTour $newTour)
;      (if (== $newTour $tour)
;           (recusriveSwap $tour $lenTour (swap $tour $lenTour)) ;; if the candidate tour is same as current tour, swap again
;           $newTour
;      )
; )

; (= (simulated-annealing-loop $state $currentTour $lenTour $Temp $finalTemp $coolRate $isInit $maxIter $bestTour $bestDist)
;      (if (or (<= $Temp $finalTemp) (<= $maxIter 0))
;           ($bestTour $bestDist)
;           (let*
;                (
;                     ; (() (println! ("Temp: " $Temp , "maxIter: " $maxIter)))
;                     ; (() (println! ("is Init: " $isInit)))
;                     ($currentDist (total-distance $currentTour $state $lenTour 0 0))
;                     ($candidateTour (swap $currentTour $lenTour))
;                     ($newCandidateTour (recusriveSwap $currentTour $lenTour $candidateTour))
;                     ; (() (println! ("Current Tour: " $currentTour)))
;                     ; (() (println! ("Candidate Tour: " $newCandidateTour)))
;                     ($candidateDist (total-distance $newCandidateTour $state $lenTour 0 0))
;                     ($delta (- $candidateDist $currentDist))
;                     ($acceptanceProb (math-exp (/ $delta $Temp)))
;                     ; (() (println! ("Current Dist: " $currentDist)))
;                     ; (() (println! ("Candidate Dist: " $candidateDist)))
;                     ; (() (println! ("Delta: " $delta)))
;                     ; (() (println! ("Acceptance Prob: " $acceptanceProb)))
;                     ($randomFloat (rand-random)) ;; using random.random instead of numpy.random.rand
;                     ; (() (println! ("Random Float: " $randomFloat)))
;                     ($newTemp (- $Temp (* $coolRate $Temp))) ;; decrease the temperature
;                     ; (() (println! ("New Temp: " $newTemp)))
;                     ($newIterCount (- $maxIter 1))
;                     ; (() (println! ("New Iter Count: " $newIterCount)))
;                )
;                (if (or (< $delta 0) (< $randomFloat $acceptanceProb)) ;; random-float isn't working both in metta and metta-log
;                     (if $isInit
;                          (if (> $currentDist $candidateDist)
;                               (simulated-annealing-loop $state $newCandidateTour $lenTour $newTemp $finalTemp $coolRate False $newIterCount $newCandidateTour $candidateDist)
;                               (simulated-annealing-loop $state $newCandidateTour $lenTour $newTemp $finalTemp $coolRate False $newIterCount $bestTour $bestDist)
;                          )
;                          (if (> $bestDist $candidateDist)
;                               (simulated-annealing-loop $state $newCandidateTour $lenTour $newTemp $finalTemp $coolRate False $newIterCount $newCandidateTour $candidateDist)
;                               (simulated-annealing-loop $state $newCandidateTour $lenTour $newTemp $finalTemp $coolRate False $newIterCount $bestTour $bestDist)
;                          )
;                     )
                    
;                     ; (simulated-annealing-loop $state $currentTour $lenTour $newTemp $finalTemp $coolRate $newIterCount $bestTour $bestDist)
;                     ()
;                )
;           )
;      )
; )

; !(assertEqual 
;     (let*
;      (
;           (($bestTour $bestDist) (simulated-annealing-loop 
;           ((0.90751152 0.8727447)
;           (0.09815111 0.96632283)
;           (0.15633612 0.00337229)
;           (0.3784314  0.40766615)
;           (0.12148905 0.63377925)
;           (0.93982584 0.05639235)
;           (0.98283563 0.25034879)
;           (0.69309372 0.49812167)
;           (0.25401048 0.49560316)
;           (0.47888758 0.27937148)
;           (0.18123166 0.09497495)
;           (0.87314074 0.02907323)
;           (0.62689494 0.08937162)
;           (0.7399304  0.08168714)
;           (0.924731   0.72535021)
;           (0.05086365 0.47188071)
;           (0.60555846 0.49466879)
;           (0.52262645 0.07362002)
;           (0.62464936 0.26825155)
;           (0.22669088 0.61799588)
;           )
;           (19 18 17 16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0) 
;           20 100 0.01 0.1 True 50 5 ()))
;         )

;         (<= $bestDist 9.0)
;     )
; True
;  )


;; New algo structure
;; params: deme, temperature, cooling rate, max iterations, final temperature,
;; functions needed: scoring-function, crossover(swaping function)
;; How it works:
;; 1. checks if the temp == final temp or max iterations is reached, it any of these is true break and return the best cadidate and best score
;; 2. if not, scores the current cadidate and generates a new candidate by swapping two elements in the current candidate (might change to crossover)
;; 3. scores the new candidate and calculates the delta between the new candidate and current candidate
;; 4. calculates the acceptance probability using the delta and temperature
;; 5. generates a random float between 0 and 1
;; 6. if the delta is less than 0 or the random float is less than the acceptance probability, accept the new candidate
;;    6.1 if the current candidate is the best candidate, update the best candidate and best score
;; 7. decrease the temperature by multiplying it with the cooling rate
;; 8. decrement the max iterations
;; 9. repeat from step 1

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
(= (simulated-annealing (mkDeme (mkRep (mkKbMap (mkDscKbMp $idxMp) (mkDscMp $disc)) $tree) $instSet $id) ;; $deme
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

              
              ; ()
            ;       ;; score the new instance
            ;       ;; evaluate delta b/n the new instance and current instance
            ;       ;; calculate acceptance probability
            ;       ;; generate a random float
            ;       ;; check for acceptance
            )
              ; (: simulated-annealing (-> Deme (TruthTableBScore $a) Instance $constParams $hyperParams $params (Instance Deme $state)))
              ; (= (simulated-annealing (mkDeme (mkRep (mkKbMap (mkDscKbMp $idxMp) (mkDscMp $disc)) $tree) $instSet $id);; $deme
              ;                          (mkTruthTableBScore $cpxCoeff $size $iTable) ;; $table
              ;                          $initCenter
              ;                          ($maxDist $minXoverNeighbors $bestPossibleScore) ;; $constParams
              ;                          ($Temp $finalTemp $coolRate $isInit $maxIter) ;; $hyperParams
              ;                          ($prevCenter $bestCScore $bestScore $currentNInstances $d $i) ;; $params
              ;                          )
            (simulated-annealing $newDeme $table ;; $table
                         $initCenter
                         ($maxDist $minXoverNeighbors $bestPossibleScore) ;; $constParams
                         ($newTemp $finalTemp $coolRate False $newIterCount) ;; $hyperParams
                         ((and $xOver (not $hasImproved)) $lastChance $newCenter $newBestCScore $newBestScore $updatedNumInstances $newDistance (+ 1 $i))) ;; $params
            ; (println! ("it worked"))
          )
          )
)




;; mannual testing
; !(bind! deme (mkDeme (mkRep (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (1)) 0) (ConsMap ((mkNodeId (2)) 1) NilMap))) (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) )) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) NilMMap)))) (mkTree (mkNode AND) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) Nil)))) (mkSInstSet Nil) (mkDemeId "1")))
; !(bind! demes (Cons (mkDeme (mkRep (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (1)) 0) (ConsMap ((mkNodeId (2)) 1) NilMap))) (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) )) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) )) NilMMap)))) (mkTree (mkNode AND) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) Nil)))) (mkSInstSet Nil) (mkDemeId "1")) Nil))

; !(bind! table (createTruthTableBScore 2 (mkITable
;                          (Cons (Cons False (Cons False (Cons False Nil))) 
;                          (Cons (Cons True (Cons False (Cons False Nil))) 
;                          (Cons (Cons False (Cons True (Cons False Nil)))
;                          (Cons (Cons True (Cons True (Cons True Nil))) Nil))))
;                          (Cons A (Cons B (Cons O Nil))))))
; !(simulated-annealing deme table (mkInst (Cons 0 (Cons 0 Nil))) (10 0.01 0.1 True 10 0))

; !(rand-random)
; !(< (rand-random) (acceptanceProb -0.5 1.0))
