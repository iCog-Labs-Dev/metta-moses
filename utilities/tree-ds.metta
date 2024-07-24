(: Tree Type)
(: NodeType Type)
(: NodeValue Type)
(: TreeList Type)

(: NilList TreeList)
(: ConsTree (-> Tree TreeList TreeList))

;; (: ROOT NodeType)
(: AND NodeType)
(: OR NodeType)
(: NOT NodeType)
(: LITERAL NodeType)

;; Value(value, truthValue, nodeType)
(: Value (-> Symbol Bool NodeType NodeValue))

(: NilNode Tree)
;; TreeNode(nodeValue, leftChild, rightChild, guardSet, listOfChildren)
(: TreeNode (-> NodeValue Tree Tree TreeList TreeList Tree))

;; (AND A (AND B (AND C (AND (OR A (OR B (OR C A))) (AND B (AND (AND A A) (NOT A)))))))
(:buildTree (-> Expression Tree))
(= (buildTree $expr) 
  (case $expr
    (
      ;; ( (ROOT $a $b) (TreeNode (Value Nil False ROOT) (buildTree $a) (buildTree $b) NilList NilList) )
      ( (AND $a $b) (TreeNode (Value Nil False AND) (buildTree $a) (buildTree $b) NilList NilList) )
      ( (OR $a $b) (TreeNode (Value Nil False OR) (buildTree $a) (buildTree $b) NilList NilList) )
      ( (NOT $x) (TreeNode (Value Nil False NOT) (buildTree $x) NilNode NilList NilList) )
      ( $symbol (TreeNode (Value $symbol False NOT) NilNode NilNode NilList NilList) )
    )
  )
)
(: appendTree (-> TreeList TreeList TreeList))
(= (appendTree NilList $ys) $ys)
(= (appendTree (ConsTree $x $xs) $ys) (ConsTree $x (appendTree $xs $ys)))

;; !(buildTree (AND a b))
!(buildTree (AND A (AND B (AND C (AND (OR A (OR B (OR C A))) (AND B (AND (AND A A) (NOT A))))))))