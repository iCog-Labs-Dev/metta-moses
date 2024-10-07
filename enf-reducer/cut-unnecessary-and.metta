;(: AndCut (-> Expression Expression))
(= (AndCut $expr)
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
                    ($test (collapse (let $a (getGsetAndChildren (superpose $GrandChildren)) (car-atom $a))))
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



