;; ============================================================
;;  metta-moses root entry point.
;;
;;  This single file wires together every module the MOSES pipeline
;;  needs and installs all default hyperparameters into &params.
;;  Invocation:
;;
;;      sh /home/yab/PeTTaV1/run.sh moses.metta -s --problem=parity3
;;      sh /home/yab/PeTTaV1/run.sh moses.metta -s \
;;          --problem=mux3 --maxGen=10 --nDeme=2 \
;;          --fsAlgo=smd --optAlgo=hc --capCoef=80
;;      sh /home/yab/PeTTaV1/run.sh moses.metta -s --help
;;      sh /home/yab/PeTTaV1/run.sh moses.metta -s
;;          # no --problem given: prints --help and exits
;;
;;  The import order below was taken from
;;  moses/tests/demo-problems-benchmark-test.metta (the canonical
;;  test that exercises the full pipeline) and reorganized so the
;;  parameter registry loads before any module that consumes it.
;; ============================================================

;; ---- Parameter registry must load BEFORE any consumer module ----
;; defaults.metta populates &params; registry.metta defines (param ...)
;; and (set-param ...); cli.metta parses --name=value flags from argv.
!(import! &self utilities/general-helpers)
!(import! &self parameters/registry)
!(import! &self parameters/defaults)
!(import! &self parameters/cli)

;; ---- Utilities ----
!(import! &self utilities/list-methods)
!(import! &self utilities/pair)
!(import! &self utilities/map)
!(import! &self utilities/ordered-multimap)
!(import! &self utilities/ordered-set)
!(import! &self utilities/ordered-multiset)
!(import! &self utilities/nodeId)
!(import! &self utilities/lazy-random-selector)
!(import! &self utilities/lru-cache)

;; ---- Boolean reduction rules ----
!(import! &self reduct/boolean-reduct/rte-helpers)
!(import! &self reduct/boolean-reduct/cut-unnecessary-or)
!(import! &self reduct/boolean-reduct/cut-unnecessary-and)
!(import! &self reduct/boolean-reduct/n-ary-propagate-not)
!(import! &self reduct/boolean-reduct/n-ary-gather-junctors)
!(import! &self reduct/boolean-reduct/delete-inconsistent-handle)
!(import! &self reduct/boolean-reduct/zero-constraint-subsumption)
!(import! &self reduct/boolean-reduct/one-constraint-subsumption)
!(import! &self reduct/boolean-reduct/promote-common-constraints)
!(import! &self reduct/boolean-reduct/reduce-to-elegance)

!(import! &self utilities/tree)

;; ---- Scoring ----
!(import! &self scoring/cacheSpace)
!(import! &self scoring/fitness)
!(import! &self scoring/bscore)
!(import! &self scoring/cscore)

;; ---- Feature selection ----
!(import! &self feature-selection/feature-selection-helpers)
!(import! &self feature-selection/similarity-scorers)
!(import! &self feature-selection/select-top-features)
!(import! &self feature-selection/simple)
!(import! &self feature-selection/smd)
!(import! &self feature-selection/incremental)
!(import! &self feature-selection/hc)
!(import! &self feature-selection/random-feature-selection)
!(import! &self feature-selection/feature-selection-main)

;; ---- Representation ----
!(import! &self representation/knob-representation)
!(import! &self representation/lsk)
!(import! &self representation/disc-probe)
!(import! &self representation/logical-probe)
!(import! &self representation/sample-logical-perms)
!(import! &self representation/logical-canonize)
!(import! &self representation/add-logical-knobs)
!(import! &self representation/build-logical)
!(import! &self representation/build-knobs)
!(import! &self representation/knob-mapper)
!(import! &self representation/representation)
!(import! &self representation/create-representation)

!(import! &self scoring/complexity-based-scorer)

;; ---- Optimization (hill climbing is the only production-ready algorithm) ----
!(import! &self optimization/hillclimbing/cross-top-one-helpers)
!(import! &self optimization/hillclimbing/cross-top-one)
!(import! &self optimization/hillclimbing/hill-climbing-helpers)

;; ---- Deme + metapopulation pipeline ----
!(import! &self deme/create-deme)
!(import! &self moses/neighborhood-sampling)

!(import! &self metapopulation/exemplar-type)
!(import! &self metapopulation/exemplar-selection)
!(import! &self metapopulation/metapopulation)

!(import! &self representation/instance)

!(import! &self deme/deme-id-creation)
!(import! &self deme/score-deme)
!(import! &self deme/merge-demes)
!(import! &self deme/expand-deme)

;; ---- Top-level entry point: defines (moses), (optimizer-for ...) ----
!(import! &self moses/demo-problems)

;; ---- Apply any --name=value flags the user passed on the command line ----
;; This is a no-op when no flags are passed; with flags, it overwrites the
;; matching defaults in &params before (moses) is called.
!(apply-cli-overrides)

;; ---- Run ----
;; If no --problem was set on the CLI (and no in-script set-param),
;; (moses) routes to no-problem-help-and-exit, which prints --help
;; and halts. Otherwise the full pipeline runs.
!(moses)
