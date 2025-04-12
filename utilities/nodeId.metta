;;;;;;;;;;;;;;;;;;; ID System ;;;;;;;;;;;;;;;;;;;;

;; Uses indices to identify nodes in a tree. 
;; Example: (AND A (OR B C))
;; AND : (0)
;; A : (1) or (0 1)
;; (OR B C) : (2) or (0 2)
;; B : (2 1)
;; C : (2 2)

(: NodeId Type)
(: mkNodeId (-> $tuple NodeId)) 

;; Finds a subtree at a specific level in the tree.
;; Params:
;;   $tree: - The input tree (mkTree, mkNullVex, or Nil).
;;   $levelId: - index indicating the level (0 for root, 1 for first child, etc.).
;; Returns:
;;   (Tree $a) - The subtree at the specified level, or Nil if out of bounds.
(: findLevelById (-> (Tree $a) Number (Tree $a)))
(: findLevelById (-> (Tree $a) Number (Tree $a)))
(= (findLevelById (mkTree (mkNode $r) $children) $levelId)
   (if (== $levelId 0)
       (mkTree (mkNode $r) $children)
       (List.getByIdx $children (- $levelId 1))))
(= (findLevelById (mkNullVex $children) $levelId)
   (if (== $levelId 0)
       (mkNullVex $children)
       (List.getByIdx $children (- $levelId 1))))
(= (findLevelById Nil $levelId) Nil)

;; Traverses a tree to find a node by its ID path.
;; Parameters:
;;   $tree: - The input tree (mkTree, mkNullVex, or Nil).
;;   $id: - A mkNodeId-wrapped tuple of indices (e.g., (mkNodeId (2 1))) representing the path.
;; Returns:
;;   (Tree $a) - The subtree at the specified ID path, or an error if invalid.
(: findNodeById (-> (Tree $a) NodeId (Tree $a)))
(: findNodeById (-> (Tree $a) NodeId (Tree $a)))
(= (findNodeById $tree (mkNodeId ())) $tree)
(= (findNodeById Nil $id) Nil)
(= (findNodeById $tree (mkNodeId $id))
   (let*
     (
       ($head (car-atom $id))
       ($tail (cdr-atom $id))
       ($level (findLevelById $tree $head))
     )
     (case $level
       (
         ((mkTree $n $c)
          (if (== $tail ())
              (mkTree $n $c)
              (let*
              (
               ($nextHead (car-atom $tail))
               ($nextTail (cdr-atom $tail))
               ($nextLevel (findLevelById (mkTree $n $c) $nextHead))
              )
              (findNodeById $nextLevel (mkNodeId $nextTail))
              ))
         )
         ((mkNullVex $c)
          (if (== $tail ())
              (mkNullVex $c)
              (let*
              (
               ($nextHead (car-atom $tail))
               ($nextTail (cdr-atom $tail))
               ($nextLevel (findLevelById (mkNullVex $c) $nextHead))
              )
              (findNodeById $nextLevel (mkNodeId $nextTail))
              ))
         ($else (Error "Index out of bounds"))
       )
       )
      )

   )
)
