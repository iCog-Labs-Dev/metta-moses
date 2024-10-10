 ;(: orCut (-> Expression Expression))
 ; orCut transformation
 ;;   - applied when OR node has single child
 ;;;        - returns guardset of child expression and grandchildren
 ;;   - if starting node isn't an OR node will return the expression itself
 ;;;        - (AND A B)
 ;;;        - ( A B)
 ; Example
 ;;  (OR (AND (NOT D) C)) ->((NOT D) C)
 ;;  (OR A) -> A

( = (orCut $expresion)
    (if  (== $expresion ()) ()
        ( let  $type (get-metatype $expresion)
             ; Check if what is passed in is a symbol/Literal and not an expression
            (if (== $type Symbol)
                $expresion
                (let* (
                        ($head (car-atom $expresion))
                        ($tail (cdr-atom $expresion))
                        ($subhead (car-atom $tail))
                        ($subtail (cdr-atom $tail))
                    ) (if ( and (== $head OR) (== $subtail ()))
                    (if ( == Symbol (get-metatype $subhead))
                        ($subhead) ; To make sure to always return Expression instead of Symbol
                        (let*
                            (
                                ( ($guardSet $children) (getGsetAndChildren  (car-atom $tail)))
                            )
                        (concatTuple $guardSet $children)
                    )

            )
        $expresion)))))
)