(: Tree Type)
(: NodeType Type)
(: NodeValue Type)
(: TreeList Type)

(: NilList TreeList)
(: ConsTree (-> Tree TreeList TreeList))

(: ROOT NodeType)
(: AND NodeType)
(: OR NodeType)
(: NOT NodeType)
(: LITERAL NodeType)

;; Value(value, truthValue, nodeType)
(: Value (-> Number Bool NodeType NodeValue))

(: NilNode Tree)
;; TreeNode(nodeValue, leftChild, rightChild, guardSet, listOfChildren)
(: TreeNode (-> NodeValue Tree Tree TreeList TreeList Tree))

;; (AND A (AND B (AND C (AND (OR A (OR B (OR C A))) (AND B (AND (AND A A) (NOT A)))))))
;; (: buildTree (-> Expression Tree))
(= (buildTree $expr) 
  (case $expr
    (
      ( (AND $a $b) (TreeNode (Value 0 False AND) (buildTree $a) (buildTree $b) NilList NilList) )
      ( (OR $a $b) (TreeNode (Value Nil False OR) (buildTree $a) (buildTree $b) NilList NilList) )
      ( (NOT $x) (TreeNode (Value Nil False NOT) (buildTree $x) NilNode NilList NilList) )
      ( $symbol (TreeNode (Value $symbol False LITERAL) NilNode NilNode NilList NilList) )
    )
  )
)

;; (: buildTreeWithRoot (-> Expression Tree))
(= (buildTreeWithRoot $expr)
  (TreeNode (Value Nil False ROOT) NilNode (buildTree $b) NilList NilList)
)

;; !(buildTree (AND 1 2))
;; !(buildTree (AND a b))
!(buildTree (AND A (AND B (AND C (AND (OR A (OR B (OR C A))) (AND B (AND (AND A A) (NOT A))))))))