! (register-module! ../../metta-moses-reduction)
! (import! &self metta-moses-reduction:utilities:general-helper-functions)

(= (promoteCommonLiterals $expr)
     (case (car-atom $expr)
        (
                (AND
                    (let* 
                        (
                        (($gSet $children) (getGsetAndChildren $expr))
                        ($result (processOrChildren (car-atom $children)))
                        (($head $tail) $result)                     
                        ($updatedExpr (concatTuple $gSet $head))
                        ($final (concatTuple $updatedExpr ($tail)))                       
                        )   
                        (cons-atom AND $final)
                    )
            )
            ($else $else)
        )
    )
)

(= (processOrChildren $expr)
    (let* 
        (
            (($literals $children) (getGsetAndChildren $expr)) 
            ($childrenLiteral   (collapse (getGsetAndChildren (superpose $children))))
            ($common (findCommonLiterals $literals $childrenLiteral))         
        )
        (if (== $common ())
            (() $expr)
            (let*
                ( 
                ($updatedChildren (removeCommonLiterals $common $children))
                ($updatedLiterals (removeElement $common $literals))
                ($newExp (concatTuple $updatedLiterals $updatedChildren ))
                ($res (cons-atom OR $newExp))              
                )
                ($common $res)
            )

        )
    )
)

!(promoteCommonLiterals (AND A B (OR A C (AND A D (OR G J)) (AND A E))))
