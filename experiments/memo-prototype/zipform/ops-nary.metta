;; ---------------------------------------------------------------------------
;; zipform/ops-nary.metta -- variant-P (production-definitions) op clauses.
;; Imported ONLY by variant-P entry files; NEVER coexists with unquoted
;; candidate data (unlike zipform/ops.metta, which keeps AND/OR/NOT purely
;; as inert DATA symbols with zero clauses). This file gives them REAL
;; clauses, mirroring production's own row-level convention (a single call
;; over the whole args tuple, no rowFnOf/isMonoid/mempty tables, no monoid
;; fold):
;;
;;   (= (AND $args) (all $args))
;;   (= (OR  $args) (any $args))
;;   (= (NOT ($x))  (not $x))
;;
;; CRITICAL FILE-LOCAL HAZARD (probe-verified, see probes/probe-nary-quote-
;; store-retrieve.metta): once this file is imported, AND/OR/NOT become LIVE
;; heads for the rest of the translation unit -- any BARE literal `(AND ...)`
;; / `(OR ...)` / `(NOT (...))` occurrence written directly as source text
;; ANYWHERE in a file that (transitively) imports this one compiles as a
;; goal call at translation time (same whole-file-prescan rule documented in
;; zipform/rewriter.metta / probes/probe-zip-quote-unfired.metta), REGARDLESS
;; of where in the importing file that occurrence sits. Every variant-P file
;; must `(quote ...)` every such literal. This does NOT affect runtime values
;; that merely carry AND/OR/NOT as a functor after being built by `cons`, or
;; bound to a variable via `match`/`let` destructuring from space content --
;; the probe confirmed those stay fully inert through let-destructure and
;; through being passed as a plain function argument; only literal SOURCE
;; TEXT occurrences trigger the goal-call compilation.
;;
;; --- local `all`/`any`, copied semantics from production's
;; utilities/general-helpers.metta (that file is NOT imported -- the
;; prototype stays self-contained under experiments/memo-prototype/, same
;; convention common/list-helpers.metta already established for List.*):
;;   production: (= (any $bools) (once (is-member True $bools)))
;;               (= (all $expressions) (if (once (is-member False $expressions)) False True))
;; Re-implemented here HOF-style via foldl-atom over the builtin `and`/`or`
;; (style rule: HOFs/composition over fresh recursion) instead of is-member
;; + once -- PeTTa's `and`/`or` are NOT short-circuit (verified elsewhere in
;; this prototype), so a plain fold over the whole tuple is semantically
;; equivalent to production's is-member scan, just phrased as a catamorphism
;; instead of a membership test. Crucially this ALSO gives the correct
;; identities on an EMPTY tuple, which is what the nullary zipWithN case
;; below needs:
;;   all(())  = foldl-atom(() , True , and)  = True   (AND's identity)
;;   any(())  = foldl-atom(() , False, or)   = False  (OR's identity)
;; matching production's own (all ()) = True / (any ()) = False exactly (an
;; empty tuple never contains False, nor True, so both production's
;; is-member scan and this fold agree).
;; ---------------------------------------------------------------------------

(= (all $args) (foldl-atom $args True $acc $x (and $acc $x)))
(= (any $args) (foldl-atom $args False $acc $x (or $acc $x)))

;; --- production-style n-ary op clauses -------------------------------------
;; Row-level dispatch: evalZipTermCore's zipWithN branch calls `($op $row)`
;; where $row is the whole per-row value tuple (v1 .. vk) -- a call
;; `(AND (v1 v2 v3))` has ONE argument, the tuple itself, so it matches the
;; single-arg pattern `(AND $args)` below with $args bound to (v1 v2 v3).
;; NOT is unary and its row value is a 1-tuple `(v)` (zipWithN's own $row
;; shape, not a bare value), so its clause destructures that 1-tuple
;; directly, same args-tuple convention documented in zipform/ops.metta's
;; "how to add an op" comment for an unmapped unary op.
(= (AND $args) (all $args))
(= (OR $args) (any $args))
(= (NOT ($x)) (not $x))
