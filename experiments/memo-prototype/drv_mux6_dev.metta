;; ---------------------------------------------------------------------------
;; drv_mux6_dev.metta -- scores the SAME mux6 replay stream as
;; drv_mux6_zipform_G.metta, but with DEV's production evaluator
;; (scoring/fitness.metta evalSubtree: per-row sealed/reduce template over
;; &subtreeCache), imported directly from the worktree checkout (../../scoring
;; /...). Same benchLoop / benchCountTrue / (current-time) timing as the
;; zipform drivers, so BENCH_ELAPSED_SEC and CHECKSUM are directly comparable.
;; A matching CHECKSUM (140043) proves both evaluators compute the same
;; columns; BENCH_ELAPSED_SEC is the head-to-head evaluator wall-clock.
;;
;; Candidates arrive quote-wrapped (mux6.replay-quoted): benchGetCandidate
;; strips the quote in the match pattern so the wrapped expr reaches
;; evalSubtree inert (the production AND/OR/NOT clauses would otherwise fire),
;; exactly as the zipform driver feeds rewriteTreeCached.
;; ---------------------------------------------------------------------------

;; production scoring chain (all self-contained, zero internal imports):
!(import! &self ../../utilities/general-helpers)   ;; List.*, all/any/is-member
!(import! &self ../../utilities/list-methods)       ;; map, List.map/drop/flatten
!(import! &self ../../scoring/cacheSpace)           ;; !(bind! &subtreeCache ...)
!(import! &self ../../scoring/fitness)              ;; evalSubtree, combineNode, evalRow, varColumn
!(import! &self ../../scoring/boolean-ops)          ;; AND/OR/NOT operator clauses
!(import! &self common/truth-tables)                ;; mux6Table (experiment's)
!(import! &self captures/mux6.replay-quoted)        ;; the replay stream

;; identical checksum + candidate accessor as the zipform drivers
(= (benchCountTrue $col) (foldl-atom $col 0 $acc $b (if (== $b True) (+ $acc 1) $acc)))
(= (benchGetCandidate $i) (car-atom (collapse (match &replayStream (candidate $i (quote $e)) $e))))

;; mux6 row count (evalSubtree's $n): rows of the fixed table
(= (mux6N) (let (mkITable $rows $labels) (mux6Table) (List.length $rows)))

(= (benchLoop $i $n $acc)
   (if (> $i $n)
       $acc
       (let $e (benchGetCandidate $i)
         (let $col (evalSubtree $e (mux6Table) (mux6N))
           (benchLoop (+ $i 1) $n (+ $acc (benchCountTrue $col)))))))

!(println! (BENCH_LABEL mux6_dev_evalSubtree))
!(let $n (car-atom (collapse (match &replayStream (streamLength $n) $n)))
   (let $t0 (current-time)
     (let $checksum (benchLoop 1 $n 0)
       (let $t1 (current-time)
         (progn
           (println! (BENCH_STREAMLEN $n))
           (println! (BENCH_ELAPSED_SEC (- $t1 $t0)))
           (println! (CHECKSUM $checksum)))))))
