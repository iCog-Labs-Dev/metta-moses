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
;;            A branch the subtraction empties is the empty conjunction, i.e.
;;              true, so the POA is a tautology and is dropped from the parent.
;; Example: input: POA ==> (OR (AND (NOT B) C) (NOT B)), parent ==> (AND A (OR (AND (NOT B) C) (NOT B)) (OR (NOT C) (AND (NOT B) (NOT D))))
;;        : output: ((AND A (NOT B) (OR (AND C) (AND)) (OR (NOT C) (AND (NOT B) (NOG D)))) () True)
;(: promoteCommonConstraints (-> Expression Expression (Expression Expression Bool)))
(= (promoteCommonConstraints $parent $current)
    ;; Constants are inert: there is nothing to promote out of a truth value, and the
    ;; rebuild helpers below (addLiterals, removeElement) assume an Expression parent.
    (if (and (and (not (== $current ())) (not (== $parent ())))
             (not (or (isConstant $current) (isConstant $parent))))
        (let*
            (
              ;; (() (println! (=== Inside PromoteCommonConstraints ===)))
              ;; (() (println! (Parameters ==> Parent: $parent Current: $current)))

              ($currentHead (if (== (get-metatype $current) Expression) (car-atom $current) ()))
              (($literals $children) (getLiteralChildren $current))
              ($childrenLiteral (if (not (== $children ())) (map-atom $children $ch (getLiterals $ch)) ()))
              ;; ONLY for an OR POA, where a bare literal IS an alternative and its guard set is
              ;; itself. Intersecting only the sub-expression branches was unsound:
              ;; (OR (AND A B) C D) promoted A and B, absent from C and D. In an AND POA the
              ;; same literals are CONJUNCTS and must stay out, or (AND F) makes F "common".
              ;; quote: ($lit) is a live-head tuple ((NOT B)) once boolean-ops is loaded.
              ($bareGuardSets (if (== $currentHead OR) (map-atom $literals $lit (quote ($lit))) ()))
              ($allGuardSets (concatTuple $bareGuardSets $childrenLiteral))
              ($common (if (not (== $allGuardSets ())) (findCommon $allGuardSets) ()))
            )
            (if (== $common ())
                ($parent $current False)
                (let*
                    (
                      ;; (() (println! (Removing Common Literals: $common)))
                      ($updatedChildren (removeCommonLiterals $common $children))
                      ($updatedLiterals (removeElement $common $literals))
                      ;; A branch the promotion empties is the empty conjunction = TRUE, which
                      ;; makes the whole disjunction true. A consumed bare literal is one such
                      ;; branch, which is what (!= $updatedLiterals $literals) detects.
                      ($isTautology (and (== $currentHead OR)
                                         (or (not (== $updatedLiterals $literals))
                                             (any (map-atom $updatedChildren $b (== $b TRUE))))))
                    )
                    (if $isTautology
                        ;; true is the AND-identity: the POA leaves, the promoted literals stay
                        (if (== $parent $current)
                            (TRUE () True)
                            ((addLiterals (removeElement ($current) $parent) $common) () True))
                        (let*
                            (
                              ($newExp (concatTuple $updatedLiterals $updatedChildren ))

                              ($newCurrent (cons-atom OR $newExp))
                              ($updatedParent (findAndReplace $current $newCurrent $parent))
                              ($updatedParent' (addLiterals $updatedParent $common))
                            )
                            ($updatedParent' $newCurrent True)
                        )
                    )
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
        (intersection-atom $lit $common)
    )
)

;; A function to remove literals in $common from a nested tuple: $tuple.
;; Example: input: common ==> (A B), tuple ==> ((A C B H) (A B D) (A C F B))
;;          output: ((C H) (D) (C F))
;;          input: common ==> (A B), tuple ==> ((AND A C B H) (AND A B D))
;;          output: ((AND C H) TRUE)
;; A branch stripped of every constraint is the empty conjunction = TRUE; emptiedToConstant
;; emits it here so the caller can tell it from a childless placeholder. The subtraction
;; stays over the WHOLE element: $common holds only literals, so a junctor head survives.
(= (removeCommonLiterals $common $tuple)
   ( if (== $tuple ())
        ()
        (map-atom $tuple $tp (emptiedToConstant $tp (removeElement $common $tp)))
   )
)

