;; Native boolean evaluation: these operator clauses are the SINGLE source of
;; AND/OR/NOT semantics. rewriteTree (scoring/fitness) compiles a candidate Tree
;; into a column term that names these ops as its row functions, and
;; evalSubtree applies them. Depends on general-helpers (all/any).
;;
;; Quote rule: these clause names double as data constructors. A bare
;; (AND ...)/(OR ...)/(NOT ...) of a defined arity in any module loaded after
;; this one compiles as a CALL -- quote such data sites.

;; Wrapped form: one arity-1 clause each = n-ary; NOT takes the same wrapped
;; argument list. zipOp, mapOp and zipWithN (scoring/fitness) call these
;; clauses with one row tuple, so an op needs only this one clause.
(= (AND $args) (all $args))
(= (OR  $args) (any $args))
(= (NOT ($x))  (not $x))
