;; ===========================================================================
;; TUTORIAL / START-HERE: the zipform kernel, VARIANT G (generic ops), end to
;; end on a table you can read. Every example we discussed lives here.
;;
;; Run:  /home/yab/PeTTa-pr165/run.sh <abs-path-to-this-file>       (PR-165 only)
;; Then read the STEP*/SECTION* lines in the output top to bottom.
;;
;; VARIANT G in one sentence: AND/OR/NOT (and any new op) are DEFINED at their
;; row arity, and the rewriter passes the op symbol straight into
;; (zipWith $op ...) / (fmap $op ...) -- there is NO rowFnTable. The price is a
;; QUOTE regime: because the ops are defined, every literal (AND ...) etc. in
;; this file is wrapped in `quote` so it stays clean candidate DATA instead of
;; compiling to a grounded `partial(...)` (see zipform/ops-generic.metta's
;; header for the translator mechanism). Miss a quote -> silent corruption.
;; ===========================================================================

!(bind! &params (new-space))
!(import! &self ../../parameters/registry)
!(import! &self (library lib_memo))
!(import! &self common/list-helpers)
!(import! &self common/kernel-common)
!(import! &self zipform/ops-generic)
!(import! &self zipform/rewriter-generic)
!(import! &self zipform/evaluator-dispatch)
!(import! &self zipform/rewrite-cache-memo)

;; A 4-row truth table, row-major, one row per line, target column (Out) LAST.
;;   x     y     z     Out
;;   True  True  True  True
;;   False True  False False
;;   True  False False False
;;   False False True  False
;; => columns:  x = (T F T F)   y = (T T F F)   z = (T F F T)
(= (demoTable) (mkITable
                 (
                   (True  True  True  True)
                   (False True  False False)
                   (True  False False False)
                   (False False True  False)) (x y z Out)))

;; Install the table once (stores it + row count 4 in the param registry that
;; evalZipTerm reads) and start with an empty cache.
!(setZipTable (demoTable))
!(clear-memoize)
!(clear-memoize-stats)

;; ===========================================================================
;; SECTION A -- the core pipeline on the boss's candidate: lambda x y z .
;; and(x, or(y, z)), in the wrapped shape (AND (x (OR (y z)))). Scoring is
;; always the SAME two composed calls:  (evalZipTerm (rewriteTreeCached CAND)).
;; ===========================================================================

;; STEP 1 -- the input candidate as the pipeline represents it (quoted).
!(println! (STEP1_candidate (quote (AND (x (OR (y z)) z)))))

;; STEP 2 -- PREPROCESSING REWRITE: rewriteTreeCached materializes the
;; candidate as an explicit zipWith term. Pure data; the table is untouched.
;; Note the emitted row functions are the op SYMBOLS AND/OR (variant G), not
;; the builtins and/or. 3 children -> foldr1 nested binary.
!(println! (STEP2_rewritten_term (rewriteTreeCached (quote (AND (x (OR (y z)) z))))))

;; STEP 3 -- a leaf: a bare label rewrites to (col <label>); evaluating it
;; extracts that column from the table.
!(println! (STEP3_column_x (evalZipTerm (rewriteTreeCached (quote x)))))
!(println! (STEP3_column_y (evalZipTerm (rewriteTreeCached (quote y)))))
!(println! (STEP3_column_z (evalZipTerm (rewriteTreeCached (quote z)))))

;; STEP 4 -- the boss's helper "(zipWith or coly colz)": scoring (OR (y z))
;; zips columns y and z with OR.  y=(T T F F) z=(T F F T) -> (T T F T)
!(println! (STEP4_helper_or_y_z (evalZipTerm (rewriteTreeCached (quote (OR (y z)))))))

;; STEP 5 -- the 2-child candidate (AND (x (OR (y z)))). The cache already
;; holds (col x)/(col y)/(col z) and the whole (zipWith OR ...) subterm from
;; steps 3-4, so this computes only ONE new thing: the outer zipWith AND.
;; x=(T F T F) & helper(T T F T) -> (T F F F)
!(println! (STEP5_full_column (evalZipTerm (rewriteTreeCached (quote (AND (x (OR (y z)))))))))

;; STEP 6 -- the cache so far (this is a GLOBAL lib_memo pool across BOTH the
;; rewrite cache and the eval cache -- both rewriteTreeCached and evalZipTerm
;; are memoized -- so the totals mix the two; that is expected, not a bug).
!(println! (STEP6_stats (get-memoize-stats)))

;; STEP 7 -- subterm sharing across candidates: a DIFFERENT candidate,
;; (NOT ((OR (y z)))), contains the SAME inner (OR (y z)) subterm and must HIT
;; the cached helper column, computing only the outer NOT.
!(println! (STEP7_sharing (rewriteTreeCached (quote (NOT ((OR (y z))))))))
!(println! (STEP7_sharing (evalZipTerm (rewriteTreeCached (quote (NOT ((OR (y z)))))))))
!(println! (STEP8_stats_after (get-memoize-stats)))

