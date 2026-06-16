# MOSES Hyperparameter Map

This file maps the tunable parameters used by the project, where they are
defined, how they are organized, and where they are passed at runtime.

Scope:

- Core `moses` executable parameters from
  `moses/moses/main/problem-params.cc` and `moses/moses/main/moses_exec_def.h`.
- Runtime parameter structs in `moses/moses/moses`,
  `moses/moses/optimization`, `moses/moses/deme`, and
  `moses/moses/metapopulation`.
- Integrated and standalone feature-selection parameters.
- Scoring, subsampling, and auxiliary utility knobs that change model search,
  scoring, candidate generation, or evaluation.

Operational input, output, logging, and formatting options are included only
where they carry values into the same structures or affect repeatability.

## Core Data Flow

The primary `moses` binary uses this flow:

```text
argv
  -> problem_manager / option_manager
  -> problem_params::add_options()
  -> boost::program_options::variables_map
  -> problem_params raw fields
  -> problem_params::parse_options()
  -> runtime structs:
       moses_parameters
       optim_parameters
       hc_parameters
       ps_parameters
       deme_parameters
       subsample_deme_filter_parameters
       metapop_parameters
       diversity_parameters
       ensemble_parameters
       feature_selector_parameters
       feature_selection_parameters
       metapop_printer
  -> problem-specific run() creates a scorer
  -> metapop_moses_results()
  -> adjust_termination_criteria() and autoscale_diversity()
  -> metapop_moses_results_b()
  -> optimizer + deme_expander + metapopulation
  -> run_moses()
  -> local_moses(), mpi_moses(), or distributed_moses()
```

Key source references:

- Raw option definitions: `moses/moses/main/problem-params.cc:153`.
- Option aliases and short flags: `moses/moses/main/moses_exec_def.h:37`.
- Raw staging fields and nested runtime structs:
  `moses/moses/main/problem-params.h:56`.
- Parse-time mapping into runtime structs:
  `moses/moses/main/problem-params.cc:2058`.
- Optimizer, deme expander, and metapopulation construction:
  `moses/moses/moses/moses_main.h:270`.
- Execution-mode dispatch: `moses/moses/moses/moses_main.cc:54`.

## Runtime Structure

| Struct | Source | Role | Main consumers |
| --- | --- | --- | --- |
| `problem_params` | `moses/moses/main/problem-params.h:56` | Raw CLI staging plus nested runtime objects. | `problem.cc`, table/demo problem `run()` methods, `parse_options()`. |
| `moses_parameters` | `moses/moses/moses/moses_params.h:40` | Top-level run limits and local/MPI/remote execution. | `run_moses()`, `local_moses()`, `mpi_moses()`, `distributed_moses()`. |
| `optim_parameters` | `moses/moses/optimization/optimization.h:73` | Generic optimizer settings. | Optimizer factory in `moses_main.h`, all optimizers. |
| `hc_parameters` | `moses/moses/optimization/hill-climbing.h:41` | Hill-climbing local search settings. | `hill_climbing` constructor and loop. |
| `ps_parameters` | `moses/moses/optimization/particle-swarm.h:46` | Particle swarm settings. | `particle_swarm`. |
| `eda_parameters` | `moses/moses/optimization/univariate.h:38` | Univariate EDA settings. | `univariate_optimization`; currently default-only in the core factory. |
| `sa_parameters` | `moses/moses/optimization/star-anneal.h:44` | Star-shaped simulated-annealing-like settings. | `simulated_annealing`; currently default-only in the core factory. |
| `deme_parameters` | `moses/moses/deme/deme_params.h:37` | Representation/deme expansion settings. | `deme_expander`, `representation`. |
| `subsample_deme_filter_parameters` | `moses/moses/metapopulation/metapop_params.h:108` | SS-deme and SS-fitness filters. | `deme_expander`, `metapopulation::subsample`. |
| `metapop_parameters` | `moses/moses/metapopulation/metapop_params.h:161` | Metapopulation selection, merge, cap, diversity, boosting. | `metapopulation`, `ensemble`, merge code. |
| `diversity_parameters` | `moses/moses/metapopulation/metapop_params.h:32` | Behavioral diversity pressure and distance functions. | `metapopulation`, `autoscale_diversity()`. |
| `ensemble_parameters` | `moses/moses/metapopulation/ensemble_params.h:30` | Boosted ensemble/expert behavior. | `ensemble`, precision table problem. |
| `feature_selector_parameters` | `moses/moses/deme/feature_selector.h:38` | Dynamic feature selection inside MOSES. | `feature_selector`, `deme_expander`. |
| `feature_selection_parameters` | `moses/feature-selection/main/feature-selection.h:46` | Feature-selection algorithm, scorer, and sub-algorithm knobs. | Standalone `feature-selection`, integrated `feature_selector`. |

