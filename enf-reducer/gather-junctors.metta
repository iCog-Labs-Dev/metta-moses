! (register-module! ../../metta-moses-reduction)
! (import! &self metta-moses-reduction:types)
! (import! &self metta-moses-reduction:utilities:list-helpers)
! (import! &self metta-moses-reduction:utilities:tree-helpers)

(:gatherJunctors (-> Tree Tree Tree))
(=(gatherJunctors $currentNode $centerNode)
    (if (or (== $currentNode NilNode) (== $centerNode NilNode))
        NilNode
        (let* (
            ($currentNodeType (getNodeType $currentNode))
            ($centerNodeType (getNodeType $centerNode))
            ($currentLeft (getChild $currentNode L))
            ($currentRight (getChild $currentNode R))
            ($centerLeft (getChild $centerNode L))
            ($centerRight (getChild $centerNode R))
            ((TreeNode (Value $valueName $constraint $currentNodeType) $guardSet $children) $currentNode)
            
        )
        (if (and (== $currentNodeType ROOT) (not (== $currentRight NilNode)))
            
            (TreeNode (Value $valueName $constraint AND) $guardSet (Cons $currentLeft (Cons (gatherJunctors $currentRight $centerNode) Nil)))
            
            (if (or (== $currentNodeType AND) (== $currentNodeType OR))
                (if  (== $currentNodeType $centerNodeType)
                    (if (and (not (== $currentLeft NilNode)) (not (== $currentRight NilNode)))
                        (TreeNode (Value $valueName $constraint AND) $guardSet 
                                (Cons (gatherJunctors $currentLeft $centerNode) (Cons (gatherJunctors $currentRight $centerNode) Nil)))
                        $currentNode
                    )
                    (let  $newCenterNode (appendChild $centerNode $currentNode)
                        (appendChild (appendChild $newCenterNode (gatherJunctors $currentLeft $currentNode)) 
                            (gatherJunctors $currentRight $currentNode))

                    )
                )
                (if (== $currentNodeType LITERAL)
                    (if (== $centerNodeType AND)
                        (appendToGuardSet $centerNode $currentNode)
                        (appendChild $centerNode (TreeNode (Value $valueName $constraint AND) (Cons $currentNode Nil) $children))
                    )
                    $currentNode
                )
                    
                )
            )
        

        )
    )
)
!(gatherJunctors (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value a True LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value b True LITERAL) Nil Nil) (Cons (TreeNode (Value c True LITERAL) Nil Nil) Nil))) Nil))) (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value a True LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value b True LITERAL) Nil Nil) (Cons (TreeNode (Value c True LITERAL) Nil Nil) Nil))) Nil))))
