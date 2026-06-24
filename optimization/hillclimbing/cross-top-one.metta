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
       ($list (List.partialSort instance> $newInst $nToMakeNew ()))
      )
      (if (== $list ())
          ()
          (let*
             (
              ((cons $reference $rest) $list)

              ($targetExpr (List.takeN (- $nToMakeNew 1) $rest))
              ((mkSInst (mkPair $referenceInst $referenceScore)) $reference)

              ($newInstances (merger $targetExpr $baseInstance $referenceInst))
              )
             (exprToList $newInstances)
          ))))

;; similar to the above 'crossTopOne' but with slight changes on the comparison function that is passed to the Lost.partialSort to compare the mutualInformation based scores
; (: crossTopOneFs (-> (InstanceSet $a) Number Number Number Instance (InstanceSet $a)))
(= (crossTopOneFs (mkSInstSet $instSet) $nToMake $sampleStart $sampleSize $baseInstance)
   (let* (
           ;; ($_ (println! (Inside crossTopOneFs)))
           ($nToMakeNew (if (< (- $sampleSize 1) $nToMake) (- $sampleSize 1) $nToMake))
           ;; ($_ (println! (NToMake: $nToMakeNew)))
           (($prevInst $newInst) (List.splitAt $sampleStart $instSet))
           ($list (List.partialSort instanceFs>= $newInst $nToMakeNew ())) ;; deconstruct the partial sorted set of instances into the reference and the rest and take the next N values from the rest for crossover
           ;; ($_ (println! (New instances After merging: $newInstances)))
           ;; ($_ (println! ""))
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
               )
               (mkSInstSet (List.appendList (exprToList $newInstances) $newInst))))))

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

      ($pairCount (/ (* $sampleSize (- $sampleSize 1)) 2))
      ($nToMakeNew (if (< $pairCount $nToMake) $pairCount $nToMake))

       ($nToSortRaw (+ (sqrt-math (* 2 $nToMakeNew)) 3))
       ($nToSort (if (< $sampleSize $nToSortRaw) $sampleSize $nToSortRaw))

       ($sortedList (List.partialSort instance> $newInst $nToSort ()))

       ($topInsts (List.takeN $nToSort $sortedList))

       ($newInstances (crossPairs () $topInsts $baseInstance () $nToMakeNew))
       )

      (exprToList $newInstances)
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

        ;; sample_size choose 3
        ($tripleFactor (* (- $sampleSize 1) (- $sampleSize 2)))
        ($maxTriples (/ (* $sampleSize $tripleFactor) 6))
        ($nToMakeNew (if (< $maxTriples $nToMake) $maxTriples $nToMake))

       ($nToSortRaw (+ (cbrt-math (* 6 $nToMakeNew)) 3))
       ($nToSort (if (< $sampleSize $nToSortRaw) $sampleSize $nToSortRaw))
       ($sortedList (List.partialSort instance> $newInst $nToSort ()))

        ($topInsts (List.takeN $nToSort $sortedList))
        ($newInstances (crossTriples () $topInsts $baseInstance () $nToMakeNew))
        )

       (exprToList $newInstances)
    ))
