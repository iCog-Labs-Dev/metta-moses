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
    (let* 
      (
        ($grandChild (head (getChildren $child)))
        ($updatedGuardSetTree (replaceGuardSet $current (unionSet (getGuardSet $current) (getGuardSet $grandChild))) )
        ($currentNodeChildren (getChildren $updatedGuardSetTree))
        ($updatedChildrenTree (replaceChildren $updatedGuardSetTree (extend (getChildren $grandChild) $currentNodeChildren)))
        ($finalUpdatedTree (findAndRemoveTree (getChildren $updatedChildrenTree) $grandChild))
      )
        ($finalUpdatedTree)
    )
)
)


(= (guardSetChecker $children)(
  if (> (length (getGuardSet (head $children))) 0)(length (getGuardSet (head $children)))(0)
  )
)

;; -----------------------------------
;; -----------------------------------
;; -------- A function that given children and the a local command set,
;; -------- it returns the updated command set
;; -----------------------------------
;; -----------------------------------

(: commandSetIterator(-> (List Tree) Tree Tree)
(= (commandSetIterator $children $localCommandSet)
  if (== (length $children) 0) ($localCommandSet)(
    if (== (and 
            (and (> (length (getChildren (head (getChildren $children)))) 0) (== (guardSetChecker $children) 1))
            (and (> (length $children) 0) (== (get-type (head $children)) AND))
            ) 
        True
        )(
              unionSet (getGuardSet (head $children)) (commandSetIterator (tail $children) $localCommandSet)
            )(
              commandSetIterator (tail $children) $localCommandSet
              )
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
