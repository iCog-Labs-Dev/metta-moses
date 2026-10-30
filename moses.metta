;; ============================================================
;;  metta-moses root entry point.
;;
;;  This single file wires together every module the MOSES pipeline
;;  needs and installs all default hyperparameters into &params.
;;  Invocation ($PETTA is the path to PeTTa's run.sh):
;;
;;      sh "$PETTA" moses.metta -s --problem=parity3
;;      sh "$PETTA" moses.metta -s \
;;          --problem=mux3 --maxGen=10 --nDeme=2 \
;;          --fsAlgo=smd --optAlgo=hc --capCoef=80
;;      sh "$PETTA" moses.metta -s --help
;;      sh "$PETTA" moses.metta -s
;;          # no --problem given: prints --help and exits
;;
;;  The module list and its load order are in moses-imports.metta.
;;  The full-pipeline tests import the same file.
;; ============================================================

!(import! &self moses-imports)

;; ---- Apply command-line configuration ----
!(apply-cli-overrides)

;; ---- Load external domain ----
;; The domain file is imported into the same MeTTa environment, so its
;; actions, perceptions, fitness functions and other definitions become
;; available to generic MOSES.
!(load-domain-file)

;; ---- Run ----
!(moses)
