;; ---------------------------------------------------------------------------
;; Bench driver TEMPLATE -- never run this file directly (see gen-driver.py's
;; TOKEN placeholder markers below, filled in for each concrete driver written
;; under drivers/*.metta). Placeholder names deliberately spelled with a
;; TOKEN_ prefix here (rather than literal $VAR text) purely so this header
;; comment survives naive substitution unmangled -- gen-driver.py's actual
;; str.replace() keys are documented at the top of gen-driver.py itself.
;;
;; Run order per lib_memo_doc.md guidance + kernel-memo.metta staleness notes:
;;   reset/clear cache+stats, config (M only), setTable, T0, fold, T1, stats.
;; ---------------------------------------------------------------------------

!(bind! &params (new-space))
!(import! &self ../../parameters/registry)
$KERNEL_IMPORT_LINE
$TABLE_IMPORT_LINE
!(import! &self captures/$WORKLOAD.replay)

;; --- cheap deterministic checksum: total True-cell count across every
;; evaluated candidate's result column. Identical accumulation logic for
;; both variants -- only $EVAL_FN differs -- so a mismatch between an M run
;; and an S run on the same workload signals a real correctness bug. ---
(= (benchCountTrue $col) (foldl-atom $col 0 $acc $b (if (== $b True) (+ $acc 1) $acc)))

(= (benchGetCandidate $i) (car-atom (collapse (match &replayStream (candidate $i $e) $e))))

(= (benchLoop $i $n $acc)
   (if (> $i $n)
       $acc
       (let $e (benchGetCandidate $i)
         (let $col ($EVAL_FN $e)
           (benchLoop (+ $i 1) $n (+ $acc (benchCountTrue $col)))))))

$RESET_BLOCK
!($SET_TABLE $TABLE_CALL)

!(println! (BENCH_LABEL $LABEL))
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
           (println! (STATS $STATS_CALL))
           $EXTRA_STATS_LINE)))))
