
;; crossover --  a helper function for 
; (: swapValue (-> $a $a $a $a))                        
(= (swapValue $t $b $r) (if (== $b $r) $t $r))
          
; compareAndSwap -- iteratively compares the base and refrence instances and applies the crossover to the target at the location where there is difference between the two
;;              (cons $t $ts) -- the target list
;;              (cons $b $bs) -- the base list
;;              (cons $r $rs) -- the reference list
;;              $acc          -- an accumulator for the new to be formed instance list
; (: compareAndSwap (-> (List $a) (List $a) (List $a) (List $a) (List $a)))
(= (compareAndSwap (cons $t $ts) (cons $b $bs) (cons $r $rs) $acc)
    (case $ts
        ((() (let $crossover (swapValue $t $b $r) (List.append $crossover $acc)))
         ($else (let $updatedTarget (List.append (swapValue $t $b $r) $acc)
                        (compareAndSwap $ts $bs $rs $updatedTarget))))))


;; mergeInstance -- handles the crossover of single instance   
;;               $target -- the instance to be changed with new values from the reference
;;               $base   -- the instance which is going to be compared to the reference instance     
;;               $reference -- the reference instance
; (: mergeInstance (-> Instance Instance Instance Instance))
(= (mergeInstance (mkInst $target) (mkInst $base) (mkInst $reference))
    (let ($tSize $bSize $rSize) ((List.length $target) (List.length $base) (List.length $reference))
        (if (and (== $tSize $bSize) (== $tSize $rSize))
            (mkInst (compareAndSwap $target $base $reference ()))
            (Error ($tSize $bSize $rSize) "Unequal target base and/or reference sizes")))
)


;; merger --          handles the non-deterministic operation of crossing over from the reference instance to the target instances             
;;                    $targetInstances -- an expression of scored instances
;;                    $baseInst         -- a based instance without its score
;;                    $referenceInst    -- a reference (best instance) instance without its score
;; ;; returns an expression of Scored instances with the new instances recieveing the worst composite possible score 
;  (: merger (-> Expression Instance Instance Expression))
 (= (merger $targetInstances $baseInst $referenceInst)
     (map-atom $targetInstances $tI 
        (let (mkSInst (mkPair $targetInst $score)) $tI 
             (let $mergedInstance (mergeInstance $targetInst $baseInst $referenceInst)
                  (mkSInst (mkPair $mergedInstance (worstCscore)))))))

;; similar to the above 'merger' but with slight modification on the initial score to be 0 in case of feature selection
; (: mergerFs (-> Expression Instance Instance Expression))
 (= (mergerFs $targetInstances $baseInst $referenceInst)
     (map-atom $targetInstances $tI 
         (let (mkSInst (mkPair $targetInst $score)) $tI (mkSInst (mkPair (mergeInstance $targetInst $baseInst $referenceInst) 0)))))


;;   -------crossTopTwo Helepers----;;

;; crossPairsToRef -- Cross a reference instance against the remaining
;;                    candidate instances and accumulate the offspring..
(= (crossPairsToRef () $reference $base $acc $limit)
   $acc)

(= (crossPairsToRef (cons $target $rest) $reference $base $acc $limit)
   (if (>= (List.length $acc) $limit)
       $acc
       (let*
         (
           ((mkSInst (mkPair $targetInst $targetScore)) $target)
           ($merged (mkSInst (mkPair (mergeInstance $targetInst $base $reference) (worstCscore)))))
         (crossPairsToRef $rest $reference $base (cons $merged $acc) $limit))))


;; crossPairs -- Generate pairwise crossover combinations among
;;               the selected top-scoring instances.
;; used by crossTopTwo.

(= (crossPairs () $base $acc $limit)
   $acc)

;; Select current reference instance and generate
;; all offspring against the remaining candidates.
(= (crossPairs (cons $reference $rest) $base $acc $limit)
   (if (>= (List.length $acc) $limit)
       $acc
       (let*
         (
           ((mkSInst (mkPair $referenceInst $referenceScore)) $reference)

           ($updatedAcc (crossPairsToRef $rest $referenceInst $base $acc $limit)))
         (crossPairs $rest $base $updatedAcc $limit))))



;;-------- crossTopThree Helpers-------;;

;; crossTriplesToRef -- Cross a target instance against two reference
;;                      instances in sequence and accumulate offspring.
(= (crossTriplesToRef () $jRef $iRef $base $acc $limit) $acc)

(= (crossTriplesToRef (cons $target $rest) $jRef $iRef $base $acc $limit)
   (if (>= (List.length $acc) $limit)
       $acc
       (let*
         (
           ((mkSInst (mkPair $targetInst $score)) $target)
           ($merged (mkSInst (mkPair (mergeInstance (mergeInstance $targetInst $base $iRef) $base $jRef) (worstCscore)))))
           (crossTriplesToRef $rest $jRef $iRef $base (cons $merged $acc) $limit))))


;; crossTripleMiddle -- For a fixed reference instance, generate
;;                      crossover offspring using lower-ranked references

(= (crossTripleMiddle () $iRef $base $acc $limit) $acc)


(= (crossTripleMiddle (cons $j $jRest) $iRef $base $acc $limit)
   (if (>= (List.length $acc) $limit)
       $acc
       (let*
         (((mkSInst (mkPair $jInst $jScore)) $j)
           ($updatedAcc (crossTriplesToRef $jRest $jInst $iRef $base $acc $limit)))

       (crossTripleMiddle $jRest $iRef $base $updatedAcc $limit))))
       

;; crossTriples -- Generate triple-wise crossover combinations among
;;                 the selected top-scoring instances.
;; used by crossTopThree.

(= (crossTriples () $base $acc $limit) $acc)

(= (crossTriples (cons $i $iRest) $base $acc $limit)
   (if (>= (List.length $acc) $limit)
       $acc
       (let*
         (
           ((mkSInst (mkPair $iInst $iScore)) $i)
           ($updatedAcc (crossTripleMiddle $iRest $iInst $base $acc $limit)))
           (crossTriples $iRest $base $updatedAcc $limit))))