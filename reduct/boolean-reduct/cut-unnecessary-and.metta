;; A function to remove an unnecessary AND and its child.
;; Definitions: A guard set of a POA is the set of literals in the POA.
;; Preconditions: The point of application (POA) is and AND node,
;;                has an empty guard set, one child and
;;                for each child C of the POA, the intersection 
;;                of the guard sets of the children of C is empty.
;; Action: The function returns the POA's granChildren instead of an updated POA.
;;         This implies that the POA is removed and it's grandChildren are put in it's place.
;; Example: input: (AND (OR (AND B D) (NOT E)))
;;          output: ((AND B D) (NOT E))
;; (: andCut (-> Expression Expression))
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
                    $grandChildren
                    $expr
                )
            )
            $expr
        )
    )
)
