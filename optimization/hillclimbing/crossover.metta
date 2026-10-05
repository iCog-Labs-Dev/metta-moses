;; crossTopOne --       Cross the single top-scoring instance against the next-highest scorers.
;;                      As arguments, accepts a range of scored instances ("the sample"),
;;                      and a single instance from which these were all derived ("the base"
;;                      or center instance). This will create a number of new instances,
;;                      which will be a cross of the highest-scoring instance with the
;;                      next-highest scoring instances.

; (: crossTopOne (-> Deme Number Number Number Instance Deme))
 (= (crossTopOne $deme $nToMake $sampleStart $sampleSize $baseInstance)
   (let*
      (
       ((mkDeme $rep (mkSInstSet $instSet) $demeId) $deme)

       ($nToMakeNew (if (< (- $sampleSize 1) $nToMake) (- $sampleSize 1) $nToMake))
       (($prevInst $newInst) (List.splitAt $sampleStart $instSet))
       ;; Restrict partial_sort to the recorded sample window and request one
       ;; reference plus nToMake targets.
       ($sample (List.takeN $sampleSize $newInst))
       ($list (List.partialSort instance> $sample (+ $nToMakeNew 1) ()))
      )
      (if (== $list ())
          ()
          (let*
             (
              ((cons $reference $rest) $list)

              ($targetExpr (List.takeN $nToMakeNew $rest))
              ((mkSInst (mkPair $referenceInst $referenceScore)) $reference)

              ($newInstances (merger $targetExpr $baseInstance $referenceInst))
              )
             $newInstances
          ))))

;; similar to the above 'crossTopOne' but with slight changes on the comparison function that is passed to the Lost.partialSort to compare the mutualInformation based scores
; (: crossTopOneFs (-> (InstanceSet $a) Number Number Number Instance (InstanceSet $a)))
(= (crossTopOneFs (mkSInstSet $instSet) $nToMake $sampleStart $sampleSize $baseInstance)
   (let* (
           ($nToMakeNew (if (< (- $sampleSize 1) $nToMake) (- $sampleSize 1) $nToMake))
           (($prevInst $newInst) (List.splitAt $sampleStart $instSet))
           ($sample (List.takeN $sampleSize $newInst))
           ($list (List.partialSort instanceFs>= $sample $nToMakeNew ()))
         )
         (if (== $list ())
             (mkSInstSet $instSet)
             (let*
               (
                 ((cons $reference $rest) $list)
                 ($targetInstances (List.takeN (- $nToMake 1) $rest))
                 ($targetExpr (List.listToExpr $targetInstances))

                 ((mkSInst (mkPair $referenceInst $referenceScore)) $reference)
                 ($newInstances (mergerFs $targetExpr $baseInstance $referenceInst))
                 ($uniqueNewInstances (unique-atom (exprToList $newInstances)))
                 ;; The unified incremental scorer relies on an append-only
                 ;; population: preserve every existing scored row and add
                 ;; only genuinely new instance payloads at the end.
                 ($existingInstances
                   (map-atom $instSet $row
                     (getInst $row)))
                 ($freshNewInstances
                   (filter-atom $uniqueNewInstances $row
                     (not
                       (once
                         (is-member
                           (getInst $row)
                           $existingInstances)))))
               )
               (mkSInstSet
                 (List.appendList $freshNewInstances $instSet))))))

;; crossTopTwo
;; Performs 2-simplex crossover (pairwise combinations).
;; Selects top-ranked instances, partially sorts them, and generates offspring by
;; crossing each reference instance with all better-ranked instances.
;; Ensures O(n²) combinations are bounded by num-to-make and sample size.
;; Returns only the generated offspring instances as a list.
;; Does not modify or append to the original deme.
;; Intended for use by a higher-level crossover routine that combines
;; offspring instances from multiple crossover operators and merges them back into
;; the population
(= (crossTopTwo $deme $nToMake $sampleStart $sampleSize $baseInstance)

   (let*
     (
      ((mkDeme $rep (mkSInstSet $instSet) $demeId) $deme)
      (($prevInst $newInst) (List.splitAt $sampleStart $instSet))
      ;; Match the half-open [sampleStart, sampleStart + sampleSize) range
      ;; passed to std::partial_sort in C++.
      ($sample (List.takeN $sampleSize $newInst))

      ($pairCount (/ (* $sampleSize (- $sampleSize 1)) 2))
      ($nToMakeNew (if (< $pairCount $nToMake) $pairCount $nToMake))

       ;; C++ assigns sqrt(2*n)+3 to unsigned, truncating the estimate.
       ($nToSortRaw (int (+ (sqrt-math (* 2 $nToMakeNew)) 3)))
       ($nToSort (if (< $sampleSize $nToSortRaw) $sampleSize $nToSortRaw))

       ($sortedList (List.partialSort instance> $sample $nToSort ()))

       ;; C++ traverses the complete sample; only its top nToSort prefix is
       ;; ordered. The result limit stops traversal before the unsorted tail
       ;; can affect the intended simplex prefix.
       ($newInstances (crossPairs () $sortedList $baseInstance () $nToMakeNew))
       )
      $newInstances
      ))

;; cbrt-math -- Approximate cube root.
;;              Used to estimate how many top-ranked instances should be
;;              selected so enough triple combinations can be generated.n
(= (cbrt-math $n)
   (pow-math $n (/ 1 3)))

;; crossTopThree
;; Performs 3-simplex crossover (triple combinations).
;; Selects top-ranked instances and generates offspring using nested merges:
;; a target instance is copied, then merged with two higher-ranked references.
;; Approximates O(n³) combinations but bounds the number generated using
;; cube-root sampling and the requested crossover budget.
;; Produces diverse offspring while limiting combinatorial explosion.
;; Returns only the generated offspring instances as a list.
;; Does not modify or append to the original deme.
;; Intended for use by a higher-level crossover routine that combines
;; insatances from multiple crossover operators and merges them back into
;; the population.
(= (crossTopThree $deme $nToMake $sampleStart $sampleSize $baseInstance)
  (let*
     (
      ((mkDeme $rep (mkSInstSet $instSet) $demeId) $deme)

        (($prevInst $newInst) (List.splitAt $sampleStart $instSet))
        ;; Restrict ranking to the recorded C++ sample window.
        ($sample (List.takeN $sampleSize $newInst))

        ;; sample_size choose 3
        ($tripleFactor (* (- $sampleSize 1) (- $sampleSize 2)))
        ($maxTriples (/ (* $sampleSize $tripleFactor) 6))
        ($nToMakeNew (if (< $maxTriples $nToMake) $maxTriples $nToMake))

       ;; C++ stores cbrt(6*n)+3 in unsigned before using it as an index.
       ($nToSortRaw (int (+ (cbrt-math (* 6 $nToMakeNew)) 3)))
       ($nToSort (if (< $sampleSize $nToSortRaw) $sampleSize $nToSortRaw))
       ($sortedList (List.partialSort instance> $sample $nToSort ()))

        ;; The C++ i-loop traverses the full sample after partially sorting its
        ;; prefix.
        ($newInstances
          (crossTriples () $sortedList 0 $baseInstance
            (makeCrossoverSlots $nToMakeNew) $nToMakeNew))
        )

       $newInstances
    ))
