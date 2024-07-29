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

;; -----------------------------------
;; -----------------------------------
;; -------- function to build a tree of type "Tree" from an expression
;; -----------------------------------
;; -----------------------------------

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

;; -----------------------------------
;; -----------------------------------
;; -------- function to build a tree with a root node of "ROOT"
;; -----------------------------------
;; -----------------------------------

(= (buildTreeWithRoot $expr)
  (TreeNode (Value Nil False ROOT) NilNode (buildTree $b) NilList NilList)
)

;; -----------------------------------
;; -----------------------------------
;; -------- a function to get the right or left child
;; -----------------------------------
;; -----------------------------------

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

;; -----------------------------------
;; -----------------------------------
;; -------- a function to get node children
;; -----------------------------------
;; -----------------------------------

(: getNodeChildren (-> Tree TreeList))
(= (getNodeChildren $node)
  (case $node
    (
      ( (TreeNode $nodeVal $leftNode $rightNode $guardSet $children) $children )
    )
  )
)

;; -----------------------------------
;; -----------------------------------
;; -------- a function to get guardset
;; -----------------------------------
;; -----------------------------------

(: getNodeGuardSet (-> Tree TreeList))
(= (getNodeGuardSet $node)
  (case $node
    (
      ( (TreeNode $nodeVal $leftNode $rightNode $guardSet $children) $guardSet )
    )
  )
)

;; -----------------------------------
;; -------- updateChild
;; -------- Given a binary tree node and position (left, right) indicating which child to update, replace it's left or right child with the given node.
;; -----------------------------------
;; -----------------------------------

(: Position Type)
(: l Position)
(: r Position)

;; (node postition(l or r) newNode)
(: updateChild (-> Tree Position Tree Tree))
(= (updateChild $node $position $newNode)
  (case $node (
			((TreeNode (Value $valueName $truthValue $nodeType) $left $right $guardSet $children)
				(case $position (
						(	l
								 (TreeNode (Value $valueName $truthValue $nodeType) $newNode $right $guardSet $children)
						)

						(	r
								 (TreeNode (Value $valueName $truthValue $nodeType) $left $newNode $guardSet $children)
						)
					)
				)
			)
		)
  )
)

;; example
;; !(updateChild (buildTree(AND A (OR B C))) r (buildTree (AND Y Z)))
