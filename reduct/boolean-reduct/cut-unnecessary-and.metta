;; A function to remove an unnecessary AND and its child.
;; Definitions: A guard set of a POA is the set of literals in the POA.
;; Preconditions: The point of application (POA) is and AND node,
;;                has an empty guard set, one child and
;;                for each child C of the POA, the intersection 
;;                of the guard sets of the children of C is empty.
;; Action: The function returns the POA's grandChildren instead of an
;;            updated POA and also a boolean value corresponding to
;;            whether the transformation function is applied or not.
;;         Returing the grandChidlren implies that the POA is removed and it's grandChildren are put in it's place.
;; Example: input: (AND (OR (AND B D) (NOT E)))
;;          output: (((AND B D) (NOT E)) True)
;; (: andCut (-> Expression (Expression Bool)))
(= (andCut $expr)
    (let*
        (
            (($guardSet $child) (getLiteralChildren $expr))
            ($tail (cdr-atom $child))
        )
        (if (and (== $tail ()) (== $guardSet ())) ;; Has no guardSet and has single child
            (let*
                (
                    (($_ $grandChildren) (getLiteralChildren (car-atom $child)))
                    ($allLiterals (collapse (getGuardSet (superpose $grandChildren) ())))
                    ($common (findCommon $allLiterals))
                )
                (if (== $common ())
                    ($grandChildren True)
                    ($expr False)
                )
            )
            ($expr False)
        )
    )
)
