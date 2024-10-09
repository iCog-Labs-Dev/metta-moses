
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
            ($finalUpdatedTree (replaceChildren $updatedChildrenTree (findAndRemove $grandChild (getChildren $updatedChildrenTree) )))
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

;this function is used to call the `applyOrCut` function on 
;all instances of the children of a tree.
(: applyOrCutToChildren (-> (-> $t $t $t) $t (List $t) $t))
(= (applyOrCutToChildren $f $current Nil) $current)
(= (applyOrCutToChildren $f $current (Cons $x $xs)) 
    (applyOrCutToChildren $f ($f $x $current) $xs) ;If $f applies to $x and $current, then it must also apply to $xs and ($f $x $current).
                                                  ;($f $x $current) is a new value for $current.
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

        (($updatedCurrent $updatedChild $signal) (reduceToElegance $current $child $dominantSet $localCommandSet))

        (() (println! (updatedChild ==> $updatedChild updatedCurrent ==> $updatedCurrent)))
      )
      (case $signal
        (
          (DELETE
            (if (> (length (getChildren $updatedCurrent)) 0)
                (let*
                    (
                      ($updatedChildren (findAndRemove $updatedChild (getChildren $updatedCurrent)))
                      ($removedChildCurrent (replaceChildren $updatedCurrent $updatedChildren))
                    )
                    ($removedChildCurrent ADVANCE)
                )
                ($updatedCurrent DELETE)
            )
          )
          (DISCONNECT ($updatedCurrent DISCONNECT))
          (KEEP ($updatedCurrent ADVANCE))
          ($_ ($updatedCurrent $signal))
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
(: mapParent (-> $f (List $t) $t (List $tt)))
(= (mapParent $f Nil $parent) Nil)
(= (mapParent $f (Cons $x $xs) $parent)
  (Cons ($f $x $parent) (mapParent $f $xs $parent))
)
;;A function that finds a tree node from a list of trees and replaces it with a new node.
(: findAndReplace (-> Tree Tree (List Tree) (List Tree)))
(= (findAndReplace $oldChild $newChild Nil) Nil)
(= (findAndReplace $oldChild $newChild (Cons $x $xs))
  (if (== $oldChild $x)
      (Cons $newChild $xs)
      (Cons $x (findAndReplace $oldChild $newChild $xs))
  )
)

;;a function that decouples the tuple output of `applyAndCut` and returns only the second element of the tuple.
(: decoupleAndCutOutput (-> (Tree Bool) Bool))
(= (decoupleAndCutOutput ((TreeNode $nodeValue $guardSet $children) $bool)) $bool)

(: andSubTreeElegance (-> Tree Tree (List Tree) (List Tree) (Tree Signal)))
(= (andSubTreeElegance $child $current $handleSet $commandSet)
   (let*
     (
       (() (println! (Inside andSubTreeElegance)))

       (($fstUpdatedCurrent $updatedChild $signal) (reduceToElegance $current $child $handleSet $commandSet))
     )
     (case $signal 
       (
         (DELETE ((replaceChildren $fstUpdatedCurrent Nil) DELETE))
         (DISCONNECT ((replaceChildren $fstUpdatedCurrent (findAndRemove $updatedChild (getChildren $fstUpdatedCurrent))) ADVANCE))
         (KEEP
           (let*
             (
               ($resultSet (intersections (getChildren $updatedChild)))

               (() (println! (resultSet ==> $resultSet)))
             )
             (if(> (length $resultSet) 0) 
               (let*
                 (
                   ($updatedGuardSetCurrent (setUnion treeIsMember (getGuardSet $fstUpdatedCurrent) $resultSet))
                   ($updatedGrandChildren (mapList computeGrandChildGuardSet (getChildren $updatedChild) $resultSet))
                   ($sndUpdatedChild (replaceChildren $updatedChild $updatedGrandChildren))
                   ($result (mapParent applyAndCut (getChildren $sndUpdatedChild) $sndUpdatedChild))
                   ($sndUpdatedGrandChildren (map car-atom $result))
                   ($trdUpdatedChild (replaceChildren $sndUpdatedChild $sndUpdatedGrandChildren))
                   ($finalUpdatedCurrent (replaceChildren $updatedGuardSetCurrent (findAndReplace $updatedChild $trdUpdatedChild (getChildren $updatedGuardSetCurrent))))
                 )
                 ($finalUpdatedCurrent RESET)
               )
               (let*
                 (
                   (() (println! (Children of UpdatedChild: (getChildren $updatedChild))))

                   ($res (mapParent applyAndCut (getChildren $updatedChild) $updatedChild))
                   ($bools (map decoupleAndCutOutput $res))
                   ($containsTerminalAndNode (any $bools))

                   (() (println! (Result ==> $res)))
                   (() (println! (Bools ==> $bools )))
                   (() (println! (Contains Terminal And Node ==> $containsTerminalAndNode)))
                 )
                 (if (not $containsTerminalAndNode) ($fstUpdatedCurrent ADVANCE) ($fstUpdatedCurrent RESET))
               )
             )
           )
         )
         ($else ($fstUpdatedCurrent $signal))
       )
     )
   )
)

;; Helper function for itarator
; iterator function
(: iterator (-> Tree (List Tree) (List Tree) (Tree ReductionSignal)))
(= (iterator $current $dominantSet $commandSet)
   (let*
     (
       (() (println! (inside Iterator )))

       ($previousGuardSet (getGuardSet $current))
       ($handleSet (setUnion treeIsMember $dominantSet (getGuardSet $current)))
     )
     (if (not (isConsistent $handleSet))
           ($current DELETE)
           (let ($updatedCurrent $signal) (andSubTreeIterator (getChildren $current) $current $handleSet $commandSet 0)
              (if (~= $signal NONE)
                  ($updatedCurrent $signal) 
                  (let*
                    (
                      (() (println! (Inside Iterator after andSubTreeIterator call fstupdatedcurrent ==> $updatedCurrent)))
                      ;; (() (println! (The signal is $signal)))

                      ($sndupdatedcurrent (applyOrCutToChildren applyOrCut $updatedCurrent (getChildren $updatedCurrent)))
                      ($setsAreIdentical (compareSets $previousGuardSet (getGuardSet $sndupdatedcurrent)))

                      (() (println! (secondUpdatedCurrent is $sndupdatedcurrent setsAreIdentical is $setsAreIdentical)))
                    )
                    (if (not $setsAreIdentical) 
                        (iterator $sndupdatedcurrent $dominantSet $commandSet) 
                        ($sndupdatedcurrent NONE)
                    )
                  )
              )
           )
     )
   )
)

;; A function which is the reimplementation of the orSubTreeIterator function found in python
(: orSubTreeIterator (-> (List Tree) Tree (List Tree) (List Tree) Number (Tree Signal)))
(= (orSubTreeIterator Nil $currentNode $dominantSet $commandSet $currentChildIndex) ($currentNode NONE))
(= (orSubTreeIterator (Cons $x $xs) $currentNode $dominantSet $commandSet $currentChildIndex)
   (let*
      (
        (() (println! (Inside orSubTreeIterator)))

        ($children (Cons $x $xs))
        ($child (indexOfTree $currentChildIndex $children))
        ($localCommandSet $commandSet)
        ($localCommandSetUpdated (commandSetIterator $child $children $localCommandSet))
        (($updatedCurrent $signal) (orSubTreeElegance $child $currentNode $dominantSet $localCommandSetUpdated))

        (() (println! (Inside orSubTreeIterator After orSubElegance)))
        (() (println! (children ==> $children)))
      )
      (case $signal
        (
          (ADVANCE
            (if (< (+ $currentChildIndex 1) (length $children))
                (orSubTreeIterator $children $updatedCurrent $dominantSet $commandSet (+ $currentChildIndex 1))
                ($updatedCurrent NONE)
            )
          )
          (RESET
            (orSubTreeIterator $children $updatedCurrent $dominantSet $commandSet 0)
          )
          ($else ($updatedCurrent $signal))
        )
      )
   )
)

;; A function which is the reimplementation of the andSubTreeIterator function found in python
(: andSubTreeIterator(-> (List Tree) Tree (List Tree) (List Tree) Number (Tree Signal)))
(= (andSubTreeIterator Nil $currentNode $handleSet $commandSet $currentChildIndex) ($currentNode NONE))
(= (andSubTreeIterator (Cons $x $xs) $currentNode $handleSet $commandSet $currentChildIndex) 
  (let () (println! (Inside andSubTreeIterator))
       (let*
          (
            (() (println! (Inside andSubTreeIterator before calling AndSubTreeElegance)))

            ($children (Cons $x $xs))
            ($currentChild (indexOfTree $currentChildIndex $children))
            (($updatedCurrent $signal) (andSubTreeElegance $currentChild $currentNode $handleSet $commandSet))

            (() (println! (Inside AndSubTreeIterator After andSubTreeElegance with updatedCurrent ==> $updatedCurrent And Signal $signal)))
            (() (println! (AndSubTreeIterator ==> $currentChildIndex children ==> $children currentNode ==> $currentNode handleSet ==> $handleSet commandSet ==> $commandSet)))
          )
          (case $signal
            (
              (ADVANCE
                (if (< (+ $currentChildIndex 1) (length $children))
                    (andSubTreeIterator $children $updatedCurrent $handleSet $commandSet (+ $currentChildIndex 1))
                    ($updatedCurrent NONE)
                )
              )
              (RESET
                (andSubTreeIterator $children $updatedCurrent $handleSet $commandSet 0) 
              )
              ($else ($updatedCurrent $signal))
            )
          )
       )
  )
)

;; Helper functions for the RTE algorithm it self

;; A helper function that acts like a lambda function definition in the map found in the OR case below.
(: updateGuardSet ((List Tree) Tree Tree))
(= (updateGuardSet $commonToAllChildren $child) (replaceGuardSet $child (setDifference  treeIsMember (getGuardSet $child) $commonToAllChildren Nil)))

;; Map function that accepts a binary function and it's second argument.
(: mapChild (-> $f (List Tree) (List Tree) (List Tree)))
(= (mapChild $function $secondArg Nil) Nil)
(= (mapChild $function $secondArg (Cons $x $xs))
      (Cons ($function $secondArg $x) (mapChild $function $secondArg $xs))
)

; a function to get the guardset of an n-ary expression as a tuple. 
(= (getGuardSetExp $expOriginal $expRecursive $acc)
    (if (== (get-metatype $expOriginal) Symbol) ($expOriginal) ;if $exp is LITERAL, the guardSet is the set containing the literal itself
    (if (== $expRecursive ()) $acc
        (let*
            (
                ($head (car-atom $expRecursive))
                ($headIsExpression (== (get-metatype $head) Expression))
                ($tail (cdr-atom $expRecursive))
                ($tailIsExpression (== (get-metatype $tail) Expression))
            )
            (if (== $head NOT) 
             (case $expOriginal
                 (
                     ((NOT $b) (if (== (get-metatype $b) Symbol) $expOriginal ())) ;If the head of the expression is NOT, $b should only be a literal for it to have a guardSet of (NOT $b). If $b is an expression, the guardSet is ()
                 )
             )
             (if (== $head OR) ()  ;an OR expression doesn't have a guardSet
                 (if (== $head AND) ; an AND expression has a guardSet which contains its literal and (NOT $literal) children
                     (getGuardSetExp $expOriginal $tail $acc)
                     (if $headIsExpression
                         (case $head
                             (
                                 ( (NOT $a) (getGuardSetExp $expOriginal $tail (cons-atom $head $acc)))
                                 ($else (getGuardSetExp $expOriginal $tail $acc))
                             )
                         )
                         (getGuardSetExp $expOriginal $tail (cons-atom $head $acc))
                     )
                 )
             )
            )
        )
    ) 
    )
)

;a function to check whether an n-ary expression is consistent or not.
(= (isConsistentExp $exp)
(let $guardSetTuple (getGuardSetExp $exp $exp ()) 
(if (== $guardSetTuple ()) True
        (let*
            (
                ($head (car-atom $guardSetTuple))
                ($tail (cdr-atom $guardSetTuple))
            )
        (if (isMember (Not $head) $tail) False
            (isConsistentExp $tail)
        ))
)
)   
)

;a helper function to the zeroConstraintSubsume function
;a function which checks if an Expression (a representation of a node) has a child or not
(= (nodeHasChildExp $node)
(let*
(
    ($head (car-atom $node))
    ($tail (cdr-atom $node))
    ($nodeType (get-metatype $node))
)
(if (== $nodeType Symbol) 
 False 
 (if (== $tail ()) 
     False 
     True
 )
)
)
)

;a function that will return Gardset(literals for OR) and the children as a tuple ((Gset), (Children))
(= (GsetandChildren $expr $literals $nonLiterals)
    (if (== $expr ())
        ($literals $nonLiterals)
        (let* 
            (   
                ($head (car-atom $expr))
                ($tail (cdr-atom $expr))
                ($isLiteral (or (== (get-metatype $head) Symbol) (unify $head (NOT $_) True False)))
            )
            (if (or (== $head AND) (== $head OR)) 
                (GsetandChildren $tail $literals $nonLiterals)

                (if $isLiteral 
                    (GsetandChildren $tail (concatTuple $literals ($head)) $nonLiterals)
                    (GsetandChildren $tail $literals (concatTuple $nonLiterals ($head)))        
                )
            )
        )
    )
)

(= (getGsetAndChildren $expr) (GsetandChildren $expr () ()))

; Function to find common literals between a tuple and a nested tuple
(= (findCommonLiterals $tuple $nestedTuple)
    (if (or (== $nestedTuple ()) (== $tuple ()))
        ()
        (let* 
            (
                ($first (car-atom $nestedTuple))
                ($tail (cdr-atom $nestedTuple))
                ($common (collapse (intersection (superpose $tuple) (superpose $first))))
            )
            (if (== $tail ())
                $common
                (findCommonLiterals $common $tail)
            )
        )
    )
)

; Function to find common literals in a nested tuple
(= (findCommon $nestedTuple)
    (if (or (== $nestedTuple ()) (== (cdr-atom $nestedTuple) ()))
        ()
        (let* (
            ($first (car-atom $nestedTuple))
            ($tail (cdr-atom $nestedTuple))
        )
        (findCommonLiterals $first $tail)
        )
    )
)
;function to find returin the Gardset of an expression
(= (getGuardSet $expr $acc)
    (if (== $expr ())
        $acc
        (let* 
            (
                ($head (car-atom $expr))
                ($tail (cdr-atom $expr))
                ($isLiteral (or (== (get-metatype $head) Symbol) (unify $head (NOT $_) True False)))
            )
            (if (or (== $head AND) (== $head OR)) 
                (getGuardSet $tail $acc)
                (if $isLiteral 
                    (getGuardSet $tail (concatTuple $acc ($head)))
                    (getGuardSet $tail $acc)
                )
            )
        )
    )
)

