;; ---------------------------------------------------------------------------
;; Probe gate for the "reduce-dispatch, memoized combinators" backend
;; (variant R). PR-165 PeTTa ONLY (both `reduce` and lib_memo are PR-165
;; extensions). Do NOT build zipform/evaluator-reduce-memo.metta until every
;; assertion below passes.
;;
;; Q1 (THE LINCHPIN, memoize-on-unevaluated-args): a memoized 3-ary
;; combinator (zipWithP) is dispatched via `(reduce $t)` on a cons-built,
;; UNEVALUATED term, so its $a/$b parameters bind to raw unreduced subterms
;; (e.g. `(col x)` stored as a plain data list, never fired as a call,
;; exactly the shape rewriteTree emits). Question: does lib_memo key on
;; those raw structural args (so a second call with a STRUCTURALLY
;; IDENTICAL cons-built subterm is a cache HIT), and does a HIT skip the
;; body entirely (hence skip the body's own child-`reduce` calls, so the
;; children are never touched again)? Proven two ways: (a) lib_memo's own
;; get-memoize-stats delta, (b) an independent side-effect counter
;; (&colLookupCount, incremented only when `col`'s own clause body actually
;; runs) that must NOT increase between call 1 and call 2.
;;
;; Q2 (reduce-inside-memoized-body): does `(reduce $x)` -- called on a
;; plain function-parameter variable, inside a MEMOIZED function's own
;; clause body -- dispatch correctly? Source-level corroboration already
;; found in /home/yab/PeTTa-pr165/src/translator.pl: `reduce([F|Args], Out)`
;; calls `resolve_runtime_call(F, Args, Out, Goal)`, which explicitly tries
;; `metta_try_dispatch_call/4` (lib_memo's own hook) FIRST and only falls
;; back to a direct call if that hook doesn't apply -- so `reduce` on a
;; memoized function's OWN dispatch also goes through the cache. This probe
;; is the empirical confirmation (zipWithP's body's `(reduce $a)`/`(reduce
;; $b)` calls dispatch to `col`'s clause correctly in Q1 above, AND
;; zipWithP's own top-level dispatch, reached via `(reduce $t)`, is itself
;; memoized -- both directions exercised by Q1's two calls).
;;
;; Q3 (zipWithN idiom): `map-atom` + per-child `reduce` for an n-ary
;; combinator holding its children as ONE args-tuple parameter, plus the
;; Grounded-guard helper `evalChild` needed because `(reduce <Grounded
;; atom>)` does not do what a naive column-consumer wants (see standalone
;; check below) -- constant-leaf children (True/False, parsed to Prolog
;; true/false, metatype Grounded per metta.pl:178-179) must be broadcast
;; via List.repeat instead of reduced.
;; ---------------------------------------------------------------------------

!(import! &self ../common/list-helpers)
!(import! &self (library lib_memo))

;; --- tiny 4-row column data (data head `col`, given ONE clause below; used
;; purely as a data-tag inside cons-built terms elsewhere, never written as
;; a literal `(col x)` call at a term-construction site -- matches the
;; convention already verified in probe-zip-reduce-groundterm.metta / probe-
;; zip-memo-subterm-key.metta) ------------------------------------------------
!(change-state! &colLookupCount 0)
(= (colData x) (cons True (cons False (cons True (cons False ())))))
(= (colData y) (cons True (cons True (cons False (cons False ())))))
(= (col $label)
   (let $_ (change-state! &colLookupCount (+ 1 (get-state &colLookupCount)))
     (colData $label)))

;; =====================  Q1 + Q2: memoized zipWithP  =========================
!(memoize zipWithP 3)
(= (zipWithP $f $a $b)
   (let* (($av (reduce $a)) ($bv (reduce $b)))
     (List.zipWith $f $av $bv)))

;; Cons-built (never literal) so $a/$b arrive at zipWithP UNEVALUATED, exactly
;; the shape zipform/rewriter.metta materializes -- (cons col (cons x ())) is
;; the raw two-element list [col, x], not a fired call.
(= (flatTermQ1)
   (cons zipWithP (cons and (cons (cons col (cons x ())) (cons (cons col (cons y ())) ())))))

(= (expectedQ1) (True False False False))

!(clear-memoize)
!(clear-memoize-stats)

;; --- call 1: MISS (first time this structural key is seen) -----------------
!(let $t (flatTermQ1) (println! (Q1_CALL1_RESULT (reduce $t))))
!(println! (Q1_STATS_AFTER_CALL1 (get-memoize-stats)))
!(println! (Q1_COLCOUNT_AFTER_CALL1 (get-state &colLookupCount)))

;; --- call 2: structurally IDENTICAL cons-built args -> must be a cache HIT,
;; and &colLookupCount must be UNCHANGED (children never re-reduced on a hit)
!(let $t (flatTermQ1) (println! (Q1_CALL2_RESULT (reduce $t))))
!(println! (Q1_STATS_AFTER_CALL2 (get-memoize-stats)))
!(println! (Q1_COLCOUNT_AFTER_CALL2_MUST_MATCH_CALL1 (get-state &colLookupCount)))

;; correctness (not just cache mechanics)
!(let $t (flatTermQ1) (test (reduce $t) (expectedQ1)))

;; explicit single-valuedness gate (no duplicate solutions from double-import
;; or overlapping clauses): exactly one column for one reduce call.
!(let $t (flatTermQ1) (test (size-atom (collapse (reduce $t))) 1))

;; =====================  Q3: Grounded-guard + zipWithN idiom  =================
;; standalone check: reduce of a bare Grounded atom, THROUGH A LET-BOUND VAR
;; (a literal `(reduce True)` -- Expr not a variable at translation time --
;; is rejected by the translator's own `reduce` special-case with a syntax
;; error before the program even runs; confirmed separately, not asserted
;; here since a syntax error aborts the whole file). True parses to Prolog
;; `true` (metta.pl:178), metatype Grounded; through a let-bound var (the
;; only form `reduce` accepts, and exactly what evalChild's own $c parameter
;; below receives at runtime), reduce's Prolog clause `reduce([F|Args], Out)
;; :- nonvar(F), atom(F), fun(F) -> ...` requires its argument to unify with
;; `[F|Args]` (a non-empty list) -- a bare atom does NOT unify with that
;; shape, so this must fall to reduce's Case 3 ("leave unevaluated") -- but
;; Case 3 also expects `[F|Args]`, so the actual runtime behavior for a
;; non-list Grounded value is the open question this checks.
!(println! (Q3_REDUCE_ON_LETBOUND_GROUNDED_TRUE (let $c True (reduce $c))))

;; evalChild: the ONE guard helper every combinator's child-handling routes
;; through -- Grounded child -> broadcast (List.repeat rowCount); else ->
;; reduce it for real.
(= (evalChild $rows $c)
   (if (== (get-metatype $c) Grounded)
       (List.repeat $rows $c)
       (reduce $c)))

;; zipWithNP: n-ary combinator, children held as ONE args-tuple; each child
;; is resolved through evalChild via map-atom (never List.zipWith directly on
;; unreduced children -- the cons-pattern unification trap documented in
;; probe-zip-reduce-groundterm.metta Part 1).
!(memoize zipWithNP 2)
(= (zipWithNP $op $children)
   (let $cols (map-atom $children $c (evalChild 4 $c))
     (transposeColsP $op $cols)))

(= (transposeColsP $op $cols)
   (if (== (car-atom $cols) ())
       ()
       (cons ($op (map-atom $cols $cc (car-atom $cc)))
             (transposeColsP $op (map-atom $cols $cc (cdr-atom $cc))))))

;; row-level op: 3-ary AND over a row-tuple, mixing a real column child (col
;; x), a real column child (col y), and a CONSTANT Grounded leaf child (True)
;; -- exercises both evalChild branches in the same node.
(= (and3 ($a $b $c)) (and $a (and $b $c)))

(= (nAryTermQ3)
   (cons zipWithNP (cons and3 (cons (cons (cons col (cons x ())) (cons (cons col (cons y ())) (cons True ()))) ()))))

;; expected: colX=(T F T F), colY=(T T F F), constant True broadcast to
;; (T T T T) over 4 rows -- and3 row-by-row: T&T&T=T, F&T&T=F, T&F&T=F,
;; F&F&T=F
(= (expectedQ3) (True False False False))

!(clear-memoize)
!(clear-memoize-stats)
!(change-state! &colLookupCount 0)
!(let $t (nAryTermQ3) (println! (Q3_RESULT (reduce $t))))
!(let $t (nAryTermQ3) (test (reduce $t) (expectedQ3)))
!(let $t (nAryTermQ3) (test (size-atom (collapse (reduce $t))) 1))

;; junk-value gate: no `partial(...)` wrapper anywhere in these results (the
;; documented arity-mismatch corruption signature) -- grepped from the run
;; log by the harness-runner, not assertable in-language, so this comment is
;; the marker for that external check.
