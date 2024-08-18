(: reduct (-> Expression Tree))
(=(reduct $expression)
    (let* (
        ($builtTree (buildTreeWithRoot $expression))
        ($propagateTruthValue (propagateTruthValue $builtTree True))
        ($gatherJunctorTree (gatherJunctors $propagateTruthValue NilNode))
        (($reducedTree $action) (reduceToElegance $gatherJunctorTree Nil Nil))
    )
        $reducedTree
    )
)