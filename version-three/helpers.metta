
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
(= (hasExpression $exp)
    (if (== $exp ())
        False
        (let* (
                ($head (car-atom $exp))
                ($tail (cdr-atom $exp))
                ($isHeadExpression (== (get-metatype $head) Expression))

            )(if $isHeadExpression
                (let $secondHead (car-atom $head)
                    (if (== $secondHead NOT)
                        (hasExpression $tail)
                        True
                    )
                )
                (hasExpression $tail)
            )
        )
    )
)
(= (pop-helper $exp $accum)
    (if (== (cdr-atom $exp) ())
        $accum
        (let $head (car-atom $exp)
            (pop-helper (cdr-atom $exp) (cons-atom $head $accum))
        )
    )

)
(= (pop $exp)
    (if (== $exp ())
        $exp
        (reverse-list (pop-helper $exp ()) ())
    )
)

