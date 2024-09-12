> (: propagateNot (-> $expr $expr))
(= (propagateNot $expr)
    (case $expr
        (
            ((AND $a $b) (AND (propagateNot $a) (propagateNot $b)))
            ((OR $a $b) (OR (propagateNot $a) (propagateNot $b)))
            ((NOT $a) 
                (case $a 
                    (
                        ((AND $b $c) (OR (propagateNot (NOT $b)) (propagateNot (NOT $c))))
                        ((OR $b $c) (AND (propagateNot (NOT $b)) (propagateNot (NOT $c))))
                        ((NOT $b) (propagateNot $b))
                        ($symbol (NOT $symbol))
                    )
                )
            )
            ($symbol $symbol)
        )
    )
)

