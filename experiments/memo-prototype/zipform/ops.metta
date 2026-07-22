;; ---------------------------------------------------------------------------
;; zipform/ops.metta -- data tables + lookups for the rewriter/evaluator. The
;; rewriter (zipform/rewriter.metta) and evaluator core (zipform/evaluator-
;; common.metta) never change to add a new op: they only ever call rowFnOf /
;; isMonoid / mempty, or (for the zipWithN, arity>2-non-foldable path)
;; dispatch on the op symbol itself via an args-tuple clause the op defines.
;;
;; HOW TO ADD AN OP (worked example: a 3-ary XOR):
;;   - args-tuple n-ary op (no simple binary reduction): define its row-level
;;     clause directly, dispatched on the tuple shape (probe-zip-argstuple-
;;     dispatch's convention): `(= (XOR ($a $b $c)) (xor3 $a $b $c))`.
;;     zipWithN calls it var-headed as `($op $rowTuple)` -- no table entry
;;     needed for this case at all. This SAME convention covers a future
;;     UNARY op with no rowFnTable entry too: the rewriter's arity-1 branch
;;     falls back to `(zipWithN $op ($c))` whenever `(rowFnOf $op)` returns
;;     $op unchanged (i.e. no table row below), so a plain `(= (XYZ ($a)) ...)`
;;     clause is all a new unmapped unary op needs.
;;   - binary/unary op with a plain row function (like AND/OR/NOT): add a row
;;     to rowFnTable mapping the SOURCE-language head (e.g. XOR2) to its
;;     DATA-language row-fn symbol (a builtin like `and`/`or`/`not`, or a
;;     custom row-fn function of the same var-headed-appliable shape).
;;   - foldable n-ary op reducible via right-fold of its own binary case
;;     (like AND/OR): add the source head to monoids (so arity>2 goes
;;     through the binary fold instead of zipWithN) AND give it a rowFnTable
;;     entry (needed by the arity-2 and fold-recursion cases); if it is ever
;;     applied with ZERO children, also add its identity value to
;;     memptyTable. IMPORTANT: a foldable op's arity-1 case (singleton
;;     wrapping, e.g. `(AND (c))`) is a semantic IDENTITY -- the rewriter
;;     returns the rewritten child directly with no wrapper at all (never a
;;     unary call to the op's BINARY row-fn like `and`/`or`, which would
;;     silently evaluate as a grounded partial application and corrupt the
;;     column). This is handled generically by rewriteTree's `isMonoid`
;;     check in the arity-1 branch -- no per-op change needed here.
;; In every case: the rewriter/evaluator cores above never need to change.
;;
;; Single-clause + if-guard style for every PUBLIC lookup below (rowFnOf /
;; isMonoid / mempty) -- never an overlapping literal-pattern clause and
;; a variable-pattern clause for the SAME head (probe-zip-deep-column-4096's
;; documented infinite-backtracking hazard). The internal assoc-scan helpers
;; use the same nil-vs-cons structurally-DISJOINT two-clause shape already
;; established by common/list-helpers.metta's List.index (never a hazard:
;; the two clauses match mutually exclusive shapes -- zero args vs. one-or-
;; more -- never the same shape at two different literal/variable heads).
;;
;; AND/OR/NOT below are used purely as DATA symbols (compared with `==` or
;; matched positionally) -- never given `(= (AND ...) ...)` clauses anywhere
;; in this prototype, so the literal tables below stay inert regardless of
;; where in the file (or in importing files) they are read from, exactly the
;; convention already established by common/kernel-common.metta and
;; common/reference-formulas.metta.
;; ---------------------------------------------------------------------------

;; --- row-function table: source-language op -> data-language row-fn symbol -
(= (rowFnTable) ((AND and) (OR or) (NOT not)))

(= (rowFnOfScan () $op) $op)
(= (rowFnOfScan (cons ($k $v) $rest) $op)
   (if (== $k $op) $v (rowFnOfScan $rest $op)))

;; rowFnOf: op symbol -> row-fn symbol to apply var-headed inside zipWith /
;; fmap. Default (no table entry): the op symbol itself, so a future op
;; named consistently in both languages needs no table row at all.
(= (rowFnOf $op) (rowFnOfScan (rowFnTable) $op))

;; --- monoid table: ops whose arity>2 case right-folds their own binary ----
;;
;; WHAT IS A MONOID? An operation is a monoid when it has two properties:
;;   1. ASSOCIATIVE: grouping doesn't matter -- (a AND b) AND c == a AND (b AND c),
;;      so an n-ary application can be computed as any nesting of binary ones.
;;   2. IDENTITY element ("mempty", Haskell's name for it): a value that
;;      changes nothing when combined -- True for AND (True AND x == x),
;;      False for OR (False OR x == x).
;; Both boolean AND and OR qualify. NOT does not (it is unary, nothing to
;; associate), which is why it is absent from this table.
;;
;; Why the rewriter cares -- each property licenses one rewrite rule:
;;   - associativity lets it turn the n-ary node (AND (a b c)) into nested
;;     BINARY zipWith terms, (zipWith and A (zipWith and B C)), whose inner
;;     subterms become their own shareable cache entries (foldr1 in
;;     zipform/rewriter.metta);
;;   - the identity makes the degenerate arities principled rather than
;;     special-cased: zero children -> the mempty constant column below;
;;     one child, (AND (c)) -> just c itself (folding a single element
;;     needs no operation at all).
;; Non-monoid n-ary ops can't be decomposed this way, so they take the
;; zipWithN args-tuple path instead (one call per row over the whole tuple).
(= (monoids) (AND OR))

(= (isMonoid $op) (once (is-member $op (monoids))))

;; --- mempty table: value of a monoid op applied to 0 children ------------
(= (memptyTable) ((AND True) (OR False)))

(= (memptyScan () $op) (Error $op "mempty: no nullary identity registered for this op"))
(= (memptyScan (cons ($k $v) $rest) $op)
   (if (== $k $op) $v (memptyScan $rest $op)))

;; mempty: op symbol -> its 0-arity identity value. Loud Error default
;; (unlike rowFnOf's permissive default): silently guessing a wrong identity
;; would corrupt every row of the column, so an op reaching this with no
;; table entry is a real bug, not a legitimately-extensible case.
(= (mempty $op) (memptyScan (memptyTable) $op))
