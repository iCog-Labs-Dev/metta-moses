;; Native boolean evaluation: the three operator clauses are the SINGLE source
;; of AND/OR/NOT semantics; scoring/fitness's rewriteTree turns a candidate Tree
;; into a materialized column term that names these ops as its row functions,
;; and evalSubtree reduce-dispatches them. Depends on general-helpers (all/any).
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

;; --- ROW (scalar, per-cell) arities: the zipform column engine ---------------
;; The rewriter passes the op SYMBOL straight into its emitted (zipWith $op ..)
;; / (fmap $op ..) nodes, so the op symbol IS the row function (no rowFnTable).
;; These scalar clauses INTENTIONALLY coexist with the n-ary data clauses above:
;; AND/2 and OR/2 are distinct predicates from AND/1 and OR/1, and for NOT the
;; wrapped clause cannot match a bare cell while the scalar clause's body fails
;; on a 1-tuple, so each operand shape selects exactly one clause.
;; RISK: NOT/1 scalar overlaps NOT/1 wrapped on the same head and arity -- the
;; documented backtracking hazard; recheck solution counts if either clause,
;; the operand shapes, or the runtime changes.
;; RISK: applied to SYMBOLS, (AND x1 x2) now yields zero solutions where it once
;; yielded an unreduced term. No current caller does that; a future one would
;; fail silently.
(= (AND $a $b) (and $a $b))
(= (OR  $a $b) (or  $a $b))
(= (NOT $a)    (not $a))
;; XOR has a row arity only; it lives here beside its monoid/mempty registration
;; in fitness.metta, which without a definition would let (XOR ...) score to
;; unreduced terms with no error.
(= (XOR $a $b) (or (and $a (not $b)) (and (not $a) $b)))
