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
                ( l $leftChild)
                ( r $rightChild)
                ($else "Error: Invalid option: must be l or r")
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
(: appendTree (-> TreeList TreeList TreeList))
(= (appendTree NilList $ys) $ys)
(= (appendTree (ConsTree $x $xs) $ys) (ConsTree $x (appendTree $xs $ys)))



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
						( $else
									"Error: Invalid option: must be l or r"
						)
					)
				)
			)
		)
  )
)

;; example
;; !(updateChild (buildTree(AND A (OR B C))) r (buildTree (AND Y Z)))


;; -----------------------------------
;; -------- Append Children
;; -------- Given a node and a tree, append the tree to the node's children.
;; -----------------------------------
;; -----------------------------------


(: appendChildren (-> Tree Tree Tree))
(= (appendChildren $node $child)
  (case $node 
		(
			( 
				(TreeNode (Value $valueName $truthValue $nodeType) $left $right $guardSet $children)
				(TreeNode (Value $valueName $truthValue $nodeType) $left $right $guardSet (ConsTree $child $children))
			)
		)
  )
)

;; example

;; !(appendChildren 
;;		(TreeNode (Value Nil False AND) 
;;					(TreeNode (Value A False LITERAL) NilNode NilNode NilList NilList)
;;					(TreeNode (Value B False LITERAL) NilNode NilNode NilList NilList)
;;			NilList
;;			(ConsTree 
;;							(TreeNode (Value Nil False AND) 
;;									(TreeNode (Value C False LITERAL) NilNode NilNode NilList NilList) 
;;									(TreeNode (Value D False LITERAL) NilNode NilNode NilList NilList) NilList NilList)
;;							NilList
;;			) 
;;		)
;;
;;		(buildTree (AND Y Z))
;;	)

;;function to check if a tree is member of a treelist
(= (member-tree $x $y)
    (case ($x $y)
        (
            (((TreeNode $nodeValueX $leftChild $rightChild $guardSet $listOfChildren) (Cons (TreeNode $nodeValueL $leftChild $rightChild $guardSet $listOfChildren) $t))
                 (if (== $nodeValueX $nodeValueL) 
                     True 
                     (member-tree $x $t))
             )
            ($else False)
        )
    )
)

;;function to return the intersection of two treelists
(= (tree-intersection $lst1 $lst2)
    (case $lst1
    (
        ((Cons $h $t) 
         (if (member-tree $h $lst2) 
            (Cons $h (tree-intersection $t $lst2)) 
            (tree-intersection $t $lst2)
         ) 
        )
        (() ())
    )
    )
)

;;!(member-tree (TreeNode (Value Nil False OR) (TreeNode (Value a False NOT) NilNode NilNode NilList NilList) (TreeNode (Value b False NOT) Nil
;;Node NilNode NilList NilList) NilList NilList) 
;;(Cons (TreeNode (Value Nil False AND) (TreeNode (Value a False NOT) NilNode NilNode NilList NilList) (TreeNode (Value b False NOT) Nil
;;Node NilNode NilList NilList) NilList NilList) (Cons (TreeNode (Value Nil False OR) (TreeNode (Value a False NOT) NilNode NilNode NilList NilList) (TreeNode (Value b False NOT) Nil
;;Node NilNode NilList NilList) NilList NilList) ())))

;;! (tree-intersection
;; (Cons (TreeNode (Value Nil False AND) (TreeNode (Value a False NOT) NilNode NilNode NilList NilList) (TreeNode (Value b False NOT) Nil
;;Node NilNode NilList NilList) NilList NilList) (Cons (TreeNode (Value Nil False OR) (TreeNode (Value a False NOT) NilNode NilNode NilList NilList) (TreeNode (Value b False NOT) Nil
;;Node NilNode NilList NilList) NilList NilList) ()))
;; (Cons (TreeNode (Value Nil False AND) (TreeNode (Value a False NOT) NilNode NilNode NilList NilList) (TreeNode (Value b False NOT) Nil
;;Node NilNode NilList NilList) NilList NilList) (Cons (TreeNode (Value Nil True OR) (TreeNode (Value a False NOT) NilNode NilNode NilList NilList) (TreeNode (Value b False NOT) Nil
;;Node NilNode NilList NilList) NilList NilList) ()))
;;)
