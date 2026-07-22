;; ---------------------------------------------------------------------------
;; zipform/rewriter-nary.metta -- variant-P (production-definitions) rewriter.
;; Twin of zipform/rewriter.metta (DO NOT MODIFY that file), but with NO
;; monoid-fold combine strategy at all: every node, of EVERY arity, becomes a
;; single cons-built `(zipWithN $op (<rewritten children>))` term -- no
;; foldr1, no rowFnOf, no isMonoid, no mempty, no fmap ever emitted. This is
;; the "production-style clause-dispatch" combine strategy: the whole
;; per-row args tuple is handed to the op symbol itself ($op $row), which
;; zipform/ops-nary.metta gives a real n-ary clause (AND/OR via local
;; all/any, NOT via a 1-tuple destructure) -- see that file's header for the
;; row-dispatch shape.
;;
;; Same "never write a literal zipWithN/col source form" discipline as
;; zipform/rewriter.metta (those heads are live once zipform/evaluator-
;; common.metta is imported alongside this file in the same harness/driver):
;; every constructed node goes through `cons`.
;;
;; NULLARY CAVEAT (probe-verified, see probes/probe-nary-transpose-empty.metta
;; and probes/probe-nary-nullary-zipwithn.metta): a nullary op node emits
;; `(zipWithN $op ())` uniformly here (no special-case, per the design's "no
;; monoid fold" mandate) -- but evaluator-common.metta's zipWithN branch
;; feeds the (here: empty) per-child column list through `transposeCols`,
;; whose own base case is `(if (== (car-atom $cols) ()) () ...)`; with
;; $cols = () (zero columns, not one all-() column), `car-atom` on an empty
;; expression FAILS outright (verified directly against evaluator-common.metta
;; unmodified: `(transposeCols ())` produces zero solutions, no exception).
;; So a genuine nullary AND/OR node (`(AND ())` in the wrapped-tree source
;; language) cannot be scored by this rewriter + the shared evaluator, full
;; stop -- a real, load-bearing gap in the (untouched, DO-NOT-MODIFY)
;; evaluator, not something ops-nary.metta's all/any identities can paper
;; over (they're never reached; transposeCols fails before `($op $row)` is
;; even called). Grepped all four capture logs (captures/*.raw.log) for
;; literal `AND ()` / `OR ()` occurrences: zero hits in majority3, mux6,
;; parity3, rand12 -- this benchmark never exercises the gap. Documented,
;; not fixed (evaluator-common.metta is off-limits).
;;
;; SINGLETON NOTE: a singleton node `(AND (c))` still becomes `(zipWithN AND
;; ((col c)))` here (uncollapsed, unlike zipform/rewriter.metta's monoid
;; identity shortcut) -- per-row this calls `(AND (v))` -> `(all (v))` ->
;; `v` (correct value, one extra cache entry per such node vs. variant M's
;; zero-wrapper identity rewrite).
;;
;; NOTE ON IMPORTS: matching zipform/rewriter.metta's own convention, this
;; file has NO self-import of common/list-helpers (needs List.length only
;; for nothing here, actually not even that -- map-atom/car-atom/cons/
;; get-metatype are the only builtins used, all requiring zero shared-module
;; imports). The one thing THIS file needs beyond builtins is `memoize` /
;; `clear-memoize` etc. for its own `rewriteTreeNaryCached` wrapper, so
;; (mirroring zipform/rewrite-cache-memo.metta's own precedent, which is
;; imported multiple times across a driver/harness with `library lib_memo`
;; safely -- library imports, unlike plain .metta module imports, are
;; idempotent, see that file's callers) this file imports `(library
;; lib_memo)` itself.
;; ---------------------------------------------------------------------------

!(import! &self (library lib_memo))

;; rewriteTreeNary: recursive rewriter, production-style combine strategy.
;; Node shape is uniformly ($op ($c1 .. $ck)) (same convention as
;; zipform/rewriter.metta); leaves are bare label symbols; grounded True/
;; False constants pass through unchanged.
(= (rewriteTreeNary $exp)
   (if (== (get-metatype $exp) Grounded)
       $exp
       (if (== (get-metatype $exp) Symbol)
           (cons col (cons $exp ()))
           (let ($op $children) $exp
             (let $recChildren (map-atom $children $c (rewriteTreeNary $c))
               (cons zipWithN (cons $op (cons $recChildren ()))))))))

!(memoize rewriteTreeNaryCached 1)
(= (rewriteTreeNaryCached $exp) (rewriteTreeNary $exp))
