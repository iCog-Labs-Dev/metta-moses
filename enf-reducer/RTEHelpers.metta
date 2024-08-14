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
(: guardSetChecker (-> (List Tree) Number))
(= (guardSetChecker $children)(
  if (> (length (getGuardSet (head $children))) 0)
    (length (getGuardSet (head $children)))
    (0)
  )
)

;; -----------------------------------
;; -----------------------------------
;; -------- A function that given children and the a local command set,
;; -------- it returns the updated command set
;; -----------------------------------
;; -----------------------------------

(: commandSetIterator(-> (List Tree) (List Tree) (List Tree)))
(= (commandSetIterator Nil $localCommandSet)($localCommandSet))
(= (commandSetIterator (Cons $x $xs) $localCommandSet)(
    if(and 
        (and (== (getChildren (head (Cons $x $xs))) Nil) (== (guardSetChecker (Cons $x $xs)) 1))
        (== (getNodeType (head (Cons $x $xs))) AND)
      )(
        setUnion treeIsMember (getGuardSet (head (Cons $x $xs))) (commandSetIterator (tail (Cons $x $xs)) $localCommandSet)
      )
      (commandSetIterator (tail (Cons $x $xs)) $localCommandSet)
  )
)

; orSubTreeElegance implementation
(: Signal Type)
(: ReductionSignal Signal)
(: IterationSignal Signal)
(: DELETE ReductionSignal)
(: DISCONNECT ReductionSignal)
(: KEEP ReductionSignal)
(: ADVANCE IterationSignal)

(: orSubTreeElegance (-> Tree Tree (List Tree) (List Tree) (Tree Signal)))
(= (orSubTreeElegance $child $current $dominantSet $localCommandSet)
    (let $outcome DELETE ;; Simulate the result returned by the reduceToElegance function, Which is not implemented Currently.
                         ;; The possible outcomes of reduceToElegance function are DELETE, DISCONNECT, or KEEP.
        (case $outcome
          (
            (DELETE
                (if (> (length (getChildren $current)) 0)
                    ((let $currentChildren (findAndRemoveTree $child (getChildren $current) )
                        ($currentChildren ADVANCE)))
                    ($current DELETE) 
                )
            )
            (DISCONNECT ($current DISCONNECT))
            (KEEP ($current ADVANCE))
          )
        )
    )
)


; helper function for itarator

(: applyToChildren (-> Tree (List Tree) Tree))
(= (applyToChildren $current $children)
   (case $children
      (Nil $current) ; If there are no more children, return the current node
      ((Cons $child $rest)
         ; Apply `applyOrCut` to the current node and the child
         (let (($newChild (applyOrCut $current $child)))
            ; Prepend the result as a child of the current node
            (let (($newCurrent (prependChild $current $newChild)))
               ; Recur with the remaining children
               (applyToChildren $newCurrent $rest)
            )
         )
      )
   )
)


; iterator function
(: iterator (-> Tree (List Tree) (List Tree) (Tree ReductionSignal)))
(= (iterator $current $dominant_set $command_set) 
   
   (
    let*(

        ($previousGuardSet (getGuardSet $current))
        ($handle_set (union $dominant_set (getGuardSet $current)))
        (($fstupdatedcurrent $signal) (andSubTreeIterator (getGuardSet $current) $current $handle_set $command_set))
    )
    (
        (if (not (isConsistent $handle_set)) (($current DELETE)) 
                (if (not (== $signal NONE)) ($fstupdatedcurrent $signal) 

                let*(
                    ($sndupdatedcurrent (applyToChildren $fstupdatedcurrent (getChildren $fstupdatedcurrent)))
                )
                (if (not (compareSets $previousGuardSet (getGuardSet $sndupdatedcurrent))) 
                      (iterator $sndupdatedcurrent $dominant_set $command_set)) ($sndupdatedcurrent NONE)
                
                )
        
        )
    )
   )

)

