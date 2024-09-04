
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

;; A function to remove unnecessary AND node.
;; And AND node is said to be unnecessary if it has no guardSet and only one child.
(: applyAndCut (-> Tree Tree (Tree Bool)))
(= (applyAndCut $grandChild $child)
  (if (and (== (length (getChildren $grandChild)) 1) (== (getGuardSet $grandChild) Nil))
     (if (>= (length (getChildren (head (getChildren $grandChild)))) 0)
        (let* 
          (
            ($firstNodeOfGrandChild (head (getChildren $grandChild)))
            ($updatedChildrenTree (replaceChildren $child (extend (getChildren $child) (getChildren $firstNodeOfGrandChild))))
            ($finalUpdatedTree (replaceChildren $updatedChildrenTree (findAndRemoveTree $grandChild (getChildren $updatedChildrenTree) )))
            ($hasTerminalAndNode (containsTerminalAndNode (getChildren $firstNodeOfGrandChild)))
          )
          ($finalUpdatedTree $hasTerminalAndNode)
        )
        ($child False)
     )
     ($child False)
  )
)


;; Helper Functions for applyOrCut to enhance readability
(: updateGuardSetTree (-> Tree Tree Tree))
(= (updateGuardSetTree $target $node2)
   (let* 
     (
      ($A (getGuardSet $target))
      ($B (getGuardSet $node2))
     )
     (replaceGuardSet $target (setUnion treeIsMember $A $B))
  )
)

;; Helper Functions for applyOrCut to enhance readability
(: updateChildrenTree (-> Tree Tree Tree))
(= (updateChildrenTree $target $node2)
  (replaceChildren $target (extend (getChildren $target) (getChildren $node2)))
)

;; Helper Functions for applyOrCut to enhance readability
(: removeChildFromTree (-> Tree Tree Tree))
(= (removeChildFromTree $parentNode $target)
   (replaceChildren $parentNode (findAndRemoveTree $target (getChildren $parentNode)))
)

;; This function that removes unnecessary OR nodes from the tree.
;; An OR node is deemed to be unnecessary if it only has one child.
(: applyOrCut (-> Tree Tree Tree))
(= (applyOrCut $child $current)
    (if (== (length (getChildren $child)) 1)
        (let* 
          (
            ($grandChild (headOfChildren (getChildren $child)))
            ($updatedGuardSetTree (updateGuardSetTree $current $grandChild))
            ($updatedChildrenTree (updateChildrenTree $updatedGuardSetTree $grandChild))
            ($updatedTree (removeChildFromTree $updatedChildrenTree $child) )
            ($finalUpdatedTree (removeChildFromTree $updatedTree $grandChild) )
          )
          $finalUpdatedTree 
        )
        $current
    )
)

;; -----------------------------------
;; -----------------------------------
;; -------- A function that given children and the a local command set,
;; -------- it returns the updated command set
;; -----------------------------------
;; -----------------------------------

