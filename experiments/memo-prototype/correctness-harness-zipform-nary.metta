;; ---------------------------------------------------------------------------
;; Correctness harness for the zipform boss-literal rewrite kernel, NARY
;; (variant-P, production-definitions) variant: zipform/ops-nary.metta +
;; zipform/rewriter-nary.metta (production-style n-ary clause dispatch --
;; `(= (AND $args) (all $args))`, no monoid fold/rowFnOf/mempty/fmap at all)
;; combined with the EXISTING, UNCHANGED zipform/evaluator-common.metta +
;; zipform/evaluator-memo.metta -- verified (probes/probe-nary-endtoend.metta)
;; that the shared evalZipTermCore's zipWithN branch, which calls `($op
;; $row)` with $row = the WHOLE per-row value tuple, dispatches straight to
;; ops-nary.metta's `(AND $args)` / `(OR $args)` / `(NOT ($x))` clauses with
;; zero evaluator changes needed. PR-165 PeTTa ONLY (lib_memo).
;;
;; Run:  /home/yab/PeTTa-pr165/run.sh <abs-path-to-this-file>
;;
;; Mirrors correctness-harness-zipform-memo.metta's 13-assertion structure,
;; adapted at exactly three points where variant P's semantics genuinely
;; differ from variant M's (documented at each site below):
;;   - singleton AND/OR is NOT collapsed to an identity rewrite here (no
;;     monoid table to consult) -- it stays one *extra* zipWithN wrapper
;;     around the child, so the "structural assert 3" analogue below checks
;;     the UNCOLLAPSED shape instead of an identity-with-the-child equality.
;;   - the materialized parity3 zipterm's expected shape is entirely
;;     different (every node, including the arity-1 NOT nodes, becomes its
;;     own zipWithN wrapper -- no fmap anywhere).
;;   - three new "no-junk gate" assertions (size-atom(collapse(...))==1
;;     duplicate-solution checks + a literal `partial` absence scan) per the
;;     task spec, mirroring correctness-harness-zipform-reduce.metta's own
;;     gates.
;;
;; QUOTE REGIME: common/reference-formulas.metta's OWN formulaAndAB /
;; formulaOrAB / formulaNotA / formulaNestedAndOrNot / parity3Formula getters
;; return BARE (AND ...)/(OR ...)/(NOT ...) literals (verified: that file's
;; header says so, "AND/OR/NOT are never defined as functions anywhere in
;; this prototype" -- true of zipform/ops.metta, but NOT of THIS harness,
;; which imports zipform/ops-nary.metta instead). Calling those getters
;; directly here would misfire (their returned literal source occurrence
;; would compile as a live AND/OR/NOT goal call at translation time, same
;; whole-file-prescan hazard documented in zipform/ops-nary.metta's header).
;; This harness therefore defines its OWN P-local quoted thunks for every
;; formula that contains a bare AND/OR/NOT literal (formulaLeafA is exempt --
;; its body is the bare symbol A, no AND/OR/NOT anywhere, so it is reused
;; directly), while still reusing every expected* column getter verbatim
;; (those are plain True/False tuples, never AND/OR/NOT, so they stay inert
;; regardless of ops-nary.metta being in scope). Verified (probes/probe-
;; nary-direct-nolet.metta) that a `(= (thunk) (quote EXPR))` function,
;; called as a DIRECT nested argument -- `(rewriteTreeNaryCached (thunk))`,
;; no `let`-destructure needed -- compiles to a plain fact returning EXPR as
;; inert data verbatim (PeTTa special-cases a function body that is exactly
;; `(quote ...)`, both suppressing goal-call compilation for its contents
;; AND stripping the wrapper at compile time), so this is safe and simpler
;; than the space/match `(let (quote $e) ... $e)` idiom the replay captures
;; need (those go through an actual space, not a direct function body).
;; ---------------------------------------------------------------------------

!(bind! &params (new-space))
!(import! &self ../../parameters/registry)
!(import! &self (library lib_memo))
!(import! &self common/list-helpers)
!(import! &self common/kernel-common)
!(import! &self zipform/ops-nary)
!(import! &self zipform/rewriter-nary)
!(import! &self zipform/evaluator-common)
!(import! &self zipform/evaluator-memo)
!(import! &self common/truth-tables)
!(import! &self common/reference-formulas)

;; --- P-local quoted formula thunks (see QUOTE REGIME note above) ----------
(= (formulaNotAQ) (quote (NOT (A))))
(= (formulaAndABQ) (quote (AND (A B))))
(= (formulaOrABQ) (quote (OR (A B))))
(= (formulaNestedAndOrNotQ) (quote (AND ((OR (A B)) (NOT (B))))))
(= (formulaSingletonAndOrABQ) (quote (AND ((OR (A B))))))
(= (formulaSingletonOrAndABQ) (quote (OR ((AND (A B))))))
(= (parity3FormulaQ)
   (quote (OR ( (AND (X1 (NOT (X2)) (NOT (X3))))
                (AND ((NOT (X1)) X2 (NOT (X3))))
                (AND ((NOT (X1)) (NOT (X2)) X3))
                (AND (X1 X2 X3)) ))))

;; === Reference-formula correctness (tiny 4-row miniTable) ===================
!(setZipTable (miniTable))
!(clear-memoize)
!(clear-memoize-stats)

!(println! (RESULT formulaLeafA (evalZipTerm (rewriteTreeNaryCached (formulaLeafA)))))
!(test (evalZipTerm (rewriteTreeNaryCached (formulaLeafA))) (expectedLeafA))

!(println! (RESULT formulaNotA (evalZipTerm (rewriteTreeNaryCached (formulaNotAQ)))))
!(test (evalZipTerm (rewriteTreeNaryCached (formulaNotAQ))) (expectedNotA))

!(println! (RESULT formulaAndAB (evalZipTerm (rewriteTreeNaryCached (formulaAndABQ)))))
!(test (evalZipTerm (rewriteTreeNaryCached (formulaAndABQ))) (expectedAndAB))

!(println! (RESULT formulaOrAB (evalZipTerm (rewriteTreeNaryCached (formulaOrABQ)))))
!(test (evalZipTerm (rewriteTreeNaryCached (formulaOrABQ))) (expectedOrAB))

!(println! (RESULT formulaNestedAndOrNot (evalZipTerm (rewriteTreeNaryCached (formulaNestedAndOrNotQ)))))
!(test (evalZipTerm (rewriteTreeNaryCached (formulaNestedAndOrNotQ))) (expectedNestedAndOrNot))

;; === Singleton AND/OR: NOT an identity rewrite here (no monoid table) ======
;; (AND ((OR (A B)))) still computes the correct value (per-row `(AND (v))`
;; -> `(all (v))` -> v), but the MATERIALIZED TERM keeps its wrapper node --
;; one extra zipWithN entry vs. variant M's zero-wrapper identity shortcut.
;; Column assert 1 (value-level, same expected columns variant M's harness
;; uses for its own singleton asserts):
!(println! (RESULT singletonAndOrAB (evalZipTerm (rewriteTreeNaryCached (formulaSingletonAndOrABQ)))))
!(test (evalZipTerm (rewriteTreeNaryCached (formulaSingletonAndOrABQ))) (expectedOrAB))

!(println! (RESULT singletonOrAndAB (evalZipTerm (rewriteTreeNaryCached (formulaSingletonOrAndABQ)))))
!(test (evalZipTerm (rewriteTreeNaryCached (formulaSingletonOrAndABQ))) (expectedAndAB))

;; Structural assert 3 (P's analogue of the memo harness's singleton-identity
;; structural check): rewriteTreeNaryCached of a singleton-AND formula is
;; EXACTLY `(zipWithN AND ((<rewritten OR-child>)))` -- the child's own
;; rewrite (zipWithN OR ((col A) (col B))) wrapped in ONE extra zipWithN AND
;; layer, NOT collapsed away. Built via `quote` (zipWithN/col ARE live heads
;; here via the imported evaluator).
(= (expectedSingletonAndZipterm)
   (quote (zipWithN AND ((zipWithN OR ((col A) (col B)))))))
!(println! (SINGLETON_AND_UNCOLLAPSED (rewriteTreeNaryCached (formulaSingletonAndOrABQ))))
!(println! (SINGLETON_AND_UNCOLLAPSED_EXPECTED (expectedSingletonAndZipterm)))
!(test (rewriteTreeNaryCached (formulaSingletonAndOrABQ)) (expectedSingletonAndZipterm))

;; Assert 4: unmapped unary op via the zipWithN args-tuple convention (same
;; convention zipform/ops.metta's "how to add an op" comment documents, and
;; the SAME convention ops-nary.metta's own AND/OR/NOT already use uniformly
;; -- IDOP demonstrates a brand-new custom op needs zero table entries under
;; the nary rewriter, exactly like every other op here). IDOP is harness-
;; local, mirroring correctness-harness-zipform-memo.metta's own IDOP assert
;; (that harness's literal `(IDOP (A))` occurrence works despite IDOP having
;; a same-file clause too -- IDOP is a transparent identity, so even if the
;; whole-file prescan fired it early at the literal call site, the result is
;; identical to the intended row-dispatch value; kept unquoted here to match
;; that harness's own precedent).
(= (IDOP ($a)) $a)
!(println! (RESULT idopA (evalZipTerm (rewriteTreeNaryCached (IDOP (A))))))
!(test (evalZipTerm (rewriteTreeNaryCached (IDOP (A)))) (expectedLeafA))

;; === Structural assert: materialized parity3 zipterm (n-ary path) ==========
;; parity3Formula (common/reference-formulas.metta, reproduced P-locally
;; above as parity3FormulaQ) is
;;   (OR ( (AND (X1 (NOT (X2)) (NOT (X3))))
;;         (AND ((NOT (X1)) X2 (NOT (X3))))
;;         (AND ((NOT (X1)) (NOT (X2)) X3))
;;         (AND (X1 X2 X3)) ))
;; -- OR has arity 4, each AND arity 3, each NOT arity 1. EVERY node here,
;; regardless of arity, becomes its own zipWithN wrapper (no fmap, no
;; foldr1/binary nesting) -- this is the entire point of the nary rewriter.
;; Per-leaf: X1 -> (col X1); (NOT (X2)) -> (zipWithN NOT ((col X2))).
;;
;; t1z = (zipWithN AND ((col X1) (zipWithN NOT ((col X2))) (zipWithN NOT ((col X3)))))
;; t2z = (zipWithN AND ((zipWithN NOT ((col X1))) (col X2) (zipWithN NOT ((col X3)))))
;; t3z = (zipWithN AND ((zipWithN NOT ((col X1))) (zipWithN NOT ((col X2))) (col X3)))
;; t4z = (zipWithN AND ((col X1) (col X2) (col X3)))
;; full = (zipWithN OR (t1z t2z t3z t4z))
(= (expectedParity3NaryZipterm)
   (quote
     (zipWithN OR
       ( (zipWithN AND ((col X1) (zipWithN NOT ((col X2))) (zipWithN NOT ((col X3)))))
         (zipWithN AND ((zipWithN NOT ((col X1))) (col X2) (zipWithN NOT ((col X3)))))
         (zipWithN AND ((zipWithN NOT ((col X1))) (zipWithN NOT ((col X2))) (col X3)))
         (zipWithN AND ((col X1) (col X2) (col X3))) ))))

!(println! (PARITY3_NARY_ZIPTERM (rewriteTreeNaryCached (parity3FormulaQ))))
!(println! (PARITY3_NARY_ZIPTERM_EXPECTED (expectedParity3NaryZipterm)))
!(test (rewriteTreeNaryCached (parity3FormulaQ)) (expectedParity3NaryZipterm))

;; === Full parity3 formula correctness (8-row parity3Table) =================
!(setZipTable (parity3Table))
!(clear-memoize)
!(clear-memoize-stats)

!(change-state! &parity3RtermP (rewriteTreeNaryCached (parity3FormulaQ)))
!(println! (RESULT parity3Formula (evalZipTerm (get-state &parity3RtermP))))
!(test (evalZipTerm (get-state &parity3RtermP)) (expectedParity3Formula))

;; --- no-junk gate 1: exactly one solution out of the scoring call (no
;; doubled results from double-import or overlapping col/zipWithN clauses).
!(test (size-atom (collapse (evalZipTerm (get-state &parity3RtermP)))) 1)

;; --- no-junk gate 2: no `partial` grounded-application leakage anywhere in
;; the output column. Variant P's design (every op, every arity, called via
;; the SAME `($op $row)` full-tuple dispatch -- no singleton special-casing,
;; unlike variant M's original bug this prototype's ops.metta documents)
;; structurally can't produce a partial application, but this is asserted
;; directly rather than assumed.
(= (containsPartial $col) (once (is-member partial $col)))
!(test (containsPartial (evalZipTerm (get-state &parity3RtermP))) False)

;; === Cache-behavior check =====================================================
;; Second evalZipTerm call on the IDENTICAL already-rewritten term (no repeat
;; call to rewriteTreeNaryCached here, isolating evalZipTerm's own hit/miss
;; behavior). Same shape as correctness-harness-zipform-memo.metta's own
;; check: a function-level memo hit short-circuits before the body (and its
;; own recursive evalZipTerm calls on children) ever runs.
!(println! (STATS after-first-pass (get-memoize-stats)))
!(evalZipTerm (get-state &parity3RtermP))
!(println! (STATS after-second-pass-expect-pure-hits (get-memoize-stats)))

;; === Table-switch staleness demo =============================================
;; (AND (A B)) is a valid formula against BOTH miniTable (4 rows) and
;; majority3Table (8 rows) since both tables have labels A and B -- but the
;; two tables carry different A/B data and different row counts.
!(setZipTable (miniTable))
!(invalidate-memoize evalZipTerm)
!(change-state! &andAbRtermP (rewriteTreeNaryCached (formulaAndABQ)))
!(println! (RESULT-miniTable formulaAndAB (evalZipTerm (get-state &andAbRtermP))))
;; populates evalZipTerm's cache for the materialized (zipWithN AND ((col A)
;; (col B))) term against miniTable.

!(setZipTable (majority3Table))
;; single-valuedness gate on the param registry itself after a table switch
;; (set-param dedupes by design -- confirm exactly one value is readable).
!(test (size-atom (collapse (param zipTable))) 1)

;; Isolate the REWRITE-cache hit measurement: call rewriteTreeNaryCached
;; ALONE (no evalZipTerm call yet) -- deliberately NO invalidate-memoize of
;; rewriteTreeNaryCached anywhere in this section (it is table-independent
;; and needs none, same as rewriteTreeCached in variant M).
!(println! (STATS before-rewrite-after-table-switch (get-memoize-stats)))
!(change-state! &andAbRtermP2 (rewriteTreeNaryCached (formulaAndABQ)))
!(println! (STATS after-rewrite-after-table-switch-expect-plus1-hit (get-memoize-stats)))
!(test (get-state &andAbRtermP2) (quote (zipWithN AND ((col A) (col B)))))
;; Confirms the rewrite-cache HIT still returned the correct (table-
;; independent) materialized term even after the table switch.

;; NO invalidate-memoize of evalZipTerm here -- deliberately demonstrate
;; eval-cache staleness against the NEW table.
!(println! (STALE-WITHOUT-CLEAR formulaAndAB (evalZipTerm (get-state &andAbRtermP2))))
;; Expected (miniTable-era, WRONG for majority3Table): (False False False True)

!(invalidate-memoize evalZipTerm)
!(println! (CORRECT-AFTER-CLEAR formulaAndAB (evalZipTerm (get-state &andAbRtermP2))))
;; Hand-computed majority3Table A/B columns (common/truth-tables.metta):
;;   A = (False False False False True  True  True  True )
;;   B = (False False True  True  False False True  True )
;;   AND(A,B) row-by-row: F,F,F,F,F,F,T,T
!(test (evalZipTerm (get-state &andAbRtermP2)) (False False False False False False True True))

;; --- no-junk gate 3: final duplicate/junk gate on the post-clear,
;; post-switch correct result.
!(test (size-atom (collapse (evalZipTerm (get-state &andAbRtermP2)))) 1)
