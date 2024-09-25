(: propagateNot (-> $expr $expr))

(= (propagateNot $expr)
    (case $expr
        (
            ( ($logic $a $b) ($logic (propagateNot $a) (propagateNot $b)))
            ( (NOT (AND $b $c)) (OR (propagateNot (NOT $b)) (propagateNot (NOT $c))))
            ( (NOT (OR $b $c)) (AND (propagateNot (NOT $b)) (propagateNot (NOT $c))))
            ( (NOT (NOT $x)) (propagateNot $x))
            ( (NOT $symbol) (NOT $symbol))
            ( $symbol  $symbol)
        )
)
)

! (propagateNot (NOT (AND (AND I (AND J (NOT (OR K (OR L M))))) (AND B (NOT (AND C (OR D (OR E (NOT (OR F (AND G H)))))))))))
