(= (iterate-and-insert $accum $data)
    (let* (
            ($head (car-atom $accum))
            ($tail (cdr-atom $accum))
        )
        (if (== $data ())
            $accum
            (let $midValue (iterate-and-insert (cons-atom (car-atom $data) $tail) (cdr-atom $data))
                (cons-atom $head $midValue)
            )
        )
    )
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


!(iterate-and-insert (OR (AND A B) C) (OR (AND B C) E))
