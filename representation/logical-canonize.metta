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


(= (isAnArgument $it) (and (not (is-member $it (AND OR NOT))) (== (get-metatype $it) Symbol)))

(= (isBoolean $it) (is-member $it (True False)))
