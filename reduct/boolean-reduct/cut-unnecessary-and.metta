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
;; (: andCut (-> Expression Expression (Expression Expression Bool)))
(= (andCut $parent $current)
    (let*
        (
            (($guardSet $child) (getLiteralChildren $current))
            ($tail (cdr-atom $child))
        )
        (if (and (== $tail ()) (== $guardSet ())) ;; Has no guardSet and has single child
            (let*
                (
                    (($_ $grandChildren) (getLiteralChildren (car-atom $child)))
                    ($allLiterals (collapse (getGuardSet (superpose $grandChildren) ())))
                    ($common (findCommon $allLiterals))
                    ($updatedParent (removeElement ($current) $parent))
                )
                (if (== $common ())
                    ((addChildren $updatedParent $grandChildren) () True)
                    ($parent $current False)
                )
            )
            ($parent $current False)
        )
    )
)
