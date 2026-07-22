;; ---------------------------------------------------------------------------
;; Probe 1 (zipform Phase 1, probe gate). Two claims:
;;
;; (A) A MINIMAL inline rewriter can turn the wrapped candidate shape
;;     (AND (x (OR (y z)))) into the materialized zipWith term
;;     (zipWith and (col x) (zipWith or (col y) (col z))).
;;
;; (B) THE CRITICAL CLAIM: the rewriter's `cons`-built output stays INERT
;;     data even once zipWith/col become LIVE clause heads elsewhere in the
;;     same file (the condition that will hold in the real modules).
;;
;; Order-of-definition hazard this probe is designed around (discovered
;; while building it, see scratch probes probe-order-check{2,5,6}.metta):
;; PeTTa/PeTTaV1 do a WHOLE-FILE prescan of every `(= (Head ...) ...)` head
;; defined ANYWHERE in the file (regardless of textual order) to decide, at
;; TRANSLATION time, whether a literal nested `(Head ...)` occurrence
;; compiles to a Prolog goal call `Head(Args...,Result)` or stays plain
;; literal data. So: a symbol with ZERO clauses anywhere in the file (AND,
;; OR here) always compiles its literal occurrences as inert data (no
;; `quote`/`cons` needed -- matches probe-expr-key.metta's working idiom).
;; But a symbol that IS defined SOMEWHERE in the file (zipWith/col in
;; Section B below) has EVERY literal occurrence of that head anywhere in
;; the file compiled as a goal call -- including inside another clause's
;; body defined earlier in the file (confirmed: a plain-literal `expected`
;; clause written before the zipWith def below hard-errors with "Unknown
;; procedure: zipWith/4" when queried before that line executes, because
;; translation already treated its body as a goal call). Two independent
;; fixes sidestep this: `cons`-building (what the real rewriter must use,
;; since it needs runtime substructure) and `(quote ...)` (works for a
;; static literal target, used for `expected` below). Both were verified to
;; stay literal/inert regardless of where in the file the live def appears.
;; ---------------------------------------------------------------------------

;; --- op-symbol lookup table (source-language op -> data-language functor) --
(= (opSym AND) and)
(= (opSym OR) or)
(= (opSym NOT) not)

(= (isLeaf $e) (== (get-metatype $e) Symbol))

;; --- minimal recursive rewriter: wrapped tree -> materialized zip term -----
;; Node shape (uniform, same convention as combineOp in common/kernel-common
;; and scoring/fitness.metta): ($op ($c1 $c2 .. $ck)). if-chain on children
;; count (size-atom); only the 2-child (binary AND/OR) case is exercised by
;; this probe's target shape, so that is the only arm built out. Every
;; constructed node uses `cons`, never a literal (zipWith ...)/(col ...)
;; form in source position, so nothing here depends on whether those heads
;; are live.
(= (zipRewrite $e)
   (if (isLeaf $e)
       (cons col (cons $e ()))
       (let ($op $children) $e
         (if (== (size-atom $children) 2)
             (cons zipWith
                   (cons (opSym $op)
                         (cons (zipRewrite (index-atom $children 0))
                               (cons (zipRewrite (index-atom $children 1)) ()))))
             (Error $e "zipRewrite: unsupported child count (probe only covers arity 2)")))))

;; Independent oracle for the target shape, built via `quote` (not by
;; calling zipRewrite) so the test isn't a tautology, and immune to the
;; order hazard above regardless of where Section B's live defs land.
(= (expected) (quote (zipWith and (col x) (zipWith or (col y) (col z)))))

;; =====================  Section A: correctness  ============================
;; AND/OR are NOT defined anywhere in this file, so the raw literal input
;; below stays inert data at the call site with no wrapping needed.
!(println! (SECTION_A_OUTPUT (zipRewrite (AND (x (OR (y z)))))))
!(println! (SECTION_A_EXPECTED (expected)))
!(test (zipRewrite (AND (x (OR (y z))))) (expected))

;; =====================  Section B: inertness-under-definition  =============
;; Now make zipWith AND col LIVE heads -- the real-module condition.
(= (zipWith $f $a $b) FIRED)
(= (col $x) FIRED)

;; Sanity check the FIRED clauses actually work on a literal written AFTER
;; the definitions (so the inertness test below isn't vacuously true).
!(println! (SECTION_B_SANITY (zipWith and (col x) (col x))))
!(test (zipWith and (col x) (col x)) FIRED)

;; The critical claim: same zipRewrite function, same input, re-run AFTER
;; zipWith/col are live -- must STILL equal the structured term, not FIRED.
!(println! (SECTION_B_INERTNESS (zipRewrite (AND (x (OR (y z)))))))
!(test (zipRewrite (AND (x (OR (y z))))) (expected))

;; `expected` itself must also still be the structured term post-Section-B
;; (proves `quote` is equally immune to the live-def hazard).
!(println! (SECTION_B_EXPECTED_STILL_INERT (expected)))
!(test (expected) (quote (zipWith and (col x) (zipWith or (col y) (col z)))))
