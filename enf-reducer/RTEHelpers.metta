
;a function to remove a child from a tree's listOfChildren and return an updated tree
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
;; The function takes a treeNode and checks if it has only one child and no guardSet, if so, it merges the child and the current node as one. It also checks the existence of a terminal and node in the child of the tree which will be beneficial for the `andSubTreeElegance` function. 
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
;; -------- Function that 
;; -------- 1. adds a target OR Node's child's
;; -------- guardset to the guardset of the target's parent 
;; -------- 2. adds the target OR Node's children to the parent's list of children 
;; -------  3. removes target OR Node from it's parent's list of children.
;; -----------------------------------
;; -----------------------------------

;; ----- Helper Functions for applyOrCut to enhance readability
(: updateGuardSetTree (-> Tree Tree Tree))
(= (updateGuardSetTree $target $node2)(
   let* (
      ($A (getGuardSet $target))
      ($B (getGuardSet $node2))
   )
    (replaceGuardSet $target (setUnion treeIsMember $A $B))
  )
)

(: updateChildrenTree (-> Tree Tree Tree Tree))
(= (updateChildrenTree $target $node1 $node2)(
    replaceChildren $target (extend (getChildren $node1) (getChildren $node2))
  )
)

(: removeChildFromTree (-> Tree Tree Tree))
(= (removeChildFromTree $parentNode $target)(
    replaceChildren $parentNode (findAndRemoveTree $target (getChildren $parentNode))
  )
)

(: applyOrCut (-> Tree Tree Tree))
(= (applyOrCut $child $current)(
  if(== (length (getChildren $child)) 1)
     (let* (
        ($grandChild (head (getChildren $child)))
        ($updatedGuardSetTree (updateGuardSetTree $current $grandChild))
        ($updatedChildrenTree (updateChildrenTree $updatedGuardSetTree $grandChild $updatedGuardSetTree))
        ($updatedTree (removeChildFromTree $updatedChildrenTree $child) )
        ($finalUpdatedTree (removeChildFromTree $updatedTree $grandChild) )
     )
      $finalUpdatedTree 
    )
    $current
)
)

;; a helper function used inside commandSetIterator.
(: guardSetChecker (-> (List Tree) Number))
(= (guardSetChecker $children)(
  if (> (length (getGuardSet (head $children))) 0)
    (length (getGuardSet (head $children)))
    0
  )
)

;; -----------------------------------
;; -----------------------------------
;; -------- A function that given children and the a local command set,
;; -------- it returns the updated command set
;; -----------------------------------
;; -----------------------------------

(: commandSetIterator(-> (List Tree) (List Tree) (List Tree)))
(= (commandSetIterator Nil $localCommandSet) $localCommandSet)
(= (commandSetIterator (Cons $x $xs) $localCommandSet)
(if (and 
        (and (== (getChildren (head (Cons $x $xs))) Nil) (== (guardSetChecker (Cons $x $xs)) 1))
        (== (getNodeType (head (Cons $x $xs))) AND)
      )(
        setUnion treeIsMember (getGuardSet (head (Cons $x $xs))) (commandSetIterator (tail (Cons $x $xs)) $localCommandSet)
      )
      (commandSetIterator (tail (Cons $x $xs)) $localCommandSet)
  )
)

; orSubTreeElegance implementation

(: orSubTreeElegance (-> Tree Tree (List Tree) (List Tree) (Tree Signal)))
(= (orSubTreeElegance $child $current $dominantSet $localCommandSet)
    (let () (println! (inside orSubTreeElegance))
    (let*
      (
        (($updatedChild $outcome) (reduceToElegance $child $dominantSet $localCommandSet))
        ($updatedCurrent (replaceChildren $current (findAndReplaceChild $child $updatedChild (getChildren $current))))
      )
      (let () (println! (updatedChild ==> $updatedChild updatedCurrent ==> $updatedCurrent))
      (case $outcome
          (
            (DELETE
                (if (> (length (getChildren $current)) 0)
                    (let* 
                        (
                          ($updatedChildren (findAndRemoveTree $child (getChildren $current)))
                          ($removedChildCurrent (replaceChildren $current $updatedChildren))
                        )
                        ($removedChildCurrent ADVANCE)
                    )
                    ($updatedCurrent DELETE)
                )
            )
            (DISCONNECT ($updatedCurrent DISCONNECT))
            (KEEP ($updatedCurrent ADVANCE))
            ($_ ($updatedCurrent $outcome))
          )
        )
    )
    )
)
)