;; Function that iterates over the siblings of the current child and computes the local command set.
;; A sibling will be added to the local command set if it is a terminal AND node with a single constraint.
(: commandSetIterator (-> Tree (List Tree) (List Tree) (List Tree)))
(= (commandSetIterator $_ Nil $localCommandSet) $localCommandSet)
(= (commandSetIterator $child (Cons $x $xs) $localCommandSet)
  (if (and
          (and (== (getChildren $x) Nil) (== (length (getGuardSet $x)) 1))
          (and (== (getNodeType $x) AND) (~= $child $x))
      )
      (let $tempResult (setUnion treeIsMember (getGuardSet $x) (commandSetIterator $child $xs $localCommandSet))
        (setDifference treeIsMember $tempResult (getGuardSet $child) Nil)
      )
      (commandSetIterator $child $xs $localCommandSet)
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
          ;;(let () (resultSet ==> $resultSet)
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
                   if (== $containsTerminalAndNode False)($updatedCurrentTree ADVANCE)($updatedCurrentTree RESET)
                 )
               )
            )
          ;;)
          )
        )
        ;;($_ ($updatedChild $outcome))

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
(: iterator (-> Tree (List Tree) (List Tree) (Tree ReductionSignal)))
(= (iterator $current $dominant_set $command_set)
  ;; (let () (println! (inside Iterator ))
   (let* (
       ($previousGuardSet (getGuardSet $current))
       ($handle_set (setUnion treeIsMember $dominant_set (getGuardSet $current)))
       (($signal $fstupdatedcurrent) (andSubTreeIterator (getChildren $current) $current $handle_set $command_set 0))
      )
      ;; (let () (println! (Inside Iterator after andSubTreeIterator call fstupdatedcurrent ==> $fstupdatedcurrent))
       (if (not (isConsistent $handle_set)) 
           ($current DELETE) 
          ;;  (let () (println! (handle_set is $handle_set current is $current)
           (if (not (== $signal NONE)) 
              ($signal $fstupdatedcurrent) 
               (let* (
                  ($sndupdatedcurrent (applyToChildren $fstupdatedcurrent (getChildren $fstupdatedcurrent)))
                  ($setsAreIdentical (compareSets $previousGuardSet (getGuardSet $sndupdatedcurrent)))

               )
                ;; (let () (println! (secondUpdatedCurrent is $sndupdatedcurrent setsAreIdentical is $setsAreIdentical))
                      (if (not $setsAreIdentical) 
                          (iterator $sndupdatedcurrent $dominant_set $command_set) 
                          ($sndupdatedcurrent NONE)
                      )
                ;; )
               )
           )
           )
      ;;  )
   )
  ;;  )
   )
;; )
;; )

;;a function which is the reimplementation of the orSubTreeIterator function found in python

(: orSubTreeIterator (-> Tree (List Tree) Tree (List Tree) (List Tree) (Tree Signal)))
(= (orSubTreeIterator $child $remainingChildren $currentNode $dominantSet $commandSet)
(let () (println! (Inside orSubTreeIterator))
(let*
 (
      ($localCommandSet $commandSet)
      ($localCommandSetUpdated (commandSetIterator $child $remainingChildren $localCommandSet))
      (($orNode $action) (orSubTreeElegance $child $currentNode $dominantSet $localCommandSetUpdated))
    ;($action ADVANCE);will be replaced with the above code once the functions 'orSubTreeElegance' and 'commandSetIterator' are implemented

 )
 (let () (println! (Inside orSubTreeIterator After orSubElegance))
 (case $action
     (
        (ADVANCE
        (let () (println! (remainingChildren ==> $remainingChildren))
         (if (== (length $remainingChildren) 0)
              ($orNode NONE)
             (orSubTreeIterator (headOfChildren $remainingChildren) (tail $remainingChildren) $orNode $dominantSet $commandSet)

             
         )
        )
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

;;(: andSubTreeIterator(-> (List Tree) Tree (List Tree) (List Tree) (Signal Tree)))
(: andSubTreeIterator(-> (List Tree) Tree (List Tree) (List Tree) Number (Signal Tree)))
;; (= (andSubTreeIterator $children $currentNode $handleSet $commandSet) 
;;     (andSubTreeIterator $children $currentNode $handleSet $commandSet 0)
;; )
(= (andSubTreeIterator $children $currentNode $handleSet $commandSet $currentChildIndex) 
  (let () (println! (Inside andSubTreeIterator))
    (if (> (length $children) 0) 
        (let*
            (
              ($currentChild (indexOfTree $currentChildIndex $children))
              (($updatedCurrent $action) (andSubTreeElegance $currentChild $currentNode $handleSet $commandSet))
            )
            (let () (println! (AndSubTreeIterator ==> $currentChildIndex children ==> $children currentNode ==> $currentNode handleSet ==> $handleSet commandSet ==> $commandSet)) ;;checking currentIndex
            (case $action
                (
                  (ADVANCE
                    (if (< (+ $currentChildIndex 1) (length $children))
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
        (NONE $currentNode)
     )
  )
)
