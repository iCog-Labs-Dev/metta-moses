! (register-module! ../../metta-moses-reduction)
! (import! &self metta-moses-reduction:utilities:tree-ds)

(: (-> (-> Number Number Number) Number Number))
(= (treeFoldl $func $acc NilNode) $acc)
(= (treeFoldl $func $acc (TreeNode $nodeVal $leftTree $rightTree $guardSet $children))
  (let $leftAcc
    (case $leftTree
      (
        ( (NilNode) 0 )
        ( (TreeNode $innerNodeVal $innerLeftTree $innerRightTree $innerGuardSet $innerChildren) 
          (case $innerNodeVal
            (
              ( (Value Nil $truthVal $type) 0 )
              ( (Value $val $truthVal $type) (treeFoldl $func ($func $acc $val) $innerLeftTree) )
            )
          )
        )
      )
    )
    (case $rightTree
      (
        ( (NilNode) 0 )
        ( (TreeNode $innerNodeVal $innerLeftTree $innerRightTree $innerGuardSet $innerChildren) 
          (case $innerNodeVal
            (
              ( (Value Nil $truthVal $type) 0 )
              ( (Value $val $truthVal $type) (treeFoldl $func ($func $leftAcc $val) $innerRightTree) )
            )
          )
        )
      )
    )
  )
)

(= (add $x $y) (+ $x $y))

!(treeFoldl add 0 (buildTree (AND 1 2)))
