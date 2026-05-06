; ;; crossTopTwo -- Cross pairs of high-scoring instances in a 2-simplex pattern.

;;       Generates new instances by pairwise crossover of top-ranked instances - 2-simplex
;;       Each pair (j < i) is merged using a base instance to create new instance.


;; (: crossTopTwo (-> Deme Number Number Number Instance Deme))
(= (crossTopTwo $deme $nToMake $sampleStart $sampleSize $baseInstance)
   (let* (

        ;; Extract representation, instance set, and ID from deme
        ((mkDeme (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $tree) (mkSInstSet $instSet) $demeId) $deme)
         (($prevInst $newInst) (List.splitAt $sampleStart $instSet))

        ;; Ensure number of generated instances does not exceed possible pair combinations
        ($maxPairs (/ (* $sampleSize (- $sampleSize 1)) 2))
        ($nToMakeNew (if (< $maxPairs $nToMake) $maxPairs $nToMake))

        ($nToSort  (+ (sqrt-math (* 2 $nToMakeNew)) 3))

        ;; Select and partially sort top-scoring instances for crossover
        ($sortedList (List.partialSort instance> $newInst $nToSort Nil))
    )
       (if (== $sortedList Nil)
            $deme
            (let* (

                ;; Select top-K instances to form crossover pool
                ($instList (List.takeN $nToSort $sortedList))

                ;; Generate newInstances by crossing each higher-score instance with all lower-score ones
                ($newInstances (crossPairs $instList $baseInstance $nToMakeNew))
            )
            (mkDeme 
                (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $tree)
                (mkSInstSet (List.appendList (exprToList $newInstances) $instSet))
                 $demeId)
           )
        ))
)