;; ===========================================================================
;; SECTION B -- UNARY op (NOT) via the fmap path (generic, not hardcoded to
;; NOT: any unary op defined at scalar arity flows through (fmap $op child)).
;; (NOT (y)) -> (fmap NOT (col y)); not(T T F F) = (F F T T)
;; ===========================================================================
!(println! (SECTIONB_not_term   (rewriteTreeCached (quote (NOT (y))))))
!(println! (SECTIONB_not_column (evalZipTerm (rewriteTreeCached (quote (NOT (y)))))))

;; ===========================================================================
;; SECTION C -- N-ARY MONOID op: AND is associative + identity True, so the
;; rewriter folds any arity into nested BINARY zipWith terms (foldr1), and the
;; degenerate arities are principled.
;; ===========================================================================
;; arity 3: (AND (x y z)) -> (zipWith AND (col x) (zipWith AND (col y) (col z)))
;;   x&y&z = (T F T F)&(T T F F)&(T F F T) = (T F F F)
!(println! (SECTIONC_and3_term   (rewriteTreeCached (quote (AND (x y z))))))
!(println! (SECTIONC_and3_column (evalZipTerm (rewriteTreeCached (quote (AND (x y z)))))))
;; arity 1: (AND (x)) is a semantic IDENTITY -> just the child, no wrapper.
!(println! (SECTIONC_and1_identity (rewriteTreeCached (quote (AND (x))))))
;; arity 0: (AND ()) -> the mempty identity column (all True).
!(println! (SECTIONC_and0_mempty (evalZipTerm (rewriteTreeCached (quote (AND ()))))))

;; ===========================================================================
;; SECTION D -- XOR, a first-class MONOID op. XOR lives entirely in
;; zipform/ops-generic.metta: its binary row-fn clause `(= (XOR $a $b) ...)`
;; PLUS its (monoids) + (memptyTable) registration (identity False). ADDING AN
;; OP is exactly that: for a plain binary op, ONE row-fn clause; for a foldable
;; n-ary op like XOR, that clause + the two registration lines -- and the
;; rewriter/evaluator never change. Because XOR is a registered monoid, an
;; n-ary (XOR (a b c)) FOLDS via foldr1 into nested binary zipWith terms and
;; never reaches the zipWithN path. Candidates must be quoted as usual.
;; ===========================================================================
;; binary: (XOR (x y)) -> (zipWith XOR (col x) (col y)); x=(T F T F) y=(T T F F) -> (F T T F)
!(println! (SECTIOND_xor2_term   (rewriteTreeCached (quote (XOR (x y))))))
!(println! (SECTIOND_xor2_column (evalZipTerm (rewriteTreeCached (quote (XOR (x y)))))))
;; n-ary (monoid fold, NOT zipWithN): (XOR (x y z)) ->
;;   (zipWith XOR (col x) (zipWith XOR (col y) (col z))) = parity(x,y,z) = (T T T T)
!(println! (SECTIOND_xor3_term   (rewriteTreeCached (quote (XOR (x y z))))))
!(println! (SECTIOND_xor3_column (evalZipTerm (rewriteTreeCached (quote (XOR (x y z)))))))
;; composes with AND/OR for free: (AND ((XOR (x y)) (OR (y z))))
!(println! (SECTIOND_xor_nested  (evalZipTerm (rewriteTreeCached (quote (AND ((XOR (x y)) (OR (y z)))))))))

;; ===========================================================================
;; SECTION E -- GENUINE N-ARY NON-MONOID op via the zipWithN path. A real
;; ternary AND3 (not a binary fold) goes through zipWithN, which transposes
;; the child columns into per-row TUPLES and applies (AND3 <rowTuple>). The op
;; must therefore be defined to take a SINGLE TUPLE arg (args-tuple
;; convention), NOT three separate args:
;;    (= (AND3 ($a $b $c)) ...)   <-- correct (tuple)
;;    (= (AND3 $a $b $c) ...)     <-- WRONG here: zipWithN hands it one tuple,
;;                                    so it partial-applies and corrupts.
;; (See the discussion on a future `applyRow` spread that would let the
;; natural 3-arg shape work too.)
;; ===========================================================================
(= (AND3 ($a $b $c)) (and $a (and $b $c)))
;; (AND3 (x y z)) -> (zipWithN AND3 ((col x) (col y) (col z))); = x&y&z = (T F F F)
!(println! (SECTIONE_and3_term   (rewriteTreeCached (quote (AND3 (x y z))))))
!(println! (SECTIONE_and3_column (evalZipTerm (rewriteTreeCached (quote (AND3 (x y z)))))))