## Core `moses` Hyperparameters

### Execution and Search Limits

| CLI option | Default | Runtime target | Used/passed at |
| --- | --- | --- | --- |
| `--random-seed`, `-r` | `1` | Seeds global `randGen()` | `problem_params::parse_options()`; affects all stochastic search. |
| `--jobs`, `-j` | local host gets `1` if omitted | `jobs_t jobs`, `moses_params.jobs`, `meta_params.jobs` | `setting_omp()`, remote command construction, metapop merge maintenance. |
| `--min-pool` | `50` | OpenMP pool threshold | Passed to `setting_omp(jobs[localhost], min_pool)`. |
| `--mpi` | `false` when compiled with MPI | `moses_params.mpi`, `moses_params.local` | `run_moses()` selects `mpi_moses()` when enabled. |
| `--max-evals`, `-m` | `10000` | `moses_params.max_evals` | `local_moses()` global loop and per-deme optimizer budget. |
| `--max-time` | `INT_MAX` | `moses_params.max_time` | `local_moses()` and optimizer timeout checks. |
| `--max-gens`, `-g` | `-1` | `moses_params.max_gens` | `local_moses()` generation termination. |
| `--max-score`, `-A` | `very_best_score` sentinel | `moses_params.max_score`, `optim_params.terminate_if_gte` | `adjust_termination_criteria()` and optimizer stopping. |
| `--problem`, `-H` | `it` | `problem_params.problem` | Selects table/demo problem implementation through `problem_manager`. |
| `--nsamples` | `-1` | `problem_params.nsamples` | Table subsampling and demo sampling setup. |
| `--balance` | `0` | `problem_params.balance` | Balances compressed table classes in table problem setup. |
| `--exemplar`, `-e` | none | `problem_params.exemplars` | Parsed to `combo_tree`; passed as initial bases to `metapopulation`. |

### Generic Optimizer Parameters

| CLI option | Default | Runtime target | Used/passed at |
| --- | --- | --- | --- |
| `--opt-algo`, `-a` | `hc` | `optim_params.opt_algo` | Optimizer factory chooses `hill_climbing`, `simulated_annealing`, `univariate_optimization`, or `particle_swarm`. |
| `--pop-size-ratio`, `-P` | `20` | `optim_params.pop_size_ratio` | `optim_parameters::pop_size()` for EDA-style optimizers. |
| `--max-dist`, `-D` | `4` | `optim_params.max_dist` | `optim_parameters::max_distance()`; used by widening hill-climb and star anneal. |
| scorer-derived minimum improvement | scorer-specific | `optim_params.min_score_improvement` | Set in `adjust_termination_criteria()` from `c_scorer.min_improv()`. |
| internal `term_improv` | `1.0` | `optim_params.term_improv` | `max_gens_improv()` in univariate optimization. Not CLI-exposed. |
| internal `window_size_pop` | `0.05` | `optim_params.window_size_pop` | RTR/window size calculation. Not CLI-exposed. |
| internal `window_size_len` | `1` | `optim_params.window_size_len` | RTR/window size calculation. Not CLI-exposed. |

### Hill-Climbing Parameters

| CLI option | Default | Runtime target | Used/passed at |
| --- | --- | --- | --- |
| `--hc-max-nn-evals` | `20000` | `hc_params.max_nn_evals` | Limits local-neighborhood evaluations per iteration. |
| `--hc-fraction-of-nn` | `2.0` | `hc_params.fraction_of_nn` | Controls sampled fraction of estimated nearest neighbors. |
| `--hc-crossover`, `-Z` | `true` | `hc_params.crossover` | Enables crossover path in `hill_climbing`. |
| `--hc-crossover-pop-size` | `120` | `hc_params.crossover_pop_size` | Caps newly created crossover instances per iteration. |
| `--hc-crossover-min-neighbors` | `400` | `hc_params.crossover_min_neighbors` | Crossover trigger threshold versus neighborhood size. |
| `--hc-resize-to-fit-ram` | `false` | `hc_params.resize_to_fit_ram` | Allows deme shrinking based on RAM use. |
| `--hc-allow-resize-deme` | `false` | same as above | Deprecated alias for `--hc-resize-to-fit-ram`. |
| `--hc-single-step`, `-L` | `false` | `hc_params.single_step` | Stops after first improvement when enabled. |
| `--hc-widen-search`, `-T` | `false` | `hc_params.widen_search` | Allows increasing search radius until `max_dist`. |
| internal `score_range` | `5.0` | `hc_params.score_range` | Deme shrink cutoff in `resize_by_score()`. Not CLI-exposed. |
| internal `max_allowed_instances` | `10000` | `hc_params.max_allowed_instances` | Maximum deme size after resize. Not CLI-exposed. |

