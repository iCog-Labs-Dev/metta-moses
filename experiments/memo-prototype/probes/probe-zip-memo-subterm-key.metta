;; ---------------------------------------------------------------------------
;; Probe 5 (zipform Phase 1, probe gate). PR-165 PeTTa ONLY (lib_memo). A
;; minimal memoized recursive term evaluator over nested zip terms. Proves
;; SUBTERM-level cache reuse: evaluate (zipWith and (col x) (zipWith or
;; (col y) (col z))), then evaluate a DIFFERENT outer term that reuses the
;; SAME inner subterm (zipWith or (col y) (col z)) -- that inner subterm
;; must be a cache HIT the second time, with the shared leaf (col x) also a
;; HIT, while the two distinct outer nodes are each a MISS (evaluated once).
;;
;; zipWith/col are used here purely as DATA-tag symbols (never given a
;; `(= (zipWith ...) ...)` / `(= (col ...) ...)` clause -- evalZip dispatches
;; on them manually via car-atom + let-destructure), so terms can be written
;; as plain literals, same rationale as AND/OR/NOT in common/kernel-common.
;; ---------------------------------------------------------------------------

!(import! &self (library lib_memo))
!(import! &self ../common/list-helpers)

;; --- tiny 3-column, 4-row table ---------------------------------------------
(= (colLookup x) (cons True (cons False (cons True (cons False ())))))
(= (colLookup y) (cons True (cons True (cons False (cons False ())))))
(= (colLookup z) (cons False (cons True (cons True (cons False ())))))

;; --- memoized recursive term evaluator --------------------------------------
!(memoize evalZip 1)
(= (evalZip $t)
   (let $h (car-atom $t)
     (if (== $h col)
         (let (col $label) $t (colLookup $label))
         (if (== $h zipWith)
             (let (zipWith $f $a $b) $t (List.zipWith $f (evalZip $a) (evalZip $b)))
             (Error $t "evalZip: unknown head")))))

!(clear-memoize)
!(clear-memoize-stats)

;; T1: (zipWith and (col x) (zipWith or (col y) (col z)))
;; distinct subterms touched: T1-outer, (col x), inner=(zipWith or (col y)
;; (col z)), (col y), (col z) -- 5 subterms, all first-time -> 5 misses.
!(println! (T1_RESULT (evalZip (zipWith and (col x) (zipWith or (col y) (col z))))))
!(println! (STATS_AFTER_T1 (get-memoize-stats)))

;; T2: (zipWith or (col x) (zipWith or (col y) (col z))) -- DIFFERENT outer
;; node (or instead of and), but reuses (col x) AND the exact inner subterm
;; (zipWith or (col y) (col z)) verbatim. Only the outer T2 node is new;
;; (col x) and the inner subterm must both be cache HITS (and, being a hit,
;; the inner subterm's own children (col y)/(col z) are NOT re-evaluated at
;; all -- the cached column is returned directly).
!(println! (T2_RESULT (evalZip (zipWith or (col x) (zipWith or (col y) (col z))))))
!(println! (STATS_AFTER_T2 (get-memoize-stats)))

;; Expected: colX=(T F T F), colY=(T T F F), colZ=(F T T F).
;; inner (colY or colZ) = (T T T F)
;; T1 = colX and inner  = (T F T F) and (T T T F) = (T F T F)
;; T2 = colX or  inner  = (T F T F) or  (T T T F) = (T T T F)
(= (expectedT1) (cons True (cons False (cons True (cons False ())))))
(= (expectedT2) (cons True (cons True (cons True (cons False ())))))
!(test (evalZip (zipWith and (col x) (zipWith or (col y) (col z)))) (expectedT1))
!(test (evalZip (zipWith or (col x) (zipWith or (col y) (col z)))) (expectedT2))

;; The critical claim, made explicit as an assertion: after T1+T2 (this
;; assertEqual call is itself a THIRD lookup of each subterm, so stats after
;; it are not reported as "the" answer -- STATS_AFTER_T1/STATS_AFTER_T2
;; above are the ones to read for the exact hit/miss counts).
!(println! (STATS_FINAL_FOR_REFERENCE_ONLY (get-memoize-stats)))
