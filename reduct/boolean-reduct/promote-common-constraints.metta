;; A function to identify and return literals common
;;  to all cildren of a point of application(POA) and
;;  the updated POA after the promotion.
;; Definitions: Guard set of a POA is the set of literals in the POA.
;; Preconditions: The POA is an OR node and the intersection of the
;;                  guard sets of the children of the POA is not empty.
;; Action: Let S be the intersection of the guard sets of the children
;;            of the POA. The literals in S are subtraced from the
;;            guard set of each of the children of the POA.
;;            Then S, the updated POA is returned and a boolean indicator
;;            whether the transformation is applied or not.
;; Example: input: POA ==> (OR (AND (NOT B) C) (NOT B))
;;        : output: (((NOT B)) (OR C (AND)))
;(: promoteCommonConstraints (-> Expression (Expression Expression Bool)))
(= (promoteCommonConstraints $expr)
    (let*
        (
          (($literals $children) (getLiteralChildren $expr))
          ($childrenLiteral (collapse (getLiterals (superpose $children))))
          ($shared (findCommon $childrenLiteral))
          ($common (atomIntersection $literals $shared))
        )
        (if (== $common ())
            (() $expr False)
            (let*
                (
                  ($updatedChildren (removeCommonLiterals $common $children))
                  ($updatedLiterals (removeElement $common $literals))
                  ($newExp (concatTuple $updatedLiterals $updatedChildren ))
                  ($res (cons-atom OR $newExp))
                )
                ($common $res True)
            )
        )
    )
)


;;A function to find the intersection between two tuples
(= (atomIntersection $lit $common)
    (if (== $lit ())
        $common
        (collapse (intersection (superpose $lit) (superpose $common)))
    )
)

;; A function to remove literals in $common from a nested tuple: $tuple.
;; Example: input: common ==> (A B), tuple ==> ((A C B H) (A B D) (A C F B))
;;          output: (((C H) (D) (C F)))
(= (removeCommonLiterals $common $tuple)
   ( if (== $tuple ())
        ()
        (collapse (removeElement $common (superpose $tuple)))
   )
)

