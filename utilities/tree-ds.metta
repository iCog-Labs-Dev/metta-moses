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
(: Value (-> $v Bool NodeType NodeValue))

(: NilNode Tree)
;; TreeNode(nodeValue, leftChild, rightChild, guardSet, listOfChildren)
(: TreeNode (-> NodeValue Tree Tree TreeList TreeList Tree))

;; function to build a tree of type "Tree" from an expression
(= (buildTree $expr) 
  (case $expr
    (
      ( (AND $a $b) (TreeNode (Value Nil False AND) (buildTree $a) (buildTree $b) NilList NilList) )
      ( (OR $a $b) (TreeNode (Value Nil False OR) (buildTree $a) (buildTree $b) NilList NilList) )
      ( (NOT $x) (TreeNode (Value Nil False NOT) NilNode (buildTree $x) NilList NilList) )
      ( $symbol (TreeNode (Value $symbol False LITERAL) NilNode NilNode NilList NilList) )
    )
  )
)

;; function to build a tree with a root node of "ROOT"
(= (buildTreeWithRoot $expr)
  (TreeNode (Value Nil False ROOT) NilNode (buildTree $b) NilList NilList)
)

(: getNodeChildren (-> Tree TreeList))
(= (getNodeChildren $node)
  (case $node
    (
      ( (TreeNode $nodeVal $leftNode $rightNode $guardSet $children) $children )
    )
  )
)

(: getNodeGuardSet (-> Tree TreeList))
(= (getNodeGuardSet $node)
  (case $node
    (
      ( (TreeNode $nodeVal $leftNode $rightNode $guardSet $children) $guardSet )
    )
  )
)

!(buildTree (AND A (AND B (AND C (AND (OR A (OR B (OR C A))) (AND B (AND (AND A A) (NOT A))))))))