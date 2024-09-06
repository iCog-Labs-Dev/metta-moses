
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
   (let*
      (
        (() (println! (inside orSubTreeElegance)))

        (($updatedCurrent $updatedChild $outcome) (reduceToElegance $current $child $dominantSet $localCommandSet))
        ($sndUpdatedCurrent (replaceChildren $updatedCurrent (findAndReplaceChild $child $updatedChild (getChildren $updatedCurrent))))

        (() (println! (updatedChild ==> $updatedChild updatedCurrent ==> $updatedCurrent)))
      )
      (case $outcome
        (
          (DELETE
            (if (> (length (getChildren $sndUpdatedCurrent)) 0)
                (let* 
                    (
                      ($updatedChildren (findAndRemoveTree $updatedChild (getChildren $sndUpdatedCurrent)))
                      ($removedChildCurrent (replaceChildren $updatedCurrent $updatedChildren))
                    )
                    ($removedChildCurrent ADVANCE)
                )
                ($sndUpdatedCurrent DELETE)
            )
          )
          (DISCONNECT ($sndUpdatedCurrent DISCONNECT))
          (KEEP ($sndUpdatedCurrent ADVANCE))
          ($_ ($sndUpdatedCurrent $outcome))
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
   (let*
     (
       (() (println! (Inside andSubTreeElegance)))
       (($fstUpdatedCurrent $updatedChild $outcome) (reduceToElegance $current $child $handleSet $commandSet))
     )
     (case $outcome 
       (
         (DELETE ((replaceChildren $fstUpdatedCurrent Nil) DELETE))
         (DISCONNECT ((replaceChildren $fstUpdatedCurrent (findAndRemoveTree $child (getChildren $fstUpdatedCurrent))) ADVANCE))
         (KEEP
           (let*
             (
               ($sndUpdatedCurrent (replaceChildren $fstUpdatedCurrent (findAndReplaceChild $child $updatedChild (getChildren $fstUpdatedCurrent))))
               ($resultSet (intersections (getChildren $updatedChild)))
               (() (println! (resultSet ==> $resultSet)))
             )
             (if(> (length $resultSet) 0) 
               (let*
                 (
                   ($updatedGuardSetCurrent (setUnion treeIsMember (getGuardSet $sndUpdatedCurrent) $resultSet))
                   ($updatedGrandChildren (mapList computeGrandChildGuardSet (getChildren $updatedChild) $resultSet))
                   ($sndUpdatedChild (replaceChildren $updatedChild $updatedGrandChildren))
                   ($result (mapParent applyAndCut (getChildren $sndUpdatedChild) $sndUpdatedChild))
                   ($sndUpdatedGrandChildren (map car-atom $result))
                   ($trdUpdatedChild (replaceChildren $sndUpdatedChild $sndUpdatedGrandChildren))
                   ($finalUpdatedCurrent (replaceChildren $updatedGuardSetCurrent (findAndReplaceChild $updatedChild $trdUpdatedChild (getChildren $updatedGuardSetCurrent))))
                 )
                 ($finalUpdatedCurrent RESET)
               )
               (let*
                 (
                   ($res (mapParent applyAndCut (getChildren $updatedChild) $updatedChild))
                   ($bools (map decoupleAndCutOutput $res))
                   ($containsTerminalAndNode (any $bools))
                 )
                 (if (== $containsTerminalAndNode False) ($updatedCurrentTree ADVANCE) ($updatedCurrentTree RESET))
               )
             )
           )
         )
         ($else 
           (let $sndUpdatedCurrent (replaceChildren $fstUpdatedCurrent (findAndReplaceChild $child $updatedChild (getChildren $fstUpdatedCurrent)))
              ($sndUpdatedCurrent $outcome)
           )
         )
       )
     )
   )
)

;; Helper function for itarator

(: applyToChildren (-> Tree (List Tree) Tree))
(= (applyToChildren $current Nil) $current)
(= (applyToChildren $current (Cons $x $xs)) 
    (let $newCurrent (applyOrCut $x $current)
      (applyToChildren $newCurrent $xs)
    )
)

; iterator function
(: iterator (-> Tree Tree (List Tree) (List Tree) (Tree Tree ReductionSignal)))
(= (iterator $parent $current $dominantSet $commandSet)
  ;; (let () (println! (inside Iterator ))
   (let* 
     (
       ($previousGuardSet (getGuardSet $current))
       ($handleSet (setUnion treeIsMember $dominantSet (getGuardSet $current)))
     )
      ;; (let () (println! (Inside Iterator after andSubTreeIterator call fstupdatedcurrent ==> $fstupdatedcurrent))
     (if (not (isConsistent $handleSet))
           ($parent $current DELETE)
          ;;  (let () (println! (handleSet is $handleSet current is $current)
           (let ($updatedParent $updatedCurrent $outcome) (andSubTreeIterator $parent (getChildren $current) $current $handleSet $commandSet)
              (if (~= $outcome NONE)
                  ($updatedParent $updatedCurrent $outcome) 
                  (let*
                    (
                      ($sndupdatedcurrent (applyToChildren $updatedCurrent (getChildren $updatedCurrent)))
                      ($setsAreIdentical (compareSets $previousGuardSet (getGuardSet $sndupdatedcurrent)))
                    )
                    ;; (let () (println! (secondUpdatedCurrent is $sndupdatedcurrent setsAreIdentical is $setsAreIdentical))
                    (if (not $setsAreIdentical) 
                        (iterator $updatedParent $sndupdatedcurrent $dominantSet $commandSet) 
                        ($updatedParent $sndupdatedcurrent NONE)
                    )
                    ;; )
                  )
              )
           )
           )
      ;;  )
     )
  ;;  )
   )
;; )
;; )

;; A function which is the reimplementation of the orSubTreeIterator function found in python
(: orSubTreeIterator (-> Tree (List Tree) Tree (List Tree) (List Tree) Number (Tree Tree Signal)))
(= (orSubTreeIterator $parent $children $currentNode $dominantSet $commandSet $currentChildIndex)
(let () (println! (Inside orSubTreeIterator))
(let*
 (
      ($child (indexOfTree $currentChildIndex $children))
      ($localCommandSet $commandSet)
      ($localCommandSetUpdated (commandSetIterator $child $children $localCommandSet))
      (($updatedCurrent $action) (orSubTreeElegance $child $currentNode $dominantSet $localCommandSetUpdated))
 )
 (let () (println! (Inside orSubTreeIterator After orSubElegance))
 (case $action
     (
        (ADVANCE
        (let () (println! (children ==> $children))
          (if (< (+ $currentChildIndex 1) (length $children))
              (orSubTreeIterator $parent $children $updatedCurrent $dominantSet $commandSet (+ $currentChildIndex 1))
              ($parent $updatedCurrent NONE)
          )
        )
        )
        (RESET
          (orSubTreeIterator $parent $children $updatedCurrent $dominantSet $commandSet 0)
        )
        ($else ($parent $updatedCurrent $action))
     )
 )
)
)))

;; A function which is the reimplementation of the andSubTreeIterator function found in python
(: andSubTreeIterator(-> Tree (List Tree) Tree (List Tree) (List Tree) Number (Tree Tree Signal)))
(= (andSubTreeIterator $parent $children $currentNode $handleSet $commandSet $currentChildIndex) 
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
                        (andSubTreeIterator $parent $children $updatedCurrent $handleSet $commandSet (+ $currentChildIndex 1))
                        ($parent $updatedCurrent NONE)
                    )
                  )
                  (RESET
                    (andSubTreeIterator $parent $children $updatedCurrent $handleSet $commandSet 0) 
                  )
                  ($else ($parent $updatedCurrent $action))
                )
            )
            )
        )
        ($parent $currentNode NONE)
     )
  )
)

;; Helper functions for the RTE algorithm it self

;; A helper function that acts like a lambda function definition in the map found in the OR case below.
(: updateGuardSet ((List Tree) Tree Tree))
(= (updateGuardSet $commonToAllChildren $child) (replaceGuardSet $child (setDifference (getGuardSet $child) $commonToAllChildren)))

;; Map function that accepts a binary function and it's second argument.
(: mapChild (-> Atom $t (List Tree) (List Tree)))
(= (mapChild $function $secondArg Nil) Nil)
(= (mapChild $function $secondArg (Cons $x $xs))
      (Cons ($function $secondArg $x) (mapChild $function $secondArg $xs))
)
