
;; ============================================================
;; cli-list-override-smoke.metta
;;
;; Manual CLI integration smoke test.
;;
;; Verifies the complete path:
;;
;;   argv
;;     -> apply-cli-overrides
;;     -> parse-flag
;;     -> set-param
;;     -> parameter registry
;;
;; Run with:
;;
;;   run.sh parameters/tests/cli-list-override-smoke.metta -s \
;;     --actions=tttWin,tttBlock,tttCenter \
;;     --perceptions=tttCanWin,tttCanBlock,tttCenterFree
;; ============================================================

!(import! &self ../../utilities/general-helpers)
!(import! &self ../registry)
!(import! &self ../defaults)
!(import! &self ../cli)

;; Apply the actual command-line arguments.
!(apply-cli-overrides)

;; ---- Verify action override ----
!(assertEqual
   (param actions)
   (tttWin tttBlock tttCenter))

;; ---- Verify perception override ----
!(assertEqual
   (param perceptions)
   (tttCanWin tttCanBlock tttCenterFree))

