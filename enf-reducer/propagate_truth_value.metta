! (register-module! ../../metta-moses-reduction)
! (import! &self metta-moses-reduction:types)
! (import! &self metta-moses-reduction:utilities:list-helpers)


(= (propagateTruthValue $tree $truthValueArg)
    (if (isTreeWellFormed $tree)
            (let* (
                    ($right (getChild $tree R))
                    ($left (getChild $tree L))
                    ($nodeType (getNodeType $tree))
                )(if (== $nodeType ROOT)
                    (if (not (== $right Nil))
                            ;;(TreeNode (Value $valueName $truthValue $nodeType) $left (propagateTruthValue $right $truthValueArg)  $guardSet $children)
                            (replaceChild $tree (Cons (propagateTruthValue $right $truthValueArg) Nil) R)
                            $tree
                    )
                    (if (== $nodeType NOT)
                            ;; (case $right (
                            ;;         ((TreeNode $valueChild $rightChild $leftForChild $guardSetForChild $childrenForChild)
                            ;;             (propagateTruthValue $right (not $truthValueArg))
                            ;;         )
                            ;;     )
                            ;; )
                        (if (== (isTreeWellFormed $right) True)
                            (propagateTruthValue $right (not $truthValueArg))
                            (The tree structure isnt correct)
                        )
                        (case $tree(
                            ((TreeNode (Value $valueName $bool $nodeType) $guardSet (Cons $left (Cons $right Nil)))
                          
                        (if (or (== $nodeType OR) (== $nodeType AND))
                           
                            (if (== False $truthValueArg)
                                (if (== $nodeType AND)
                                     (changeTree $tree (TreeNode (Value $valueName $truthValue OR) $guardSet (Cons (propagateTruthValue $left $truthValueArg) (Cons (propagateTruthValue $right $truthValueArg)))))
                                     (changeTree $tree (TreeNode (Value $valueName $truthValue AND) $guardSet (Cons (propagateTruthValue $left $truthValueArg) (Cons (propagateTruthValue $right $truthValueArg)))))
                                    ;; (changeTree $tree (TreeNode (Value $valueName $truthValue AND) $left $right $guardSet $children))

                                ) 
                                (if (and (not (== $left Nil)) (not (== $right Nil)))
                                    (changeTree $tree (TreeNode (Value $valueName $truthValue $nodeType) (Cons (propagateTruthValue $left $truthValueArg) (Cons (propagateTruthValue $right $truthValueArg) Nil))))
                                    $tree
                                )
                            )
                            (changeTree $tree (TreeNode (Value $valueName $truthValueArg $nodeType) $guardSet (Cons $left (Cons $right Nil))))

                        )
                    )
                       
                )
            )

                    )
                (Error the tree is not well formed)
            ))
    )
)
            

        
    


;;!(propagateTruthValue (buildTree (OR a (AND b c))) True)
(:isTreeWellFormed (->Tree Bool))
(=(isTreeWellFormed $tree)
    (case $tree (
        (
            (TreeNode (Value $value $constraint $nodeType) $guardSet $children True)
            (Nil True)
            ($_ False)
        )
    )
    )
)
;;!(isTreeWellFormed (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value a False LITERAL) Nil Nil) (Cons (TreeNode (Value b False LITERAL) Nil Nil) Nil))))
