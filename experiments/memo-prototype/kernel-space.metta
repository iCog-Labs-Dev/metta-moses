;; ---------------------------------------------------------------------------
;; Variant S: hand-rolled &space-cache columnar scoring kernel. Runs on BOTH
;; PeTTaV1 (production) and PR-165 PeTTa -- no lib_memo import, only
;; new-space/match/add-atom/remove-atom, all present on both runtimes (see
;; scoring/cacheSpace.metta / scoring/fitness.metta:173-189 for the
;; production idiom this mirrors).
;;
;; Import-path note: see the comment at the top of kernel-memo.metta -- the
;; same working_dir-is-fixed-at-startup behavior applies here, so these
;; paths are written relative to experiments/memo-prototype/.
;;
;; PARAM NOTE: table, row count, and the hit/miss counters live in the
;; shared hyperparameter registry (param protoTable / param protoRowCount /
;; param protoCacheHits / param protoCacheMisses, see parameters/
;; registry.metta) instead of change-state!/get-state cells. The entry
;; harness is responsible for `!(bind! &params (new-space))` + importing the
;; registry BEFORE importing this file. Names are kept DISTINCT from
;; kernel-memo.metta's memo*/zipform's zip* names on purpose -- see the
;; matching note in kernel-memo.metta.
;; ---------------------------------------------------------------------------

!(import! &self common/list-helpers)
!(import! &self common/kernel-common)

!(bind! &protoSubtreeCache (new-space))

;; setProtoTable: install the fixed table for this scoring run and cache its
;; row count (mirrors setMemoTable in kernel-memo.metta).
(= (setProtoTable $itable)
   (let (mkITable $rows $labels) $itable
     (let* (($_  (set-param protoTable $itable))
            ($_2 (set-param protoRowCount (List.length $rows))))
       (List.length $rows))))

;; getSpaceStats: manual hit/miss counters in the same shape lib_memo's
;; get-memoize-stats returns, so the two harnesses can be compared 1:1.
(= (getSpaceStats)
   ((cache_hit (param protoCacheHits)) (cache_miss (param protoCacheMisses))))

;; resetProtoCache: drain &protoSubtreeCache AND zero the counters (unlike
;; lib_memo's clear-memoize, which also resets stats as a side effect --
;; here that's made explicit rather than implicit).
(= (resetProtoCache)
   (let* (($entries (collapse (match &protoSubtreeCache $e $e)))
          ($_        (map-atom $entries $e (remove-atom &protoSubtreeCache $e)))
          ($_2       (set-param protoCacheHits 0))
          ($_3       (set-param protoCacheMisses 0)))
     ()))

;; evalColCached: wrapped (sub)expression -> boolean column, memoized in
;; &protoSubtreeCache keyed by the ground wrapped expr (valid for the run's
;; single fixed table, exactly like &subtreeCache in scoring/fitness.metta).
;; Grounded True/False leaves are cheap constant columns and are not cached,
;; matching evalCol's split in kernel-memo.metta and evalSubtree's split in
;; scoring/fitness.metta.
(= (evalColCached $exp)
   (if (== (get-metatype $exp) Grounded)
       (List.repeat (param protoRowCount) $exp)
       (chain (collapse (match &protoSubtreeCache (subtree $exp $v) $v)) $hit
         (if (== $hit ())
             (let* (($_miss (set-param protoCacheMisses (+ 1 (param protoCacheMisses))))
                    ($col (if (== (get-metatype $exp) Expression)
                             ;; every node is uniformly ($op ($c1 .. $ck))
                             (let ($op $children) $exp
                               (combineOp $op (map-atom $children $c (evalColCached $c)) (param protoRowCount)))
                             ;; bare label leaf
                             (varColumn (param protoTable) $exp)))
                    ($_add (add-atom &protoSubtreeCache (subtree $exp $col))))
               $col)
             (let $_hit (set-param protoCacheHits (+ 1 (param protoCacheHits)))
               (car-atom $hit))))))
