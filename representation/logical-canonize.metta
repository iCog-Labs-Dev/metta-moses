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
(= (isAnArgument $it) (and (not (once (is-member $it (quote (AND OR NOT TRUE FALSE))))) (== (get-metatype $it) Symbol)))

;; TRUE/FALSE join the booleans rather than the arguments: a reduced exemplar can now BE a
;; constant (demeToTrees already emits one), and canonizing it as an argument would build
;; knobs over it as though it were a data column.
(= (isBoolean $it) (once (is-member $it (True False TRUE FALSE))))
