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
!(iterate-and-insert (OR (AND A B) C) ((AND B C) E))
