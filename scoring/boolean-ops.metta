;; Native boolean evaluation: the three operator clauses are the SINGLE source
;; of AND/OR/NOT semantics; preOrderExp turns a candidate Tree into the wrapped
;; eval shape that evalSubtree (scoring/fitness) scores columnar-ly,
;; reduce-dispatching the clauses per row. Depends on general-helpers (all/any).
;;
;; Quote rule: these clause names double as data constructors. A bare arity-1
;; (AND ...)/(OR ...) tuple or singleton-argument (NOT (...)) in any module
;; loaded after this one compiles as a CALL -- quote such data sites.

;; One arity-1 clause each = n-ary; NOT takes the same wrapped argument list,
;; so every node is uniformly (Op (children)) and children arrive fully
;; evaluated. Only the wrapped (NOT (x)) fires; flat (NOT A) matches no clause.
(= (AND $args) (all $args))
(= (OR  $args) (any $args))
(= (NOT ($x))  (not $x))

;; preOrderExp: Tree -> wrapped shape. Every operator node becomes
;; (Op (children)); leaves stay label symbols; nullary AND/OR -> (Op ()), its
;; identity. Emissions are quote-protected so the clauses cannot fire here.
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

;; childrenExp: preOrderExp over child Trees, dropping empty knob passthroughs.
(= (childrenExp $children)
   (filter-atom (map-atom $children $c (preOrderExp $c)) $x (!= $x ())))
