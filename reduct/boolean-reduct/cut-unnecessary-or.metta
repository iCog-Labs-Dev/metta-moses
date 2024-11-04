;; A function to remove an unnecessary OR and its child.
;; Preconditions: The point of application (POA) has only one child.
;; Action: If the preconditions are met, the function adds the POA's
;;            grandChildren to the POA's parent and removes the POA
;;            from parent. It then returns the updated parent, an
;;            empty atom and a boolean value of true. If conditions 
;;            are not met, it returns the state unchanged.
;; Example: input: POA ==> (OR (AND (NOT D))), parent => (AND B (OR (AND (NOT D))))
;;          output: ((AND B (NOT D)) () True)
;; (: orCut (-> Expression Expression (Expression Expression Bool)))
(= (orCut $parent $current)
    (let*
        (
            ($op (car-atom $current))
            ($children (cdr-atom $current))
            ($child (car-atom $children))
            ($restChildren (cdr-atom $children))
            ($grandChildren (if (== (get-metatype $child) Symbol) () (cdr-atom $child)))
            ($updatedParent (removeElement ($current) $parent))
        )
        (case $op
          (
              (AND ($parent $current False))
              (NOT ($parent $current False))
              (OR (if (== $restChildren ())
                      ((addChildren $updatedParent $grandChildren) () True) ;; Add the children to the parent of POA.
                      ($parent $current False)
                  )
              )
          )
        )
    )
)
