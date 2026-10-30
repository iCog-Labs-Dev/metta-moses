;; Generate all possible combination of neighbors at a given distance.
;; Given a center instance, which is a list of numbers, we generate all
;;  variations of that instance at a specified distance.
;;
;; For example for a center instance of (0 0 0 1), a possible neighbor
;;  at distance 1 would be (0 0 0 0) or (0 0 1 1). The distance used is
;;  a hamming distance of bits.
;;
;; This function is a wrapper for the varyNKnobs function. It makes the
;;  output of varyNKnobs unique and removes the center instance from the
;;  result. It also wraps each neighbor in mkInst.
;;
;; Params:
;;    (mkMultip $m) - The multiplicity of the knobs
;;    (mkInst (cons $x $xs)) - The center instance. It doesn't handle () case because
;;                              it doesn't make sense to have an empty instance.
;;    $dist - The hamming distance from the center instance to search for neighbors
;;
;; Returns: List of instances.
;; (: generateAllInNeighborhood (-> Multiplicity Instance Number (List Instance)))
(= (generateAllInNeighborhood (mkMultip $m) (mkInst ()) $dist) ())
(= (generateAllInNeighborhood (mkMultip $m) (mkInst (cons $x $xs)) $dist)
   (if (== $dist 0)
       ((mkInst (cons $x $xs)))
       (let $multips (genList 1 (- $m 1))
          (let $instExp (cons $x $xs)
          (let $listNeighbors (let $neighbors (varyNKnobs $multips $instExp $dist)
                                      (map-atom $neighbors $neighbor (mkInst $neighbor)))
          (let $uqListNeighbors (unique-atom $listNeighbors)
          (let $uqListNeighbors' (subtraction-atom $uqListNeighbors ((mkInst (cons $x $xs))))
            $uqListNeighbors')))))))

;; Disc-aware exhaustive neighborhood generation. Each knob can expose a
;; different effective multiplicity after discprobe.
(= (effectiveSpecValues (mkMultip $m))
   (if (<= $m 1)
       ()
       (genList 1 (- $m 1))))

(= (discEffectiveSpecLists (mkDscMp ())) ())
(= (discEffectiveSpecLists (mkDscMp (cons ($spec $knob) $tail)))
   (cons (effectiveSpecValues (getKnobMultip $knob))
         (discEffectiveSpecLists (mkDscMp $tail))))

;; Corrected implementation matching C++ vary_n_knobs semantics for spec lists.
;; Same fix as varyNKnobs: returns the instance at dist == 0, dead end at
;; startI >= length, and omits single-position $changeIs from the output.
(= (varyNKnobsBySpecLists $specLists $instExp $dist)
   (varyNKnobsBySpecLists $specLists $instExp $dist 0))
(= (varyNKnobsBySpecLists $specLists $instExp $dist $startI)
   (case ($dist (>= $startI (length $instExp)))
     (
       ((0 $_) ($instExp))
       ((1 $_) (varyNKnobsBySpecListsDist1 $specLists $instExp $startI))
       (($dist True) ())
       (($dist False)
        (let*
          (
            ($specs (List.getByIdx $specLists $startI))
            ($changeRest (varyNKnobsBySpecLists $specLists $instExp $dist (+ $startI 1)))
            ($changeDs (map-atom $specs $m (varyNKnobsBySpecLists $specLists (changeAt $m $startI $instExp) (- $dist 1) (+ $startI 1))))
            ($flatDs (foldl-atom $changeDs () $acc $changeD (append $changeD $acc)))
            ($final (append $changeRest $flatDs))
          )
          (filter-atom $final isNotUnit))))))

;; Fast path for dist=1: flat iteration over positions, no recursive
;; list-of-lists construction. Matches varyNKnobsDist1 pattern.
(= (varyNKnobsBySpecListsDist1 $specLists $instExp $startI)
   (if (>= $startI (length $instExp))
       ()
       (let*
         (
           ($specs (List.getByIdx $specLists $startI))
           ($currentVariations (map-atom $specs $m (changeAt $m $startI $instExp)))
           ($restVariations (varyNKnobsBySpecListsDist1 $specLists $instExp (+ $startI 1)))
           ($final (append $currentVariations $restVariations))
         )
         (filter-atom $final isNotUnit))))

(= (generateAllInNeighborhoodForDisc (mkDscMp $disc) (mkInst ()) $dist) ())
(= (generateAllInNeighborhoodForDisc (mkDscMp $disc) (mkInst (cons $x $xs)) $dist)
   (if (== $dist 0)
       ((mkInst (cons $x $xs)))
       (let*
          (
            ($specLists (discEffectiveSpecLists (mkDscMp $disc)))
            ($instExp (cons $x $xs))
            ($listNeighbors (let $neighbors (varyNKnobsBySpecLists $specLists $instExp $dist)
                                 (map-atom $neighbors $neighbor (mkInst $neighbor))))
            ($uqListNeighbors (unique-atom $listNeighbors))
            ($uqListNeighbors' (subtraction-atom $uqListNeighbors ((mkInst (cons $x $xs)))))
          )
          $uqListNeighbors')))


;; varyNKnobs returns the instances at the given distance from $instExp,
;; as plain expressions. generateAllInNeighborhood post-processes them.
;; It matches C++ vary_n_knobs: it generates instances at EXACTLY the target
;; distance. It records an instance only when dist == 0 (all modifications
;; used). The dead end (startI >= length) returns () for unresolvable paths.
;;
;; Params:
;;   $multips: The possible values of each knob. For a discrete knob with 3
;;     values, $multips is (1 2). changeAt encodes the value 0, so it is not in the list.
;;   $instExp: The center instance as an expression of numbers
;;   $dist: The hamming distance
(= (varyNKnobs $multips $instExp $dist) (varyNKnobs $multips $instExp $dist 0))
(= (varyNKnobs $multips $instExp $dist $startI)
   (case ($dist (>= $startI (length $instExp)))
     (
       ((0 $_) ($instExp))
       ((1 $_) (varyNKnobsDist1 $multips $instExp $startI))
       (($dist True) ())
       (($dist False)
        (let*
          (
            ($changeRest (varyNKnobs $multips $instExp $dist (+ $startI 1)))
            ($changeDs (map-atom $multips $m (varyNKnobs $multips (changeAt $m $startI $instExp) (- $dist 1) (+ $startI 1))))
            ($flatDs (foldl-atom $changeDs () $acc $changeD (append $changeD $acc)))
            ($final (append $changeRest $flatDs))
          )
          (filter-atom $final isNotUnit))))))

;; Fast path for dist=1: flat iteration over positions, no recursive
;; list-of-lists construction. Analogous to C++ UNROLL_TAIL_CALL /
;; UNROLL_TAIL_CALL_DISC macros (neighborhood_sampling.h:359-389,417-434).
(= (varyNKnobsDist1 $multips $instExp $startI)
   (if (>= $startI (length $instExp))
       ()
       (let*
         (
           ($currentVariations (map-atom $multips $m (changeAt $m $startI $instExp)))
           ($restVariations (varyNKnobsDist1 $multips $instExp (+ $startI 1)))
           ($final (append $currentVariations $restVariations))
         )
         (filter-atom $final isNotUnit))))

(= (isNotUnit $x) (!= () $x))

(= (changeAt $new $i $list)
   (if (== $list ())
       ()
       (let ($h $t) (decons-atom $list)
       (if (== $i 0)
           (let $newValue (if (== $h $new) 0 $new) (cons-atom $newValue $t))
           (let $t' (changeAt $new (- $i 1) $t)
             (cons-atom $h $t'))))))


;; This function generates one instance within a distance (difference in knob specifications)
;; of $dist from the central instance. It uses the knob map to get the multiplicity of each knob,
;; because the central instance only contains the list of specifications.
;; Parameters:
;;      $n: Not used (the sample index).
;;      $dist: The distance from the central instance.
;;      $kbMp: The knob map used to get the multiplicity of the knob.
;;      $centralInst: The instance from which the new instance is generated.
;; (: sampleFromNeighborhood` (-> Number Number KnobMap Instance Instance))
(= (sampleFromNeighborhood` $n $dist (mkKbMap (mkDscMp $disc)) (mkInst $centralInst))
        (let* 
            (
              ($knobLen (MultiMap.length $disc))
              ($instLen (List.length $centralInst))
              )
              (if (== $knobLen $instLen)
                  (let* (
                    ($selectedIndices (lazyRandomSelector 0 (- $instLen 1) $dist))
                    ($updatedInst (foldl-atom $selectedIndices $centralInst $updated $rand (updateInst $rand $disc $updated)))
                    ($inst (mkInst $updatedInst))
                  )
                  $inst) 
                  (Error ($knobLen $instLen) "Not Equal"))))

;; Similar to sampleFromNeighborhood` above, but for feature selection.
;; It caps the distance at the instance length, because lazyRandomSelector fails for a larger distance.
;; (: sampleFromNeighborhoodFs` (-> Number Number (ITable Bool) Instance Instance))
(= (sampleFromNeighborhoodFs` $n $dist (mkITable (cons $column $columns) $labels) (mkInst $centralInst))
        (let* 
            (
              ($featureLen (- (List.length $labels) 1)) 
              ($instLen (List.length $centralInst))
              ($cappedDist (min-atom ($dist $instLen)))
              ) 
              (if (== $featureLen $instLen) 
                  (let* (
                    ($selectedIndices (lazyRandomSelector 0 (- $instLen 1) $cappedDist))
                    ($updatedInst (foldl-atom $selectedIndices $centralInst $updated $rand (updateInstFs $rand $updated)))
                  )
                  (mkInst $updatedInst)) 
                  (Error ($featureLen $instLen) "Not Equal"))))
;; A helper of sampleFromNeighborhood` that updates the central instance.
;;
;; Parameters:
;;      $rand: A random index from lazyRandomSelector. The position to update in $newInst
;;      $disc: A multi-map (extracted from the knob mapper) of DiscSpec LogicalSubtreeKnob or ActionSubtreeKnob,
;;             used to retrieve the lsk/ask from which the knob multiplicity can be obtained.
;;      $newInst: The original central instance.
;; (: updateInst (-> Number (MultiMap (DiscSpec $knob)) Instance Instance))
(= (updateInst $rand $disc $newInst)
        (let*
          (
            (($decSpec $knob) (MultiMap.getByIdx $rand $disc))
            ((mkMultip $multi) (getKnobMultip $knob))
            ($curSpec (List.getByIdx $newInst $rand))
          )
          (if (<= $multi 1)
              $newInst
              (let*
                (
                  ($upper (- $multi 1))
                  ($randomSpec (+ (py-call (random.randint 0 (- $upper 1))) 1))
                )
                (if (== $randomSpec $curSpec)
                    (List.replaceAt $newInst $rand 0)
                    (List.replaceAt $newInst $rand $randomSpec))))))

;; Similar to updateInst above, but for feature selection: the new value is 0 or 1.
;; (: updateInstFs (-> Number Instance Instance))
(= (updateInstFs $rand $newInst)
        (let*
          (
            ($curSpec (List.getByIdx $newInst $rand))
            ($randomSpec (py-call (random.randint 0 1)))
          )
          (if (== $randomSpec $curSpec)
                              (List.replaceAt $newInst $rand 0)
                              (List.replaceAt $newInst $rand $randomSpec))))

;; Samples $sampleSize instances at the given distance with sampleFromNeighborhood`.
;; The samples are not necessarily unique.
;; Parameters:
;;      $sampleSize: Number of instances to generate
;;      $dist: Distance from the center instance
;;      $kbMp: Knob map for variations
;;      $inst: Center instance
;; Returns: A list of $sampleSize instances.

;; (: sampleFromNeighborhood (-> Number Number KnobMap Instance (List Instance)))
(= (sampleFromNeighborhood $sampleSize $dist $kbMp $inst)
   (let* (
      ($list (genList (- $sampleSize 1)))

      ($x (map-atom $list $i (sampleFromNeighborhood` $i $dist $kbMp $inst)))
    )
    $x))

;; Similar to sampleFromNeighborhood above, but for feature selection.
;; It uses sampleFromNeighborhoodFs` to sample from the neighborhood.
;; (: sampleFromNeighborhoodFs (-> Number Number (ITable Bool) Instance (List Instance)))
(= (sampleFromNeighborhoodFs $sampleSize $dist $itable $inst)
   (let* (
      ($list (genList (- $sampleSize 1)))
      ($x (map-atom $list $i (sampleFromNeighborhoodFs` $i $dist $itable $inst)))
    )
    (exprToList $x)))

;;  isPossibleSize: Calculates if the requested number of neighbors can be generated at a given distance from a center instance.
;; Uses combinatorics: chooses $dist positions from instance length and counts variations based on knob multiplicity.
;; Parameters:
;;      $sampleSize: Number of instances to generate
;;      $dist: Distance from the center
;;      $inst: Center instance
;;      $multip: Knob multiplicity
;; Returns: true if total neighbors ≥ $sampleSize, else false
;; Formula: n! / ((n - d)! * d!) * (m-1)^d  ( where n = instance length, d = hamming distance, m = knob multiplicity)

;; (: isPossibleSize (-> Instance Number Number Bool))
(= (isPossibleSize $sampleSize $dist (mkInst $centralInst)) 
    
           (let* (
               ($instLen (List.length $centralInst))
               ($n (factorial $instLen))
               ($r (factorial (- $instLen $dist)))
               ($d (factorial $dist))
               ($m (pow-math 2 $dist)) ; assuming knob multiplicty is 3, so m-1 = 1, hence m = 2 that is why (pow-math 2 $dist)
               ($maxNeighbors (/ $n (* $r $d)))
               ($totalNeighbors (* $maxNeighbors $m))
             ) 
               (>= $totalNeighbors $sampleSize)

            )
)

;; Computes the hamming distance between two instances.
;; Example: inst1: (0 0 0 1), inst2: (0 0 0 0) => distance: 1
;;          inst1: (0 1 0 1), inst2: (0 0 0 0) => distance: 2
(: distance (-> Expression Expression Number) )
(= (distance $inst1 $inst2)
   (if (~= (size-atom $inst1) (size-atom $inst2))
       (Error (Inst: $inst1 and Inst: $inst2) (Instances are not equal length))
   (if (== $inst1 ())
       0
       (let ($h1 $t1) (decons-atom $inst1)
       (let ($h2 $t2) (decons-atom $inst2)
          (+ (if (== $h1 $h2) 0 1) (distance $t1 $t2)))))))

;; The hamming distance between two mkInst instances of equal length.
;; (: distance` (-> Instance Instance Number) )
(= (distance` (mkInst ()) (mkInst ())) 0)
(= (distance` (mkInst (cons $x $xs)) (mkInst (cons $y $ys)))
      (+ (if (== $x $y) 0 1) (distance` (mkInst $xs) (mkInst $ys))))

;; An alias of distance` with a different name, so that it does not
;;  collide with the typed distance function above.
;; (: distance' (-> Instance Instance Number))
(= (distance' $inst1 $inst2) (distance` $inst1 $inst2))

;; Assigns an initial large negative score to an instance.
;; Params:
;;   $inst: The instance to be scored.
;; Returns:
;;   (ScoredInstance $score): Scored instance with an initial large negative score -10^37.
;; (: initInstScore (-> Instance (ScoredInstance $score)))
(= (initInstScore $inst)
(mkSInst (mkPair $inst (worstCscore))))

;; similar to the above 'initInstScore' but for feature selection to make the initial score 0 (the minimum Mutual Information score)
;; (: initInstScoreFs (-> Instance (ScoredInstance $score)))
(= (initInstScoreFs $inst)
(mkSInst (mkPair $inst 0)))

;; Converts a Scored Instance back to a plain Instance.
;; Param: scored instance
;; Returns:a normal instance without any score
;; (: removeInstScore (-> (ScoredInstance $score) Instance))
(= (removeInstScore (mkSInst (mkPair $inst $score))) $inst)

;; Samples or generates new instances at a specified distance from a center instance,
;; gives them the worst score, and updates the Deme by appending the new scored instances.
;; Params:
;;   $totalNeighbors: Estimated number of neighbors at distance $dist.
;;   $numNewInstances: Desired number of new instances to add.
;;   $centerInst: Reference instance for distance calculations.
;;   $deme: Deme
;;   $dist: Distance from $centerInst for sampling/generating instances.
;; Returns:
;;   (Deme Number) - Tuple of updated Deme with new scored instances appended and number of new instances added.
;; (: sampleNewInstances (-> Number Number Instance Deme Number (Deme Number)))
(= (sampleNewInstances $totalNeighbors $numNewInstances $centerInst (mkDeme (mkRep (mkKbMap (mkDscMp $disc)) $tree) (mkSInstSet $instList) $demeId) $dist)
 (let*
  (
    ;; No first-knob lookup is needed here. Avoiding that unused access also
    ;; keeps an empty knob map on the normal representation-skip path.
    ($kbMp (mkKbMap (mkDscMp $disc)))
    ($updatedTotalNeighbors
         (if (> (* 2 $numNewInstances) $totalNeighbors)
             (countNeighborhood $kbMp $centerInst $dist $numNewInstances)
             $totalNeighbors))
    ($newInstances (if (< $numNewInstances $updatedTotalNeighbors)
                       (sampleFromNeighborhood $numNewInstances $dist $kbMp $centerInst)
                       (generateAllInNeighborhoodForDisc (mkDscMp $disc) $centerInst $dist)))
    ($scoredNewInstances (List.map initInstScore $newInstances))
    ;; A sampled vector can be repeated or can already be present in the deme.
    ;; Preserve sampling order, append only genuinely new vectors, and return
    ;; the number of rows that can require a scorer call.
    ($freshInstances
      (uniqueUnseenScoredInstances $scoredNewInstances $instList))
    ($updatedInstList (List.concat $instList $freshInstances))
    ($actualNewInstances (List.length $freshInstances))
 )
 ((mkDeme (mkRep $kbMp $tree) (mkSInstSet $updatedInstList) $demeId)
  $actualNewInstances)))

;; Remove duplicate sampled rows and rows whose instances are already present
;; in the deme, preserving the first occurrence and its sample order.
(= (uniqueUnseenScoredInstances $sampledRows $existingRows)
   (let* (
          ($existingInstances (map-atom $existingRows $row (removeInstScore $row)))
          ($uniqueSampledRows (unique-atom $sampledRows))
         )
     (filter-atom $uniqueSampledRows $row
       (not
         (once
           (is-member (removeInstScore $row) $existingInstances))))))

;; Similar to sampleNewInstances above, but for feature selection.
;; It uses countNeighborhoodFs, sampleFromNeighborhoodFs and initInstScoreFs.
;; The multiplicity is 2 (the values 0 and 1).

;; (: sampleNewInstancesFs (-> Number Number Instance (ITable Bool) (InstanceSet $a) Number ((InstanceSet $a) Number)))
(= (sampleNewInstancesFs $totalNeighbors $numNewInstances $centerInst $itable (mkSInstSet $instList) $dist)
 (let*
  (
    ($updatedTotalNeighbors
         (if (> (* 2 $numNewInstances) $totalNeighbors)
             (countNeighborhoodFs $centerInst $dist $numNewInstances)
             $totalNeighbors))
    ($newInstances (if (< $numNewInstances $updatedTotalNeighbors)
                       (sampleFromNeighborhoodFs $numNewInstances $dist $itable $centerInst)
                       (generateAllInNeighborhood (mkMultip 2) $centerInst $dist)))
    ($scoredNewInstances (List.map initInstScoreFs $newInstances))
    ;; Feature-selection populations obey the same append-only contract:
    ;; retain old rows, discard duplicate vectors, and count only fresh suffix
    ;; rows that the mutual-information scorer will actually receive.
    ($freshInstances
      (uniqueUnseenScoredInstances $scoredNewInstances $instList))
    ($updatedInstList (List.concat $instList $freshInstances))
    ($actualNewInstances (List.length $freshInstances))
 )
 ((mkSInstSet $updatedInstList) $actualNewInstances)))
