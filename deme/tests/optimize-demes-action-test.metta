!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)

!(import! &self ../expand-deme)

;; ============================================================
;; optimizeDemes dispatch test for the tagged ACTION context.
;;
;; A stub optimizer defined in-test just RETURNS its own arguments wrapped
;; in an inert tuple. Like the real optimizers it ALSO has a 3-arg clause
;; (the shape the untagged catch-all optimizeDemes clause calls), pinned to
;; the boolean (mkTruthTableBScore ...) context -- for a tagged action
;; context that head cannot match, so the catch-all contributes NO result
;; and dispatch stays deterministic. (Without any 3-arg clause PeTTa would
;; curry the call into a `partial` term instead of failing.)
;; ============================================================

(= (stubOptimizer $deme $targetScore $inst $params)
   (stubGot $deme $targetScore $inst $params))
(= (stubOptimizer $deme (mkTruthTableBScore $cpx $size $itable) $inst)
   (stubGotBoolean $deme $inst))

;; The action clause unpacks (mkActionCtx $nTrials $cpxRatio $target)
;; and repacks (mkParams applyActionBasedScore ($nTrials $cpxRatio))
;; plus the bare $target -- assert the stub received exactly that.
!(assertEqual
  (collapse (optimizeDemes sdtDeme (mkActionCtx 2 3.5 100.0) (mkInst (1)) stubOptimizer))
  ((stubGot sdtDeme 100.0 (mkInst (1)) (mkParams applyActionBasedScore (2 3.5)))))

;; dispatch determinism: exactly ONE clause fired for the tagged context
!(assertEqual
  (size-atom (collapse (optimizeDemes sdtDeme (mkActionCtx 2 3.5 100.0) (mkInst (1)) stubOptimizer)))
  1)

;; behavior-change guard: the strategy 3-tuple clause is gone, so a bare
;; 3-tuple context now falls through to the untagged catch-all, which calls
;; the 3-arg stubOptimizer. That stub's only 3-arg clause pins its 2nd arg to
;; (mkTruthTableBScore ...); a bare 3-tuple fails that destructure, so the
;; call silently fails and collapse yields the empty result.
!(assertEqual
  (collapse (optimizeDemes sdtDeme (2 3.5 100.0) (mkInst (1)) stubOptimizer))
  ())

;; regression guard: a boolean (mkTruthTableBScore ...) context still takes
;; the untagged catch-all, passing the context through opaquely
!(assertEqual
  (collapse (optimizeDemes sdtDeme (mkTruthTableBScore 2.0 4 sdtITable) (mkInst (1)) stubOptimizer))
  ((stubGotBoolean sdtDeme (mkInst (1)))))
