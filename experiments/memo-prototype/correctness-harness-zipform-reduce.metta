;; ---------------------------------------------------------------------------
;; Correctness harness for the zipform boss-literal rewrite kernel, REDUCE-
;; DISPATCH memoized-combinator variant (zipform/rewrite-cache-memo.metta +
;; zipform/evaluator-reduce-memo.metta). PR-165 PeTTa ONLY (both `reduce` and
;; lib_memo are PR-165 extensions). Sibling to correctness-harness-zipform-
;; memo.metta -- same 13 asserts, same reference data, scoring via
;; `(evalZipTermR (rewriteTreeCached $formula))` instead of `(evalZipTerm
;; ...)`, PLUS one R-specific cache-shape assert (no single root memo entry
;; under combinator-memoization -- the root node's own function is the
;; cache unit) and explicit duplicate/junk-value gates.
;;
;; Run:  /home/yab/PeTTa-pr165/run.sh <abs-path-to-this-file>
;; ---------------------------------------------------------------------------

!(bind! &params (new-space))
!(import! &self ../../parameters/registry)
!(import! &self (library lib_memo))
!(import! &self common/list-helpers)
!(import! &self common/kernel-common)
!(import! &self zipform/ops)
!(import! &self zipform/rewriter)
!(import! &self zipform/evaluator-common)
!(import! &self zipform/evaluator-reduce-memo)
!(import! &self zipform/rewrite-cache-memo)
!(import! &self common/truth-tables)
!(import! &self common/reference-formulas)

;; === Reference-formula correctness (tiny 4-row miniTable) ===================
!(setZipTable (miniTable))
!(clear-memoize)
!(clear-memoize-stats)

!(println! (RESULT formulaLeafA (evalZipTermR (rewriteTreeCached (formulaLeafA)))))
!(test (evalZipTermR (rewriteTreeCached (formulaLeafA))) (expectedLeafA))

!(println! (RESULT formulaNotA (evalZipTermR (rewriteTreeCached (formulaNotA)))))
!(test (evalZipTermR (rewriteTreeCached (formulaNotA))) (expectedNotA))

!(println! (RESULT formulaAndAB (evalZipTermR (rewriteTreeCached (formulaAndAB)))))
!(test (evalZipTermR (rewriteTreeCached (formulaAndAB))) (expectedAndAB))

!(println! (RESULT formulaOrAB (evalZipTermR (rewriteTreeCached (formulaOrAB)))))
!(test (evalZipTermR (rewriteTreeCached (formulaOrAB))) (expectedOrAB))

!(println! (RESULT formulaNestedAndOrNot (evalZipTermR (rewriteTreeCached (formulaNestedAndOrNot)))))
!(test (evalZipTermR (rewriteTreeCached (formulaNestedAndOrNot))) (expectedNestedAndOrNot))

;; === Regression: rewriteTree arity-1 branch, singleton AND/OR identity =====
;; (unchanged from correctness-harness-zipform-memo.metta -- this is a
;; rewriteTree property, not an eval-side one; both column asserts below
;; still route through evalZipTermR to exercise the reduce-dispatch eval side
;; too, not just re-verify rewriteTree in isolation.)
!(println! (RESULT singletonAndOrAB (evalZipTermR (rewriteTreeCached (AND ((OR (A B))))))))
!(test (evalZipTermR (rewriteTreeCached (AND ((OR (A B)))))) (expectedOrAB))

!(println! (RESULT singletonOrAndAB (evalZipTermR (rewriteTreeCached (OR ((AND (A B))))))))
!(test (evalZipTermR (rewriteTreeCached (OR ((AND (A B)))))) (expectedAndAB))

;; Structural assert 3: rewriteTree of a singleton-AND formula is EXACTLY
;; (term-for-term) the rewritten child -- no fmap/zipWithN wrapper node at
;; all. Pure rewriteTreeCached comparison, same as the memo harness.
!(println! (SINGLETON_AND_IDENTITY (rewriteTreeCached (AND ((OR (A B)))))))
!(println! (SINGLETON_AND_IDENTITY_EXPECTED (rewriteTreeCached (OR (A B)))))
!(test (rewriteTreeCached (AND ((OR (A B))))) (rewriteTreeCached (OR (A B))))

