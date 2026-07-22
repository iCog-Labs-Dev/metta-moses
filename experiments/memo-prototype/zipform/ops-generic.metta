;; ---------------------------------------------------------------------------
;; zipform/ops-generic.metta -- variant G ("generic ops"): the rowFnTable-FREE
;; op layer. Instead of keeping AND/OR/NOT as pure inert DATA and mapping them
;; to the builtins `and`/`or`/`not` via a rowFnTable (zipform/ops.metta's
;; design), this variant DEFINES AND/OR/NOT directly at their natural row
;; arity and lets the rewriter pass the op symbol straight through into
;; `(zipWith $op ...)` / `(fmap $op ...)` -- so `rowFnOf` collapses to the
;; identity and the whole table disappears. Adding a new binary op becomes
;; literally one clause here, zero rewriter/evaluator edits.
;;
;; WHY THIS NEEDS A QUOTE REGIME (and zipform/ops.metta does not):
;; the moment AND/OR/NOT are given clauses, the PeTTa translator rewrites
;; EVERY literal `(AND ...)` occurrence whose arity != the defined arity into
;; a grounded `partial('AND', ...)` term at translation time
;; (src/translator.pl build_call_or_partial). That poisons candidate-DATA
;; occurrences (which are arity-1: `(AND (c1 .. ck))` = AND applied to one
;; children-list) unless they arrive as clean data via `quote`. Consequences,
;; all handled below or in the entry files:
;;   - the two op TABLES here (`monoids`, `memptyTable`) mention AND/OR as
;;     data, so their bodies are `quote`d -- verified (probe-g-tables) that a
;;     quoted body yields a clean list that `is-member`/`==` match against a
;;     clean destructured op symbol;
;;   - candidate sources (reference-formulas, replay captures, inline harness
;;     candidates) must be `quote`d too -- entry files use the *-quoted
;;     variants;
;;   - the rewriter destructures GENERICALLY (`(let ($op $children) ...)`,
;;     a variable head), never a literal `(AND $cs)` clause head -- a literal
;;     head would itself compile to a `partial(...)` PATTERN that a clean
;;     quoted candidate can never unify with (probe-quote-and-destructure).
;;
;; AND/OR/NOT as ROW functions (scalar, per-cell) -- distinct arities from the
;; arity-1 candidate-data shape, which is exactly why defining them does NOT
;; clobber the data path (the data `(AND (children))` has no matching clause
;; and stays inert-to-matching under `quote`):
(= (AND $a $b) (and $a $b))
(= (OR  $a $b) (or  $a $b))
(= (NOT $a)    (not $a))
;; XOR: defined HERE (not downstream) so its row-fn clause lives with its
;; monoid/mempty registration below -- registration without definition would
;; let (XOR ...) score to unreduced (XOR ...) terms with no error.
(= (XOR $a $b) (or (and $a (not $b)) (and (not $a) $b)))

;; --- monoid table: ops whose arity>2 case right-folds their own binary ------
;;
;; WHAT IS A MONOID? An operation is a monoid when it has two properties:
;;   1. ASSOCIATIVE: grouping doesn't matter -- (a AND b) AND c == a AND (b AND c),
;;      so an n-ary application can be computed as any nesting of binary ones.
;;   2. IDENTITY element ("mempty", Haskell's name for it): a value that
;;      changes nothing when combined -- True for AND (True AND x == x),
;;      False for OR (False OR x == x).
;; Boolean AND (identity True), OR (identity False) and XOR (identity False)
;; all qualify -- XOR is associative and commutative, so (XOR (a b c)) is the
;; parity of a,b,c and folds correctly as any nesting of binary XOR. NOT does
;; not (it is unary, nothing to associate), which is why it is absent here.
;;
;; Why the rewriter cares -- each property licenses one rewrite rule:
;;   - associativity lets it turn the n-ary node (AND (a b c)) into nested
;;     BINARY zipWith terms, (zipWith AND A (zipWith AND B C)), whose inner
;;     subterms become their own shareable cache entries (foldr1);
;;   - the identity makes the degenerate arities principled: zero children ->
;;     the mempty constant column; one child, (AND (c)) -> just c itself.
;;
;; `quote`d so the literal op data mentions survive the ops being defined
;; above (see header). Called value is the clean list (AND OR XOR). NOTE: XOR
;; is registered here as a monoid but DEFINED downstream (e.g. the walkthrough
;; / a domain op file); isMonoid is only evaluated when an XOR candidate is
;; actually rewritten, by which point its binary clause is in scope.
(= (monoids) (quote (AND OR XOR)))

(= (isMonoid $op) (once (is-member $op (monoids))))

;; --- mempty table: value of a monoid op applied to 0 children ---------------
;; `quote`d for the same reason as `monoids`.
(= (memptyTable) (quote ((AND True) (OR False) (XOR False))))

(= (memptyScan () $op) (Error $op "mempty: no nullary identity registered for this op"))
(= (memptyScan (cons ($k $v) $rest) $op)
   (if (== $k $op) $v (memptyScan $rest $op)))

;; mempty: op symbol -> its 0-arity identity value. Loud Error default:
;; silently guessing a wrong identity would corrupt every row of the column.
(= (mempty $op) (memptyScan (memptyTable) $op))
