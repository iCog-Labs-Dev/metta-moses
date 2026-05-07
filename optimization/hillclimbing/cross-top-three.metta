
;; Performs 3-simplex crossover on a sorted subset of a deme.
;; Generates new instances by combining triples (i, j, k)
;; where i > j > k, using hierarchical merging.

;; (: crossTopThree (-> Deme Number Number Number Instance Deme))
(= (crossTopThree $deme $nToMake $sampleStart $sampleSize $baseInstance)
   (let* (
        ;; Extract representation, instance set, and ID from deme
       ((mkDeme (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $tree) (mkSInstSet $instSet) $demeId) $deme)
        
        ;; Ensure number of generated instances does not exceed  the budget
        ($max (/ (* $sampleSize (* (- $sampleSize 1) (- $sampleSize 2))) 6))
        ($limit (if (< $max $nToMake) $max $nToMake))
        (($prevInst $newInst) (List.splitAt $sampleStart $instSet))

        ($nToSort (+ (cbrt-math (* 6 $limit)) 3))

        ;; Select and partially sort top-scoring instances for crossover
        ($sorted (List.partialSort instance> $newInst $nToSort Nil))
   )
   (if (== $sorted Nil)
       $deme
       (let* (
            ($instList (List.takeN $nToSort $sorted))
            ($newInstances (crossOuterLoop $instList $baseInstance $limit))
            )
            (mkDeme 
                (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $tree)
                (mkSInstSet (List.appendList  $newInstances $instSet))
                 $demeId)
       
       ))))