### Particle Swarm Parameters

| CLI option or field | Default | Runtime target | Used/passed at |
| --- | --- | --- | --- |
| `--ps-max-particles` | `50` | `ps_params.max_parts` | Upper clamp in `particle_swarm::calc_swarm_size()`. |
| `bit_c1`, `cont_c1` | `0.7` | `ps_parameters` | Individual learning-rate constants. Not CLI-exposed. |
| `disc_c1` | `2.05` | `ps_parameters` | Discrete individual learning constant. Not CLI-exposed. |
| `bit_c2`, `cont_c2` | `1.43` | `ps_parameters` | Social constants. Not CLI-exposed. |
| `disc_c2` | `2.05` | `ps_parameters` | Discrete social constant. Not CLI-exposed. |
| `inertia` | `0.7` | `ps_parameters` | Continuous velocity update inertia. Not CLI-exposed. |
| velocity/value bounds | see `particle-swarm.h:59` | `ps_parameters` | Clamp and generation functions in `particle_swarm`. Not CLI-exposed. |

### EDA and Star-Anneal Parameters

These algorithms are selectable through `--opt-algo`, but their specialized
parameter structs are not wired to CLI options in the main `moses` binary.
The factory constructs them with defaults.

| Struct field | Default | Runtime target | Used/passed at |
| --- | --- | --- | --- |
| `eda_parameters.selection` | `2` | tournament size when `> 1` | `univariate_optimization::operator()`. |
| `eda_parameters.selection_ratio` | `1` | selected population ratio | Computes `n_select`. |
| `eda_parameters.replacement_ratio` | `0.5` | generated population ratio | Computes `n_generate`. |
| `eda_parameters.model_complexity` | `1` | model parsimony setting | Defined but not prominently used in current univariate path. |
| `sa_parameters.init_temp` | `30` | anneal temperature | `simulated_annealing`. |
| `sa_parameters.min_temp` | `0` | anneal temperature floor | `dist_temp()`. |
| `sa_parameters.temp_step_size` | `0.5` | anneal schedule field | Default-only in current code. |
| `sa_parameters.accept_prob_temp_intensity` | `0.5` | acceptance probability field | Default-only in current code. |
| `sa_parameters.max_new_instances` | `100` | max new instances | Default-only in current code. |

### Representation and Reduction Parameters

| CLI option | Default | Runtime target | Used/passed at |
| --- | --- | --- | --- |
| `--include-only-operator`, `-N` | none | `problem_params.include_only_ops_str`, then `ignore_ops` | Converted to an allowed-operator set by excluding other builtins. |
| `--ignore-operator`, `-n` | none | `deme_params.ignore_ops`, reduction rules | Passed into `representation` and logical/continuous reductions. |
| `--linear-regression` | `false` | `deme_params.linear_contin` plus extra ignored ops | Restricts continuous expressions; also ignores `div`, `exp`, `log`, `sin`. |
| `--logical-perm-ratio` | `0.0` | `deme_params.perm_ratio` | Passed to `representation` and `build_knobs` to choose logical literal pairs. |
| `--contin-depth` | `5` | global continuous representation depth | Applied through `set_depth(contin_depth)`. |
| `--reduct-knob-building-effort`, `-B` | `2` | `bool_reduct_rep` | Builds logical reduction rules for representation building. |
| `--reduct-candidate-effort`, `-E` | `2` | `bool_reduct`, `contin_reduct` | Builds reduction rules for candidate scoring and continuous reductions. |
| `--reduce-all`, `-d` | `true` | `deme_params.reduce_all` | `complexity_based_scorer` reduces all candidates before evaluation when true. |
| `--cache-size`, `-s` | `3000` | `behave_cscore` cache size | Passed when problem-specific scorer is wrapped. Set to `0` for boosting and SS modes. |

Note: `deme_parameters::max_candidates_per_deme` is declared, but the current
main parse path writes `--max-candidates-per-deme` into
`metapop_parameters::max_candidates_per_deme`, which is the field actually used
while retaining top candidates after deme optimization.

### Metapopulation, Complexity, and Boosting

