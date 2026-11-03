;; ---------------------------------------------------------------------------
;; Ant end to end: the same run as
;;   sh run.sh moses.metta -s --problem=ant --nEval=500 --maxGen=5
;; ---------------------------------------------------------------------------
;; This test runs the action pipeline with the modules that production loads:
;; it imports moses-imports.metta, the same module list as moses.metta, in the
;; same order (PeTTa compiles a call to a function that is not loaded yet as
;; data, so the order changes the results).
;;
;; Why: ttt-action-smoke-test does not load reduct/action-reduct. When
;; scoring/action-ops was loaded after the reducer, the reducer turned action terms
;; into calls, and this run returned no FinalResult with no error. Only a run with
;; the production imports shows that.

!(import! &self ../../moses-imports)

;; The CLI flags of the command above, set the way apply-cli-overrides sets them.
!(set-param problem ant)
!(set-param nEval 500)
!(set-param maxGen 5)

;; moses-run is what (moses) calls for --problem=ant. The run must return a
;; FinalResult with at least one program.
!(assertEqual
  (let (FinalResult $programs) (moses-run)
    (> (size-atom $programs) 0))
  True)
