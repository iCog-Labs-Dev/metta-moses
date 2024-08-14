(= (exec True) True)
(= (exec False) False)

(= (exec ($op $exp1 $exp2))
    (if (== $op AND)
        (and (exec $exp1) (exec $exp2))
        (if (== $op OR)
            (or (exec $exp1) (exec $exp2))
            ERROR
        )
    )
)

!(exec (AND True (OR False True)))