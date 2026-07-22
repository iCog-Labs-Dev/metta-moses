;; ---------------------------------------------------------------------------
;; Correctness harness for the zipform kernel, variant G ("generic ops":
;; zipform/ops-generic.metta defines AND/OR/NOT at their row arity and the
;; rewriter passes the op symbol straight through -- rowFnTable-free).
;; PR-165 PeTTa ONLY (lib_memo). Mirrors correctness-harness-zipform-memo
;; .metta assertion-for-assertion; the differences are ALL a consequence of
;; ops-generic.metta giving AND/OR/NOT clauses:
;;   1. imports zipform/ops-generic + zipform/rewriter-generic (not ops/
;;      rewriter) and common/reference-formulas-quoted (not the unquoted one);
;;   2. every inline candidate literal `(AND ...)` / `(OR ...)` is `quote`d,
;;      else it compiles to a grounded partial before the rewriter sees it;
;;   3. the materialized-term STRUCTURAL asserts expect the op SYMBOLS
;;      AND/OR/NOT in the emitted term (variant M/the plain rewriter emit the
;;      builtins and/or/not via rowFnTable; variant G emits the ops directly);
;;   4. the custom unary-op assert defines IDOP at SCALAR arity `(= (IDOP $a)
;;      $a)` (variant G fmaps a unary op over the column, applying it per
;;      cell) rather than the args-tuple `(= (IDOP ($a)) $a)` the zipWithN
;;      path needed.
;;
;; Run:  /home/yab/PeTTa-pr165/run.sh <abs-path-to-this-file>
;; A clean run to the end = every `test` passed (it halts(1) on first FAIL).
;; ---------------------------------------------------------------------------

!(bind! &params (new-space))
!(import! &self ../../parameters/registry)
!(import! &self (library lib_memo))
!(import! &self common/list-helpers)
!(import! &self common/kernel-common)
!(import! &self zipform/ops-generic)
!(import! &self zipform/rewriter-generic)
!(import! &self zipform/evaluator-dispatch)
!(import! &self zipform/rewrite-cache-memo)
!(import! &self common/truth-tables)
!(import! &self common/reference-formulas-quoted)

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
;; Inline candidates are `quote`d (ops-generic defines AND/OR, so a bare
;; literal would compile to a partial). (AND ((OR (A B)))) is a singleton-AND
;; identity over its OR child, so it must equal the OR(A,B) column.
!(println! (RESULT singletonAndOrAB (evalZipTerm (rewriteTreeCached (quote (AND ((OR (A B)))))))))
!(test (evalZipTerm (rewriteTreeCached (quote (AND ((OR (A B))))))) (expectedOrAB))

!(println! (RESULT singletonOrAndAB (evalZipTerm (rewriteTreeCached (quote (OR ((AND (A B)))))))))
!(test (evalZipTerm (rewriteTreeCached (quote (OR ((AND (A B))))))) (expectedAndAB))

;; Structural assert: rewriteTree of a singleton-AND formula is EXACTLY the
;; rewritten child -- no wrapper node at all.
!(println! (SINGLETON_AND_IDENTITY (rewriteTreeCached (quote (AND ((OR (A B))))))))
!(println! (SINGLETON_AND_IDENTITY_EXPECTED (rewriteTreeCached (quote (OR (A B))))))
!(test (rewriteTreeCached (quote (AND ((OR (A B)))))) (rewriteTreeCached (quote (OR (A B)))))

;; Custom unary op via the fmap path (variant G: a unary non-monoid op is
;; fmapped over the column, applied per cell -- so IDOP is defined at SCALAR
;; arity). (IDOP (A)) rewrites to (fmap IDOP (col A)); IDOP(cell)=cell, so the
;; result is the plain A column.
(= (IDOP $a) $a)
!(println! (RESULT idopA (evalZipTerm (rewriteTreeCached (quote (IDOP (A)))))))
!(test (evalZipTerm (rewriteTreeCached (quote (IDOP (A))))) (expectedLeafA))

