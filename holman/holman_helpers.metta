!(register-module! ../../metta-moses-reduction)
!(import! &self metta-moses-reduction:utilities:helper-functions)
!(import! &self metta-moses-reduction:reduction:utils)
!(import! &self metta-moses-reduction:utilities:tree-ds)

(:get-children-tree (-> Tree TreeList))
(= (get-children-tree $tree $accumulator)
    (case $tree (
           ((TreeNode $x $xs)
                (case $x(
                        ((Value Nil $bool-value $junctor-value)

                        )   
                    )
                ) 
           )
        )
    )
)