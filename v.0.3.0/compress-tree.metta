
(= (compressTree $tree $parentTreeType)
    (if (== NONE $parentTreeType)
        (case $tree(
                (($op $exp1 $exp2)
                    ($op (compressTree $exp1 $op) (compressTree $exp2 $op))
                )

            )
        )
        
        (let* (
                ($head (car-atom $tree))
                ($tail (cdr-atom $tree))
                ($headIsJunctor (or (eq $head AND) (eq $head OR)))
            )
            (if $headIsJunctor
                (if (eq $head $parentTreeType)
                    (let* (
                            ($intermediateTree (iterate-and-insert ($head) $tail))
                            ($intermediateHead (car-atom $intermediateTree))
                            ($intermediateTail (cdr-atom $intermediateTree))
                            ($nextIteration (changeToList (compressTree $intermediateTail $intermediateHead)))
                        )
                        (cons-atom $intermediateHead $nextIteration)

                    )
                    (compressTree $tail $head)
                      
                )
                (compressTree $tail $parentTreeType)
            )
        )
        
    )

)

