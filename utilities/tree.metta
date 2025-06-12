(: Tree (-> $a Type))
(: mkTree (-> (Node $a) (List (Tree $a)) (Tree $a)))
(: Node (-> $a Type))
(: mkNode (-> $a (Node $a)))

(: NullVertex (Tree $a))
(: mkNullVex (-> (List (Tree $a)) (Tree $a)))

(: getNodeValue (-> (Tree $a) (Node $a)))
(= (getNodeValue (mkNullVex $xs)) (Error (mkNullVex $xs) "Null Vertex has no value"))
(= (getNodeValue (mkTree $nodeValue $chl)) $nodeValue)

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
          ;; ($reduced (REDUCE $preordered))
        )
        (buildTree $preordered))) ;; TODO: Remove when REDUCE is implemented.
        ;; (buildTree $reduced)))

;; Get an id of a certain node. And (0) if the root node.
;; Example:
;;    Id of A in the (AND (OR (AND A B))) => (1 1 1)
;;    Id of (AND A B) in the (AND (OR (AND A B))) => (1 1)
;; Params:
;;   $tree: The full tree to search
;;   $targetTree: The target tree to find the ID of.
;; Returns:
;;   NodeId: The id of the targetTree if found.
(: getNodeId (-> (Tree $a) (Tree $a) NodeId))
(: getNodeId (-> (Tree $a) (Tree $a) NodeId NodeId))
(= (getNodeId $tree $targetTree) (getNodeId $tree $targetTree (mkNodeId (0))))
(= (getNodeId $tree $targetTree (mkNodeId $parentIdx))
    (if (== $tree $targetTree)
        (mkNodeId $parentIdx)
        (chain (getChildren $tree) $children
        (chain (List.index $children $targetTree) $targetIdx
        (if (== $targetIdx -1)
            (chain (List.foldl applyGetNodeId ($targetTree (mkNodeId $parentIdx) (mkNodeId (-1)) 1) $children) $state
              (let ($_ $__ $nodeId $iter) $state $nodeId))
            (if (== $parentIdx (0)) ;; If parentIdx is (0) don't include it in the index.
                (mkNodeId ((+ 1 $targetIdx)))
                (mkNodeId (unionAtom $parentIdx ((+ 1 $targetIdx))))))))))

;; Helper function for the getNodeId function.
;;   The function's sole purpose is to make the
;;   getNodeById compatible for the foldr function call.
(: applyGetNodeId (-> (Tree $a) ((Tree $a) NodeId NodeId Number) ((Tree $a) NodeId NodeId Number)))
(= (applyGetNodeId $currTree ($targetTree (mkNodeId $parentIdx) $accId $iter))
    (if (== $accId (mkNodeId (-1)))
        (chain (getNodeId $currTree $targetTree (mkNodeId ($iter))) $nodeId
        (chain (if (== $parentIdx (0)) (mkNodeId $idx) (mkNodeId (unionAtom $parentIdx $idx))) $newId ;; If parentIdx (0) don't include it in the index.
          (let (mkNodeId $idx) $nodeId
            (if (== $idx (-1))
                ($targetTree (mkNodeId $parentIdx) $nodeId (+ 1 $iter))
                ($targetTree $nodeId $newId (+ 1 $iter))))))
        ($targetTree (mkNodeId $pareantIdx) $accId (+ 1 $iter))))

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

   ;; If no more id or targetTree is root.
   (if (or (== $id ()) (== (mkNodeId $id) (mkNodeId (0)))) ;; Without the mkNodeId constructor the interpreter treats the () and (0) as different types.
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
(= (appendChild (mkNullVex Nil) $targetId $child) ($child (mkNodeId (0))))
(= (appendChild (mkNullVex (Cons $x $xs)) $targetId $child) (Error (mkNullVex (Cons $x $xs)) "Null vertex can't have more than one child"))
(= (appendChild (mkTree $node $children) (mkNodeId $target) $child)
   (let*
      (
        ( $tree (mkTree $node $children))
        ( $targetNode (getNodeById $tree (mkNodeId $target)))
        ( $childrenTgt (getChildren $targetNode))
        ( $updatedChildrenTgt (List.append $child $childrenTgt))
        ( $childIndex (List.length $updatedChildrenTgt))

        ;; Comparison has to be in mkNodeId constructor because if not,
        ;;    when the expression size is different so will the type and
        ;;    cause bad type error sometimes. For example, (2 3) 's type
        ;;    is (Number Number) and (0) 's type is (Number) hence the
        ;;    interpreter throws a bad type error.
        ( $idOfChild (if (== (mkNodeId $target) (mkNodeId (0))) ($childIndex) (union-atom $target ($childIndex))))
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
        
;; check if tree is null vertex 
(: isNullVertex (-> (Tree $a) Bool))
(= (isNullVertex $tree)
    (case $tree
        (((mkNullVex $children) True)
         ($else False))))

;; Takes a tree and decides if the node is an argument or not.
;; An argument is anything that's not an operator or a null vertex.
(: isArgument (-> (Tree $a) Bool))
(= (isArgument (mkNullVex $x)) False)
(= (isArgument (mkTree (mkNode $x) $children))
   (and (not (isMember $x (AND OR NOT))) (== $children Nil)))

;; A function to calculate the complexity of a tree.
;;  The complexity of a tree is the number of arguments it contains.
;;  That means, ANDs, ORs and NOTs have no complexity. 
;; Knobs, or null vetices aren't included in the complexity calculatio.
(: treeComplexity (-> (Tree $a) Number))
(= (treeComplexity (mkNullVex $x)) 0)
(= (treeComplexity (mkTree (mkNode $a) $children)) ;; AND, OR and NOT have no complexity
   (if (isArgument (mkTree (mkNode $a) $children))
       1
       (List.sum (List.map treeComplexity $children))))          

;; NOTE: for future use -- a function to determine the alphabet size of a given tree for computation of complexity ratio
;; takes a truth table and adds 3 (for AND,. OR and NOT) to the number of input labels
(: alphabetSize (-> (ITable $a) Number))
(= (alphabetSize (mkITable $rows $labels)) 
    (+ 3 (- (List.length $labels) 1)))                   
