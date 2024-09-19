 ;a function to return the top element of an expression
(= (returnTop $exp)
    (case $exp
        (
            ( (AND $a $b) AND)
            ( (OR $a $b) OR)
            ( (NOT $a) NOT)
            ($symbol $symbol)
        )
)
)

 ;a function to add a tree edge to the atomspace
(= (addEdge $treeName $parentId $parentValue $parentConstraint $parentGuardSet $childId $childValue $childConstraint)
    (let $tree $treeName
        (add-atom &self (= ($tree) (Tree $parentId $parentValue $parentConstraint $parentGuardSet (Tree $childId $childValue $childConstraint))))
    )
)

 ;a function to build a non-deterministic tree from a given expression
(= (buildTree $treeName $exp $start)
    (let*
        (
            ($tree $treeName)
            ($level (+ $start 1))
            ($nextLevel (+ $level 1))
        )
    (case $exp
        (
            ( (AND $a $b)
                (let*
                    (
                        ($addFirst (addEdge $tree ($level 1) AND False Nil ($nextLevel 1) (returnTop $a) False))
                        ($addSecond (addEdge $tree ($level 1) AND False Nil ($nextLevel 1) (returnTop $b) False))
                        ($aIsExpression (== (get-metatype $a) Expression))
                        ($bIsExpression (== (get-metatype $b) Expression))
                    )
                (if (and $aIsExpression $bIsExpression)
                    ( (buildTree $treeName $a $level) (buildTree $treeName $b $level))
                    (if $aIsExpression
                        (buildTree $treeName $a $level)
                        (if $bIsExpression (buildTree $treeName $b $level) ("Reached Leaf node"))
                    )
            )            )
)
( (OR $a $b)
    (let*
        (
            ($addFirst (addEdge $tree ($level 1) OR False Nil ($nextLevel 1) (returnTop $a) False))
            ($addSecond (addEdge $tree ($level 1) OR False Nil ($nextLevel 1) (returnTop $b) False))
            ($aIsExpression (== (get-metatype $a) Expression))
            ($bIsExpression (== (get-metatype $b) Expression))
        )
    (if (and $aIsExpression $bIsExpression)
        ( (buildTree $treeName $a $level) (buildTree $treeName $b $level))
        (if $aIsExpression
            (buildTree $treeName $a $level)
            (if $bIsExpression (buildTree $treeName $b $level) ("Reached Leaf node"))
        )
)
)
)
( (NOT $a)
    (let*
        (
            ($addFirst (addEdge $tree ($level 1) NOT False Nil ($nextLevel 1) (returnTop $a) False))
            ($aIsExpression (== (get-metatype $a) Expression))
        )
    (if $aIsExpression (buildTree $treeName $a $level) ("Reached Leaf node"))
)
)
($else False)
)
)

)
)
 ;testcases
 ;! (buildTree x (AND A (OR A B)) 0)
 ;! (buildTree x (AND (AND A B) (OR A B)) 0)
 ;! (buildTree x (NOT A) 0)
 ;! (buildTree x (AND A (NOT (AND A B))) 0)
 ;! (x)
