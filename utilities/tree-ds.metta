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
      ( (NOT $x) (TreeNode (Value Nil False NOT) (buildTree $x) NilNode NilList NilList) )
      ( $symbol (TreeNode (Value $symbol False LITERAL) NilNode NilNode NilList NilList) )
    )
  )
)

;; !(buildTree (AND a b))
!(buildTree (AND A (AND B (AND C (AND (OR A (OR B (OR C A))) (AND B (AND (AND A A) (NOT A))))))))

;; function to build a tree with a root node of "ROOT"
(= (buildTreeWithRoot $expr)
  (TreeNode (Value Nil False ROOT) NilNode (buildTree $b) NilList NilList)
)

;a function to get the right or left child
(: getChild (-> Tree String Tree))
(= (getChild $tree $opt) 
 (case $tree
     (
        ((TreeNode $nodeValue $leftChild $rightChild $guardSet $listOfChildren)
         (case $opt
             (
                ("L" $leftChild)
                ("R" $rightChild)
                ($else "Error: Invalid option: must be 'L' or 'R'")
             )))
        (() ())
     )) )

;!(getChild (buildTree (AND a b)) ())


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

