;; Native boolean evaluation -- the three operator clauses that are the SINGLE
;; source of AND/OR/NOT semantics for the whole scorer, plus preOrderExp, which
;; turns a candidate Tree into the wrapped eval shape the columnar evaluator
;; (scoring/fitness.metta's evalSubtree) consumes.
;;
;; The columnar backbone (&subtreeCache) evaluates each subtree once into a
;; per-row boolean column: on a cache miss the node's one-level template (fresh
;; MeTTa vars) is built once, each row is unified into it via sealed, and a
;; single `reduce` dispatches the clauses below -- so the operator semantics
;; are never re-implemented in the engine (see evalRowT in fitness.metta).
;;
;; DEPENDS ON utilities/general-helpers (all/any, is-member) -- entry files must
;; import it before this module.
;;
;; Quote rule: these clause names double as the data constructors used in
;; candidate trees and reduct expressions. Any bare arity-1 (AND ...)/(OR ...)
;; tuple -- or a (NOT (...)) whose argument is a singleton -- in a module
;; loaded after this one compiles as a CALL -- wrap such data sites in
;; (quote ...). Every emission below is quote-protected so the clauses cannot
;; fire at template-build time.

;; Wrapped-list operators: single arity-1 clause = n-ary, and NOT takes the
;; SAME wrapped argument list as AND/OR -- (NOT (x)) -- so every operator node
;; is uniformly (Op (kids)) and the engine needs no per-operator shape cases.
;; NOT's head destructures the singleton, so only the wrapped form fires (flat
;; data like (NOT A) matches no clause). The engine reduces a node whose
;; children are already boolean VALUES, so each clause receives fully
;; evaluated children.
(= (AND $args) (all $args))
(= (OR  $args) (any $args))
(= (NOT ($x))  (not $x))

;; preOrderExp: Tree -> wrapped eval shape. EVERY operator node becomes
;; (Op (kids)) -- NOT included: (NOT (k)); leaves stay as their label symbol
;; (or a nullary AND/OR becomes (Op ()), its identity). Mirrors
;; utilities/tree's preOrder but wraps children in an extra list so evalSubtree
;; can dispatch structurally.
;; Every emission is quote-protected so the AND/OR/NOT clauses cannot fire here.
(= (preOrderExp (mkTree (mkNode $r) ()))
   (if (once (is-member $r (quote (AND OR))))
       (quote ($r ()))
       $r))
(= (preOrderExp (mkKnob (mkNullVex $tree) $lsk $i)) ())
(= (preOrderExp (mkKnob (mkTree $node $children) $lsk $i))
   (preOrderExp (mkTree $node $children)))
(= (preOrderExp (mkTree (mkNode $r) (cons $x $xs)))
   (let $childrenExp (childrenExp (cons $x $xs))
        (quote ($r $childrenExp))))

;; childrenExp: map preOrderExp over child Trees, dropping empty knob
;; passthroughs.
(= (childrenExp $children)
   (filter-atom (map-atom $children $c (preOrderExp $c)) $x (!= $x ())))
