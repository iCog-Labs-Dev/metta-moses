;; crossTopOne --       Cross the single top-scoring instance against the next-highest scorers.
;;                      As arguments, accepts a range of scored instances ("the sample"),
;;                      and a single instance from which these were all derived ("the base"
;;                      or center instance). This will create a number of new instances,
;;                      which will be a cross of the highest-scoring instance with the
;;                      next-highest scoring instances.

(: crossTopOne (-> Deme Number Number Number Instance Deme))
(= (crossTopOne $deme $nToMake $sampleStart $sampleSize $baseInstance)
    (trace! (Inside crossTopOne: $nToMake $sampleStart $sampleSize) 
            (let* (
                    ((mkDeme (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $tree) (mkSInstSet $instSet) $demeId) $deme)
                    (() (println! (Inside crossTopOne)))
                    ($nToMakeNew (if (< (- $sampleSize 1) $nToMake) (- $sampleSize 1) $nToMake))
                    ;; (() (println! (NToMake: $nToMakeNew)))
                    ((Cons $reference $rest) (List.partialSort instance>= $instSet $nToMakeNew Nil)) ;; deconstruct the partial sorted set of instances into the reference and the rest and take the next N values from the rest for crossover
                    ($targetInstances (List.takeN (- $nToMake 1) $rest))
                    ($targetExpr (List.listToExpr $targetInstances))

                    ((mkSInst (mkPair $referenceInst $referenceScore)) $reference)
                    ($newInstances (merger $targetExpr $baseInstance $referenceInst))
                    (() (println! (New instances After merging: $newInstances)))
                    (() (println! "")))
                (mkDeme (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $tree) (mkSInstSet (List.appendList (pyExprToList $newInstances) $instSet)) $demeId))))

;; merger --          handles the non-deterministic operation of crossing over from the reference instance to the target instances             
;;                    $targetInstances -- an expression of scored instances
;;                    $baseInst         -- a based instance without its score
;;                    $referenceInst    -- a reference (best instance) instance without its score
;; ;; returns an expression of Scored instances with the new instances recieveing the worst composite possible score 
;; (: merger (-> Expression Instance Instance Expression))
;; (= (merger $targetInstances $baseInst $referenceInst)
;;     (collapse (let (mkSInst (mkPair $targetInst $score)) (superpose $targetInstances)
;;        (mkSInst (mkPair (mergeInstance $targetInst $baseInst $referenceInst) (worstCscore))))))

;; mergeInstance -- handles the crossover of single instance   
;;               $target -- the instance to be changed with new values from the reference
;;               $base   -- the instance which is going to be compared to the reference instance     
;;               $reference -- the reference instance
(: mergeInstance (-> Instance Instance Instance Instance))
(= (mergeInstance (mkInst $target) (mkInst $base) (mkInst $reference))
    (let ($tSize $bSize $rSize) ((List.length $target) (List.length $base) (List.length $reference))
        (if (and (== $tSize $bSize) (== $tSize $rSize))
            (mkInst (compareAndSwap $target $base $reference Nil))
            (Error ($tSize $bSize $rSize) "Unequal target base and/or reference sizes"))))

;; compareAndSwap -- iteratively compares the base and refrence instances and applies the crossover to the target at the location where there is difference between the two
;;              (Cons $t $ts) -- the target list
;;              (Cons $b $bs) -- the base list
;;              (Cons $r $rs) -- the reference list
;;              $acc          -- an accumulator for the new to be formed instance list
(: compareAndSwap (-> (List $a) (List $a) (List $a) (List $a) (List $a)))
(= (compareAndSwap (Cons $t $ts) (Cons $b $bs) (Cons $r $rs) $acc)
    (case $ts
        ((Nil (let $crossover (swapValue $t $b $r) (List.append $crossover $acc)))
         ($else (let $updatedTarget (List.append (swapValue $t $b $r) $acc)
                        (compareAndSwap $ts $bs $rs $updatedTarget))))))

;; crossover --  a helper function for 
(: swapValue (-> $a $a $a $a))                        
(= (swapValue $t $b $r) (if (== $b $r) $t $r))          
