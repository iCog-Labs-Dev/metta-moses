(: propagateTruthValue (-> Tree Bool Tree))
(= (propagateTruthValue $tree $truthValueArg)
    (if (== (isTreeWellFormed $tree) True)
            (let* (
                    ($right (getChild $tree R))
                    ($left (getChild $tree L))
                    ($nodeType (getNodeType $tree))
                    ((TreeNode $nodeValue $guardSet $children) $tree)
                )(if (== $nodeType ROOT)
                    (if (not (== $right NilNode))
                        (replaceChild $tree (propagateTruthValue $right $truthValueArg) R)
                        $tree
                    )
                    (if (== $nodeType NOT)
                       (propagateTruthValue $right (not $truthValueArg))
                       (let
                          (Value $valueName $truthValue $_)
                          $nodeValue
                          (if (or (== $nodeType OR) (== $nodeType AND))
                                (if (== False $truthValueArg)
                                        (let
                                          $updatedTree
                                          (if (== $nodeType AND)
                                                (changeType $tree OR)
                                                (changeType $tree AND)
                                          )
                                          (let* (
                                                  ($leftNotNil (not (== $left NilNode)))
                                                  ($rightNotNil (not (== $right NilNode)))
                                              )
                                              (if (and $leftNotNil $rightNotNil)
                                                  (replaceChild (replaceChild $updatedTree (propagateTruthValue $left $truthValueArg) L) (propagateTruthValue $right $truthValueArg) R)
                                                  $updatedTree
                                              )
                                          )
                                        )
                                        (replaceChild (replaceChild $tree (propagateTruthValue $left $truthValueArg) L) (propagateTruthValue $right $truthValueArg) R)
                                )
                               (TreeNode (Value $valueName $truthValueArg $nodeType) $guardSet $children)
                          )
                       )
                    )
                )
            )
        (Tree isn't well formed)
    )
)

(: isTreeWellFormed (Tree Bool))
(= (isTreeWellFormed $tree)
    (case $tree (
       
            ((TreeNode (Value $value $bool $nodeType) $guardSet $children) True)
            (NilNode True)
            ($else False)
        )
    )
)
