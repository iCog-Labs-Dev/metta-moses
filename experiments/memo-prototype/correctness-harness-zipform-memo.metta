;; ---------------------------------------------------------------------------
;; Correctness harness for the zipform boss-literal rewrite kernel, memo
;; variant (zipform/rewrite-cache-memo.metta + zipform/evaluator-memo.metta,
;; both lib_memo-backed). PR-165 PeTTa ONLY. See correctness-harness-
;; zipform-space.metta for the twin harness that runs on both runtimes.
;;
;; Run:  /home/yab/PeTTa-pr165/run.sh <abs-path-to-this-file>
;;
;; Assertions use the native `test` translator construct (same one used by
;; correctness-harness-memo.metta / correctness-harness-space.metta); it
;; prints "is X, should Y. <PASS/FAIL glyph>" and halts(1) on the first
;; failed comparison, so a clean run to the end means every assertion below
;; passed.
;;
;; Every formula is scored via `(evalZipTerm (rewriteTreeCached $formula))`
;; against the SAME hand-computed expected columns common/reference-
;; formulas.metta already carries for the plain kernel harnesses -- zero new
;; reference data, except the ONE new structural assert below (the
;; materialized parity3 zipterm), whose expected nesting is derived by hand
;; in a comment right above it.
;;
;; DEVIATION FROM SPEC / IMPORT ORDER NOTE: the individual zipform/*.metta
;; module files do NOT self-import their common/list-helpers, common/
;; kernel-common, or zipform/ops prerequisites (unlike kernel-memo.metta /
;; kernel-space.metta, which each self-import their two leaf deps). Reason,
;; found empirically while building this harness: this harness needs BOTH
;; the rewrite chain (rewrite-cache-memo -> rewriter -> ops/list-helpers)
;; AND the eval chain (evaluator-memo -> evaluator-common -> list-helpers/
;; kernel-common) side by side, and "import! does not dedupe" (verified: a
;; leaf module reached via two independent chains from one entry file gets
;; its clauses asserted twice, so every call through it returns duplicate
;; solutions -- e.g. `test` on a leaf-column result failed comparing an
;; 8-times-duplicated list against a plain expected list). This harness is
;; therefore the single choke point that imports every shared leaf EXACTLY
;; once, in dependency order, before importing the modules that use them --
;; the same convention common/kernel-common.metta itself already follows
;; (it has zero `!(import! ...)` lines and assumes its caller supplies
;; List.foldl/List.repeat).
;; ---------------------------------------------------------------------------

!(bind! &params (new-space))
!(import! &self ../../parameters/registry)
!(import! &self (library lib_memo))
!(import! &self common/list-helpers)
!(import! &self common/kernel-common)
!(import! &self zipform/ops)
!(import! &self zipform/rewriter)
!(import! &self zipform/evaluator-common)
!(import! &self zipform/evaluator-memo)
!(import! &self zipform/rewrite-cache-memo)
!(import! &self common/truth-tables)
!(import! &self common/reference-formulas)

;; === Reference-formula correctness (tiny 4-row miniTable) ===================
!(setZipTable (miniTable))
!(clear-memoize)
!(clear-memoize-stats)

!(println! (RESULT formulaLeafA (evalZipTerm (rewriteTreeCached (formulaLeafA)))))
!(test (evalZipTerm (rewriteTreeCached (formulaLeafA))) (expectedLeafA))

!(println! (RESULT formulaNotA (evalZipTerm (rewriteTreeCached (formulaNotA)))))
!(test (evalZipTerm (rewriteTreeCached (formulaNotA))) (expectedNotA))

!(println! (RESULT formulaAndAB (evalZipTerm (rewriteTreeCached (formulaAndAB)))))
!(test (evalZipTerm (rewriteTreeCached (formulaAndAB))) (expectedAndAB))

!(println! (RESULT formulaOrAB (evalZipTerm (rewriteTreeCached (formulaOrAB)))))
!(test (evalZipTerm (rewriteTreeCached (formulaOrAB))) (expectedOrAB))

!(println! (RESULT formulaNestedAndOrNot (evalZipTerm (rewriteTreeCached (formulaNestedAndOrNot)))))
!(test (evalZipTerm (rewriteTreeCached (formulaNestedAndOrNot))) (expectedNestedAndOrNot))

;; === Regression: rewriteTree arity-1 branch, singleton AND/OR identity =====
;; Bug: rewriteTree's k==1 branch unconditionally emitted (fmap
;; (rowFnOf $op) child) -- for a foldable op (AND/OR) this produced a UNARY
;; call to a BINARY builtin (e.g. `(and $v)`), which PeTTa silently
;; evaluates to a grounded (partial and (v)) term instead of erroring,
;; corrupting every downstream column. Fix: a singleton foldable node is a
;; semantic identity ((AND (c)) == c, (OR (c)) == c), so rewriteTree now
;; returns the rewritten child directly with no wrapper for that case.
;;
;; Column assert 1: (AND ((OR (A B)))) == OR(A,B) column (AND-singleton is
;; an identity over its OR child; OR(A,B) hand-computed in reference-
;; formulas.metta as expectedOrAB = (False True True True)).
!(println! (RESULT singletonAndOrAB (evalZipTerm (rewriteTreeCached (AND ((OR (A B))))))))
!(test (evalZipTerm (rewriteTreeCached (AND ((OR (A B)))))) (expectedOrAB))

;; Column assert 2: (OR ((AND (A B)))) == AND(A,B) column (OR-singleton is
;; an identity over its AND child; AND(A,B) hand-computed as expectedAndAB
;; = (False False False True)).
!(println! (RESULT singletonOrAndAB (evalZipTerm (rewriteTreeCached (OR ((AND (A B))))))))
!(test (evalZipTerm (rewriteTreeCached (OR ((AND (A B)))))) (expectedAndAB))

;; Structural assert 3: rewriteTree of a singleton-AND formula is EXACTLY
;; (term-for-term) the rewritten child -- no fmap/zipWithN wrapper node
;; at all. Both sides go through rewriteTreeCached (a pure keyed-cache
;; wrapper around rewriteTree, zipform/rewrite-cache-memo.metta), so neither
;; side needs quoting: no literal zipWith/col/fmap/zipWithN source form
;; appears anywhere in this assert.
!(println! (SINGLETON_AND_IDENTITY (rewriteTreeCached (AND ((OR (A B)))))))
!(println! (SINGLETON_AND_IDENTITY_EXPECTED (rewriteTreeCached (OR (A B)))))
!(test (rewriteTreeCached (AND ((OR (A B))))) (rewriteTreeCached (OR (A B))))

;; Assert 4: unmapped unary op via the zipWithN args-tuple fallback (the
;; k==1 branch's third path -- $op has no rowFnTable entry and is not a
;; monoid). IDOP is a trivial harness-local identity op defined with the
;; args-tuple convention documented in zipform/ops.metta's "how to add an
;; op" comment: `(= (IDOP ($a)) $a)`. No table entry means (rowFnOf IDOP)
;; returns IDOP unchanged, so rewriteTree emits (zipWithN IDOP (col A)),
;; and evalZipTermCore's zipWithN arm dispatches each row var-headed as
;; (IDOP (row-tuple)). IDOP(A) must equal the plain A column (expectedLeafA
;; = (False False True True)).
(= (IDOP ($a)) $a)
!(println! (RESULT idopA (evalZipTerm (rewriteTreeCached (IDOP (A))))))
!(test (evalZipTerm (rewriteTreeCached (IDOP (A)))) (expectedLeafA))

;; === Structural assert: materialized parity3 zipterm (n-ary fold path) =====
;; parity3Formula (common/reference-formulas.metta) is
;;   (OR ( (AND (X1 (NOT (X2)) (NOT (X3))))         ; t1, arity 3
;;         (AND ((NOT (X1)) X2 (NOT (X3))))         ; t2, arity 3
;;         (AND ((NOT (X1)) (NOT (X2)) X3))         ; t3, arity 3
;;         (AND (X1 X2 X3)) ))                      ; t4, arity 3
;; -- OR has arity 4 (>2, foldable) and each AND has arity 3 (>2, foldable),
;; so BOTH levels exercise rewriteTree's foldr1 path, never the plain
;; arity-2 zipWith arm.
;;
;; foldr1(fn, (c1 c2 c3 c4)) = (zipWith fn c1 (zipWith fn c2 (zipWith fn c3 c4)))
;; (right-associated: c4 is the recursion base case, not an injected seed).
;;
;; Per-leaf rewriteTree: X1 -> (col X1); (NOT (X2)) -> (fmap not (col X2));
;; (NOT (X3)) -> (fmap not (col X3)); etc.
;;
;; t1z = (zipWith and (col X1) (zipWith and (fmap not (col X2)) (fmap not (col X3))))
;; t2z = (zipWith and (fmap not (col X1)) (zipWith and (col X2) (fmap not (col X3))))
;; t3z = (zipWith and (fmap not (col X1)) (zipWith and (fmap not (col X2)) (col X3)))
;; t4z = (zipWith and (col X1) (zipWith and (col X2) (col X3)))
;;
;; full = (zipWith or t1z (zipWith or t2z (zipWith or t3z t4z)))
;;
;; Built via `quote` (hazard 2: zipWith/col/fmap ARE live heads in this
;; file via the imported evaluator, so a bare literal here would fire).
(= (expectedParity3Zipterm)
   (quote
     (zipWith or
       (zipWith and (col X1) (zipWith and (fmap not (col X2)) (fmap not (col X3))))
       (zipWith or
         (zipWith and (fmap not (col X1)) (zipWith and (col X2) (fmap not (col X3))))
         (zipWith or
           (zipWith and (fmap not (col X1)) (zipWith and (fmap not (col X2)) (col X3)))
           (zipWith and (col X1) (zipWith and (col X2) (col X3))))))))

!(println! (PARITY3_ZIPTERM (rewriteTreeCached (parity3Formula))))
!(println! (PARITY3_ZIPTERM_EXPECTED (expectedParity3Zipterm)))
!(test (rewriteTreeCached (parity3Formula)) (expectedParity3Zipterm))

;; === Full parity3 formula correctness (8-row parity3Table) =================
!(setZipTable (parity3Table))
!(clear-memoize)
!(clear-memoize-stats)

!(change-state! &parity3Rterm (rewriteTreeCached (parity3Formula)))
!(println! (RESULT parity3Formula (evalZipTerm (get-state &parity3Rterm))))
!(test (evalZipTerm (get-state &parity3Rterm)) (expectedParity3Formula))

;; === Cache-behavior check =====================================================
;; Second evalZipTerm call on the IDENTICAL already-rewritten term (no repeat
;; call to rewriteTreeCached here, so this isolates evalZipTerm's own hit/
;; miss behavior from rewriteTreeCached's). The top-level materialized node
;; is now a single cache HIT, and because a function-level memo hit short-
;; circuits before the body (and its own internal recursive evalZipTerm
;; calls on children) ever runs, no child subterm is touched again either:
;; exactly +1 hit, +0 misses -- the same shape of result as kernel-
;; memo.metta's evalCol (also memoized on the full expression) under the
;; identical two-pass check in correctness-harness-memo.metta.
!(println! (STATS after-first-pass (get-memoize-stats)))
!(evalZipTerm (get-state &parity3Rterm))
!(println! (STATS after-second-pass-expect-pure-hits (get-memoize-stats)))

;; === Table-switch staleness demo =============================================
;; (AND (A B)) is a valid formula against BOTH miniTable (4 rows) and
;; majority3Table (8 rows) since both tables have labels A and B -- but the
;; two tables carry different A/B data and different row counts.
!(setZipTable (miniTable))
!(invalidate-memoize evalZipTerm)
!(change-state! &andAbRterm (rewriteTreeCached (formulaAndAB)))
!(println! (RESULT-miniTable formulaAndAB (evalZipTerm (get-state &andAbRterm))))
;; populates evalZipTerm's cache for the materialized (zipWith and (col A)
;; (col B)) term against miniTable.

!(setZipTable (majority3Table))
;; Isolate the REWRITE-cache hit measurement: call rewriteTreeCached ALONE
;; (no evalZipTerm call yet) so this stats delta reflects only rewrite-cache
;; behavior -- deliberately NO invalidate-memoize of rewriteTreeCached
;; anywhere in this section (it is table-independent and needs none).
!(println! (STATS before-rewrite-after-table-switch (get-memoize-stats)))
!(change-state! &andAbRterm2 (rewriteTreeCached (formulaAndAB)))
!(println! (STATS after-rewrite-after-table-switch-expect-plus1-hit (get-memoize-stats)))
!(test (get-state &andAbRterm2) (quote (zipWith and (col A) (col B))))
;; Confirms the rewrite-cache HIT still returned the correct (table-
;; independent) materialized term even after the table switch, with no
;; clear ever touching &rewriteTermCache's lib_memo entry.

;; NO invalidate-memoize of evalZipTerm here -- deliberately demonstrate
;; eval-cache staleness against the NEW table.
!(println! (STALE-WITHOUT-CLEAR formulaAndAB (evalZipTerm (get-state &andAbRterm2))))
;; Expected (miniTable-era, WRONG for majority3Table): (False False False True)
;; evalZipTerm replays the stale 4-row miniTable column verbatim: it has no
;; way to know setZipTable silently changed the backing state, matching the
;; "memoized functions reading state serve STALE results after state
;; mutation" warning also demonstrated by kernel-memo.metta's evalCol.

!(invalidate-memoize evalZipTerm)
!(println! (CORRECT-AFTER-CLEAR formulaAndAB (evalZipTerm (get-state &andAbRterm2))))
;; Hand-computed majority3Table A/B columns (common/truth-tables.metta):
;;   A = (False False False False True  True  True  True )
;;   B = (False False True  True  False False True  True )
;;   AND(A,B) row-by-row: F,F,F,F,F,F,T,T
!(test (evalZipTerm (get-state &andAbRterm2)) (False False False False False False True True))
