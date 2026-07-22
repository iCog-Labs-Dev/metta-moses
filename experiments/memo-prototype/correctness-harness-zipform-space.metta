;; ---------------------------------------------------------------------------
;; Correctness harness for the zipform boss-literal rewrite kernel, space
;; variant (zipform/rewrite-cache-space.metta + zipform/evaluator-
;; space.metta, both hand-rolled &space caches). Runs on BOTH runtimes -- no
;; lib_memo import.
;;
;; Run:  /home/yab/PeTTa-pr165/run.sh <abs-path-to-this-file>
;;   sh  /home/yab/PeTTaV1/run.sh    experiments/memo-prototype/correctness-harness-zipform-space.metta -s
;;
;; Assertions use the native `test` translator construct (same one used by
;; correctness-harness-memo.metta / correctness-harness-space.metta); it
;; prints "is X, should Y. <PASS/FAIL glyph>" and halts(1) on the first
;; failed comparison, so a clean run to the end means every assertion below
;; passed.
;;
;; Every formula is scored via `(evalZipTermCached (rewriteTreeCached
;; $formula))` against the SAME hand-computed expected columns common/
;; reference-formulas.metta already carries for the plain kernel harnesses --
;; zero new reference data, except the ONE new structural assert below (the
;; materialized parity3 zipterm), whose expected nesting is derived by hand
;; in a comment right above it (same derivation as the memo harness).
;;
;; DEVIATION FROM SPEC / IMPORT ORDER NOTE: see correctness-harness-zipform-
;; memo.metta's identical note -- the individual zipform/*.metta module
;; files do NOT self-import their common/list-helpers / common/kernel-common
;; / zipform/ops prerequisites, because this harness needs BOTH the rewrite
;; chain and the eval chain side by side and "import! does not dedupe"
;; (verified empirically: duplicate transitive imports corrupt `test`'s
;; single-value comparisons with duplicated solutions). This harness is the
;; single choke point that imports every shared leaf exactly once, in
;; dependency order, matching common/kernel-common.metta's own existing
;; zero-self-import convention.
;; ---------------------------------------------------------------------------

!(bind! &params (new-space))
!(import! &self ../../parameters/registry)
!(import! &self common/list-helpers)
!(import! &self common/kernel-common)
!(import! &self zipform/ops)
!(import! &self zipform/rewriter)
!(import! &self zipform/evaluator-common)
!(import! &self zipform/evaluator-space)
!(import! &self zipform/rewrite-cache-space)
!(import! &self common/truth-tables)
!(import! &self common/reference-formulas)

;; === Reference-formula correctness (tiny 4-row miniTable) ===================
!(setZipTable (miniTable))
!(resetZipCache)

!(println! (RESULT formulaLeafA (evalZipTermCached (rewriteTreeCached (formulaLeafA)))))
!(test (evalZipTermCached (rewriteTreeCached (formulaLeafA))) (expectedLeafA))

!(println! (RESULT formulaNotA (evalZipTermCached (rewriteTreeCached (formulaNotA)))))
!(test (evalZipTermCached (rewriteTreeCached (formulaNotA))) (expectedNotA))

!(println! (RESULT formulaAndAB (evalZipTermCached (rewriteTreeCached (formulaAndAB)))))
!(test (evalZipTermCached (rewriteTreeCached (formulaAndAB))) (expectedAndAB))

!(println! (RESULT formulaOrAB (evalZipTermCached (rewriteTreeCached (formulaOrAB)))))
!(test (evalZipTermCached (rewriteTreeCached (formulaOrAB))) (expectedOrAB))

!(println! (RESULT formulaNestedAndOrNot (evalZipTermCached (rewriteTreeCached (formulaNestedAndOrNot)))))
!(test (evalZipTermCached (rewriteTreeCached (formulaNestedAndOrNot))) (expectedNestedAndOrNot))

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
!(println! (RESULT singletonAndOrAB (evalZipTermCached (rewriteTreeCached (AND ((OR (A B))))))))
!(test (evalZipTermCached (rewriteTreeCached (AND ((OR (A B)))))) (expectedOrAB))

;; Column assert 2: (OR ((AND (A B)))) == AND(A,B) column (OR-singleton is
;; an identity over its AND child; AND(A,B) hand-computed as expectedAndAB
;; = (False False False True)).
!(println! (RESULT singletonOrAndAB (evalZipTermCached (rewriteTreeCached (OR ((AND (A B))))))))
!(test (evalZipTermCached (rewriteTreeCached (OR ((AND (A B)))))) (expectedAndAB))

