;; A function to remove an unnecessary OR and its child.
;; Preconditions: The point of application (POA) has only one child.
;; Action: The function returns the POA's grandChildren instead of
;;         an updated POA. This implies that the POA is removed and
;;         it's grandChildren are put in it's place.
;; Example: input: (OR (AND (NOT D)))
;;          output: ((NOT D))
;; (: orCut (-> Expression Expression))
(= (orCut $exp)
    (let*
        (
            ($op (car-atom $exp))
            ($children (cdr-atom $exp))
            ($child (car-atom $children))
            ($restChildren (cdr-atom $children))
            ($grandChildren (if (== (get-metatype $child) Symbol) () (cdr-atom $child)))
        )
        (case $op
          (
              (AND $exp)
              (NOT $exp)
              (OR (if (== $restChildren ()) $grandChildren $exp))
          )
        )
    )
)
