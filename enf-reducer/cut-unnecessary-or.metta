 ; Cut unnecessary OR, DOESN'T process sub expressions
 ; To be used with iterator
( = (orCut $expresion)
    (if  (== $expresion ()) ()
        ( let  $type (get-metatype $expresion)
             ; Check if what is passed in is a symbol/Literal and not an expression
            (if (== $type Symbol)
                $expresion
                (let* (
                        ($head (car-atom $expresion))
                        ($tail (cdr-atom $expresion))
                    ) (if (== $head OR)
                    (let* (
                            ($subhead (car-atom $tail))
                            ($subtail (cdr-atom $tail))
                        ) (if (== $subtail ()) $subhead (cons-atom $head $tail)))
                (cons-atom $head $tail))
        ))))
)