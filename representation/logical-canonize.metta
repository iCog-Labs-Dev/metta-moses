;; if-chain (not case): case unifies the key against each pattern via Prolog
;; = /2, which succeeds and BINDS when the key is a var — plus we observed
;; case producing spurious output when the key is a Grounded value like
;; `true`. `==` in an if-chain is structural and safe on any input.
(= (logicalCanonize (mkTree (mkNode $it) $children))
   (if (== $it AND)
       (mkTree (mkNode OR) (cons (mkTree (mkNode $it) $children) ()))
   (if (== $it OR)
       (mkTree (mkNode AND) (cons (mkTree (mkNode $it) $children) ()))
   (if (== $it NOT)
       (mkTree (mkNode AND) (cons (mkTree (mkNode $it) $children) ()))
       (if (isAnArgument $it)
           (mkTree (mkNode AND) (cons (mkTree (mkNode $it) $children) ()))
           (if (isBoolean $it)
               (mkTree (mkNode OR) (cons (mkTree (mkNode AND) ()) ()))
               (Error InvalidTreeValueInsideLogicalCanonize)))))))


;; Var-safe: is-member uses unification which would spuriously succeed for
;; an unbound var against any list element. Rewrite as == disjunction.
;; Metatype check accepts Variable so leaves built with fresh Prolog vars
;; (via varize-itable) count as arguments.
(= (isAnArgument $it)
   (and (not (or (== $it AND) (or (== $it OR) (== $it NOT))))
        (or (== (get-metatype $it) Symbol)
            (== (get-metatype $it) Variable))))

(= (isBoolean $it) (List.contains $it (True False)))
