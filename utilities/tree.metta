(: Tree (-> $a Type))
(: mkTree (-> (Node $a) (List (Tree $a)) (Tree $a)))

(: Node (-> $a Type))
(: mkNode (-> $a (Node $a)))

(: NullVertex (Tree $a))
(: mkNullVex (-> (List (Tree $a)) (Tree $a)))

(: getChildren (-> (Tree $a) (List (Tree $a))))
(= (getChildren (mkTree (mkNode $r) $children)) $children)
(= (getChildren (mkNullVex $children)) $children)

(: updateChildren (-> (Tree $a) (List (Tree $a)) (Tree $a)))
(= (updateChildren (mkTree (mkNode $r) $oldChildren) $newChildren)
   (mkTree (mkNode $r) $newChildren))
(= (updateChildren (mkNullVex $oldChildren) $newChildren)
   (mkNullVex $newChildren))

(: preOrder (-> (Tree $a) $a))
(= (preOrder (mkTree (mkNode $r) Nil)) $r)
(= (preOrder (mkNullVex $knobs)) ())
(= (preOrder (mkTree (mkNode $r) (Cons $x $xs)))
     (let*
         (
           ($lc  (List.map preOrder (Cons $x $xs)))
           ($lc' (List.filter (. not isUnit) $lc))
           ($lcE (List.listToExpr $lc'))
           ;; (()   (println! (Root: $r Children: $lc Children': $lc' Expression: $lcE)))
           ($exp (cons-atom $r $lcE))
         )
         $exp)
)

(: buildTree (-> $a (Tree $a)))
(= (buildTree $expr)
        (if (== (get-metatype $expr) Expression)
            (let ($head $tail) (decons-atom $expr)
                (mkTree (mkNode $head) (exprToList (map buildTree $tail))))
            (mkTree (mkNode $expr) Nil))
            )

(: cleanTree (-> (Tree $a) (Tree $a)))
(= (cleanTree $tree)
    (let*
        (
          ($preordered (preOrder $tree))
          ($reduced (REDUCE $preordered))
        )
        (buildTree $reduced)))

;; Finds the NodeId of a subtree within the children of a target node.
;; Params:
;;   $tree: - The full tree to search.
;;   $targetId: - ID of the target node.
;;   $subtree: - The subtree to locate among the target node's children.
;;   $iter: - index to check children, increments recursively.
;; Returns:
;;   NodeId - The NodeId of the Subtree
(: getSubtreeId (-> (Tree $a) NodeId (Tree $a) Number NodeId))
(= (getSubtreeId $tree (mkNodeId $targetId) $subtree $iter)
   (let*
     (
       ($targetNode (getNodeById $tree (mkNodeId $targetId)))
       ($children   (getChildren $targetNode))
       ($currNode   (List.getByIdx $children $iter))
     )
     (if (== $currNode $subtree)
         (let*
           (
             ($index (+ $iter 1))
             ($idOfSubtree (union-atom $targetId ($index)))
           )
           (mkNodeId $idOfSubtree))
         (getSubtreeId $tree (mkNodeId $targetId) $subtree (+ $iter 1)))))

;; Retrieves the children list of a node identified by its NodeId.
;; Params:
;;   $tree: - The full tree to search.
;;   $id: - ID of the target node.
;; Returns:
;;   (List (Tree $a)) - The list of children of the target node.
(: getChildrenById (-> (Tree $a) NodeId (List (Tree $a))))
(= (getChildrenById $tree (mkNodeId $id))
   (let $targetNode (getNodeById $tree (mkNodeId $id))
     (getChildren $targetNode)))

;; Creates a new tree with a node inserted above the given tree as its parent.
;; Params:
;;   $tree: - The original tree to be placed as a child.
;;   $node: - The new node to become the root, wrapping $tree.
;; Returns:
;;   (Tree $a) - A new mkTree with $node as the root and $tree as its only child.
(: insertAbove (-> (Tree $a) (Node $n) (Tree $a)))
(= (insertAbove $tree $node)
   (mkTree $node (Cons $tree Nil))
)

;; Replaces a subtree at a specific NodeId with a new subtree.
;; Params:
;;   $tree: - The tree to modify.
;;   $id: - ID of the node to be replace.
;;   $newSubtree: - The new subtree to insert.
;; Returns:
;;   (Tree $a) - The updated tree with $newSubtree at $id.
(: replaceNodeById (-> (Tree $a) NodeId (Tree $a) (Tree $a)))
(= (replaceNodeById $tree (mkNodeId $id) $newSubtree)
   (if (== $id ())
       $newSubtree
       (let* (($headId (car-atom $id))
              ($tailId (cdr-atom $id))
              ($children (getChildren $tree))
              ($childToUpdate (List.getByIdx $children (- $headId 1)) )
              ($updatedChild
                 (if (== $tailId ())
                     $newSubtree
                     (replaceNodeById $childToUpdate (mkNodeId $tailId) $newSubtree)))
              ($newChildren
                 (List.replaceAt $children (- $headId 1) $updatedChild)))
         
         (updateChildren $tree $newChildren))))

;; Appends a child to a target node's children and returns the updated tree and child's NodeId.
;; Parameters:
;;   $tree: - The tree to modify.
;;   $target: - ID of the target node
;;   $child: - The new child to append.
;; Returns:
;;   ((Tree $a) NodeId) - Tuple of updated tree and NodeId of the new child.
(: appendChild (-> (Tree $a) NodeId (Tree $a) ((Tree $a) NodeId)))
(= (appendChild $tree (mkNodeId $target) $child)
   (let*
      (
        ( $targetNode (getNodeById $tree (mkNodeId $target)))
        ( $childrenTgt (getChildren $targetNode))
        ( $updatedChildrenTgt (List.append $child $childrenTgt))
        ( $childIndex (List.length $updatedChildrenTgt))
        ( $idOfChild (union-atom $target ($childIndex)))
        ( $newTargetSubtree (updateChildren $targetNode $updatedChildrenTgt))
        ( $updatedTree (replaceNodeById $tree (mkNodeId $target) $newTargetSubtree))
      )
    ($updatedTree (mkNodeId $idOfChild))))

;; getChildrenByIdx -- retrieve children of a tree using index values
(: getChildrenByIdx (-> (Tree $a) Number (List (Tree $a))))
(= (getChildrenByIdx $tree $idx)
        (case $tree
            (((mkTree (mkNode $r) $childrenTgt) (List.getByIdx $childrenTgt $idx))
              ((mkNullVex $childrenTgt) (List.getByIdx $childrenTgt $idx))
              ($else (Error (Node not found or invalid))))))


;; check if tree is empty
(: isEmpty (-> (Tree $a) Bool))
(= (isEmpty $tree)
    (case $tree
        (((mkNullVex Nil) True)
        ($else False))))

