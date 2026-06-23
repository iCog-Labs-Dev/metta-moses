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

;; ---- Run identity / inputs ----
;; These describe *what* to run; everything below describes *how*.
;;
;; `problem` deliberately has NO default: invoking (moses) without an
;; explicit problem (via --problem=<name> on the CLI or via
;; (set-param problem <name>) in the script) prints --help and exits.
;; This makes "run with no args" show help instead of silently running
;; whatever sample problem was last chosen.
!(add-atom &params (seed     0))
!(add-atom &params (maxGen   50))
!(add-atom &params (nDeme    1))

;; ---- Input table (boolean CSV path) ----
;; inputFile: filesystem path to a CSV with boolean-valued columns. When
;;   non-empty, (moses) loads the table from this file instead of
;;   dispatching to the demo problem function named by `problem`.
;;   Accepted cell formats: True/False, 1/0, yes/no, t/f (case-insensitive).
;; targetFeature: name of the output column. Empty -> last column.
;; Best-possible raw score is 0 for clean (non-noisy) data; noisy tables
;; (duplicate input rows with conflicting outputs) will terminate via
;; maxGen rather than by hitting the perfect-classifier target.
!(add-atom &params (inputFile     ""))
!(add-atom &params (targetFeature ""))

;; ---- Algorithm selection ----
;; optAlgo: which deme-local optimizer to dispatch to inside runMoses.
;;   Recognized values: hc (hill climbing).
;;   sa / univariate exist in the tree but are not integration-tested;
;;   passing them will halt with a clear error.
;; fsAlgo: which feature-selection algorithm runMoses pipes into expandDeme.
;;   Recognized values include: None, smd, sim, inc, rd, mi, hc.
!(add-atom &params (optAlgo hc))
!(add-atom &params (fsAlgo  None))

;; ---- Representation building ----
;; discProbe: prune complexity-reducing knob settings during logical-probe
;; pass. Default False mirrors the shipped behaviour after the test-suite
;; adjustment in d4d8529; flip to True to opt in via --discProbe=True.
!(add-atom &params (discProbe False))

;; ---- Metapopulation management ----
!(add-atom &params (capCoef 50))
!(add-atom &params (complexityTemperature 6))
!(add-atom &params (discardDominated False))
!(add-atom &params (maxCandPerDeme 100))
!(add-atom &params (minPoolSize 20))
!(add-atom &params (nToKeep 50))

;; ---- Deme expansion ----
!(add-atom &params (maxCandOutput 10))
!(add-atom &params (nEval 10000))
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
