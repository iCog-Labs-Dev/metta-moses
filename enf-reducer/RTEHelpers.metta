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

;;a function which is the reimplementation of the orSubTreeIterator function found in python

(: orSubTreeIterator(-> Tree (List Tree) Tree (List Tree) (List Tree) Signal))
(= (orSubTreeIterator $child $remainingChildren $currentNode $dominantSet $commandSet) 
(let*
 (
    ;($localCommandSet (commandSet))
    ;($localCommandSetUpdated (commandSetIterator $remainingChildren $localCommandSet))
    ;($action (orSubTreeElegance $child $currentNode $dominantSet $localCommandSetUpdated))
    ($action ADVANCE);will be replaced with the above code once the functions 'orSubTreeElegance' and 'commandSetIterator' are implemented

 )
 (case $action
     (
        (ADVANCE
         (if (> (length $remainingChildren) 0)
             (orSubTreeIterator (head $remainingChildren) (tail $remainingChildren) $currentNode $dominantSet $commandSet)
             (None $currentNode)
         )
        )
        (RESET
         (None $currentNode)
        )
        ($else ($action $currentNode))

     )

 )
))

;;a function which is the reimplementation of the andSubTreeIterator function found in python

(: andSubTreeIterator(-> (List Tree) Tree (List Tree) (List Tree) (-> (List Tree) Tree (List Tree) (List Tree) Number Signal)))
(= (andSubTreeIterator $children $currentNode $handleSet $commandSet) 
    (andSubTreeIterator $children $currentNode $handleSet $commandSet 0)
)
(: andSubTreeIterator(-> (List Tree) Tree (List Tree) (List Tree) Number Signal))
(= (andSubTreeIterator $children $currentNode $handleSet $commandSet $currentChildIndex) 
(if (== (length $children) 0) (None $currentNode)
(let*
 (
    ($currentChild (index $currentChildIndex $children))
    ;($action (andSubTreeElegance $currentChild $currentNode $handleSet $commandSet))
    ($action ADVANCE);to be replaced with the above code when 'andSubTreeElegance' is implemented

 )
 (case $action
     (
        (ADVANCE
         (if (< (+ $currentChildIndex 1) (length $children) )
             (andSubTreeIterator $children $currentNode $handleSet $commandSet (+ $currentChildIndex 1))
             (None $currentNode)
         )
        )
        (RESET
         (andSubTreeIterator $children $currentNode $handleSet $commandSet 0)
        )
        ($else ($action $currentNode))

     )

 )
)
)
)
