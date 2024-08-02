(: List type)
(: Nil (List $t))
(: Cons (-> $t (List $t) (List $t)))

(: Tree Type)
(: NodeType Type)
(: NodeValue Type)

(: ROOT NodeType)
(: AND NodeType)
(: OR NodeType)
(: NOT NodeType)
(: LITERAL NodeType)

;; Value(value, truthValue, nodeType)
(: Value (-> $v Bool NodeType NodeValue))

;; TreeNode(nodeValue, guardSet, listOfChildren)
(: TreeNode (-> NodeValue (List Tree) (List Tree) Tree))

(: Location Type)
(: L Location)
(: R Location)