| CLI option | Default | Runtime target | Used/passed at |
| --- | --- | --- | --- |
| `--complexity-temperature`, `-v` | `6.0` | `meta_params.complexity_temperature` | Boltzmann-like exemplar selection in `metapopulation::select_exemplar()`. |
| `--complexity-ratio`, `-z` | `3.5` | scorer complexity coefficient | Used by `set_noise_or_ratio()` unless `--noise` is non-negative. |
| `--noise`, `-p` | `-1` | scorer complexity coefficient | If `>= 0`, overrides complexity ratio using scorer-specific noise formula. |
| `--cap-coef` | `50.0` | `meta_params.cap_coef` | Metapopulation cap formula in `metapopulation::cap_population()`. |
| `--max-candidates-per-deme`, `-M` | `-1` | `meta_params.max_candidates_per_deme` | Limits unique top candidates kept from each deme. |
| `--revisit` | `0` | `meta_params.revisit` | Limits how often an exemplar may be selected for expansion. |
| `--discard-dominated` | `false` | `meta_params.discard_dominated` | Controls dominated candidate handling during merge. |
| `--boost` | `false` | `meta_params.do_boosting`, `ensemble_params.do_boosting` | Enables boosted scoring/ensemble behavior where supported. |
| `--boost-promote` | `1` | `ensemble_params.num_to_promote` | Max candidates promoted to ensemble per cycle. |
| `--boost-exact` | `true` | `ensemble_params.exact_experts` | Precision ensemble expert strictness. |
| `--boost-expalpha` | `2.0` | `ensemble_params.expalpha` | Exact-expert boosting coefficient. |
| `--boost-bias` | `1.0` | `ensemble_params.bias_scale` | Inexact-expert bias scaling. |

### Diversity Parameters

| CLI option | Default | Runtime target | Used/passed at |
| --- | --- | --- | --- |
| `--diversity-pressure` | `0.0` | `meta_params.diversity.pressure` | Enables uniformity penalty when `> 0`. |
| `--diversity-autoscale` | `false` | `meta_params.diversity.autoscale` | `autoscale_diversity()` rescales pressure by scorer magnitude. |
| `--diversity-exponent` | `-1.0` | `meta_params.diversity.exponent` | Aggregates diversity penalties, negative means max. |
| `--diversity-normalize` | `true` | `meta_params.diversity.normalize` | Chooses generalized mean versus generalized sum behavior. |
| `--diversity-dst` | `p_norm` | `diversity.set_dst()` | Behavioral distance: `p_norm`, `tanimoto`, or `angular`. |
| `--diversity-p-norm` | `2.0` | `diversity.set_dst(p_norm, p)` | P parameter for p-norm distance. |
| `--diversity-dst2dp` | `auto` | `diversity.set_dst2dp()` | Distance-to-penalty function: auto, inverse, complement, or power. |

### Subsample Deme and Fitness Parameters

| CLI option | Default | Runtime target | Used/passed at |
| --- | --- | --- | --- |
| `--ss-n-subsample-demes` | `0` | `filter_params.n_subsample_demes` | Enables SS-deme behavior when `> 1`; used by `deme_expander` and metapop filters. |
| `--ss-n-top-candidates` | `1` | `filter_params.n_top_candidates` | Candidate count for score variance and SS filtering. |
| `--ss-n-tuples` | `UINT_MAX` | `filter_params.n_tuples` | Tuple sampling cap for variance/agreement estimates. |
| `--ss-std-dev-threshold` | max float | `filter_params.std_dev_threshold` | Score standard-deviation pass threshold. |
| `--ss-tanimoto-mean-threshold` | `1.0` | `filter_params.tanimoto_mean_threshold` | Tanimoto mean filter threshold. |
| `--ss-tanimoto-geometric-mean-threshold` | `1.0` | `filter_params.tanimoto_geo_mean_threshold` | Tanimoto geometric mean filter threshold. |
| `--ss-tanimoto-max-threshold` | `1.0` | `filter_params.tanimoto_max_threshold` | Tanimoto max filter threshold. |
| `--ss-n-best-bfdemes` | `0` | `filter_params.n_best_bfdemes` | Selects best breadth-first demes by aggregate agreement distance. |
| `--ss-tanimoto-mean-weight` | `0.0` | `filter_params.tanimoto_mean_weight` | Aggregate agreement distance weight. |
| `--ss-tanimoto-geometric-mean-weight` | `0.0` | `filter_params.tanimoto_geo_mean_weight` | Aggregate agreement distance weight. |
| `--ss-tanimoto-max-weight` | `0.0` | `filter_params.tanimoto_max_weight` | Aggregate agreement distance weight. |
| `--ss-n-subsample-fitnesses` | `0` | `filter_params.n_subsample_fitnesses` | Enables SS-fitness wrapper when `> 1`. |
| `--ss-low-dev-pressure` | `1.0` | `filter_params.low_dev_pressure` | Low score-deviation pressure for SS-fitness. |
| `--ss-by-time` | `0` | `filter_params.by_time` | Chooses timestamp-based subsampling. |
| `--ss-contiguous-time` | `1` | `filter_params.contiguous_time` | Uses contiguous time segments for timestamp subsampling. |

