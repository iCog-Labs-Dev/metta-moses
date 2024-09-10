(= (iterate-and-insert $accum $data)
    (if (== $data ())
        $accum
        (iterate-and-insert (cons-atom (car-atom $data) $accum) (cdr-atom $data))
    )
)
!(iterate-and-insert (OR (AND A B) C) ((AND B C) E))
