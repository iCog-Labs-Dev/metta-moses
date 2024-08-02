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
      ( (NOT $x) (TreeNode (Value Nil False NOT) Nil (Cons NilNode (Cons (buildTree $x) Nil))))
      ( $symbol (TreeNode (Value $symbol False LITERAL) Nil Nil))
    )
  )
)

;; -----------------------------------
;; -----------------------------------
;; -------- function to build a tree with a root node of "ROOT"
;; -----------------------------------
;; -----------------------------------

(= (buildTreeWithRoot $expr)
  (TreeNode (Value Nil False ROOT) Nil (Cons NilNode (Cons (buildTree $expr) Nil)))
)

;; -----------------------------------
;; -----------------------------------
;; -------- a function to get the right or left child
;; -----------------------------------
;; -----------------------------------

(:getChild (-> Tree Location Tree))
(= (getChild (TreeNode $nodeValue $guardSet Nil) $opt) Nil)
(= (getChild (TreeNode $nodeValue $guardSet (Cons $l $xs)) L) $l)
(= (getChild (TreeNode $nodeValue $guardSet (Cons $l (Cons $r $xs))) R) $r)

;; -----------------------------------
;; -----------------------------------
;; -------- a function to get node children
;; -----------------------------------
;; -----------------------------------

(:getChildren (-> Tree (List Tree)))
(= (getChildren (TreeNode $nodeVal $guardSet $children)) $children)

;; -----------------------------------
;; -----------------------------------
;; -------- a function to get guardset
;; -----------------------------------
;; -----------------------------------

(:getGuardSet (-> Tree TreeList))
(= (getGuardSet (TreeNode $noeVal $guardSet $children)) $guardSet)

;; -----------------------------------
;; -------- updateChild
;; -------- Given a binary tree node and position (left, right) indicating which child to update, replace it's left or right child with the given node.
;; -----------------------------------
;; -----------------------------------

;; (node location (L or R) newNode)
(:replaceChild (-> Tree Tree Location Tree))
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

;; -----------------------------------
;; -------- Append Children
;; -------- Given a node and a tree, append the tree to the node's children.
;; -----------------------------------
;; -----------------------------------


(:appendChild (-> Tree Tree Tree))
(= (appendChild (TreeNode $nodeValue $guardSet $children) $child)
  (TreeNode $nodeValue $guardSet (Cons $child $children))
)


(:nodeEquality (-> Tree Tree Bool))
(= (nodeEquality (TreeNode $nodeValue1 $guardSet1 $children1) (TreeNode $nodeValue2 $guardSet2 $children2))
  (== $nodeValue1 $nodeValue2)
)

;;function to check if a tree is member of a treelist
(:treeIsMember (-> Tree (List Tree) Bool))
(= (treeIsMember $x $list)
   (memberWith nodeEquality $x $list)
)

;;function to return the intersection of two treelists
(:treeIntersection (-> (List Tree) (List Tree) (List Tree)))
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

; ------------------------------------

(:replaceGuardSet (-> Tree TreeList Tree) )
(= (replaceGuardSet $node $new-guardSet) 
    (let ($value $left $right $guardSet $children) 
        $node  
        (TreeNode $value $left $right $new-guardSet $children)
    )
)

(:replaceNodeValue (-> Tree NodeValue Tree))
(= (replaceNodeValue $tree $newValue)
    (let ($value $left $right $guardSet $children) 
        $node
        (TreeNode $newValue $left $right $new-guardSet $children)
    )
)

(:changeTree (-> Tree Tree Tree))
(= (changeTree $tree $newTree)
    (case $newTree  (
            ((TreeNode $newValue $newGuardSet $newChildren)
                $newTree
            )
            (Nil Nil)
            ($_ Error)

        )
    )
)
;; function that get the node types
(:getNodeType (-> Tree Atom))
(=(getNodeType (TreeNode (Value $value $bool $nodeType) $guardSet $children)) $nodeType)

(:compareTrees (-> Tree Tree Bool))
(=(compareTrees $tree1 $tree2)
    (case ($tree1 $tree2) (
        (((TreeNode (Value $symbol $constraint $nodetype) $leftChild $rightChild $guardSet $listOfChildren) (TreeNode (Value $symbol $constraint $nodetype)  $leftChild1 $rightChild1 $guardSet1 $listOfChildren1)) True)
        ($else False)
    )
    )
)

(:compareAndRemoveNode (-> Tree TreeList TreeList TreeList))
(=(compareAndRemoveNode $tree $treeList $accumulator)
    (case $treeList(
            ((ConsTree $x $xs)
                (if (== (compareTrees $tree $x) True)
                    (compareAndRemoveNode $tree $xs $accumulator)
                    (compareAndRemoveNode $tree $xs (appendTree $accumulator (ConsTree $x NilList)))
                )
            )
            ($_  $accumulator)

        )
    )
)

(= (treeFoldl $func $acc NilNode) $acc)
(= (treeFoldl $func $acc (TreeNode $nodeVal $leftTree $rightTree $guardSet $children))
  (case $nodeVal
    (
      ( (Value $val $truthVal LITERAL) 
        ($func $acc $val)
      )
      ( (Value $val $truthVal ROOT)
        (treeFoldl $func $acc $rightTree)
      )
      ( (Value $val $truthVal NOT)
        (treeFoldl $func $acc $rightTree)
      )
      ( (Value $val $truthVal AND)
        (treeFoldl $func (treeFoldl $func $acc $leftTree) $rightTree)
      )
      ( (Value $val $truthVal OR)
        (treeFoldl $func (treeFoldl $func $acc $leftTree) $rightTree)
      )
    )
  )
)

(= (treeFoldr $func $acc NilNode) $acc)
(= (treeFoldr $func $acc (TreeNode $nodeVal $leftTree $rightTree $guardSet $children))
  (case $nodeVal
    (
      ( (Value $val $truthVal LITERAL) ($func $acc $val) )
      ( (Value $val $truthVal ROOT) (treeFoldl $func $acc $rightTree) )
      ( (Value $val $truthVal NOT) (treeFoldl $func $acc $rightTree) )
      ( (Value $val $truthVal AND)
        (treeFoldl $func (treeFoldl $func $acc $leftTree) $rightTree)
      )
      ( (Value $val $truthVal OR)
        (treeFoldl $func (treeFoldl $func $acc $leftTree) $rightTree)
      )
    )
  )
)