; put you code here
(=(head $exp)
    (car-atom $exp)
)
(=(eq $a $b)
    (let* (
            ($typeA (get-metatype $a))
            ($typeB (get-metatype $b))
        )
        (if (== $typeA $typeB)
            (== $a $b)
            False
        )
    )
    
)
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
            )
            (if (eq $head $parentTreeType)
                (iterate-and-insert $head $tail)
                
            )
        )
        
    )
)
