!(import! &self list)

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

;; -----------------------------------
;; -----------------------------------
;; -------- function to build a tree of type "Tree" from an expression
;; -----------------------------------
;; -----------------------------------

(= (buildTree $expr) 
  (case $expr
    (
      ( (AND $a $b) (TreeNode (Value Nil False AND) Nil (Cons (buildTree $a) (Cons (buildTree $b) Nil))) )
      ( (AND $a $b) (TreeNode (Value Nil False AND) Nil (Cons (buildTree $a) (Cons (buildTree $b) Nil))) )
      ( (OR $a $b) (TreeNode (Value Nil False OR) Nil (Cons (buildTree $a) (Cons (buildTree $b) Nil))))
      ( (NOT $x) (TreeNode (Value Nil False NOT) Nil (Cons (buildTree $x) Nil)))
      ( $symbol (TreeNode (Value $symbol False LITERAL) Nil Nil))
    )
  )
)

 ;;!(buildTree (AND a b))
 ;;!(buildTree (AND A (AND B (AND C (AND (OR A (OR B (OR C A))) (AND B (AND (AND A A) (NOT A))))))))

;; -----------------------------------
;; -----------------------------------
;; -------- function to build a tree with a root node of "ROOT"
;; -----------------------------------
;; -----------------------------------

(= (buildTreeWithRoot $expr)
  (TreeNode (Value Nil False ROOT) Nil (Cons (buildTree $b) Nil))
)

;; -----------------------------------
;; -----------------------------------
;; -------- a function to get the right or left child
;; -----------------------------------
;; -----------------------------------

(: getChild (-> Tree Location Tree))
(= (getChild (TreeNode $nodeValue $guardSet Nil) $opt) Nil)
(= (getChild (TreeNode $nodeValue $guardSet (Cons $l $xs)) L) $l)
(= (getChild (TreeNode $nodeValue $guardSet (Cons $l (Cons $r $xs))) R) $r)

; !(getChild (buildTree b) L)
; !(getChild (buildTree (AND a b)) R)

;; -----------------------------------
;; -----------------------------------
;; -------- a function to get node children
;; -----------------------------------
;; -----------------------------------

(: getChildren (-> Tree (List Tree)))
(= (getChildren (TreeNode $nodeVal $guardSet $children)) $children)

; !(getChildren (buildTree (AND a b)))

;; -----------------------------------
;; -----------------------------------
;; -------- a function to get guardset
;; -----------------------------------
;; -----------------------------------

(: getGuardSet (-> Tree TreeList))
(= (getGuardSet (TreeNode $noeVal $guardSet $children)) $guardSet)

; !(getGuardSet (buildTree (AND a b)))
;; -----------------------------------
;; -------- updateChild
;; -------- Given a binary tree node and position (left, right) indicating which child to update, replace it's left or right child with the given node.
;; -----------------------------------
;; -----------------------------------

;; (node location (L or R) newNode)
(: replaceChild (-> Tree Tree Location Tree))
(= (replaceChild (TreeNode $nodeValue $guardSet Nil) L) 
  (TreeNode $nodeValue $guardSet (Cons $newNode Nil))
)
(= (replaceChild (TreeNode $nodeValue $guardSet (Cons $l $xs)) $newNode L)
  (TreeNode $nodeValue $guardSet (Cons $newNode $xs))
)
(= (replaceChild (TreeNode $nodeValue $guardSet (Cons $l Nil) R))
  (TreeNode $nodeValue $guardSet (Cons $l (Cons $newNode Nil)))
)
(= (replaceChild (TreeNode $nodeValue $guardSet (Cons $l (Cons $r $xs))) $newNode R)
  (TreeNode $nodeValue $guardSet (Cons $l (Cons $newNode $xs)))
)

;; example
; !(replaceChild (buildTree (NOT A)) (buildTree (OR Y Z)) L)


;; -----------------------------------
;; -------- Append Children
;; -------- Given a node and a tree, append the tree to the node's children.
;; -----------------------------------
;; -----------------------------------


(: appendChild (-> Tree Tree Tree))
(= (appendChild (TreeNode $nodeValue $guardSet $children) $child)
  (TreeNode $nodeValue $guardSet (Cons $child $children))
)

; !(appendChild (buildTree A) (buildTree (AND B)) )
;; !(appendChild
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

(: nodeEquality (-> Tree Tree Bool))
(= (nodeEquality (TreeNode $nodeValue1 $guardSet1 $children1) (TreeNode $nodeValue2 $guardSet2 $children2))
  (== $nodeValue1 $nodeValue2)
)

; !(nodeEquality (buildTree (AND A B)) (buildTree (AND A B)))

;;function to check if a tree is member of a treelist
(: treeIsMember (-> Tree (List Tree) Bool))
(= (treeIsMember $x $list)
   (memberWith nodeEquality $x $list)
)

; !(treeIsMember (buildTree D) (getChildren (buildTree (AND A D))))

;;function to return the intersection of two treelists
(: treeIntersection (-> (List Tree) (List Tree) (List Tree)))
(= (treeIntersection $list1 $list2)
    (case $list1
    (
        ((Cons $h $t) 
         (if (treeIsMember $h $list2) 
            (Cons $h (treeIntersection $t $list2)) 
            (treeIntersection $t $list2)
         ) 
        )
        ($_ (empty))
    )
    )
)

; !(treeIntersection (getChildren (buildTree (AND A B))) (getChildren (buildTree (AND D E))))