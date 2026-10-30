;; A function to remove an unnecessary AND and its child.
;; Definitions: A guard set of a POA is the set of literals in the POA.
;; Preconditions: The point of application (POA) is an AND node,
;;                has an empty guard set, one child and
;;                for each child C of the POA, the intersection
;;                of the guard sets of the children of C is empty.
;; Action: If the preconditions are met, the function adds the
;;            grandChildren of the POA to the POA's parent and returns
;;            the updated parent, empty atom and a boolean value of
;;            true.
;;         If the conditions are not met, the function returns the parent, the
;;            POA and a boolean value that tells if the POA changed.
;; Example: input: POA ==> (AND (OR (AND B D) (NOT E))), parent ==> (OR C (AND (OR (AND B D) (NOT E))))
;;          output: ((OR C (AND B D) (NOT E)) () True)
;; Constants are inert here: map-atom over a Symbol yields NO SOLUTION, a silent failure
;; out through reduce-to. The constant laws are what act on them.
(= (andCut $parent $current)
        (if (or (isConstant $parent) (isConstant $current))
            ($parent $current False)
        (if (== $parent $current)
            ($parent $current False)
            (let*
              (
                  ($parentSec (map-atom $parent $p (removeEmptyAND $p)))
                  ($currentSec (if (=== $parent $current)
                                   $parentSec
                                   (map-atom $current $c (removeEmptyAND $c))))
                  (($guardSet $child) (getLiteralChildren $currentSec))
                  ;; plain if, NOT if-decons-expr-custom: its (eval $then)
                  ;; deep-normalizes the returned tree data, firing
                  ;; scoring/boolean-ops' AND/OR/NOT clauses.
                  ;; "No child" keeps (== $tail ()) False when there is no child.
                  (($childFirst $tail) (if (and (== (get-metatype $child) Expression) (!= $child ()))
                                           (decons-atom $child)
                                           (() "No child")))
              )
              (if (and (== $tail ()) (== $guardSet ())) ;; Has no guardSet and has single child
                  (let*
                      (
                          (($grandLiterals $grandChildren) (getLiteralChildren $childFirst))
                          ($allLiterals (map-atom $grandChildren $gC (getGuardSet $gC)))
                          ($common (intersections $allLiterals))
                          ($updatedParent (removeElement ($currentSec) $parentSec))
                          ($updatedParent' (if
                                            (== () (subtraction-atom $parentSec $currentSec))
                                            $updatedParent
                                            (addChildren $updatedParent $grandChildren)))
                          ($updatedParent'' (addLiterals $updatedParent' $grandLiterals))


                      )
                      (if (== $common ())
                          ($updatedParent'' () True)
                          ($parentSec $currentSec False)
                      )
                  )
                  ($parentSec $currentSec (!= $current $currentSec))
              )
            )))
)

;; Like intersectAll, but a single set has nothing in common with other sets: it gives ().
(= (intersections $nestedTuple)
   (case $nestedTuple
     ((() $nestedTuple)
      ($else
        (if (== (cdr-atom $nestedTuple) ())
            ()
            (intersectAll $nestedTuple))))))


;; A helper function used to apply andCut in the until function.
;; This function keeps the state of the until function updated for a single function application.
(= (applyAndCut ($parent $bool ($child $remainingChildren)))
      (let*
        (
          (($updatedParent $updatedChild $appliedAndCut) (andCut $parent $child))
          (($nextChild $restChildren) (if (== $remainingChildren ()) (() ()) (decons-atom $remainingChildren)))
        )
        ($updatedParent (or $appliedAndCut $bool) ($nextChild $restChildren))
      )
)

;; Removes the empty (AND) nodes from an expression.
(= (removeEmptyAND $expr)
    (case (get-metatype $expr)
        (
            (Symbol $expr)
            (Expression
                (let*
                  (
                     (($h $t) (decons-atom $expr))
                  )
                    ;; quote: a bare ($h ...) tuple would be a runtime meta-call into
                    ;; scoring/boolean-ops' eval clauses. CAVEAT: `case` normalizes its
                    ;; scrutinee past the quote, so this guard only holds while no
                    ;; AND/OR/NOT clauses are registered (reduct-only contexts). In the
                    ;; full pipeline (boolean-ops loaded) this MeTTa clause misdispatches
                    ;; and correctness relies on the native Prolog removeEmptyAND
                    ;; override (rte-helpers-fast.pl, consulted in moses-imports.metta)
                    ;; superseding it — validated end-to-end (CI + mux6 differential).
                    (case (quote ($h $t))
                        (
                            ((AND ()) Nothing)
                            ((AND $else) (cons $h (filter-atom (map-atom $t $ts (removeEmptyAND $ts)) (!= Nothing))))
                            (($any $else) (filter-atom (map-atom $expr $ex (removeEmptyAND $ex)) (!= Nothing)))
                        )
                    )
                )
            )
            ($else $expr))))
