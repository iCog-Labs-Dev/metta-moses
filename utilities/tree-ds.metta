(: Tree Type)
(: NodeType Type)
(: TreeList Type)

;; (: ROOT NodeType)
(: AND NodeType)
(: OR NodeType)
(: NOT NodeType)
(: LITERAL NodeType)

(: NilList TreeList)
(: ConsTree (-> Tree TreeList TreeList))

(: NilNode Tree)
;; TreeNode(value, leftTree, rightTree, constraint, guardSet, children, type)
(: TreeNode (-> Symbol Tree Tree Bool TreeList TreeList NodeType Tree))

;; (AND A (AND B (AND C (AND (OR A (OR B (OR C A))) (AND B (AND (AND A A) (NOT A)))))))
(:buildTree (-> Expression Tree))
(= (buildTree $expr) 
  (case $expr
    (
      ;; ( (ROOT $a $b) (TreeNode Nil (buildTree $a) (buildTree $b) False NilList NilList ROOT) )
      ( (AND $a $b) (TreeNode Nil (buildTree $a) (buildTree $b) False NilList NilList AND) )
      ( (OR $a $b) (TreeNode Nil (buildTree $a) (buildTree $b) False NilList NilList OR) )
      ( (NOT $x) (TreeNode Nil (buildTree $x) NilNode False NilList NilList NOT) )
      ( $symbol (TreeNode $symbol NilNode NilNode False NilList NilList LITERAL) )
    )
  )
)

;; !(buildTree (AND a b))
!(buildTree (AND A (AND B (AND C (AND (OR A (OR B (OR C A))) (AND B (AND (AND A A) (NOT A))))))))