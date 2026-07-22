;; ---------------------------------------------------------------------------
;; Probe 4 (zipform Phase 1, probe gate). PeTTaV1 ONLY -- (reduce $var) is a
;; PeTTaV1 extension (translator.pl's var(Expr) branch; see
;; ci-stock-petta-divergence). Builds the nested zipWith term via `cons`,
;; defines real zipWith/col resolution against a tiny 2-column 4-row table,
;; and evaluates it via `(reduce $term)`-style dispatch (the convention
;; production evalRow uses at scoring/fitness.metta:149-151, always on a
;; let-bound variable, never a nested call expression -- `(reduce (foo))`
;; written directly does NOT work, see PITFALL note below).
;;
;; QUESTION ANSWERED: reduce is HEAD-ONLY / single-dispatch. Given $t bound
;; to a cons-built term, `(reduce $t)` finds the ONE clause matching $t's
;; head, and evaluates that clause's body NORMALLY -- any calls the body
;; ITSELF makes (including nested `(reduce $child)` calls IT explicitly
;; writes) run for real, but $t's raw, unevaluated child sub-terms are
;; handed to the clause exactly as stored; reduce never walks into them on
;; its own. So:
;;   * PART 1 (naive zipWith: body forwards $a/$b straight to List.zipWith
;;     with no explicit re-evaluation) -- FAILS SILENTLY. The unevaluated
;;     sub-term (colR x) is itself a non-empty MeTTa expression, i.e. a
;;     Prolog list [colR, x] -- it structurally UNIFIES with List.zipWith's
;;     `(cons $x $xs)` head pattern (any non-empty list matches cons), so
;;     the wrong clause fires with garbage bindings ($x=colR, a *symbol*,
;;     not True/False), and the builtin `and` call inside then fails on the
;;     type mismatch -- the whole reduce call yields ZERO results, with NO
;;     error printed. This is a real hazard: it is not a clean type error,
;;     it is silent.
;;   * PART 2 (recursive-descent zipWith: body explicitly calls `(reduce
;;     $a)` / `(reduce $b)` on its own children before handing them to
;;     List.zipWith) -- WORKS, and gives the fully-computed column in ONE
;;     top-level `(reduce $t)` call, because reduce's one dispatch step
;;     genuinely executes the matched clause's body, and that body's own
;;     explicit reduce-on-child calls recurse correctly, all the way down.
;; Conclusion for the design: no extra interpreter support is needed beyond
;; `reduce` itself, PROVIDED every zip-term-consuming clause explicitly
;; reduces each child argument before treating it structurally (never trust
;; an unevaluated child to already be ground data).
;;
;; PITFALL discovered while building this probe: `(reduce (someFn))` written
;; directly (a nested call expression as reduce's argument) does NOT work --
;; it returns the argument's VALUE completely unprocessed, no dispatch at
;; all. reduce's argument must be a plain let-bound variable, exactly the
;; production evalRow idiom: `(let $e $template (reduce $e))`.
;; ---------------------------------------------------------------------------

!(import! &self ../common/list-helpers)

;; --- tiny 2-column, 4-row table --------------------------------------------
(= (colR x) (cons True (cons False (cons True (cons False ())))))
(= (colR y) (cons True (cons True (cons False (cons False ())))))

;; =====================  Part 1: naive zipWith (no explicit child reduce) ===
(= (zipWithNaive $opsym $a $b) (List.zipWith $opsym $a $b))
(= (flatTermNaive)
   (cons zipWithNaive (cons and (cons (cons colR (cons x ())) (cons (cons colR (cons y ())) ())))))

!(println! (PART1_TERM (flatTermNaive)))
!(let $t (flatTermNaive) (println! (PART1_NAIVE_REDUCE_RESULT (reduce $t))))
;; Sanity: normal (non-reduce) literal evaluation of the SAME shape works
;; fine, because ordinary call-by-value evaluates (colR x)/(colR y) as
;; arguments before the call -- confirming the failure above is specific to
;; reduce's substitute-without-evaluating-children semantics, not to
;; zipWithNaive's definition being wrong in general.
!(println! (PART1_DIRECT_LITERAL_SANITY (zipWithNaive and (colR x) (colR y))))

;; =====================  Part 2: recursive-descent zipWith ===================
(= (zipWithR $opsym $a $b) (List.zipWith $opsym (reduce $a) (reduce $b)))
(= (nestedTermR)
   (cons zipWithR
     (cons or
       (cons (cons colR (cons x ()))
             (cons (cons zipWithR (cons and (cons (cons colR (cons x ())) (cons (cons colR (cons y ())) ())))) ())))))

;; expected: colX = (True False True False); colY = (True True False False)
;; inner: colX and colY = (True False False False)
;; outer: colX or inner  = (True False True False)
(= (expectedNested) (cons True (cons False (cons True (cons False ())))))

!(println! (PART2_TERM (nestedTermR)))
!(let $t2 (nestedTermR) (println! (PART2_RECURSIVE_REDUCE_RESULT (reduce $t2))))
!(let $t2 (nestedTermR) (test (reduce $t2) (expectedNested)))

;; single-level case through the same recursive-descent zipWithR, for
;; comparison against Part 1's failure on the equivalent naive shape.
(= (flatTermR)
   (cons zipWithR (cons and (cons (cons colR (cons x ())) (cons (cons colR (cons y ())) ())))))
(= (expectedFlat) (cons True (cons False (cons False (cons False ())))))
!(let $t3 (flatTermR) (println! (PART2_FLAT_REDUCE_RESULT (reduce $t3))))
!(let $t3 (flatTermR) (test (reduce $t3) (expectedFlat)))
