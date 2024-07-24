!(register-module! ../../metta-moses-reduction)
!(import! &self metta-moses-reduction:utilities:helper-functions)
!(import! &self metta-moses-reduction:reduction:utils)
!(import! &self metta-moses-reduction:utilities:tree-ds)

(:get-children-tree (-> Tree TreeList TreeList))
(= (get-children-tree $tree $accumulator)
    (case $tree (
           ((TreeNode $value $right $left $guardSet $children)
                (case $value(
                        ((Value Nil $constraint $nodetype)
                            (appendTree (appendTree (ConsTree $right NilList) $accumulator) (ConsTree $left NilList))
                        )
                    )
                )
                
           )
        )
    )
)

!(get-children-tree (buildTree (AND A (AND B (AND C (AND (OR A (OR B (OR C A))) (AND B (AND (AND A A) (NOT A)))))))) NilList)