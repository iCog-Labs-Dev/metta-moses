
;; ============================================================
;; cli-override-smoke.metta
;;
;; Manual end-to-end smoke test for command-line parameter
;; overrides.
;;
;; Verifies the complete path:
;;   argv -> apply-cli-overrides -> parse-flag -> set-param
;;
;; Run with:
;;   sh run.sh parameters/tests/cli-override-smoke.metta -s \
;;     --capCoef=777 \
;;     --complexityRatio=2.5
;;
;; This file is intentionally not executed by run-tests.py
;; because its filename does not match the automated *-test.metta
;; convention.
;; ============================================================

!(import! &self ../../utilities/general-helpers)
!(import! &self ../registry)
!(import! &self ../defaults)
!(import! &self ../cli)

!(apply-cli-overrides)

;; Verify that the supplied CLI values override the defaults.
!(assertEqual (param capCoef) 777)
!(assertEqual (param complexityRatio) 2.5)

