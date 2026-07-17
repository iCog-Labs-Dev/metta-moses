;; ============================================================
;; ttt-action-smoke-test.metta -- end-to-end ACTION-domain smoke test.
;;
;; Two birds with one file:
;;   1. Proof the whole generic action pipeline (representation -> deme ->
;;      hillclimbing -> scoring -> metapopulation) completes a real (small)
;;      MOSES evolution run and improves on the empty and_seq exemplar.
;;   2. A living demo of the "add a new action experiment with ZERO pipeline
;;      edits" recipe: this test defines its OWN fitness (smokeFitness,
;;      random-player only) below and binds it through the four action
;;      params, reusing the tic-tac-toe action primitives -- exactly what a
;;      user adding an experiment would do.
;;
;; The run assembly mirrors moses-run-action (moses/demo-problems.metta)
;; directly: same empty-exemplar metapop seed, same tagged
;; (mkActionCtx $nGames $cpxPen) context, same runMoses call.
;; Tests never import moses.metta, so runMoses is called here by hand.
;;
;; Import order mirrors moses.metta top to bottom (registry+defaults FIRST;
;; PeTTa gates reduction on load order, so the stack must match).
;; ============================================================

!(import! &self ../../utilities/general-helpers)
!(import! &self ../../parameters/registry)
!(import! &self ../../parameters/defaults)

!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/pair)
!(import! &self ../../utilities/map)
!(import! &self ../../utilities/ordered-multimap)
!(import! &self ../../utilities/ordered-set)
!(import! &self ../../utilities/ordered-multiset)
!(import! &self ../../utilities/nodeId)
!(import! &self ../../utilities/lazy-random-selector)
!(import! &self ../../utilities/lru-cache)

!(import! &self ../../reduct/boolean-reduct/rte-helpers)
!(import! &self ../../reduct/boolean-reduct/cut-unnecessary-or)
!(import! &self ../../reduct/boolean-reduct/cut-unnecessary-and)
!(import! &self ../../reduct/boolean-reduct/n-ary-propagate-not)
!(import! &self ../../reduct/boolean-reduct/n-ary-gather-junctors)
!(import! &self ../../reduct/boolean-reduct/delete-inconsistent-handle)
!(import! &self ../../reduct/boolean-reduct/zero-constraint-subsumption)
!(import! &self ../../reduct/boolean-reduct/one-constraint-subsumption)
!(import! &self ../../reduct/boolean-reduct/promote-common-constraints)
!(import! &self ../../reduct/boolean-reduct/reduce-to-elegance)

!(callPredicate (Predicate (consult "moses/tests/rte-helpers-fast.pl")))

!(import! &self ../../utilities/tree)

!(import! &self ../../scoring/cacheSpace)
!(import! &self ../../scoring/fitness)
!(import! &self ../../scoring/boolean-ops)
!(import! &self ../../scoring/action-registry)
!(import! &self ../../scoring/action-eval)
!(import! &self ../../scoring/action-ops)
!(import! &self ../../scoring/bscore)
!(import! &self ../../scoring/cscore)
!(import! &self ../../scoring/action-score)

!(import! &self ../../feature-selection/feature-selection-helpers)
!(import! &self ../../feature-selection/similarity-scorers)
!(import! &self ../../feature-selection/select-top-features)
!(import! &self ../../feature-selection/simple)
!(import! &self ../../feature-selection/smd)
!(import! &self ../../feature-selection/incremental)
!(import! &self ../../feature-selection/hc)
!(import! &self ../../feature-selection/random-feature-selection)
!(import! &self ../../feature-selection/feature-selection-main)

!(import! &self ../../representation/knob-representation)
!(import! &self ../../representation/lsk)
!(import! &self ../../representation/disc-probe)
!(import! &self ../../representation/logical-probe)
!(import! &self ../../representation/sample-logical-perms)
!(import! &self ../../representation/logical-canonize)
!(import! &self ../../representation/add-logical-knobs)
!(import! &self ../../representation/build-logical)
!(import! &self ../../representation/build-action)
!(import! &self ../../representation/build-knobs)
!(import! &self ../../representation/knob-mapper)
!(import! &self ../../representation/representation)
!(import! &self ../../representation/create-representation)

!(import! &self ../../scoring/complexity-based-scorer)

!(import! &self ../../examples/tic-tac-toe/tic-tac-toe-helpers)
!(import! &self ../../examples/tic-tac-toe/moves)
!(import! &self ../../examples/tic-tac-toe/random-player)
!(import! &self ../../examples/tic-tac-toe/minimax-player)
!(import! &self ../../examples/tic-tac-toe-action/ttt-action-world)
!(import! &self ../../examples/tic-tac-toe-action/ttt-action-primitives)
!(import! &self ../../examples/tic-tac-toe-action/ttt-action-episode)
!(import! &self ../../examples/tic-tac-toe-action/ttt-action-registration)

!(import! &self ../../optimization/hillclimbing/crossover-helpers)
!(import! &self ../../optimization/hillclimbing/crossover)
!(import! &self ../../optimization/hillclimbing/hill-climbing-helpers)

!(import! &self ../../deme/create-deme)
!(import! &self ../neighborhood-sampling)

!(import! &self ../../metapopulation/exemplar-type)
!(import! &self ../../metapopulation/exemplar-selection)
!(import! &self ../../metapopulation/metapopulation)