;Helper functions for `andSubTreeElegance`

;;This function applies a function to each values of the first list and the second list.
;;The second list will be repeatedly passed without changing while the elements of the first list change.
(: mapList (-> Atom (List $t) (List $t) (List $t)))
(= (mapList $f Nil $rs) Nil)
(= (mapList $f (Cons $x $xs) $rs)
  (Cons ($f $x $rs) (mapList $f $xs $rs))
)
;;A function that applies a function to the elements of the first list and a constant parent.
(: mapParent (-> Atom (List $t) $t (List $t)))
(= (mapParent $f Nil $parent) Nil)
(= (mapParent $f (Cons $x $xs) $parent)
  (Cons ($f $x $parent) (mapParent $f $xs $parent))
)
;;A function that finds a tree node from a list of trees and replaces it with a new node.
(: findAndReplaceChild (-> Tree Tree (List Tree) (List Tree)))
(= (findAndReplaceChild $oldChild $newChild Nil) Nil)
(= (findAndReplaceChild $oldChild $newChild (Cons $x $xs))
  (if (== (isNodeEqual $oldChild $x) True)(Cons $newChild $xs)(Cons $x (findAndReplaceChild $oldChild $newChild $xs)))
)

;;a function that decouples the tuple output of `applyAndCut` and returns only the second element of the tuple.
(: decoupleAndCutOutput (-> (Tree Bool) Bool))
(= (decoupleAndCutOutput ((TreeNode $nodeValue $guardSet $children) $bool)) $bool)

(: andSubTreeElegance (-> Tree Tree (List Tree) (List Tree) (Tree Signal)))
(= (andSubTreeElegance $child $current $handleSet $commandSet)
  (let () (println! (Inside andSubTreeElegance))
  (
    let ($updatedChild $outcome) (reduceToElegance $child $handleSet $commandSet) 
    (
      case $outcome 
      (
        (DELETE ((replaceChildren $current Nil) DELETE))
        (DISCONNECT ((replaceChildren $current (findAndRemoveTree $child (getChildren $current))) ADVANCE) )
        (KEEP 
        (
          let* 
          (
            ($updatedCurrentTree (replaceChildren $current (findAndReplaceChild $child $updatedChild (getChildren $current))))
            ($resultSet (intersections Nil (getChildren $updatedChild)))
          )
          (
             if(> (length $resultSet) 0) 
               (
                 let* 
                 (
                  ($updatedGuardSetTree (setUnion treeIsMember (getGuardSet $updatedCurrentTree) $resultSet))
                  ($newChild (mapList computeGrandChildGuardset (getChildren $child) $resultSet))
                  ($updatedNewChild (mapParent applyAndCut (getChildren $newChild) $newChild))
                  ($finalResult (replaceChildren $updatedGuardSetTree (findAndReplaceChild $child $updatedNewChild (getChildren $updatedGuardSetTree))))
                 )
                 ($finalResult RESET)
               )
               (
                 let* 
                 (
                  ($res (mapParent applyAndCut (getChildren $child) $child))
                  ($bools (map decoupleAndCutOutput $res))
                  ($containsTerminalAndNode (any $bools))
                 )
                 (
                   if (== $containsTerminalAndNode True)($updatedCurrentTree ADVANCE)($updatedCurrentTree RESET)
                 )
               )
            )
          )
        )
        ($_ ($updatedChild $outcome))

      )
    )
  )
)
)

; helper function for itarator

