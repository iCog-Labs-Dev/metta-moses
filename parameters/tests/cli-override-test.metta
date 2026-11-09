;; Stand-alone manual smoke check for CLI overrides.
;; Run with extra flags to confirm they land in &params:
;;   sh run.sh parameters/tests/cli-override-smoke.metta -s --capCoef=777 --complexityRatio=2.5
;; Not invoked by run-tests.py (file name doesn't match *test.metta).

!(import! &self ../../utilities/general-helpers)
!(import! &self ../registry)
!(import! &self ../defaults)
!(import! &self ../cli)

!(apply-cli-overrides)

!(assertEqual (param capCoef) 50)
!(assertEqual (param complexityRatio) 3.5)
