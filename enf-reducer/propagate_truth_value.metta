! (register-module! ../../metta-moses-reduction)
! (import! &self metta-moses-reduction:types)
! (import! &self metta-moses-reduction:utilities:list-helpers)

(=(propagateTruthValue $tree $truthValueArg)
    (case $tree (
            ((TreeNode (Value $valueName $truthValue $nodeType)  $left $right $guardSet $children)
                (if (== $nodeType ROOT)
                        (if (not (== $right NilNode))
                            (TreeNode (Value $valueName $truthValue $nodeType) $left (propagateTruthValue $right $truthValueArg)  $guardSet $children)
                            $tree
                        )
                        (if (== $nodeType NOT)
                            (case $right (
                                    ((TreeNode $valueChild $rightChild $leftForChild $guardSetForChild $childrenForChild)
                                        (propagateTruthValue $right (not $truthValueArg))
                                    )
                                )
                            )
                            (if (or (== $nodeType OR) (== $nodeType AND))
                                (if (== False $truthValueArg)
                                    (if (== $nodeType AND)
                                         (changeTree $tree (TreeNode (Value $valueName $truthValue OR) $left $right $guardSet $children))
                                         (changeTree $tree (TreeNode (Value $valueName $truthValue AND) $left $right $guardSet $children))
                                    ) 
                                    (if (and (not (== $left NilNode)) (not (== $right NilNode)))
                                        (changeTree $tree (TreeNode (Value $valueName $truthValue $nodeType) (propagateTruthValue $right $truthValueArg) (propagateTruthValue $left $truthValueArg) $guardSet $children))
                                        $tree
                                    )
                                )
                                (changeTree $tree (TreeNode (Value $valueName $truthValueArg $nodeType) $left $right $guardSet $children))

                            )

                        )

                )
            )
            ($_ $tree)

        )
    )

)
;;!(propagateTruthValue (buildTree (OR a (AND b c))) True)
(:isTreeWellFormed (->Tree Bool))
(=(isTreeWellFormed $tree)
    (case $tree (
            ((TreeNode (Value $value $constraint $nodeType) $guardSet (Cons $left (Cons $right Nil))) True)
            ($_ False)
        )
    )
)
;;!(isTreeWellFormed (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value a False LITERAL) Nil Nil) (Cons (TreeNode (Value b False LITERAL) Nil Nil) Nil))))
