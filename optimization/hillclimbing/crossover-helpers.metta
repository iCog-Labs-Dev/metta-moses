;;   -------crossTopTwo Helepers----;;

;; ----- Shared crossover helpers -----

;; Extract raw instance from scored wrapper
(= (getInst (mkSInst (mkPair $inst $score))) $inst)

;; Generate newinstances by  Crossing one reference instance with remaining candidates
(= (crossPairsToRef () $reference $base $acc $limit) $acc)

(= (crossPairsToRef (cons $target $rest) $reference $base $acc $limit)
   (if (>= (List.length $acc) $limit)
       $acc
       (let $merged (mergeInstance (getInst $target) $base $reference)
                (crossPairsToRef $rest $reference $base (cons (mkSInst (mkPair $merged (worstCscore))) $acc) $limit))
))


;; Generate pairwise crossover combinations
(= (crossPairs $list $base $limit)
   (crossPairsIter $list $base () $limit))


;; Acumulator loop for pairwise crossover generation
(= (crossPairsIter () $base $acc $limit) $acc)

(= (crossPairsIter (cons $reference $rest) $base $acc $limit)
   (if (>= (List.length $acc) $limit)
       $acc
       (let $updatedAcc(crossPairsToRef $rest (getInst $reference) $base $acc $limit)
            (crossPairsIter $rest $base $updatedAcc $limit))
))

;;-------- crossTopTwo operator -------;;

;;       Cross pairs of high-scoring instances in a 2-simplex pattern.
;;       Generates new instances by pairwise crossover of top-ranked instances - 2-simplex
;;       Each pair (j < i) is merged using a base instance to create new instance.

;; (: crossTopTwo (-> Deme Number Number Number Instance Deme))
(= (crossTopTwo $deme $nToMake $sampleStart $sampleSize $baseInstance)
   (let* 
   (
       ;; Extract representation, instance set, and ID from deme
        ((mkDeme (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $tree) (mkSInstSet $instSet) $demeId) $deme)
         (($prevInst $newInst) (List.splitAt $sampleStart $instSet))

        ;; Ensure number of generated instances does not exceed possible pair combinations
        ($pairCount (/ (* $sampleSize (- $sampleSize 1)) 2))
        ($nToMakeNew (if (< $pairCount $nToMake) $pairCount $nToMake))

        ($nToSort (+ (sqrt-math (* 2 $nToMakeNew)) 3))

        ;; Select and partially sort top-scoring instances for crossover
        ($sortedList (List.partialSort instance> $newInst $nToSort))
    )
       (if (== $sortedList ())
            $deme
            (let* (

                ;; Select top-K instances to form crossover pool
                ($topInsts (List.takeN $nToSort $sortedList))

                ;; Generate newInstances by crossing each higher-score instance with all lower-score ones
                ($newInstances (crossPairs $topInsts $baseInstance $nToMakeNew))
                ($uniqueInstances (unique-atom $newInstances))
            )
            (mkDeme 
                (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $tree)
                (mkSInstSet (List.appendList $uniqueInstances $instSet))
                 $demeId)
           )
        ))
)

;;-------- crossTopThree Helpers-------;;

;; Cube root approximation using power function
;; Used to estimate sorting size for 3-simplex selection
(= (cbrt-math $n)
   (pow-math $n (/ 1 3)))

;; Merges three instances into one using sequential application:
;; k -> iRef -> jRef using mergeInstance
;; Produces a new scored instance with worst score placeholder
(= (mergeTriple $kInst $base $iRef $jRef)
   (let* (
        ($temp (mergeInstance $kInst $base $iRef))
        ($res (mergeInstance $temp $base $jRef))
      )
   (mkSInst (mkPair $res (worstCscore)))
))

;; crossInnerLoop
;; Combines k-candidates with fixed iRef and jRef
(= (crossInnerLoop () $jRef $iRef $base $acc $limit) $acc)

(= (crossInnerLoop (cons $k $kRest) $jRef $iRef $base $acc $limit)
   (if (>= (List.length $acc) $limit)
        $acc
       (let $updatedAcc (mergeTriple (getInst $k) $base $iRef $jRef)
            (crossInnerLoop $kRest $jRef $iRef $base (cons $updatedAcc $acc) $limit))
       )
)

;; crossMiddleLoop
;; Iterates over j candidates and triggers inner k-loop
;; Builds pairwise structure for fixed iRef
(= (crossMiddleLoop () $iRef $kList $base $acc $limit) $acc)
(= (crossMiddleLoop (cons $j $jRest) $iRef $kList $base $acc $limit)
   (if (>= (List.length $acc) $limit)
       $acc
       (let $updatedAcc (crossInnerLoop $kList (getInst $j) $iRef $base $acc $limit)
              (crossMiddleLoop $jRest $iRef $kList $base $updatedAcc $limit))
))


;; crossOuterLoop wraper
(= (crossOuterLoop $list $base $limit)
   (crossOuterLoop-iter $list $list $base () $limit)
)

;; Iterates over i candidates and manages j/k generation
;; Maintains prefix list for simplex combinationsr
(= (crossOuterLoop-iter () $prefix $base $acc $limit) $acc)
(= (crossOuterLoop-iter (cons $i $iRest) $prefix $base $acc $limit)
   (if (>= (List.length $acc) $limit)
       $acc
       (let $updatedAcc (crossMiddleLoop $iRest (getInst $i)  $prefix $base $acc $limit)
            (crossOuterLoop-iter $iRest (cons $i $prefix) $base $updatedAcc $limit))
       )
   )

;;;;-----  crossTopThree operator ----------------;;;;   
;; Performs 3-simplex crossover on a sorted subset of a deme.
;; Generates new instances by combining triples (i, j, k)
;; where i > j > k, using hierarchical merging.

;; (: crossTopThree (-> Deme Number Number Number Instance Deme))
(= (crossTopThree $deme $nToMake $sampleStart $sampleSize $baseInstance)
   (let* (
        ;; Extract representation, instance set, and ID from deme
         ((mkDeme (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $tree) (mkSInstSet $instSet) $demeId) $deme)
          (($prevInst $newInst) (List.splitAt $sampleStart $instSet))
        
        ;; Ensure number of generated instances does not exceed  the budget
        ($tripleFactor (* (- $sampleSize 1) (- $sampleSize 2)))
        ($maxTriples (/ (* $sampleSize $tripleFactor ) 6))
        ($nToMakeNew (if (< $maxTriples $nToMake) $maxTriples $nToMake))
      
        ($nToSort (+ (cbrt-math (* $nToMakeNew 6)) 3))

        ;; Select and partially sort top-scoring instances for crossover
          ($sortedList (List.partialSort instance> $newInst $nToSort))
   )
   (if (== $sortedList ())
       $deme
       (let* (

            ($instList (List.takeN $nToSort $sortedList))
            ($newInstances (crossOuterLoop $instList $baseInstance $nToMakeNew))
            ($uniqueInstances (unique-atom $newInstances))
            
            )
            (mkDeme 
                (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $tree)
                (mkSInstSet (List.appendList  $uniqueInstances $instSet))
                 $demeId)
       
       ))))








