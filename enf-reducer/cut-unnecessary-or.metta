(= (cutUnnecessaryOr $expresion)
    (if (== $expresion ()) ()
        (let* (
                ($head (car-atom $expresion))
                ($tail (cdr-atom $expresion))
                ($type (get-metatype $head))
                ($newtail (cutUnnecessaryOr $tail))
            )
         ; check if head is an expression and apply orCut to head as well
        (if (== $type Expression)
            (cons-atom (cutUnnecessaryOr $head) $newtail)
            ( if (== OR $head) (let* (
                        ($subhead (car-atom $newtail))
                        ($subtail (cdr-atom $newtail))
                    ) (if (== $subtail ())
                    $subhead
                    (cons-atom $head $newtail)
                )
        )
    (cons-atom $head $newtail))
)
)
)
)