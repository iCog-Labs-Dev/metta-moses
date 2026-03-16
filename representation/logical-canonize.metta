(= (logicalCanonize (mkTree (mkNode $it) $children))
   (case $it
         (
           (AND (mkTree (mkNode OR) (Cons (mkTree (mkNode $it) $children) Nil)))
           (OR  (mkTree (mkNode AND) (Cons (mkTree (mkNode $it) $children) Nil)))
           (NOT (mkTree (mkNode AND) (Cons (mkTree (mkNode $it) $children) Nil)))
           ($_ (if (isAnArgument $it)
                   (mkTree (mkNode AND) (Cons (mkTree (mkNode $it) $children) Nil))
                   (if (isBoolean $it)
                       (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) Nil) Nil))
                       (Error InvalidTreeValueInsideLogicalCanonize)))))))


(= (isAnArgument $it) (and (not (is-member $it (AND OR NOT))) (== (get-metatype $it) Symbol)))

(= (isBoolean $it) (is-member $it (True False)))
