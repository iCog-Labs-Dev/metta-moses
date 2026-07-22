;; ---------------------------------------------------------------------------
;; zipform/evaluator-space.metta -- hand-rolled &space-cache zip-term
;; evaluator. Runs on BOTH runtimes -- no lib_memo import, only
;; new-space/match/add-atom/remove-atom (see kernel-space.metta / scoring/
;; cacheSpace.metta for the same idiom this mirrors byte-for-byte in
;; structure).
;;
;; Caches PER SUBTERM: evalZipTermCached IS the recursion callback passed
;; into evalZipTermCore, so every distinct materialized zip subterm reached
;; during a scoring run gets its own &zipSubtermCache entry, independent of
;; which top-level formula it was reached from -- mirroring kernel-
;; space.metta's evalColCached.
;;
;; NOTE ON IMPORTS: this file has NO `!(import! ...)` of its own -- it needs
;; zipform/evaluator-common (evalZipTermCore) and, transitively, common/
;; list-helpers / common/kernel-common already loaded; the entry harness is
;; the single choke point that imports the whole chain, exactly once each,
;; before importing this file (re-importing here would double-assert
;; clauses, corrupting `test`'s single-value comparisons -- verified
;; empirically, "import! does not dedupe").
;;
;; PARAM NOTE: the hit/miss counters live in the shared hyperparameter
;; registry ((param zipCacheHits)/(param zipCacheMisses), incremented via
;; set-param) instead of change-state!/get-state cells -- see the same note
;; in evaluator-common.metta. &zipSubtermCache itself STAYS a plain &space
;; (it's a cache, matching production's &subtreeCache pattern, not ad-hoc
;; state).
;; ---------------------------------------------------------------------------

!(bind! &zipSubtermCache (new-space))

;; getZipSpaceStats: manual hit/miss counters in the same shape lib_memo's
;; get-memoize-stats returns, so the two evaluator variants are comparable.
(= (getZipSpaceStats)
   ((cache_hit (param zipCacheHits)) (cache_miss (param zipCacheMisses))))

;; resetZipCache: drain &zipSubtermCache AND zero the counters (this cache
;; DOES need clearing on a table switch -- see the harness's table-switch
;; staleness demo; contrast with rewrite-cache-space.metta's cache, which is
;; table-INDEPENDENT and is never cleared).
(= (resetZipCache)
   (let* (($entries (collapse (match &zipSubtermCache $e $e)))
          ($_        (map-atom $entries $e (remove-atom &zipSubtermCache $e)))
          ($_2       (set-param zipCacheHits 0))
          ($_3       (set-param zipCacheMisses 0)))
     ()))

;; evalZipTermCached: materialized zip term -> boolean column, cached in
;; &zipSubtermCache keyed by the ground materialized term (valid for the
;; run's single fixed table). Grounded True/False leaves are cheap constant
;; columns and are not cached, matching evalZipTermCore's own split.
(= (evalZipTermCached $term)
   (if (== (get-metatype $term) Grounded)
       (List.repeat (param zipRowCount) $term)
       (chain (collapse (match &zipSubtermCache (subtree $term $v) $v)) $hit
         (if (== $hit ())
             (let* (($_miss (set-param zipCacheMisses (+ 1 (param zipCacheMisses))))
                    ($col (evalZipTermCore $term evalZipTermCached))
                    ($_add (add-atom &zipSubtermCache (subtree $term $col))))
               $col)
             (let $_hit (set-param zipCacheHits (+ 1 (param zipCacheHits)))
               (car-atom $hit))))))
