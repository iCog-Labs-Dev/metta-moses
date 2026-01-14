
;; crossover --  a helper function for 
; (: swapValue (-> $a $a $a $a))                        
(= (swapValue $t $b $r) (if (== $b $r) $t $r))
          
; compareAndSwap -- iteratively compares the base and refrence instances and applies the crossover to the target at the location where there is difference between the two
;;              (Cons $t $ts) -- the target list
;;              (Cons $b $bs) -- the base list
;;              (Cons $r $rs) -- the reference list
;;              $acc          -- an accumulator for the new to be formed instance list
; (: compareAndSwap (-> (List $a) (List $a) (List $a) (List $a) (List $a)))
(= (compareAndSwap (Cons $t $ts) (Cons $b $bs) (Cons $r $rs) $acc)
    (case $ts
        ((Nil (let $crossover (swapValue $t $b $r) (List.append $crossover $acc)))
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
            (mkInst (compareAndSwap $target $base $reference Nil))
            (Error ($tSize $bSize $rSize) "Unequal target base and/or reference sizes")))
)


;; merger --          handles the non-deterministic operation of crossing over from the reference instance to the target instances             
;;                    $targetInstances -- an expression of scored instances
;;                    $baseInst         -- a based instance without its score
;;                    $referenceInst    -- a reference (best instance) instance without its score
;; ;; returns an expression of Scored instances with the new instances recieveing the worst composite possible score 
;  (: merger (-> Expression Instance Instance Expression))
 (= (merger $targetInstances $baseInst $referenceInst)
     (collapse (let (mkSInst (mkPair $targetInst $score)) (superpose $targetInstances)
        (mkSInst (mkPair (mergeInstance $targetInst $baseInst $referenceInst) (worstCscore))))))

;; similar to the above 'merger' but with slight modification on the initial score to be 0 in case of feature selection
; (: mergerFs (-> Expression Instance Instance Expression))
 (= (mergerFs $targetInstances $baseInst $referenceInst)
     (collapse (let (mkSInst (mkPair $targetInst $score)) (superpose $targetInstances)
        (mkSInst (mkPair (mergeInstance $targetInst $baseInst $referenceInst) 0)))))