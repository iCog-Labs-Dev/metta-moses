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

;; ---- Action-run binding (the params-based fitness contract) ----
;; An ACTION experiment binds its fitness through these four params instead
;; of a table problem; (moses) routes on them (action configured <=>
;; fitness is non-()). All four default to the empty value () --
;; the same "never set" convention (param problem) relies on -- so unset
;; detection is (== (param fitness) ()).
;;
;; fitness: a function SYMBOL. The scorer calls ($fn $exp $i) per
;;   episode -- $exp is the compiled wrapped expression, $i the episode
;;   ordinal 0..n-1 -- and expects a Number back (higher = better; any
;;   non-Number result -- True, a string, an unreduced term -- scores the
;;   defined-worst -1.0 for that episode instead of entering the bscore).
;;   How the ordinal maps to opponents/trails/start-worlds is PRIVATE to
;;   that function. Symbols pass through the CLI:
;;   --fitness=tttActionFitness.
;; bestScore: the termination target, with one convention per runner:
;;   * ACTION runs: a function SYMBOL, called ($fn $n) -> Number, the
;;     target for n episodes (the experiment knows its own per-episode
;;     maximum). Unset -> the run exits via maxGen.
;;   * TABLE runs: optionally a plain NUMBER used directly as the target
;;     instead of (getBestPossibleScore)'s hardcoded 0 (useful for noisy
;;     tables that can never reach 0). Numeric CLI values arrive as real
;;     Numbers (--bestScore=2 parses to Number 2, probe-verified), so
;;     both --bestScore=<num> and an in-script
;;     !(set-param bestScore <num>) work. Any non-Number value (incl.
;;     the () default) leaves table behavior unchanged.
;; actions / perceptions: TUPLES of primitive symbols (the knob
;;   vocabulary read by representation building). actions is
;;   MANDATORY for a run (moses-run-action refuses loudly when it is unset
;;   -- without it every deme is knobless and the run silently produces
;;   nothing); perceptions may legitimately be () (an experiment
;;   with no perceptions builds action-only knobs). Tuples cannot ride the
;;   CLI, so experiments set them in-script; quote-wrap at the set-param
;;   site -- !(set-param actions (quote (act1 act2 ...))) -- because
;;   the primitives are live bare-head clauses and an unquoted tuple headed
;;   by one curries into a `partial` term (probe-verified). quote strips on
;;   evaluation, so (param actions) returns the plain tuple.
!(add-atom &params (fitness     ()))
!(add-atom &params (bestScore   ()))
!(add-atom &params (actions     ()))
!(add-atom &params (perceptions ()))

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

;; ---- Deme expansion ----
!(add-atom &params (maxCandOutput 10))
!(add-atom &params (nEval 10000))
;; genCount feeds capSize() inside resizeMetapop. Callers normally seed it
;; with the initial $maxGen of the run; this default is a safety floor so
;; that a forgotten seed doesn't make (param genCount) collapse to ().
!(add-atom &params (genCount 1000))

;; ---- Hill climbing ----
;; hcMaxDist: maximum Hamming distance from the center instance the
;; neighborhood search explores (classic optim_parameters::max_dist).
;; hcMinXoverNeighbors: neighborhood-size threshold above which the
;; crossover path engages (classic hc_params::crossover_min_neighbors,
;; classic default 400). ONE value each, regardless of problem kind --
;; the per-domain tiers (Boolean/Fs/Strategy/Action) that used to live
;; here redefined the same concept four times with untuned copies; tune
;; per RUN instead via --hcMaxDist=N / --hcMinXoverNeighbors=N or
;; in-script set-param.
!(add-atom &params (hcMaxDist 4))
!(add-atom &params (hcMinXoverNeighbors 400))
!(add-atom &params (hcMaxEvals 500))
!(add-atom &params (hcCrossoverPopSize 120))
!(add-atom &params (hcFractionOfNN 2.0))
!(add-atom &params (hcMinDemeSize 50))
!(add-atom &params (hcScoreImprovedThreshold 0.5))

;; ---- Scoring ----
!(add-atom &params (complexityRatio 3.5))
;; nTrials: episodes per candidate evaluation in ACTION domains (the action
;; analog of the strategy example's game count). Override via --nTrials=N.
!(add-atom &params (nTrials 12))

;; ---- Exemplar selection ----
!(add-atom &params (compxyTemp 6))

;; ---- Caching ----
!(add-atom &params (defaultCacheSize 60))