### Scoring and Problem-Specific Parameters

| CLI option | Default | Runtime target | Used/passed at |
| --- | --- | --- | --- |
| `--min-rand-input`, `-q` | `0.0` | `problem_params.min_rand_input` | Sampling range and activation/precision/recall bounds depending on problem. |
| `--max-rand-input`, `-w` | `1.0` | `problem_params.max_rand_input` | Sampling range and activation/precision/recall bounds depending on problem. |
| `--alpha`, `-Q` | `1.0` | `problem_params.hardness` | Constraint hardness or activation pressure for precision/recall/select scorers. |
| `--weighted-accuracy`, `-G` | `false` | `problem_params.weighted_accuracy` | `discretize_contin_bscore` scoring when thresholds are used. |
| `--discretize-threshold`, `-R` | none | `problem_params.discretize_thresholds` | Converts continuous target into classes for `discretize_contin_bscore`. |
| `--time-dispersion-pressure` | `0.0` | `problem_params.time_dispersion_pressure` | Precision scorer time activation dispersion penalty. |
| `--time-dispersion-exponent` | `1.0` | `problem_params.time_dispersion_exponent` | Distorts the time dispersion penalty. |
| `--time-bscore` | `false` | `problem_params.time_bscore` | Spreads bscore across timestamps instead of data points. |
| `--time-bscore-granularity` | `day` | `problem_params.time_bscore_granularity` | `day` or `month` timestamp grouping. |
| `--gen-best-tree` | `false` | `problem_params.gen_best_tree` | Precision problem can add canonical best candidate as an exemplar. |
| `--it-abs-err` | `false` | `problem_params.it_abs_err` | Uses absolute rather than squared error for continuous `it` scoring. |
| `--pre-positive` | `true` | `problem_params.pre_positive` | Precision/select/IP sign: precision versus negative predictive value. |
| `--well-enough` | `false` | `problem_params.use_well_enough` | Uses `partial_solver` for enum `it` problems. |
| `--ip_kld_weight`, `-K` | `1.0` | `ip_problem_params.ip_kld_weight` | Interesting-predicate scorer term. |
| `--ip_skewness_weight`, `-J` | `1.0` | `ip_problem_params.ip_skewness_weight` | Interesting-predicate scorer term. |
| `--ip_stdU_weight`, `-U` | `1.0` | `ip_problem_params.ip_stdU_weight` | Interesting-predicate scorer term. |
| `--ip_skew_U_weight`, `-X` | `1.0` | `ip_problem_params.ip_skew_U_weight` | Interesting-predicate scorer term. |
| `--problem-size`, `-k` | `5` | `demo_params.problem_size` | Demo problem arity/order for parity, disjunction, majority, mux, and polynomial regression. |
| `--combo-program`, `-y` | none | `demo_params.combo_str` | Target combo program for the `cp` demo problem. |

Table data options are not hyperparameters in the optimizer sense, but they
change the effective training/evaluation problem:

- `--input-file`, `-i`: one or more input tables.
- `--target-feature`, `-u`: target label.
- `--score-weight`: table column used as row weights during scoring.
- `--timestamp-feature`: timestamp column used by time-aware scoring and
  subsampling.
- `--ignore-feature`, `-Y`: removes input features before training.

## Integrated Feature Selection Inside `moses`

Integrated feature selection is enabled before representation building during
deme expansion. The path is:

```text
problem_params::parse_options()
  -> festor_params and fs_params
  -> table problem run()
  -> pms.deme_params.fstor = new feature_selector(...)
  -> deme_expander::create_representations()
  -> feature_selector::operator()
  -> select_feature_sets()
  -> selected features determine considered arguments for representation()
```

