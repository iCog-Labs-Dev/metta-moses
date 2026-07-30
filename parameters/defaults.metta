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
;;    - Parameters describe algorithm behavior, not problem families.
;;      Boolean, strategy, feature-selection, and action problems therefore
;;      read the same keys and may override them for a particular run.
;;    - The older metapopulation/metapopulation-params.metta also writes into
;;      &params for its isolated compatibility tests, but this registry is the
;;      source of truth for the production pipeline.
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
!(add-atom &params (maxCandPerDeme 100))
!(add-atom &params (minPoolSize 20))
!(add-atom &params (nToKeep 50))
;; Classic MOSES keeps dominated stepping stones by default and expands an
;; exemplar once unless the user explicitly permits revisits.
!(add-atom &params (discardDominated False))
!(add-atom &params (revisit 0))
;; Detailed per-expansion telemetry is opt-in for every problem family.
!(add-atom &params (diagnostics False))

;; ---- Deme expansion ----
!(add-atom &params (maxCandOutput 10))
;; maxEvals is the complete-run budget of actual new scorer calls, including
;; initialization. Zero disables expansion; a negative value is unlimited.
!(add-atom &params (maxEvals 25000))
;; nEval currently limits retained merge candidates. Despite its historical
;; name, it is not an evaluator-call budget and must not be conflated with
;; maxEvals until that interface is renamed.
!(add-atom &params (nEval 10000))
;; genCount feeds capSize() inside resizeMetapop. Callers normally seed it
;; with the initial $maxGen of the run; this default is a safety floor so
;; that a forgotten seed doesn't make (param genCount) collapse to ().
!(add-atom &params (genCount 1000))

;; ---- Hill climbing ----
;; These shared geometry controls reach every hill-climbing specialization.
!(add-atom &params (maxDist 4))
!(add-atom &params (minXoverNeighbors 400))
;; These switches mirror hc_parameters.  Keeping widening off and crossover on
;; matches the successful Santa Fe configuration and the C++ defaults.
!(add-atom &params (hcWidenSearch False))
!(add-atom &params (hcCrossover True))
!(add-atom &params (hcCrossoverPopSize 120))
!(add-atom &params (hcFractionOfNN 2.0))
!(add-atom &params (hcMinDemeSize 50))
!(add-atom &params (hcScoreImprovedThreshold 0.5))

;; ---- Scoring ----
!(add-atom &params (complexityRatio 3.5))
;; Evaluator horizon for domains with stateful execution, such as Santa Fe.
;; Boolean scorers do not consume this setting.
!(add-atom &params (steps 600))

;; ---- Caching ----
!(add-atom &params (defaultCacheSize 60))
