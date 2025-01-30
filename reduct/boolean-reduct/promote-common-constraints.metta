;; A function to identify and return literals common
;;  to all cildren of a point of application(POA) and
;;  the updated POA after the promotion.
;; Definitions: Guard set of a POA is the set of literals in the POA.
;; Preconditions: The POA is an OR node and the intersection of the
;;                  guard sets of the children of the POA is not empty.
;; Action: Let S be the intersection of the guard sets of the children
;;            of the POA. The literals in S are subtraced from the
;;            guard set of each of the children of the POA.
;;            Then S, the updated POA replaces the previous POA in the
;;              parent of the POA and the updated parent, the updated
;;              POA and a boolean indicator whether the transformation
;;              is applied or not are returned in a tuple.
;; Example: input: POA ==> (OR (AND (NOT B) C) (NOT B)), parent ==> (AND A (OR (AND (NOT B) C) (NOT B)) (OR (NOT C) (AND (NOT B) (NOT D))))
;;        : output: ((AND A (NOT B) (OR (AND C) (AND)) (OR (NOT C) (AND (NOT B) (NOG D)))) () True)
;(: promoteCommonConstraints (-> Expression Expression (Expression Expression Bool)))
(= (promoteCommonConstraints $parent $current)
    (if (and (~= $current ()) (~= $parent ()))
        (let*
            (
              ;; (() (println! (=== Inside PromoteCommonConstraints ===)))
              ;; (() (println! (Parameters ==> Parent: $parent Current: $current)))

              (($literals $children) (getLiteralChildren $current))
              ($childrenLiteral (if (~= $children ()) (collapse (getLiterals (superpose $children))) ()))
              ($common (if (~= $childrenLiteral ()) (findCommon $childrenLiteral) ()))
            )
            (if (== $common ())
                ($parent $current False)
                (let*
                    (
                      ;; (() (println! (Removing Common Literals: $common)))
                      ($updatedChildren (removeCommonLiterals $common $children))
                      ($updatedLiterals (removeElement $common $literals))
                      ($newExp (concatTuple $updatedLiterals $updatedChildren ))

                      ($newCurrent (cons-atom OR $newExp))
                      ($updatedParent (findAndReplace $current $newCurrent $parent))
                      ($updatedParent' (addLiterals $updatedParent $common))
                    )
                    ($updatedParent' $newCurrent True)
                )
            )
        )
        ($parent $current False)
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