| CLI option | Default in `moses` | Runtime target | Used/passed at |
| --- | --- | --- | --- |
| `--enable-fs` | `false` | `problem_params.enable_feature_selection` | Enables dynamic feature selection in table problem `run()` methods. |
| `--fs-target-size` | `20` | `fs_params.target_size` | Number of selected features. |
| `--fs-exp-distrib` | `false` | `fs_params.exp_distrib` | Soft exponential feature sampling for supported selectors. |
| `--fs-focus` | `incorrect` | `festor_params.restrict_incorrect`, `restrict_true` | Selects rows used by feature selection: all, active, incorrect, or active-incorrect. |
| `--fs-seed` | `add` | `increase_target_size`, `ignore_xmplr_features`, `init_xmplr_features`, `xmplr_as_feature` | Controls how exemplar features seed or constrain selection. |
| `--fs-prune-exemplar` | `0` | `festor_params.prune_xmplr` | Removes non-selected feature literals from exemplar. |
| `--fs-subsampling-ratio` | `1` | `festor_params.subsampling_ratio` | Randomly subsamples data before selecting features. |
| `--fs-subsampling-by-time` | `0` | `festor_params.subsampling_by_time` | Applies subsampling to timestamps instead of rows. |
| `--fs-demes` | `1` | `festor_params.n_demes` | Number of selected feature sets and spawned demes per exemplar. |
| `--fs-algo` | `simple` | `fs_params.algorithm` | Chooses `simple`, `inc`, `smd`, `random`, or `hc`. |
| `--fs-scorer` | `mi` | `fs_params.scorer` | Chooses mutual-information or precision scorer. |
| `--fs-threshold` | `0` | `fs_params.threshold` | Minimum improvement or MI threshold. |
| `--fs-enforce-features-filename` | none | `festor_params.enforce_features` | File of features and optional insertion probabilities. |
| `--fs-diversity-pressure` | `0.0` | `festor_params.diversity_pressure` | Penalizes similar selected feature sets when multiple demes are requested. |
| `--fs-diversity-cap` | `100` | `festor_params.diversity_cap` | Caps feature-set population before diversity ranking. |
| `--fs-diversity-interaction` | `-1` | `festor_params.diversity_interaction` | Interaction depth for MI-based feature-set diversity. |
| `--fs-diversity-jaccard` | `true` | `festor_params.diversity_jaccard` | Uses Jaccard feature-set diversity instead of MI. |
| `--fs-inc-redundant-intensity` | `-1.0` | `fs_params.inc_red_intensity` | Incremental selector redundancy penalty. |
| `--fs-inc-target-size-epsilon` | `1.0e-6` | `fs_params.inc_target_size_epsilon` | Tolerance for fixed-size incremental selection. |
| `--fs-inc-interaction-terms` | `1` | `fs_params.inc_interaction_terms` | Interaction terms for incremental selection. |
| `--fs-pre-penalty` | `1.0` | `fs_params.pre_penalty` | Feature-selection precision scorer activation penalty. |
| `--fs-pre-min-activation` | `0.5` | `fs_params.pre_min_activation` | Feature-selection precision scorer bound. |
| `--fs-pre-max-activation` | `1.0` | `fs_params.pre_max_activation` | Feature-selection precision scorer bound. |
| `--fs-pre-positive` | `true` | `fs_params.pre_positive` | Precision versus negative predictive value. |
| `--fs-hc-max-score` | `1` | `fs_params.hc_max_score` | Hill-climbing feature-selection termination score. |
| `--fs-hc-max-evals` | `10000` | `fs_params.hc_max_evals` | Hill-climbing feature-selection evaluation budget. |
| `--fs-hc-fraction-of-remaining` | `0.5` | `fs_params.hc_fraction_of_remaining` | Feature-selection HC budget allocation. |
| `--fs-hc-crossover` | `false` | `fs_params.hc_crossover` | Feature-selection HC crossover. |
| `--fs-hc-crossover-pop-size` | `120` | `fs_params.hc_crossover_pop_size` | Feature-selection HC crossover size. |
| `--fs-hc-crossover-min-neighbors` | `400` | `fs_params.hc_crossover_min_neighbors` | Feature-selection HC crossover trigger. |
| `--fs-hc-widen-search` | `true` | `fs_params.hc_widen_search` | Feature-selection HC widening. |
| integrated `hc_cache_size` | constructor default `1000` | `fs_params.hc_cache_size` | Used if `--fs-algo hc`; not exposed as a `moses` CLI option. |
| `--fs-mi-penalty` | `100.0` | `fs_params.mi_confi` | Mutual-information confidence penalty. |
| `--fs-smd-top-size` | `10` | `fs_params.smd_top_size` | Candidate count for stochastic max dependency. |

## Standalone `feature-selection` Executable

The standalone feature-selection tool parses directly into
`feature_selection_parameters` in `moses/feature-selection/main/fs-main.cc`.
The flow is:

