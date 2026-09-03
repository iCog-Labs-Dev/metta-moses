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
    (if (and (not (== $current ())) (not (== $parent ())))
        (let*
            (
              ;; (() (println! (=== Inside PromoteCommonConstraints ===)))
              ;; (() (println! (Parameters ==> Parent: $parent Current: $current)))

              ($currentHead (if (== (get-metatype $current) Expression) (car-atom $current) ()))
              (($literals $children) (getLiteralChildren $current))
              ($childrenLiteral (if (not (== $children ())) (map-atom $children $ch (getLiterals $ch)) ()))
              ;; ONLY for an OR POA, where the literals really are alternatives: a BARE LITERAL
              ;; alternative is an alternative like any other and its guard set is just itself.
              ;; Intersecting only the sub-expression branches made the promotion unsound --
              ;; (OR (AND A B) C D) promoted A and B, which do not appear in the C or D branches
              ;; at all, rewriting (A^B) v C v D as A ^ B ^ (C v D).
              ;; In an AND POA the same literals are CONJUNCTS, not alternatives, so they must
              ;; stay out of the intersection: treating (AND F)'s guard set as an alternative
              ;; set makes F "common to every branch" and promotes the node into an empty OR.
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
                      ;; A branch the promotion empties is the empty conjunction, i.e. true,
                      ;; and true in a disjunction makes the whole POA true. Now that the
                      ;; intersection covers every alternative this needs no bare-literal
                      ;; guard: a bare literal consumed by the promotion is itself such an
                      ;; emptied branch, which is what (!= $updatedLiterals $literals) detects.
                      ($isTautology (and (== $currentHead OR)
                                         (or (not (== $updatedLiterals $literals))
                                             (any (map-atom $updatedChildren $b (== $b (AND)))))))
                    )
                    (if $isTautology
                        ;; true is the AND-identity: the POA leaves, the promoted literals stay
                        (if (== $parent $current)
                            ((AND) () True)
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
;;          output: (((C H) (D) (C F)))
(= (removeCommonLiterals $common $tuple)
   ( if (== $tuple ())
        ()
        (map-atom $tuple $tp (removeElement $common $tp))
   )
)

