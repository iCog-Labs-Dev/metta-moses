;; A function to remove an unnecessary AND and its child.
;; Definitions: A guard set of a POA is the set of literals in the POA.
;; Preconditions: The point of application (POA) is and AND node,
;;                has an empty guard set, one child and
;;                for each child C of the POA, the intersection
;;                of the guard sets of the children of C is empty.
;; Action: If the preconditions are met, the function adds the
;;            grandChildren of the POA to the POA's parent and returns
;;            the updated parent, empty atom and a boolean value of
;;            true.
;;         If conditions are not met, the function returns the unchanged state.
;;            updated POA and also a boolean value corresponding to
;;            whether the transformation function is applied or not.
;; Example: input: POA ==> (AND (OR (AND B D) (NOT E))), parent ==> (OR C (AND (OR (AND B D) (NOT E))))
;;          output: ((OR C (AND B D) (NOT E)) () True)
(: andCut (-> Expression Expression (Expression Expression Bool)))
(= (andCut $parent $current)
    (let*
        (
            (($guardSet $child) (getLiteralChildren $current))
            ($tail (cdr-atom $child))
        )
        (if (and (== $tail ()) (== $guardSet ())) ;; Has no guardSet and has single child
            (let*
                (
                    (($grandLiterals $grandChildren) (getLiteralChildren (car-atom $child)))
                    ($allLiterals (collapse (getGuardSet (superpose $grandChildren))))
                    ($common (intersections $allLiterals))
                    ($updatedParent (removeElement ($current) $parent))
                    ($updatedParent' (addChildren $updatedParent $grandChildren))
                    ($updatedParent'' (addLiterals $updatedParent' $grandLiterals))
                )
                (if (== $common ())
                    ($updatedParent'' () True)
                    ($parent $current False)
                )
            )
            ($parent $current False)
        )
    )
)

;; Function to find intersections between all literals in a nested tuple
(: intersections (-> Expression Expression))
(= (intersections $nestedTuple)
   (case $nestedTuple 
     ((() $nestedTuple)
      ($else
        (if (== (cdr-atom $nestedTuple) ())
            ()
            (let*
              (
                ($first (car-atom $nestedTuple))
                ($tail (cdr-atom $nestedTuple)))
              (findCommonLiterals $first $tail)))))))


;; A helper function used to apply andCut in the until function.
;; This function keeps the state of the until function updated for a single function application.
(: applyAndCut (-> (Expression Bool (Expression Expression)) (Expression Bool (Expression Expression))))
(= (applyAndCut ($parent $bool ($child $remainingChildren)))
      (let*
        (
          (($updatedParent $updatedChild $appliedOrCut) (andCut $parent $child))
          ($nextChild (if (~= $remainingChildren ()) (car-atom $remainingChildren) ()))
          ($restChildren (if (~= $remainingChildren ()) (cdr-atom $remainingChildren) ()))
        )
        ($updatedParent (or $appliedOrCut $bool) ($nextChild $restChildren))
      )
)
