;; ============================================================
;;  Default hyperparameter values for metta-moses.
;;
;;  Every tunable parameter consumed by the MOSES algorithm is
;;  registered here as an atom of the form ($name $value) inside
;;  the shared &params atomspace. Callers look values up via
;;  (param $name); overrides arrive from the command line via
;;  parameters/cli.metta or from tests via (set-param $name $val).
;;
;;  Adding a new hyperparameter:
;;    1. Append a `!(add-atom &params ($name $defaultValue))`
;;       line in the appropriate section below.
;;    2. Replace its hardcoded use in the codebase with
;;       (param $name).
;;
;;  Notes:
;;    - Names are kept identical to the local variable names used
;;      historically in the codebase, to keep the migration easy.
;;    - The older metapopulation/metapopulation-params.metta also
;;      writes into &params (capCoef / discardDominated /
;;      maxCandPerDeme / compTemp). It is kept for backward
;;      compatibility with the existing
;;      metapopulation-params-test.metta but is no longer the
;;      source of truth.
;; ============================================================

!(bind! &params (new-space))

;; ---- Metapopulation management ----
!(add-atom &params (capCoef 50))
!(add-atom &params (complexityTemperature 6))
!(add-atom &params (discardDominated False))
!(add-atom &params (maxCandPerDeme 100))
!(add-atom &params (minPoolSize 20))
!(add-atom &params (nToKeep 50))

;; ---- Deme expansion ----
!(add-atom &params (maxCandOutput 10))
!(add-atom &params (nEval 500))
;; genCount feeds capSize() inside resizeMetapop. Callers normally seed it
;; with the initial $maxGen of the run; this default is a safety floor so
;; that a forgotten seed doesn't make (param genCount) collapse to ().
!(add-atom &params (genCount 1000))

;; ---- Hill climbing ----
;; The original code carries three contextual variants of maxDist
;; and minXoverNeighbors (boolean / feature-selection / strategy).
;; We expose all three as flat keys to preserve current behaviour.
!(add-atom &params (hcMaxDistBoolean 4))
!(add-atom &params (hcMinXoverNeighborsBoolean 400))
!(add-atom &params (hcMaxDistFs 3))
!(add-atom &params (hcMinXoverNeighborsFs 5))
!(add-atom &params (hcMaxDistStrategy 3))
!(add-atom &params (hcMinXoverNeighborsStrategy 3))
!(add-atom &params (hcMaxEvals 500))
!(add-atom &params (hcCrossoverPopSize 120))
!(add-atom &params (hcFractionOfNN 2.0))
!(add-atom &params (hcMinDemeSize 50))
!(add-atom &params (hcScoreImprovedThreshold 0.5))

;; ---- Scoring ----
!(add-atom &params (complexityRatio 3.5))

;; ---- Exemplar selection ----
!(add-atom &params (compxyTemp 6))

;; ---- Caching ----
!(add-atom &params (defaultCacheSize 60))
