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
!(import! &self zipform/rewrite-cache-memo)
!(import! &self common/truth-tables)

;; --- content-addressed bonus (driver-local; NOT a zipform/*.metta module
;; edit): memoize the binary combine step itself, keyed on actual column
;; VALUES (f, colA, colB), not the zip-subterm expression. evalZipTermCoreContent
;; is a driver-local copy of evaluator-common.metta's evalZipTermCore
;; structure (module files are off-limits, driver-local code is not) whose
;; ONLY change is the zipWith branch: it calls zipEval instead of handing
;; (f, evalled-colA, evalled-colB) straight to List.zipWith.
!(change-state! &zipEvalCallCount 0)
!(change-state! &zipEvalMissCount 0)
!(change-state! &evalZipTermContentMissCount 0)

!(memoize zipEval 3)
(= (zipEval $f $colA $colB)
   (let $_ (change-state! &zipEvalMissCount (+ 1 (get-state &zipEvalMissCount)))
     (List.zipWith $f $colA $colB)))

(= (evalZipTermCoreContent $term $eval)
   (if (== (get-metatype $term) Grounded)
       (List.repeat (param zipRowCount) $term)
       (let $h (car-atom $term)
         (if (== $h col)
             (let (col $label) $term (varColumn (param zipTable) $label))
             (if (== $h fmap)
                 (let (fmap $f $c) $term
                   (map-atom ($eval $c) $v ($f $v)))
                 (if (== $h zipWith)
                     (let (zipWith $f $a $b) $term
                       (let* (($colA ($eval $a))
                              ($colB ($eval $b))
                              ($_calls (change-state! &zipEvalCallCount (+ 1 (get-state &zipEvalCallCount)))))
                         (zipEval $f $colA $colB)))
                     (if (== $h zipWithN)
                         (let (zipWithN $op $children) $term
                           (let $cols (map-atom $children $c ($eval $c))
                             (map-atom (transposeCols $cols) $row ($op $row))))
                         (Error $term "evalZipTermCoreContent: unknown zip-term head"))))))))

!(memoize evalZipTermContent 1)
(= (evalZipTermContent $term)
   (let $_ (change-state! &evalZipTermContentMissCount (+ 1 (get-state &evalZipTermContentMissCount)))
     (evalZipTermCoreContent $term evalZipTermContent)))

!(import! &self captures/mux6.replay)

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
         (let $col (evalZipTermContent (rewriteTreeCached $e))
           (benchLoop (+ $i 1) $n (+ $acc (benchCountTrue $col)))))))

!(clear-memoize)
!(clear-memoize-stats)
!(config-memoize (strategy wtinylfu) (unique-limit 100000) (size-limit 5))
!(change-state! &zipEvalCallCount 0)
!(change-state! &zipEvalMissCount 0)
!(change-state! &evalZipTermContentMissCount 0)
!(setZipTable (mux6Table))

!(println! (BENCH_LABEL mux6_zipform_M_content))
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
           (let* (($_a (println! (ENTRIES NA)))
       ($_b (println! (CONTENT_CALLS (get-state &zipEvalCallCount))))
       ($_c (println! (CONTENT_MISSES (get-state &zipEvalMissCount)))))
  (println! (EVALTERM_MISSES (get-state &evalZipTermContentMissCount)))))))))
