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

;; a helper function used inside commandSetIterator.
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

;(: commandSetIterator(-> (List Tree) (List Tree) (List Tree)))
(= (commandSetIterator $children $localCommandSet)(
  if(== $children Nil)($localCommandSet) (
    let* 
    (
      ($c1 (== (getChildren (head $children)) Nil) )
      ($c2 (== (guardSetChecker $children) 1))
      ($c3 (not (== $children Nil)))
      ($c4 (== (getNodeType (head $children)) AND))
      ($final (and (and $c1 $c2) (and $c3 $c4)))
      ($tail (tail $children))
      ($ans (commandSetIterator $tail $localCommandSet))
      ($gs (getGuardSet (head $children)))
      ($union (setUnion $gs $ans))
;      ($union (setUnion (getGuardSet (head $children)) (commandSetIterator (tail $children) $localCommandSet)))
    )
    ($gs ---- $ans)
;      if(and (and (== (getChildren (head $children)) Nil) (== (guardSetChecker $children) 1))
;            (and (not (== $children Nil)) (== (getNodeType (head $children)) AND))
;        )(
;          setUnion (getGuardSet (head $children)) (commandSetIterator (tail $children) $localCommandSet)
;        )(commandSetIterator (tail $children) $localCommandSet)
;    $localCommandSet
    )
)
)

