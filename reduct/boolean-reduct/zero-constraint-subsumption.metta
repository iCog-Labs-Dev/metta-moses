;; A function to identify triviall-tautological subexpressions and
;;    removes the point of application(POA).
;; Definitions: Guard set of a POA is the set of literals in the POA.
;; Preconditions: The POA is OR node, has a child which has an empty 
;;                  guard set and no children.
;; Action: Return an empty expression if transformtion applied.
;;         Returning an empty expression is equivalent to deleting
;;          the POA.
;; Example: input: POA ==> (OR C)
;;        : output: ()
;; (: zeroConstraintSubsume (-> Expression Expression Expression))
(= (zeroConstraintSubsume $exp)
  (case ((get-metatype $exp) $exp)
    (
      ((Expression ()) ())
      ((Expression (NOT $x)) $exp)
      ((Symbol $exp) $exp)
      ((Expression $exp)
        (let*
          (
            ($head (car-atom $exp))
            ($children (getChildren $exp))
            ($childrenHasChildOrGuard (collapse (nodeHasChildOrGuard (superpose $children))))
          )
          (case ($head $children)
            (
              ((AND $_) $exp)
              ((OR ()) $exp)
              ((OR $children) (if (isMember False $childrenHasChildOrGuard) () $exp))
            )
          )
        )
      )
    )
  )
)


;; a helper function which checks if an expression has a child (subexpression) or a literal or not
(= (nodeHasChildOrGuard $node) (or (~= (getLiterals $node) ()) (~= (getChildren $node) ())))
