;a funcion to remove a child from a tree's listOfChildren and return an updated tree
(: disconnectSubTreeHandler (-> Tree Tree Tree))
(=(disconnectSubTreeHandler Nil $tree) $tree)
(=(disconnectSubTreeHandler $child Nil) Nil)
(=(disconnectSubTreeHandler $child (TreeNode $nodeValue $guardSet $children))
  (TreeNode 
    $nodeValue 
    $guardSet 
    (compareAndRemoveNode $child $children Nil)
  )
)

;; A function that applies the "ApplyAndCut" operation on a tree node. It is the reimplementation of the function found in python.
;; The function takes a treeNode and checks if it has only one child and no guardSet, if so, it merges the child and the current node as one. It also checks the existance of a terminal and node in the child of the tree which will be beneficial for the `andSubTreeElegance` function. 
;; The function returns the updated  tree and the boolean value together in a tuple.

(: applyAndCut (-> Tree Tree (Tree Bool)))
(= (applyAndCut $grandChild $child)
  (if (and (== (length (getChildren $grandChild)) 1) (== (getGuardSet $grandChild) Nil))
     (if (>= (length (getChildren (head (getChildren $grandChild)))) 0)
        (let* 
          (
            ($firstNodeOfGrandChild (head (getChildren $grandChild)))
            ($updatedChildrenTree (replaceChildren $child (extend (getChildren $child) (getChildren $firstNodeOfGrandChild))))
            ($finalUpdatedTree (replaceChildren $updatedChildrenTree (findAndRemoveTree $firstNodeOfGrandChild (getChildren $updatedChildrenTree) )))
            ($hasTerminalAndNode (containsTerminalAndNode (getChildren $firstNodeOfGrandChild)))
          )
          ($finalUpdatedTree $hasTerminalAndNode)
        )
        ($child False)
     )
     ($child False)
  )
)


;; -----------------------------------
;; -----------------------------------
;; -------- Function that adds the target OR Node's child's
;; -------- guardset to the guardset of its parent, add the 
;; -------- target OR Node's grandchildren to the parent's list of children, 
;; -------- remove target OR Node from it's parent's list of children.
;; -----------------------------------
;; -----------------------------------

(: applyOrCut (-> Tree Tree Tree))
(= (applyOrCut $child $current)(
  if(== (length (getChildren $child)) 1)
     (let* (
        ($grandChild (head (getChildren $child)))
        ($updatedGuardSetTree (replaceGuardSet $current (setUnion (getGuardSet $current) (getGuardSet $grandChild))))
        ($updatedChildrenTree (replaceChildren $updatedGuardSetTree (extend (getChildren $grandChild) (getChildren $updatedGuardSetTree))))
        ($finalUpdatedTree (replaceChildren $updatedChildrenTree (findAndRemoveTree $grandChild (getChildren $updatedChildrenTree))) )
     )
      $finalUpdatedTree
       )
    ($current)
  )
)