(: applyToChildren (-> Tree (List Tree) Tree))
(= (applyToChildren $current $children)
   (case $children
     (
      (Nil $current) ; If there are no more children, return the current node
      ((Cons $child $rest)
         ; Apply `applyOrCut` to the current node and the child
         (let* (
             ($newChild (applyOrCut $current $child))
             ($newCurrent (prependChild $current $newChild))
             )
              (applyToChildren $newCurrent $rest)
         )
      )
     )
   )
)


; iterator function
;;(: iterator (-> Tree (List Tree) (List Tree) (Tree ReductionSignal)))
(= (iterator $current $dominant_set $command_set)
  (let () (println! (inside Iterator ))
   (let* (
       ($previousGuardSet (getGuardSet $current))
       ($handle_set (setUnion treeIsMember $dominant_set (getGuardSet $current)))
       (($signal $fstupdatedcurrent) (andSubTreeIterator (getChildren $current) $current $handle_set $command_set))
      )
      (let () (println! (Inside Iterator after andSubTreeIterator call))
       (if (not (isConsistent $handle_set)) 
           ($current DELETE) 
           (if (not (== $signal NONE)) 
              ($signal $fstupdatedcurrent) 
               (let
                   $sndupdatedcurrent (applyToChildren $fstupdatedcurrent (getChildren $fstupdatedcurrent))
               
                   
                  (if (not (compareSets $previousGuardSet (getGuardSet $sndupdatedcurrent))) 
                       (iterator $sndupdatedcurrent $dominant_set $command_set) 
                       ($sndupdatedcurrent NONE)
                   )
               )
           )
       )
   )
   )
)
)

;;a function which is the reimplementation of the orSubTreeIterator function found in python

(: orSubTreeIterator (-> Tree (List Tree) Tree (List Tree) (List Tree) (Tree Signal)))
(= (orSubTreeIterator $child $remainingChildren $currentNode $dominantSet $commandSet)
(let () (println! (Inside orSubTreeIterator))
(let*
 (
      ($localCommandSet $commandSet)
      ($localCommandSetUpdated (commandSetIterator $remainingChildren $localCommandSet))
      (($orNode $action) (orSubTreeElegance $child $currentNode $dominantSet $localCommandSetUpdated))
    ;($action ADVANCE);will be replaced with the above code once the functions 'orSubTreeElegance' and 'commandSetIterator' are implemented

 )
 (let () (println! (Inside orSubTreeIterator After orSubTreeIterator))
 (case $action
     (
        (ADVANCE
        ;;(let () (println! (== Inside orSubTreeIterator ==))
         (if (== (length $remainingChildren) 0)
              ($orNode NONE)
             (orSubTreeIterator (head $remainingChildren) (tail $remainingChildren) $orNode $dominantSet $commandSet)

             
         )
        ;;)
        )
        (RESET
         ($orNode NONE)
        )
        ($else ($orNode $action))

     )

 )
)
)))

;;a function which is the reimplementation of the andSubTreeIterator function found in python

(: andSubTreeIterator(-> (List Tree) Tree (List Tree) (List Tree) (Signal Tree)))
(: andSubTreeIterator(-> (List Tree) Tree (List Tree) (List Tree) Number (Signal Tree)))
(= (andSubTreeIterator $children $currentNode $handleSet $commandSet) 
    (andSubTreeIterator $children $currentNode $handleSet $commandSet 0)
)
(= (andSubTreeIterator $children $currentNode $handleSet $commandSet $currentChildIndex) 
  (let () (println! (Inside andSubTreeIterator))
    (if (== (length $children) 0) 
        (NONE $currentNode)
        (let*
            (
              ($currentChild (index $currentChildIndex $children))
              (($updatedCurrent $action) (andSubTreeElegance $currentChild $currentNode $handleSet $commandSet))
            )
            (case $action
                (
                  (ADVANCE
                    (if (< (+ $currentChildIndex 1) (length $children) )
                        (andSubTreeIterator $children $updatedCurrent $handleSet $commandSet (+ $currentChildIndex 1))
                        (NONE $updatedCurrent)
                    )
                  )
                  (RESET
                    (andSubTreeIterator $children $updatedCurrent $handleSet $commandSet 0) 
                  )
                  ($else ($action $updatedCurrent))
                )
            )
        )
     )
  )
)
