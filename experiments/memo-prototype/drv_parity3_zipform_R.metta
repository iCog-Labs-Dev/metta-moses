;; ---------------------------------------------------------------------------
;; Bench driver TEMPLATE for the zipform (boss-literal zipWith kernel)
;; benchmark -- never run this file directly. Sibling to driver-template.metta
;; (that one is untouched); this one is filled in by gen-driver-zipform.py's
;; str.replace() (keys documented at the top of that script) for each
;; concrete driver written directly under experiments/memo-prototype/ (same
;; "generated drivers must live next to their relative import! targets"
;; constraint gen-driver.py's own header documents).
;;
;; Run order (same discipline as driver-template.metta / the zipform
;; correctness harnesses / lib_memo_doc.md): imports, THEN driver-local
;; defs (content-addressed bonus cell only), THEN reset/clear cache+stats,
;; config (M / M_content only), setZipTable, T0, fold, T1, stats.
;;
;; Scoring path per Phase 3 plan: the SCORE-EXPR placeholder below is one of
;;   (evalZipTerm (rewriteTreeCached VAR))          -- zipform_M
;;   (evalZipTermCached (rewriteTreeCached VAR))    -- zipform_S
;;   (evalZipTermContent (rewriteTreeCached VAR))   -- zipform_M_content (bonus)
;; substituted verbatim as text, so the candidate-expression variable it
;; refers to is the SAME let-bound $e below in all three cases.
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
!(import! &self captures/parity3.replay)

;; --- cheap deterministic checksum: total True-cell count across every
;; evaluated candidate's result column. Identical accumulation logic across
;; every variant -- only the scoring expression below differs -- so a
;; mismatch between any two cells on the same workload signals a real
;; correctness bug. ---
(= (benchCountTrue $col) (foldl-atom $col 0 $acc $b (if (== $b True) (+ $acc 1) $acc)))

(= (benchGetCandidate $i) (car-atom (collapse (match &replayStream (candidate $i $e) $e))))

(= (benchLoop $i $n $acc)
   (if (> $i $n)
       $acc
       (let $e (benchGetCandidate $i)
         (let $col (evalZipTermR (rewriteTreeCached $e))
           (benchLoop (+ $i 1) $n (+ $acc (benchCountTrue $col)))))))

!(clear-memoize)
!(clear-memoize-stats)
!(config-memoize (strategy wtinylfu) (unique-limit 100000) (size-limit 5))
!(setZipTable (parity3Table))

!(println! (BENCH_LABEL parity3_zipform_R))
!(let $n (car-atom (collapse (match &replayStream (streamLength $n) $n)))
   (let $t0 (current-time)
     (let $checksum (benchLoop 1 $n 0)
       (let $t1 (current-time)
         (progn
           (println! (BENCH_STREAMLEN $n))
           (println! (BENCH_T0 $t0))
           (println! (BENCH_T1 $t1))
           (println! (BENCH_ELAPSED_SEC (- $t1 $t0)))
           (println! (CHECKSUM $checksum))
           (println! (STATS (get-memoize-stats)))
           (println! (ENTRIES NA)))))))
