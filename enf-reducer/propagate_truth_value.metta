! (register-module! ../../metta-moses-reduction)
! (import! &self metta-moses-reduction:types)
! (import! &self metta-moses-reduction:utilities:list-helpers)
! (import! &self metta-moses-reduction:utilities:tree-helpers)


(:propagateTruthValue (-> Tree Bool Tree))
(= (propagateTruthValue $tree $truthValueArg)
    (if (== (isTreeWellFormed $tree) True)
            (let* (
                    ($right (getChild $tree R))
                    ($left (getChild $tree L))
                    ($nodeType (getNodeType $tree))
                )(if (== $nodeType ROOT)
                    (if (not (== $right Nil))
                        (propagateTruthValue $right $truthValueArg)
                        $tree
                    )
                    (if (== $nodeType NOT)
                        (if (== (isTreeWellFormed $right) True)
                            (propagateTruthValue $right (not $truthValueArg))
                            $tree
                        )
                        (let (TreeNode (Value $valueName $truthValue $nodeTypeDestructured) $guardSet $children) $tree
                            (if (or (== $nodeTypeDestructured OR) (== $nodeTypeDestructured AND))
                                (if (== False $truthValueArg)
                                        (if (== $nodeTypeDestructured AND)
                                            (TreeNode (Value $valueName $truthValue OR) $guardSet (Cons (propagateTruthValue $left $truthValueArg) (Cons (propagateTruthValue $right $truthValueArg) Nil)))
                                            (TreeNode (Value $valueName $truthValue AND) $guardSet (Cons (propagateTruthValue $left $truthValueArg) (Cons (propagateTruthValue $right $truthValueArg) Nil)))
                                        )
                                        (let* (
                                                ($leftNotNil (not (== $left NilNode)))
                                                ($rightNotNil (not (== $right NilNode)))
                                            )          
                                            (if (and $leftNotNil $rightNotNil)
                                                (TreeNode (Value $valueName $truthValue $nodeTypeDestructured) $guardSet (Cons (propagateTruthValue $left $truthValueArg) (Cons (propagateTruthValue $right $truthValueArg) Nil)))
                                                $tree
                                            )
                                        )
                                    
                                )
                                (TreeNode (Value $valueName $truthValueArg $nodeTypeDestructured) $guardSet $children)
                            ) 
                        )   
                    )
                )
            )
        (Tree isn't well formed)
    )
)
(= (isTreeWellFormed $tree)
    (case $tree (
       
            ((TreeNode (Value $value $bool $nodeType) $guardSet $children) True)
            (NilNode True)
            ($else False)
        )
    )
)
;;!(isTreeWellFormed (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value a False LITERAL) Nil Nil) (Cons (TreeNode (Value b False LITERAL) Nil Nil) Nil))))
 
;; !(changeTree (buildTree (OR a (AND b c))) (buildTree (AND a (AND b c))))
;; !(replaceChild (buildTree (OR a (AND b c))) (buildTree (AND a (AND b c))) L)
;; !(getNodeType (buildTree (OR a (AND b c))))
;;!(propagateTruthValue (buildTree (OR a (AND b c))) True)
;; !(propagateTruthValue (TreeNode (Value target1 False NOT) Nil (Cons
;;               (TreeNode (Value Nil False AND) Nil Nil)
;;               (Cons
;;                  (TreeNode (Value target1 False OR)  Nil Nil)
;;                 (Cons
;;                       (TreeNode (Value target2 True AND) Nil Nil)
;;                       Nil
;;                  )
;;           )
;;   ) ) True)