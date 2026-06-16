;; Smoke check for the root-level moses.metta entry file.
;; Doesn't actually run MOSES (which would take minutes); just confirms
;; the import chain resolves and the registry is populated correctly.
;;
;;   sh run.sh runner-smoke.metta -s
;;   sh run.sh runner-smoke.metta -s --problem=mux3 --maxGen=99
;;   sh run.sh runner-smoke.metta -s --help

!(import! &self moses)

!(println! (problem-resolved-to: (param problem)))
!(println! (maxGen-resolved-to:  (param maxGen)))
!(println! (optAlgo-resolved-to: (param optAlgo)))
!(println! (fsAlgo-resolved-to:  (param fsAlgo)))
!(println! (capCoef-resolved-to: (param capCoef)))
