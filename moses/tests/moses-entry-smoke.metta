;; Stand-alone manual smoke check for the (moses) zero-arg entry point.
;; Run via:
;;   sh run.sh moses/tests/moses-entry-smoke.metta -s --maxGen=2 --problem=parity3 --fsAlgo=None
;; Not invoked by run-tests.py (file name doesn't end in `test.metta`).

!(import! &self ../../utilities/general-helpers)
!(import! &self ../../parameters/registry)
!(import! &self ../../parameters/defaults)
!(import! &self ../../parameters/cli)

!(apply-cli-overrides)

!(println! (effective-problem: (param problem)))
!(println! (effective-optAlgo: (param optAlgo)))
!(println! (effective-fsAlgo:  (param fsAlgo)))
!(println! (effective-maxGen:  (param maxGen)))
!(println! (effective-nDeme:   (param nDeme)))
!(println! (effective-seed:    (param seed)))
