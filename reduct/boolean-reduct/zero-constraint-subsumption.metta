;; A function to identify triviall-tautological subexpressions and
;;    removes the point of application(POA).
;; Definitions: Guard set of a POA is the set of literals in the POA.
;; Preconditions: The POA is OR node, has a child which has an empty
;;                  guard set and no children.
;; Action: It will remove the POA from it's parent and return an empty
;;            expression instead of current if transformtion applied.
;;         It will additionally return a boolean value indicating
;;          whether the transformation is applied or not.
;;         
;; Example: input: POA ==> (OR C), parent ==> (AND A (OR A (NOT B)) (OR C AND))
;;        : output: ((AND A (OR A (NOT B))) () True)
;; (: zeroConstraintSubsume (-> Expression Expression (Expression Expression Bool)))
(= (zeroConstraintSubsume $parent $current)
  (case ((get-metatype $current) $current)
    (
      ((Expression ()) ($parent $current False))
      ((Expression (NOT $x)) ($parent $current False))
      ((Symbol $current) ($parent $current False))
      ((Expression $current)
        ;; 0-Subsumption is exactly the constant laws: an alternative that reduced to the
        ;; empty AND is TRUE and collapses its whole disjunction, and an empty OR is FALSE
        ;; and collapses its whole conjunction. The previous version FILTERED every empty
        ;; junctor out of an OR's children, which threw a TRUE alternative away instead of
        ;; propagating it -- and once dropped it could never be recovered.
        (let $updatedCurrent (applyConstantLaws $current)
          (if (== $updatedCurrent $current)
              ($parent $current False)
              ((findAndReplace $current $updatedCurrent $parent) $updatedCurrent True))))
    )
  )
)

;; This function's input and output is similar to the
;;    zeroConstraintSubsume function.
;; Preconditions: The point of application(POA) has no children and guard set.
;; Action: If preconditions are met, it will remove the POA from its parent and return the updated parent, empty atom and a boolean value of True.
;;         Otherwise, it will just return the unchanged state.
;; Example: input: POA ==> (AND), parent ==> (OR A C (AND) (OR A B))
;;          output: ((OR A C (OR A B)) () True)
;; (: zeroConstraintSubsume' (-> Expression Expression (Expression Expression Bool)))
(= (zeroConstraintSubsume' $parent $current)
  (case ((get-metatype $current) $current)
    (
      ((Expression ()) ($parent $current False))
      ((Expression (NOT $x)) ($parent $current False))
      ((Symbol $current) ($parent $current False))
      ((Expression $current)
        ;; An empty junctor reaching here is a CONSTANT the reducer created: reduce-to's
        ;; pre-pass has already deleted the dangling placeholders that share those shapes.
        ;; (AND) is TRUE and (OR) is FALSE, so each is either the identity or the annihilator
        ;; of the junctor it sits in:
        ;;
        ;;   parent  child   role in the parent    handled
        ;;   OR      (AND)   annihilator (true)    here -- collapse the OR to (AND)
        ;;   AND     (OR)    annihilator (false)   left in place, see below
        ;;   AND     (AND)   identity    (true)    here -- drop the child
        ;;   OR      (OR)    identity    (false)   here -- drop the child
        ;;
        ;; This is classic's Delete/Disconnect propagation (logical_rules.cc:715 and :817),
        ;; with Delete == (OR) and Disconnect == (AND). Only row 1 existed before, so a
        ;; contradiction that emptied an OR was dropped from its AND parent as though it were
        ;; the identity -- silently turning an unsatisfiable tree into TRUE.
        ;;
        ;; The two annihilator rows are handled DIFFERENTLY, and the asymmetry is forced --
        ;; both symmetric alternatives were tried and measured worse:
        ;;
        ;;  - Row 2 must NOT be collapsed here. This function only ever sees ($parent $current),
        ;;    so rewriting $parent to (OR) discards whatever $parent was nested inside, and the
        ;;    RTE walkers do not always pass a genuine parent/child pair. Collapsing it turned
        ;;    (OR !C B (AND (OR !C B) (OR B !C))) into false instead of !C v B. Leaving the (OR)
        ;;    in place is enough: applyConstantLaws falsifies the conjunction at the end of the
        ;;    round, walking the whole tree so the enclosing context survives.
        ;;  - Row 1 must NOT be deferred the same way. Leaving an (AND) sitting inside an OR for
        ;;    applyConstantLaws to collect breaks the transformations that run before it -- a
        ;;    Nothing from removeEmptyAND leaks into the guard set. Measured over the 808-tree
        ;;    differential: 508/508 -> 506/508 harvested and 300/300 -> 279/300 adversarial.
        ;;
        ;; So: propagate the TRUE here, preserve the FALSE for the end-of-round laws. What
        ;; matters in both cases is that the constant is never DESTROYED.
        (if (and (== (car-atom $parent) OR) (== $current (AND)))
            ((findAndReplace $parent (AND) $parent) (AND) True)
            (let*
              (
                ($children (getChildrenExp $current))
                ($literals (getLiterals $current))
              )
              ;; POA is an AND or OR with no children and no guard set
              (if (and (not (== $current $parent)) (not (== $parent AND)))
                  (if (and (== $literals ()) (== $children ()))
                      (if (and (== (car-atom $parent) AND) (== $current (OR)))
                          ($parent $current False)                        ;; row 2: keep the FALSE
                          ((removeElement ($current) $parent) () True))   ;; rows 3 and 4: identity
                      ($parent $current False))
                  ($parent $current False))))
      )
    )
  )
)


;; a helper function which checks if an expression has a child (subexpression) or a literal or not
(= (nodeHasChildOrGuard $node) (or (not (== (getLiterals $node) ())) (not (== (getChildrenExp $node) ()))))
