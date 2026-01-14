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
        (let*
          (
            ($head (car-atom $current))
            ($children (getChildrenExp $current))
            ($childrenHasChildOrGuard (collapse (nodeHasChildOrGuard (superpose $children))))
          )
          (case ($head $children)
            (
              ((AND $_) ($parent $current False))
              ((OR ()) ($parent $current False))
              ((OR $children)
                  (if (is-member False $childrenHasChildOrGuard)
                      ((removeElement ($current) $parent) () True)
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
        (if (and (== (car-atom $parent) OR) (== $current (AND)))
            ((eval (findAndReplace $parent (AND) $parent)) (AND) True) ;; Removes the entire OR if it has an empty AND as child
            (let*
              (
                ;  (() (println! (===Inside ZeroConstraintSubsume'===)))
                ;  (() (println! (Current: $current : Parent: $parent)))
                ($children (eval (getChildrenExp $current)))
                ($literals (eval (getLiterals $current)))
              )
              ;; POA is AND & OR and has no children and guardSet
              (if (and (not (== $current $parent)) (not (== $parent AND)))
                (if (and (== $literals ()) (== $children ()))
                    ((eval (removeElement ($current) $parent)) () True)
                    ($parent $current False)
                )
                ($parent $current False)
              )
            )
        )
      )
    )
  )
)


;; a helper function which checks if an expression has a child (subexpression) or a literal or not
(= (nodeHasChildOrGuard $node) (or (not (== (getLiterals $node) ())) (not (== (getChildrenExp $node) ()))))
