;; Cube root approximation using power function
;; Used to estimate sorting size for 3-simplex selection
(= (cbrt-math $n)
   (pow-math $n (/ 1 3)))

;; Extracts raw instance from scored instance wrapper (mkSInst)
;; Used before applying merge operations
(= (getInst (mkSInst (mkPair $inst $score)))
  (match &self (mkSInst (mkPair $inst $score) $inst)))


;; Merges three instances into one using sequential application:
;; k -> iRef -> jRef using mergeInstance
;; Produces a new scored instance with worst score placeholder
(= (mergeTriple $kInst $base $iRef $jRef)
   (let* (
        ($temp (mergeInstance $kInst $base $iRef))
        ($final  (mergeInstance $temp $base $jRef))
          )
      (mkSInst (mkPair $final (worstCscore)))
))


;; crossInnerLoop
;; Combines k-candidates with fixed iRef and jRef
(= (crossInnerLoop Nil $jRef $iRef $base $acc $limit) $acc)

(= (crossInnerLoop (Cons $k $kRest) $jRef $iRef $base $acc $limit)
   (if (>= (List.length $acc) $limit)
        $acc
       (let $newAcc (mergeTriple (getInst $k) $base $iRef $jRef)
            (crossInnerLoop $kRest $jRef $iRef $base (Cons $newAcc $acc) $limit))
       )
)


;; crossMiddleLoop
;; Iterates over j candidates and triggers inner k-loop
;; Builds pairwise structure for fixed iRef
(= (crossMiddleLoop Nil $iRef $kList $base $acc $limit) $acc)

(= (crossMiddleLoop (Cons $j $jRest) $iRef $kList $base $acc $limit)
   (if (>= (List.length $acc) $limit)
       $acc
       (let $newAcc (crossInnerLoop $kList (getInst $j) $iRef $base $acc $limit)
              (crossMiddleLoop $jRest $iRef $kList $base $newAcc $limit))
))


;; crossOuterLoop wraper
(= (crossOuterLoop $list $base $limit)
   (crossOuterLoop-iter $list $list $base Nil $limit)
)



;; Iterates over i candidates and manages j/k generation
;; Maintains prefix list for simplex combinationsr
(= (crossOuterLoop-iter (Cons $i $iRest) $prefix $base $acc $limit)
   (if (>= (List.length $acc) $limit)
       $acc
       (let $newAcc (crossMiddleLoop $iRest (getInst $i)  $prefix $base $acc $limit)
            (crossOuterLoop-iter $iRest (Cons $i $prefix) $base $newAcc $limit))
       )
   )


