;; ---------------------------------------------------------------------------
;; Bench driver TEMPLATE for the zipform-nary (variant-P, production-style
;; n-ary AND/OR/NOT clause dispatch) benchmark -- never run this file
;; directly. Filled in by gen-driver-zipform-nary.py's str.replace() (keys
;; documented at the top of that script) for each concrete driver written
;; directly under experiments/memo-prototype/ (same "generated drivers must
;; live next to their relative import! targets" constraint gen-driver.py /
;; gen-driver-zipform.py's own headers document -- relative import! paths
;; resolve against the ENTRY file's own directory for the whole process).
;;
;; Only ONE variant here (unlike driver-template-zipform.metta's S/M/
;; M_content selector): production-style combine strategy + memoized
;; evaluator reuse (zipform/evaluator-memo.metta, UNCHANGED) is the entire
;; point of variant P, so there is nothing to select between.
;;
;; QUOTED CANDIDATE STREAM: unlike variant M/S, this driver's candidates
;; come from captures/<wl>.replay-quoted.metta (scripts/capture-to-
;; replay.py --quote), NOT the plain captures/<wl>.replay.metta files (DO
;; NOT MODIFY / DO NOT read from those here) -- necessary because
;; zipform/ops-nary.metta gives AND/OR/NOT real clauses, so a bare literal
;; candidate expr stored unquoted would compile as a live goal call at
;; translation time (see zipform/ops-nary.metta's header). benchGetCandidate
;; below destructures the quote wrapper via a match pattern, verified safe
;; in probes/probe-nary-quote-store-retrieve.metta: the bound value stays
;; fully inert through let-destructure and through being passed as a plain
;; function argument into rewriteTreeNaryCached, only firing AND/OR/NOT when
;; the evaluator's own per-row zipWithN dispatch later calls them
;; deliberately.
;;
;; Run order (same discipline as driver-template-zipform.metta / the zipform
;; correctness harnesses / lib_memo_doc.md): imports, THEN driver-local defs,
;; THEN reset/clear cache+stats, config, setZipTable, T0, fold, T1, stats.
;; ---------------------------------------------------------------------------

!(bind! &params (new-space))
!(import! &self ../../parameters/registry)
!(import! &self (library lib_memo))
!(import! &self common/list-helpers)
!(import! &self common/kernel-common)
!(import! &self zipform/ops-nary)
!(import! &self zipform/rewriter-nary)
!(import! &self zipform/evaluator-common)
!(import! &self zipform/evaluator-memo)
!(import! &self common/truth-tables)
!(import! &self captures/majority3.replay-quoted)

;; --- cheap deterministic checksum: total True-cell count across every
;; evaluated candidate's result column. IDENTICAL accumulation logic to
;; driver-template-zipform.metta's benchCountTrue (only the candidate-
;; retrieval + scoring expressions below differ), so a checksum mismatch
;; against variant M/S on the same workload signals a real correctness bug
;; (semantics must be identical: same op tables' truth values, just a
;; different combine strategy). ---
(= (benchCountTrue $col) (foldl-atom $col 0 $acc $b (if (== $b True) (+ $acc 1) $acc)))

(= (benchGetCandidate $i) (car-atom (collapse (match &replayStream (candidate $i (quote $e)) $e))))

(= (benchLoop $i $n $acc)
   (if (> $i $n)
       $acc
       (let $e (benchGetCandidate $i)
         (let $col (evalZipTerm (rewriteTreeNaryCached $e))
           (benchLoop (+ $i 1) $n (+ $acc (benchCountTrue $col)))))))

!(clear-memoize)
!(clear-memoize-stats)
!(config-memoize (strategy wtinylfu) (unique-limit 100000) (size-limit 5))
!(setZipTable (majority3Table))

!(println! (BENCH_LABEL majority3_zipform_P))
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