```text
argv
  -> fs_params
  -> randGen().seed(random-seed)
  -> setting_omp(fs_params.jobs)
  -> loadTable(...)
  -> optional table subsampling
  -> feature_selection(table, fs_params)
  -> select_feature_sets()
```

Defaults that differ from integrated MOSES feature selection:

| Option | Standalone default | Integrated `moses` default | Runtime target |
| --- | --- | --- | --- |
| `--target-size`, `-C` / `--fs-target-size` | `0` | `20` | `fs_params.target_size` |
| `--inc-redundant-intensity`, `-D` / `--fs-inc-redundant-intensity` | `0.1` | `-1.0` | `fs_params.inc_red_intensity` |
| `--inc-target-size-epsilon`, `-E` / `--fs-inc-target-size-epsilon` | `0.001` | `1.0e-6` | `fs_params.inc_target_size_epsilon` |
| `--cache-size`, `-s` | `1000000` | constructor default `1000`, no integrated CLI option | `fs_params.hc_cache_size` |
| `--log-level`, `-l` | `DEBUG` | `INFO` in `moses` | logging only |

Standalone-only or differently named options:

| CLI option | Default | Runtime target | Used/passed at |
| --- | --- | --- | --- |
| `--algo`, `-a` | `simple` | `fs_params.algorithm` | `select_feature_sets()`. |
| `--scorer`, `-H` | `mi` | `fs_params.scorer` | `fs_scorer`. |
| `--input-file`, `-i` | required | `fs_params.input_file` | `loadTable()`. |
| `--target-feature`, `-u` | first target if omitted | `fs_params.target_feature_str` | `loadTable()`. |
| `--timestamp-feature` | none | `fs_params.timestamp_feature_str` | `loadTable()`. |
| `--ignore-feature`, `-Y` | none | `fs_params.ignore_features_str` | `loadTable()`. |
| `--force-feature`, `-e` | none | `fs_params.force_features_str` | Added after selected feature set is found. |
| `--initial-feature`, `-f` | none | `fs_params.initial_features` | Initial feature set for supported algorithms. |
| `--jobs`, `-j` | `1` | `fs_params.jobs` | `setting_omp()`. |
| `--random-seed`, `-r` | `1` | global RNG | Stochastic selectors and subsampling. |
| `--max-time` | `INT_MAX` | `fs_params.max_time` | HC feature-selection optimizer. |
| `--subsampling-ratio` | `1` | `fs_params.subsampling_ratio` | Standalone table subsampling. |
| `--hc-fraction-of-nn` | `2.0` | `fs_params.hc_fraction_of_nn` | HC feature-selection search. |
| `--smd-top-size` | `10` | `fs_params.smd_top_size` | SMD feature-selection algorithm. |
| `--mi-penalty`, `-c` | `100.0` | `fs_params.mi_confi` | MI confidence penalty. |
| `--pre-penalty` | `1.0` | `fs_params.pre_penalty` | Precision feature-set scorer. |
| `--pre-min-activation` | `0.5` | `fs_params.pre_min_activation` | Precision feature-set scorer. |
| `--pre-max-activation` | `1.0` | `fs_params.pre_max_activation` | Precision feature-set scorer. |
| `--pre-positive` | `true` | `fs_params.pre_positive` | Precision versus NPV scorer. |

## Evaluation and Utility Hyperparameters

These tools do not train MOSES, but they use tunable evaluation/scoring
parameters.

