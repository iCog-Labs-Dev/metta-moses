
;; ============================================================
;; cli-override-test.metta
;;
;; Verifies that parameter defaults remain unchanged when no
;; command-line overrides are supplied.
;;
;; This is an automated test and is executed by run-tests.py.
;; It intentionally does not require CLI arguments.
;; ============================================================

!(import! &self ../../utilities/general-helpers)
!(import! &self ../registry)
!(import! &self ../defaults)
!(import! &self ../cli)

;; No CLI overrides are supplied.
;; Defaults from defaults.metta should remain active.
!(apply-cli-overrides)

!(assertEqual (param capCoef) 50)
!(assertEqual (param complexityRatio) 3.5)

