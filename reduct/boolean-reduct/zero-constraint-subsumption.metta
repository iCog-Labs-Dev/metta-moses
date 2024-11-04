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
      ((currentression ()) ($current False))
      ((currentression (NOT $x)) ($current False))
      ((Symbol $current) ($current False))
      ((currentression $current)
        (let*
          (
            ($head (car-atom $current))
            ($children (getChildren $current))
            ($childrenHasChildOrGuard (collapse (nodeHasChildOrGuard (superpose $children))))
          )
          (case $children
            (
              (() ($parent $current False))
              ($else
                (if (isMember False $childrenHasChildOrGuard)
                    ((removeElement ($current) $parent) () True) ;; Remove current from parent.
                    ($parent $current False)
                )
              )
            )
          )
        )
      )
    )
  )
)


;; a helper function which checks if an expression has a child (subexpression) or a literal or not
(= (nodeHasChildOrGuard $node) (or (~= (getLiterals $node) ()) (~= (getChildren $node) ())))
