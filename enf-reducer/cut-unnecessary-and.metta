;(: andCut (-> Expression Expression))
;return POA’s grandchildren to the POA’s parent’s if it have empty Gset, 1child and the intersection of the grandchildren Gset is empty.
(= (andCut $expr)
    (let*
        (
            (($gSet $child) (getGsetAndChildren $expr))
            ($tail (cdr-atom $child))
        )
        (if (and (== $tail ()) (== $gSet ()))
            (let*
                (
                    (($Grandgset $GrandChildren) (getGsetAndChildren (car-atom $child)))
                    ($allLiterals (collapse (getGuardSet (superpose $GrandChildren) ())))
                    ($common (findCommon $allLiterals))

                )
                (if (== $common ())
                    $GrandChildren
                    $expr
                )  
            )
            $expr
        )           
    )
)



