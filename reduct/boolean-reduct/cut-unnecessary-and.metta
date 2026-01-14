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
; (: andCut (-> Expression Expression (Expression Expression Bool)))
(= (andCut $parent $current)
        (let*
          (
              ; ($_ (println! (===Inside AndCut===)))
              ; ($_ (println! (Current $current : Parent : $parent)))
              ($parentSec (collapse (removeEmptyAND (superpose $parent))))
              ($currentSec (if (=== $parent $current) $parentSec (collapse (removeEmptyAND (superpose $current)))))
              (($guardSet $child) (getLiteralChildren $currentSec))
              (($h $t) (if (and (== (get-metatype $child) Expression) (not (== $child ()))) (decons-atom $child) (() ())))
              ($tail (if-decons-expr-custom $child $h $t $t "No child"))
              ; ($_ (println! ("Tail: " $tail)))
          )
          (if (and (== $tail ()) (== $guardSet ())) ;; Has no guardSet and has single child
              (let*
                  (
                      ; ($_ (println! (===Inside AndCut===)))
                      ; ($_ (println! (Current $current : Parent : $parent)))
                      ($childFirst (if-decons-expr-custom $child $h $t $h ()))
                      (($grandLiterals $grandChildren) (getLiteralChildren $childFirst))
                      ($allLiterals (collapse (getGuardSet (superpose $grandChildren))))
                      ($common (intersections $allLiterals))
                      ($updatedParent (removeElement ($currentSec) $parentSec))
                      ($updatedParent' (if
                                        (== () (subtraction-atom $parentSec $currentSec))
                                        $updatedParent
                                        (addChildren $updatedParent $grandChildren)))
                      ($updatedParent'' (addLiterals $updatedParent' $grandLiterals))

                      ; ($l (println! (===Inside AndCut Log===)))
                      ; ($l (println! (All Literals: $allLiterals)))
                      ; ($l (println! (GrandChildren: $grandChildren : GrandLiterals: $grandLiterals)))
                      ; ($l (println! (UpdatedParent: $updatedParent : UpdatedParent': $updatedParent' )))
                      ; ($l (println! (UpdatedParent'': $updatedParent'' )))
                      ; ($l (println! (ChildFirst: $childFirst)))
                      ; ($l (println! (Child: $child)))
                      ; ($l (println! (AllLiterals: $allLiterals)))
                      ; ($l (println! (Common: $common)))

                  )
                  (if (== $common ())
                      ($updatedParent'' () True)
                      ($parentSec $currentSec False)
                  )
              )
              ($parentSec $currentSec False)
          )
        )
)

;; Function to find intersections between all literals in a nested tuple
; (: intersections (-> Expression Expression))
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
; (: applyAndCut (-> (Expression Bool (Expression Expression)) (Expression Bool (Expression Expression))))
(= (applyAndCut ($parent $bool ($child $remainingChildren)))
      (let*
        (
          ; (() (println! (===Inside ApplyAndCut===)))
          ; (() (println! (Parent: $parent : Child: $child : RemainingChildren: $remainingChildren : bool: $bool)))
          (($updatedParent $updatedChild $appliedOrCut) (eval (andCut $parent $child)))
          ($nextChild (if (~= $remainingChildren ()) (car-atom $remainingChildren) ()))
          ($restChildren (if (~= $remainingChildren ()) (cdr-atom $remainingChildren) ()))
        )
        ($updatedParent (or $appliedOrCut $bool) ($nextChild $restChildren))
      )
)

(= (removeEmptyAND $expr) ;; the function is removing the expression containing empty AND node, but it should return the parent.
    (case (get-metatype $expr)
        (
            (Symbol $expr)
            (Expression
                (let* (
                    (($h $t) (decons-atom $expr))
                    ; (() (println! (H: $h : T: $t)))
                  )
                    (case ($h $t)
                        (
                            ((AND ()) (empty))
                            ((AND $else) (concatTuple ($h) (collapse (removeEmptyAND (superpose $t)))))
                            (($any $else) (collapse (removeEmptyAND (superpose $expr))))

                        )
                    )
                )
            )
            ($else $expr))))