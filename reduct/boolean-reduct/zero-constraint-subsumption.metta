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
;(: zeroConstraintSubsume (-> Expression Expression Expression))
(= (zeroConstraintSubsume $expOriginal $expRecursive)
    (if (== $expRecursive ())
        $expOriginal
        (let*
            (
                ($head (car-atom $expRecursive))
                ($tail (cdr-atom $expRecursive))
                ($headType (get-metatype $head))
                ($headHasNoChild (not (nodeHasChildExp $head)))
            )
            (case $head
                (
                    (AND $expOriginal)
                    (NOT $expOriginal)
                    (OR (zeroConstraintSubsume $expOriginal $tail)) ;; The POA for this transformation is any OR node
                    ($else (if (and (== (getGuardSetExp $head) ()) $headHasNoChild)
                               () ;; If any child of the POA has an empty guardSet and no child, it is removed. if not, it's kept.
                               (zeroConstraintSubsume $expOriginal $tail)
                           )
                    )
                )
            )
        )
    )
)


;; a helper function which checks if an expression has a child (subexpression) or not
(= (nodeHasChildExp $node)
    (let*
        (
          ($head (car-atom $node))
          ($tail (cdr-atom $node))
          ($nodeType (get-metatype $node))
        )
        (if (== $nodeType Symbol)
            False
            (if (== $tail ())
                False
                True
            )
        )
    )
)
