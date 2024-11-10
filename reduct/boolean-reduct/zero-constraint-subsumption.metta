;; A function to identify triviall-tautological subexpressions and
;;    removes the point of application(POA).
;; Definitions: Guard set of a POA is the set of literals in the POA.
;; Preconditions: The POA is OR node, has a child which has an empty 
;;                  guard set and no children.
;; Action: Return an empty expression if transformtion applied.
;;         It will additionally return a boolean value indicating 
;;          whether the transformation is applied or not.
;;         Returning an empty expression is equivalent to deleting
;;          the POA.
;; Example: input: POA ==> (OR C)
;;        : output: ()
;; (: zeroConstraintSubsume (-> Expression (Expression Bool)))
(= (zeroConstraintSubsume $exp)
  (case ((get-metatype $exp) $exp)
    (
      ((Expression ()) ($exp False))
      ((Expression (NOT $x)) ($exp False))
      ((Symbol $exp) ($exp False))
      ((Expression $exp)
        (let*
          (
            ($head (car-atom $exp))
            ($children (getChildren $exp))
            ($childrenHasChildOrGuard (collapse (nodeHasChildOrGuard (superpose $children))))
          )
          (case ($head $children)
            (
              ((AND $_) ($exp False))
              ((OR ()) ($exp False))
              ((OR $children) (if (isMember False $childrenHasChildOrGuard) (() True) ($exp False)))
            )
          )
        )
      )
    )
  )
)


;; a helper function which checks if an expression has a child (subexpression) or a literal or not
(= (nodeHasChildOrGuard $node) (or (~= (getLiterals $node) ()) (~= (getChildren $node) ())))