;; === Structural assert: materialized parity3 zipterm (n-ary fold path) =====
;; Same nesting as the memo harness, but the emitted row functions are the op
;; SYMBOLS AND/OR/NOT (variant G passes the op through) rather than the
;; builtins and/or/not. `quote`d (zipWith/col/fmap are live evaluator heads,
;; and AND/OR/NOT are now defined too).
(= (expectedParity3Zipterm)
   (quote
     (zipWith OR
       (zipWith AND (col X1) (zipWith AND (fmap NOT (col X2)) (fmap NOT (col X3))))
       (zipWith OR
         (zipWith AND (fmap NOT (col X1)) (zipWith AND (col X2) (fmap NOT (col X3))))
         (zipWith OR
           (zipWith AND (fmap NOT (col X1)) (zipWith AND (fmap NOT (col X2)) (col X3)))
           (zipWith AND (col X1) (zipWith AND (col X2) (col X3))))))))

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

;; === Cache-behavior check ==================================================
;; Second evalZipTerm on the IDENTICAL already-rewritten term: exactly +1 hit,
;; +0 misses (a function-level memo hit short-circuits before the body runs).
!(println! (STATS after-first-pass (get-memoize-stats)))
!(evalZipTerm (get-state &parity3Rterm))
!(println! (STATS after-second-pass-expect-pure-hits (get-memoize-stats)))

;; === Table-switch staleness demo ===========================================
!(setZipTable (miniTable))
!(invalidate-memoize evalZipTerm)
!(change-state! &andAbRterm (rewriteTreeCached (formulaAndAB)))
!(println! (RESULT-miniTable formulaAndAB (evalZipTerm (get-state &andAbRterm))))

!(setZipTable (majority3Table))
!(println! (STATS before-rewrite-after-table-switch (get-memoize-stats)))
!(change-state! &andAbRterm2 (rewriteTreeCached (formulaAndAB)))
!(println! (STATS after-rewrite-after-table-switch-expect-plus1-hit (get-memoize-stats)))
;; rewrite-cache HIT still returns the correct (table-independent) term; note
;; the emitted row fn is the SYMBOL AND (variant G), not the builtin and.
!(test (get-state &andAbRterm2) (quote (zipWith AND (col A) (col B))))

;; Stale eval-cache demo (no invalidate): replays the miniTable-era column.
!(println! (STALE-WITHOUT-CLEAR formulaAndAB (evalZipTerm (get-state &andAbRterm2))))

!(invalidate-memoize evalZipTerm)
!(println! (CORRECT-AFTER-CLEAR formulaAndAB (evalZipTerm (get-state &andAbRterm2))))
;;   A = (F F F F T T T T) ; B = (F F T T F F T T) ; AND = F,F,F,F,F,F,T,T
!(test (evalZipTerm (get-state &andAbRterm2)) (False False False False False False True True))

;; === zipWithN path coverage (genuine n-ary NON-monoid op) ==================
;; The evaluator's zipWithN + transposeCols per-row-tuple dispatch is otherwise
;; asserted by nothing (AND/OR fold via foldr1->zipWith; NOT via fmap). AND3 is
;; a real ternary defined args-tuple style (= (AND3 ($a $b $c)) ...), so it is
;; NOT a monoid and rewrites to (zipWithN AND3 ((col X1)(col X2)(col X3))),
;; exercising that path. Its column must equal the monoid AND fold of the same
;; three columns (X1 & X2 & X3). Uses parity3Table (has labels X1 X2 X3).
!(setZipTable (parity3Table))
!(invalidate-memoize evalZipTerm)
(= (AND3 ($a $b $c)) (and $a (and $b $c)))
!(println! (ZIPWITHN_and3_term (rewriteTreeCached (quote (AND3 (X1 X2 X3))))))
!(println! (ZIPWITHN_and3_col  (evalZipTerm (rewriteTreeCached (quote (AND3 (X1 X2 X3)))))))
!(test (evalZipTerm (rewriteTreeCached (quote (AND3 (X1 X2 X3)))))
       (evalZipTerm (rewriteTreeCached (quote (AND (X1 X2 X3))))))
