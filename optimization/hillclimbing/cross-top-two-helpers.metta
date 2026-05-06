
;; Merge two instances using a base instance 
(= (mergeTargetToRef $target $base $reference )
   (mergeInstance $target $base $reference))
   


;; Generate newinstances by crossing a fixed reference instance with a list of targets
(= (crossPairsToRef Nil $reference $base $acc $limit) $acc)

(= (crossPairsToRef (Cons $target $rest) $reference $base $acc $limit)
   (if (>= (List.length $acc) $limit)
       $acc
       (let $merged (mergeTargetToRef  (getInst $target) $base $reference)
                (crossPairsToRef $rest $reference $base (Cons (mkSInst (mkPair $merged (worstCscore))) $acc) $limit))
))


;; Iterate over all reference instances to build full pairwise crossover set
(= (crossPairs $list $base $limit)
   (crossPairsIter $list $base Nil $limit))


;; Recursive accumulator loop for pairwise crossover generation
(= (crossPairsIter Nil $base $acc $limit) $acc)

(= (crossPairsIter (Cons $reference $rest) $base $acc $limit)
   (if (>= (List.length $acc) $limit)
       $acc
       (let $newAcc (crossPairsToRef $rest (getInst $reference) $base $acc $limit)
            (crossPairsIter $rest $base $newAcc $limit))
))