;; Structural assert 3: rewriteTree of a singleton-AND formula is EXACTLY
;; (term-for-term) the rewritten child -- no fmap/zipWithN wrapper node
;; at all. Both sides go through rewriteTreeCached (a pure &space-cache
;; wrapper around rewriteTree, zipform/rewrite-cache-space.metta), so
;; neither side needs quoting: no literal zipWith/col/fmap/zipWithN
;; source form appears anywhere in this assert.
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
!(println! (RESULT idopA (evalZipTermCached (rewriteTreeCached (IDOP (A))))))
!(test (evalZipTermCached (rewriteTreeCached (IDOP (A)))) (expectedLeafA))

;; === Structural assert: materialized parity3 zipterm (n-ary fold path) =====
;; Same derivation as correctness-harness-zipform-memo.metta (parity3Formula
;; is (OR (t1 t2 t3 t4)), OR arity 4 and each AND arity 3, both >2 and
;; foldable, so BOTH levels exercise rewriteTree's foldr1 path):
;;
;; foldr1(fn, (c1 c2 c3 c4)) = (zipWith fn c1 (zipWith fn c2 (zipWith fn c3 c4)))
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
!(resetZipCache)

!(change-state! &parity3Rterm (rewriteTreeCached (parity3Formula)))
!(println! (RESULT parity3Formula (evalZipTermCached (get-state &parity3Rterm))))
!(test (evalZipTermCached (get-state &parity3Rterm)) (expectedParity3Formula))

;; === Cache-behavior check =====================================================
;; Evaluate the SAME already-rewritten term twice; the first pass above
;; already populated &zipSubtermCache for every distinct subtree, so this
;; repeat must be pure hits.
!(println! (STATS after-first-pass (getZipSpaceStats)))
!(evalZipTermCached (get-state &parity3Rterm))
!(println! (STATS after-second-pass-expect-pure-hits (getZipSpaceStats)))

;; === Table-switch staleness demo =============================================
;; (AND (A B)) is a valid formula against BOTH miniTable (4 rows) and
;; majority3Table (8 rows) since both tables have labels A and B -- but the
;; two tables carry different A/B data and different row counts.
!(setZipTable (miniTable))
!(resetZipCache)
!(change-state! &andAbRterm (rewriteTreeCached (formulaAndAB)))
!(println! (RESULT-miniTable formulaAndAB (evalZipTermCached (get-state &andAbRterm))))
;; populates &zipSubtermCache for the materialized (zipWith and (col A) (col
;; B)) term against miniTable; ALSO populates &rewriteTermCache for the
;; ground key (rewritten (AND (A B)) ...) -- this entry is never touched
;; again below.

!(setZipTable (majority3Table))
;; Isolate the REWRITE-cache hit measurement: entry count in
;; &rewriteTermCache must NOT grow from calling rewriteTreeCached again on
;; the identical formula (a hit reuses the existing entry; a miss would add
;; a second one) -- deliberately no reset function exists for this cache at
;; all (see zipform/rewrite-cache-space.metta), so nothing could clear it
;; even if we wanted to.
!(let $before (List.length (collapse (match &rewriteTermCache $e $e)))
   (println! (REWRITE-CACHE-ENTRY-COUNT before-table-switch-rewrite $before)))
!(change-state! &andAbRterm2 (rewriteTreeCached (formulaAndAB)))
!(let $after (List.length (collapse (match &rewriteTermCache $e $e)))
   (println! (REWRITE-CACHE-ENTRY-COUNT after-table-switch-rewrite-expect-same $after)))
!(test (get-state &andAbRterm2) (quote (zipWith and (col A) (col B))))
;; Confirms the rewrite-cache HIT still returned the correct (table-
;; independent) materialized term even after the table switch, with no
;; reset ever touching &rewriteTermCache.

;; NO resetZipCache here -- deliberately demonstrate eval-cache staleness
;; against the NEW table.
!(println! (STALE-WITHOUT-RESET formulaAndAB (evalZipTermCached (get-state &andAbRterm2))))
;; Expected (miniTable-era, WRONG for majority3Table): (False False False True)
;; &zipSubtermCache replays the stale 4-row miniTable column verbatim: the
;; cache is keyed purely by the ground materialized term, with no knowledge
;; that setZipTable silently changed the backing state -- the same
;; staleness hazard as kernel-space.metta's evalColCached.

!(resetZipCache)
!(println! (CORRECT-AFTER-RESET formulaAndAB (evalZipTermCached (get-state &andAbRterm2))))
;; Hand-computed majority3Table A/B columns (common/truth-tables.metta):
;;   A = (False False False False True  True  True  True )
;;   B = (False False True  True  False False True  True )
;;   AND(A,B) row-by-row: F,F,F,F,F,F,T,T
!(test (evalZipTermCached (get-state &andAbRterm2)) (False False False False False False True True))