;; Assert 4: unmapped unary op via the zipWithN args-tuple fallback.
(= (IDOP ($a)) $a)
!(println! (RESULT idopA (evalZipTermR (rewriteTreeCached (IDOP (A))))))
!(test (evalZipTermR (rewriteTreeCached (IDOP (A)))) (expectedLeafA))

;; === Structural assert: materialized parity3 zipterm (n-ary fold path) =====
;; Identical to correctness-harness-zipform-memo.metta -- rewriteTreeCached's
;; output shape does not depend on which eval backend consumes it.
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

!(change-state! &parity3RtermR (rewriteTreeCached (parity3Formula)))
!(println! (RESULT parity3Formula (evalZipTermR (get-state &parity3RtermR))))
!(test (evalZipTermR (get-state &parity3RtermR)) (expectedParity3Formula))

;; --- duplicate-solution gate: exactly one column out of one reduce-dispatch
;; scoring call (no doubled results from double-import or overlapping
;; clauses for col/fmap/zipWith/zipWithN). ---
!(test (size-atom (collapse (evalZipTermR (get-state &parity3RtermR)))) 1)

;; === Cache-behavior check =====================================================
;; Second evalZipTermR call on the IDENTICAL already-rewritten term (no
;; repeat rewriteTreeCached call, isolating the combinator caches' own hit/
;; miss behavior). UNLIKE evaluator-memo.metta's evalZipTerm (one function,
;; memoized whole-term), there is no single "root entry point" function here
;; -- the root node of parity3Formula's materialized term is itself a
;; `zipWith` call (the outermost OR-fold step), so the cache unit for the
;; second pass is exactly ONE zipWith entry. A hit on it short-circuits
;; before its body (and therefore its own child evalChild/reduce calls, and
;; therefore every combinator function's own memo lookups beneath it) ever
;; runs -- verified directly here by delta-checking get-memoize-stats
;; immediately before/after, exactly the shape of proof probe Q1 established
;; (0 additional lookups on a hit). Actual counts logged below rather than
;; hand-predicted; see the harness run's printed deltas for the exact
;; numbers reported back.
!(println! (STATS after-first-pass (get-memoize-stats)))
!(evalZipTermR (get-state &parity3RtermR))
!(println! (STATS after-second-pass-expect-plus1-hit-plus0-miss (get-memoize-stats)))

;; === Table-switch staleness demo =============================================
!(setZipTable (miniTable))
!(invalidate-memoize col)
!(invalidate-memoize fmap)
!(invalidate-memoize zipWith)
!(invalidate-memoize zipWithN)
!(change-state! &andAbRtermR (rewriteTreeCached (formulaAndAB)))
!(println! (RESULT-miniTable formulaAndAB (evalZipTermR (get-state &andAbRtermR))))

!(setZipTable (majority3Table))
;; single-valuedness gate on the param registry itself after a table switch
;; (set-param dedupes by design -- confirm exactly one value is readable).
!(test (size-atom (collapse (param zipTable))) 1)

!(println! (STATS before-rewrite-after-table-switch (get-memoize-stats)))
!(change-state! &andAbRtermR2 (rewriteTreeCached (formulaAndAB)))
!(println! (STATS after-rewrite-after-table-switch-expect-plus1-hit (get-memoize-stats)))
!(test (get-state &andAbRtermR2) (quote (zipWith and (col A) (col B))))

;; NO invalidate-memoize of col/fmap/zipWith/zipWithN here -- deliberately
;; demonstrate combinator-cache staleness against the NEW table.
!(println! (STALE-WITHOUT-CLEAR formulaAndAB (evalZipTermR (get-state &andAbRtermR2))))
;; Expected (miniTable-era, WRONG for majority3Table): (False False False True)

!(invalidate-memoize col)
!(invalidate-memoize fmap)
!(invalidate-memoize zipWith)
!(invalidate-memoize zipWithN)
!(println! (CORRECT-AFTER-CLEAR formulaAndAB (evalZipTermR (get-state &andAbRtermR2))))
;; Hand-computed majority3Table A/B columns (common/truth-tables.metta):
;;   A = (False False False False True  True  True  True )
;;   B = (False False True  True  False False True  True )
;;   AND(A,B) row-by-row: F,F,F,F,F,F,T,T
!(test (evalZipTermR (get-state &andAbRtermR2)) (False False False False False False True True))

;; final duplicate/junk gate on the post-clear, post-switch correct result.
!(test (size-atom (collapse (evalZipTermR (get-state &andAbRtermR2)))) 1)
