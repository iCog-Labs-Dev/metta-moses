;; crossTopOne --       Cross the single top-scoring instance against the next-highest scorers.
;;                      As arguments, accepts a range of scored instances ("the sample"),
;;                      and a single instance from which these were all derived ("the base"
;;                      or center instance). This will create a number of new instances,
;;                      which will be a cross of the highest-scoring instance with the
;;                      next-highest scoring instances.

; (: crossTopOne (-> Deme Number Number Number Instance Deme))
;; TODO: Make use of the $sampleStart 
;; This is how the openCog classic does it but the reason isn't yet clear but 
;;   I suspect it is to prevent crossovering over an already crossed over 
;;   population and focus on newly generated instances only.
(= (crossTopOne $deme $nToMake $sampleStart $sampleSize $baseInstance)
            (let* (
                    ((mkDeme (mkRep (mkKbMap (mkDscMp $dscMp)) $tree) (mkSInstSet $instSet) $demeId) $deme)
                    ;; ($_ (println! (Inside crossTopOne)))
                    ($nToMakeNew (if (< (- $sampleSize 1) $nToMake) (- $sampleSize 1) $nToMake))
                    ;; ($_ (println! (SampleSize: $sampleSize NToMake: $nToMakeNew SampleStart: $sampleStart totalSize: (List.length $instSet))))
                    (($prevInst $newInst) (List.splitAt $sampleStart $instSet))
                    ;; ($list (List.partialSort instance> $newInst $nToMakeNew)) ;; deconstruct the partial sorted set of instances into the reference and the rest and take the next N values from the rest for crossover
                    ($list (List.partialSort instance> $newInst $nToMakeNew ())) ;; deconstruct the partial sorted set of instances into the reference and the rest and take the next N values from the rest for crossover

                    ;; ($_ (println! (ListLength: (List.length $list))))
                  )
                  (if (== $list ())
                      (mkDeme (mkRep (mkKbMap (mkDscMp $dscMp)) $tree) (mkSInstSet $instSet) $demeId)
                      (let*
                        (
                          ((cons $reference $rest) $list)
                          ($targetExpr (List.takeN (- $nToMake 1) $rest))

                          ((mkSInst (mkPair $referenceInst $referenceScore)) $reference)
                          ($newInstances (merger $targetExpr $baseInstance $referenceInst))
                          ;; ($_ (println! (Merger: $newInstances)))
                          ;; ($uniqueInstances (unique-atom $newInstances))
                          ;; ($_ (println! (NewInstances: (length $newInstances) UniqueInstances: (length $uniqueInstances))))
                          ;; ($__ (println! (New instances After merging: $newInstances)))
                          ;; ($_ (println! ""))
                          ;; ($_ (println! (PrevInst: $prevInst)))
                        )
                        (mkDeme (mkRep (mkKbMap (mkDscMp $dscMp)) $tree) (mkSInstSet (List.appendList (exprToList $newInstances) $instSet)) $demeId)))))

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
;; Result is appended back into the original deme.
  (= (crossTopTwo $deme $nToMake $sampleStart $sampleSize $baseInstance)

   (let*

     (
      ((mkDeme (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $tree) (mkSInstSet $instSet) $demeId) $deme)
      (($prevInst $newInst) (List.splitAt $sampleStart $instSet))

      ($pairCount (/ (* $sampleSize (- $sampleSize 1)) 2))
      ($nToMakeNew (if (< $pairCount $nToMake) $pairCount $nToMake))

       ($nToSortRaw (+ (sqrt-math (* 2 $nToMakeNew)) 3))
       ($nToSort (if (< $sampleSize $nToSortRaw) $sampleSize $nToSortRaw))

       ($sortedList (List.partialSort instance> $newInst $nToSort ()))

       ($topInsts (List.takeN $nToSort $sortedList))

       ($newInstances (crossPairs () $topInsts $baseInstance () $nToMakeNew))
       )

     (mkDeme (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $tree)
            (mkSInstSet (List.appendList (exprToList $newInstances) $instSet)) $demeId)))
  

;; cbrt-math -- Approximate cube root.
;;              Used to estimate how many top-ranked instances should be
;;              selected so enough triple combinations can be generated.n
(= (cbrt-math $n)
   (pow-math $n (/ 1 3)))

;; crossTopThree
;; Performs 3-simplex crossover (triple combinations).
;; Selects top-ranked instances and generates offspring using nested merges:
;; target instance is copied, then merged with two higher-ranked references.
;; Approximates O(n³) combinations but bounded using cube-root sampling.
;; Produces diverse offspring while limiting combinatorial explosion.
;; Result is appended back into the original deme.
(= (crossTopThree $deme $nToMake $sampleStart $sampleSize $baseInstance)
  (let*
     (
     ((mkDeme (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $tree) (mkSInstSet $instSet) $demeId) $deme)

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
    (mkDeme (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $tree)
    (mkSInstSet (List.appendList (exprToList $newInstances) $instSet)) $demeId)))

 