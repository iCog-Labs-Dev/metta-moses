(= (logicalCanonize (mkTree (mkNode $it) $children))
   (case $it
         (
           (AND (mkTree (mkNode OR) (cons (mkTree (mkNode $it) $children) ())))
           (OR  (mkTree (mkNode AND) (cons (mkTree (mkNode $it) $children) ())))
           (NOT (mkTree (mkNode AND) (cons (mkTree (mkNode $it) $children) ())))
           ($_ (if (isAnArgument $it)
                   (mkTree (mkNode AND) (cons (mkTree (mkNode $it) $children) ()))
                   (if (isBoolean $it)
                       (mkTree (mkNode OR) (cons (mkTree (mkNode AND) ()) ()))
                       (Error InvalidTreeValueInsideLogicalCanonize)))))))


;; quote: bare (AND OR NOT) would compile as an AND call once
;; scoring/boolean-ops' eval clauses are registered
(= (isAnArgument $it) (and (not (once (is-member $it (quote (AND OR NOT))))) (== (get-metatype $it) Symbol)))

(= (isBoolean $it) (once (is-member $it (True False))))