| Tool | Parameter | Default | Used/passed at |
| --- | --- | --- | --- |
| `eval-candidate` | `--random-seed`, `-r` | `1` | Seeds global RNG. |
| `eval-candidate` | `--jobs`, `-j` | `1` | `setting_omp(ecp.jobs, 10)`. |
| `eval-candidate` | `--problem`, `-H` | `f_one` | Selects scorer: recall, prerec, f_one, bep, it, pre. |
| `eval-candidate` | `--alpha`, `-Q` | `1.0` | Activation pressure/hardness for selected scorer. |
| `eval-candidate` | short `-q` | `0.0` | Minimum activation, recall, precision, or BEP range. |
| `eval-candidate` | short `-w` | `1.0` | Maximum activation, recall, precision, or BEP range. |
| `eval-candidate` | `--pre-positive` | `true` | Precision versus negative predictive value. |
| `eval-candidate-likelihood` | `--problem`, `-H` | `it` | Likelihood problem type. |
| `eval-candidate-likelihood` | `--noise`, `-p` | `0.0` | Likelihood/noise model. |
| `eval-candidate-likelihood` | `--complexity-amplifier` | `1.0` | Scales complexity penalty. |
| `eval-candidate-likelihood` | `--normalize`, `-n` | `false` | Normalizes candidate weights. |
| `eval-candidate-likelihood` | `--prerec-min-recall` | `0.0` | Prerec likelihood bound. |
| `eval-candidate-likelihood` | `--prerec-simple-precision` | `false` | Simpler prerec weight mode. |
| `eval-diversity` | `--diversity-dst` | `p_norm` | Diversity distance type. |
| `eval-diversity` | `--diversity-p-norm` | `2.0` | P-norm distance parameter. |
| `eval-features` | `--random-seed`, `-r` | `1` | Seeds global RNG. |
| `eval-features` | `--scorer`, `-H` | `mi` | Feature-set scorer. |
| `eval-features` | `--confidence-penalty-intensity`, `-d` | `0` | Confidence penalty for feature-set quality. |
| `gen-table` | `--random-seed`, `-r` | `1` | Table generation RNG. |
| `gen-table` | `--nsamples`, `-n` | `-1` | Number of generated samples. |
| `gen-table` | `--min-contin`, `-m` | `0` | Generated continuous-value lower bound. |
| `gen-table` | `--max-contin`, `-M` | `1` | Generated continuous-value upper bound. |
| `gen-table` | `--target_index`, `-t` | `0` | Target output column index. |
| `gen-disj-conj` | `--rand`, `-r` | `0` | Generation RNG. |
| `gen-disj-conj` | `--disj-children`, `-d` | `10` | Generated disjunction children. |
| `gen-disj-conj` | `--conj-children`, `-c` | `10` | Generated conjunction children. |
| `gen-disj-conj` | `--conj-children-std` | `0` | Stddev for conjunction children. |
| `gen-disj-conj` | `--repl-prob` | `0.0` | Replacement probability. |

## Example Programs and Hardcoded Tuning

The `examples` directory contains toy programs and demos with their own
command-line arguments or hardcoded values. These are not part of the main
`moses` option system, but they are useful when tracing project-wide knobs.

| Location | Parameters | How used |
| --- | --- | --- |
| `examples/example-progs/edaopt.h` | `rand_seed`, `length`, `popsize`, `max_gens`; derived `n_select=popsize`, `n_generate=popsize/2` | Shared parser for simple EDA examples such as one-max, n-max, and contin-max. |
| `examples/example-progs/onemax.cc` and similar | `tournament_selection(2)` | Hardcoded selection policy in toy EDA examples. |
| `examples/example-ant/moses-ant-hillclimbing.cc` | CLI `seed`, `maxevals`; hardcoded `n_jobs=4`, `complexity_ratio=0.16`, `complexity_temperature=2000`, HC crossover enabled | Constructs `deme_expander`, `metapopulation`, and `moses_parameters` directly. |
| `examples/example-ant/moses-ant-particleswarm.cc` | CLI `seed`, `maxevals`; hardcoded `n_jobs=4`, `complexity_ratio=0.16`, `complexity_temperature=2000`, `opt_algo=ps` | Constructs particle swarm optimizer directly. |
| `examples/example-progs/moses-ann-xor.cc` | CLI `max_eval`, `seed`, `step_size`, `expansion`, `depth`, `reduce?` | Direct ANN demo construction with univariate optimization. |
| `examples/example-progs/moses-ann-pole*.cc` | seed/max-eval style demo parameters plus ANN representation constants | Direct MOSES demo construction, often with hardcoded scoring and representation settings. |
| `moses/pleasure/pleasure` | enumeration depth and type tree are hardcoded by caller; README says variables are coded in | `pleasure/main/main.cpp` calls `enumerate_program_trees(..., 3, ...)`; no standalone hyperparameter parser. |

## Short Notes and Caveats

- The core `moses` parser intentionally stages many values in `problem_params`
  and only later copies them into nested structs in `parse_options()`.
- Some defaults differ between struct constructors and CLI registration. The
  CLI defaults are the user-visible defaults for executable runs.
- `--noise` and `--complexity-ratio` are mutually related in practice:
  `set_noise_or_ratio()` uses noise when `noise >= 0`, otherwise it uses the
  complexity ratio.
- `--boost` disables composite-score caching because cached weighted scores can
  become stale.
- SS-deme or SS-fitness modes also disable the candidate cache because the same
  candidate is evaluated over changing sampled fitness functions.
- The star-anneal and univariate optimizers still exist, but the option text
  says they have bit-rotted; only hill-climbing is described as working well.
