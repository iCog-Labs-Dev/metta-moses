
;; crossover --  a helper function for 
; (: swapValue (-> $a $a $a $a))                        
(= (swapValue $t $b $r) (if (== $b $r) $t $r))
          
; compareAndSwap -- iteratively compares the base and refrence instances and applies the crossover to the target at the location where there is difference between the two
;;              (cons $t $ts) -- the target list
;;              (cons $b $bs) -- the base list
;;              (cons $r $rs) -- the reference list
;;              $acc          -- an accumulator for the new to be formed instance list
; (: compareAndSwap (-> (List $a) (List $a) (List $a) (List $a) (List $a)))
;; Was O(N^2): List.append walks $acc each step. Switched to O(N) cons-then-reverse.
;; Profile: List.append/3 was 1.86s (2.8%) on 110K calls; now ~one reverse per merge.
(= (compareAndSwap (cons $t $ts) (cons $b $bs) (cons $r $rs) $acc)
    (case $ts
        ((() (reverse (cons-atom (swapValue $t $b $r) $acc)))
         ($else (compareAndSwap $ts $bs $rs (cons-atom (swapValue $t $b $r) $acc))))))


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
