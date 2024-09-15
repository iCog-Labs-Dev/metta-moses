;; !(register-module ../../metta-moses-reduction)
;; !(import! &self compress-tree)
;; !(import! &self helpers)

;;!(compressTree (AND (AND (AND x1 x2) (OR y1 y2)) c) NONE ())

(if (eq NONE NONE) 
    (case (AND (AND (AND x1 x2) (OR y1 y2)) c) 
            (
                (($op#45 $left#46 $right#47) 
                    (let* (
                            ($leftRecursion#48 (compressTree $left#46 () $op#45)) 
                            ($rightRecursion#49 (compressTree $right#47 () $op#45)) 
                            ($opAccumulator#50 (cons-atom $op#45 ())) 
                            ($leftAccumulated#51 (cons-atom $left#46 ())) 
                            ($rightAccumulated#52 (cons-atom $right#47 $leftAccumulated#51))
                        ) 
                        $rightAccumulated#52
                    )
                )
            )
        ) (let* (
            ($head#53 (car-atom (AND (AND (AND x1 x2) (OR y1 y2)) c))) 
            ($tail#54 (cdr-atom (AND (AND (AND x1 x2) (OR y1 y2)) c))) 
            ($isHeadJunctor#55 (or (== OR $head#53) (== AND $head#53)))
            ) (if $isHeadJunctor#55 
                (if (eq $head#53 NONE) 
                    (let* (
                        ($newAccum#56 (unlist () $tail#54))
                        ) (compressTree $tail#54 NONE $newAccum#56)
                    ) (compressTree $tail#54 $head#53 ())
                ) (let $updatedAccum#57 (cons-atom $head#53 ()) 
                    (compressTree $tail#54 NONE $updatedAccum#57)
                )
            )
        )
    )