!(import! &self ../../representation/instance)

!(import! &self ../../deme/deme-id-creation)
!(import! &self ../../deme/score-deme)
!(import! &self ../../deme/merge-demes)
!(import! &self ../../deme/expand-deme)

;; ---- Deterministic run: pin the RNG ----
!(py-call (random.seed 0))

;; ============================================================
;; THE RECIPE DEMO -- binding a NEW action fitness with zero pipeline
;; edits. This is the exact template from
;; examples/tic-tac-toe-action/ttt-action-registration.metta, instantiated
;; for a test-local fast variant: tic-tac-toe against random-player ONLY,
;; every ordinal (minimax is the expensive opponent; dropping it keeps the
;; smoke run fast AND demonstrates that a fitness fully owns its
;; ordinal->opponent mapping). The primitives themselves
;; (tttWin/tttBlock/... bare-head clauses) come from the
;; ttt-action-primitives import above; an experiment contributes NOTHING
;; beyond its fitness clauses + the four set-param bindings.
;; ============================================================

;; ---- 1. The fitness: ($fn $exp $i) -> Number; the ordinal is ignored,
;;         every episode plays random-player (reuses the ttt episode loop) --
(= (smokeFitness $exp $i) (tttActionEpisode $exp random-player))

;; ---- 2. Best reachable raw score: every episode plays random-player,
;;         and every game against random-player is winnable -> 1.0 each ----
(= (smokeBestScore $n) (* 1.0 $n))

;; ---- 3. Bind the experiment through the global params. quote is REQUIRED
;;         on both vocabulary tuples at the set-param site: the primitives
;;         are live bare-head clauses, so an unquoted tuple headed by one
;;         curries into a `partial` term (probe-verified; quote strips on
;;         set, the params hold the plain tuples) ----
!(set-param fitness smokeFitness)
!(set-param bestScore smokeBestScore)
!(set-param actions (quote (tttWin tttBlock tttCenter tttCorner tttSide)))
!(set-param perceptions (quote (tttCanWin tttCanBlock tttCenterFree)))

;; The binding is live before the run: the configured fitness symbol is
;; discoverable and the best-score function answers through the same
;; var-head dispatch the runner uses.
!(assertEqual (param fitness) smokeFitness)
!(assertEqual (let $fn (param bestScore) ($fn 4)) 4.0)

;; ============================================================
;; Small-run parameters (the moses-run-action assembly, shrunk):
;; 2 generations, 1 deme, 4 episodes/candidate, 60 hillclimbing evals.
;; ============================================================
!(set-param maxCandOutput 3)
!(set-param hcMaxEvals 60)
;; genCount feeds the cap-size formula inside resizeMetapop; moses-run-action
;; seeds it with the run's maxGen.
!(set-param genCount 2)

;; Metapop seed: the empty and_seq exemplar at the defined-worst score,
;; exactly as moses-run-action builds it -- every one of the 4 episodes
;; forfeits at -1.0 (empty-exemplar loophole), so raw = penalized = -4.0.
(= (smokeMetaPop)
   ((mkExemplar (mkTree (mkNode and_seq) ())
                (mkDemeId "1")
                (mkCscore -4.0 0 3.5 0 -4.0)
                (mkBScore (List.repeat 4 -1.0)))))

;; Root symbol of an exemplar's tree passes the structural-operator registry
;; check (the same isActionOperator the knob builder dispatches on).
(= (exemplarRootIsAction (mkExemplar (mkTree (mkNode $root) $children) $id $cscore $bscore))
   (isActionOperator $root))

;; ============================================================
;; THE RUN -- 2 generations, nDeme 1, nGames 4, target 4.0 (all wins; not
;; expected to be reached in 2 generations, so the run exits via maxGen).
;; Structural assertions only -- no exact evolved trees pinned:
;;   - the returned metapop is non-empty;
;;   - the TOP exemplar's raw score is strictly POSITIVE: the evolved
;;     policy wins more episodes than it loses. Observed under seed 0:
;;     raw 2.0 (bscore (1.0 1.0 -1.0 1.0)) for the composite conditional
;;     (and_seq (action_bool_if tttCenterFree (and_seq tttCorner)
;;               (and_seq tttSide tttCorner)) tttWin)
;;     -- far past the -4.0 empty-exemplar seed. If a runtime with a
;;     diverging py-call random draw order ever breaks this, relax the
;;     bound to (> $topRaw -4.0) (any improvement over the seed);
;;   - at least one returned exemplar is action-rooted.
;; ============================================================
!(assertEqual
  (let* (
      ($result (runMoses 2 4.0 (smokeMetaPop) 0 1
                         (mkActionCtx 4 3.5)
                         hillClimbing))
      ($_ (println! ""))
      ($_ (println! "==== Smoke-run result (tree preorder + bscore sum) ===="))
      ($_ (mapG printExemplar $result))
      ($len (OS.length $result))
      ($top (OS.getByIdx 0 $result))
      ($topRaw (getScore (getExemplarCscore $top)))
      ($_ (println! (TopRawScore: $topRaw)))
      ($anyActionRooted (any (map-atom $result exemplarRootIsAction)))
  )
  ((> $len 0) (> $topRaw 0.0) $anyActionRooted))
  (True True True))
