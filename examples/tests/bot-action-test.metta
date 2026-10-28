;; ============================================================================
;; bot-action-test.metta -- the corridor-robot ACTION domain, end to end.
;;
;; This file is BOTH a readable tour of the generic action evaluator AND a
;; real regression test: every step below is an assertEqual, so the expected
;; world / score is visible without running the file, and the suite checks it.
;;
;;   PART 1: the domain -- one bare-head clause per action / perception
;;   PART 2: RUN hand-written programs            (evalAction)
;;   PART 3: SCORE programs                        (scoreActionTree / cscore)
;;   PART 4: EVOLVE a program end to end           (runMoses) and show the
;;           optimal policy MOSES returns
;;
;; The evaluator, scorer, and pipeline are domain-agnostic: everything
;; bot-specific lives in PART 1 and the fitness in PART 3. Adding this whole
;; domain to MOSES took ZERO pipeline edits -- only the four set-param
;; bindings in PART 4.
;;
;; Import order mirrors moses.metta top to bottom (registry+defaults FIRST;
;; PeTTa gates reduction on load order). Tests never import moses.metta, so
;; PART 4 calls runMoses by hand exactly as moses-run-action assembles it.
;; ============================================================================

!(import! &self utilities/general-helpers)
!(import! &self parameters/registry)
!(import! &self parameters/defaults)

!(import! &self utilities/list-methods)
!(import! &self utilities/pair)
!(import! &self utilities/map)
!(import! &self utilities/ordered-multimap)
!(import! &self utilities/ordered-set)
!(import! &self utilities/ordered-multiset)
!(import! &self utilities/nodeId)
!(import! &self utilities/lazy-random-selector)
!(import! &self utilities/lru-cache)

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

!(callPredicate (Predicate (consult "moses/tests/rte-helpers-fast.pl")))

!(import! &self utilities/tree)

!(import! &self scoring/cacheSpace)
!(import! &self scoring/fitness)
!(import! &self scoring/boolean-ops)
!(import! &self scoring/action-registry)
!(import! &self scoring/action-eval)
!(import! &self scoring/action-ops)
!(import! &self scoring/bscore)
!(import! &self scoring/cscore)
!(import! &self scoring/action-score)

!(import! &self feature-selection/feature-selection-helpers)
!(import! &self feature-selection/similarity-scorers)
!(import! &self feature-selection/select-top-features)
!(import! &self feature-selection/simple)
!(import! &self feature-selection/smd)
!(import! &self feature-selection/incremental)
!(import! &self feature-selection/hc)
!(import! &self feature-selection/random-feature-selection)
!(import! &self feature-selection/feature-selection-main)

!(import! &self representation/knob-representation)
!(import! &self representation/lsk)
!(import! &self representation/disc-probe)
!(import! &self representation/logical-probe)
!(import! &self representation/sample-logical-perms)
!(import! &self representation/logical-canonize)
!(import! &self representation/add-logical-knobs)
!(import! &self representation/build-logical)
!(import! &self representation/build-action)
!(import! &self representation/build-knobs)
!(import! &self representation/knob-mapper)
!(import! &self representation/representation)
!(import! &self representation/create-representation)

!(import! &self scoring/complexity-based-scorer)

!(import! &self optimization/hillclimbing/crossover-helpers)
!(import! &self optimization/hillclimbing/crossover)
!(import! &self optimization/hillclimbing/hill-climbing-helpers)

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

;; ============================================================================
;; PART 1 -- THE DOMAIN: a robot in a 1-D corridor.
;;
;; World: (mkBotWorld $pos $fuel). The robot stands at $pos (0,1,2,...); the
;; GOAL is position 3. Every move costs 1 fuel. The whole contract is one
;; clause per action/perception, shaped
;;     (= (<name> $params $world) (mkARes <Bool> <newWorld>))
;; the evaluator dispatches these clauses and knows nothing about robots.
;; ============================================================================

;; ACTION botForward: step right. Fails (False) when out of fuel.
(= (botForward $params (mkBotWorld $pos $fuel))
   (if (> $fuel 0)
       (mkARes True  (mkBotWorld (+ $pos 1) (- $fuel 1)))
       (mkARes False (mkBotWorld $pos $fuel))))

;; ACTION botBackward: step left (floor at 0). Also costs fuel.
(= (botBackward $params (mkBotWorld $pos $fuel))
   (if (> $fuel 0)
       (if (> $pos 0)
           (mkARes True  (mkBotWorld (- $pos 1) (- $fuel 1)))
           (mkARes False (mkBotWorld $pos $fuel)))
       (mkARes False (mkBotWorld $pos $fuel))))

;; PERCEPTION botAtGoal: True iff standing on the goal; world untouched.
;; Perceptions and actions share one result protocol -- that is what lets
;; and_seq / action_bool_if treat any child alike.
(= (botAtGoal $params (mkBotWorld $pos $fuel))
   (mkARes (== $pos 3) (mkBotWorld $pos $fuel)))

;; ============================================================================
;; PART 2 -- RUN hand-written programs with evalAction.
;;
;; A program is nested (op (child ...)) nodes; leaves are (name ()). Every
;; literal sits under (quote ...): the operator names are live bare-head
;; clauses, so an unquoted literal in an evaluated position would compile as a
;; CALL. Quote strips on evaluation -- evalAction receives the raw expression.
;; ============================================================================

;; 2a. One action from pos 0 with 5 fuel -> success, robot now at 1, fuel 4.
!(assertEqual (evalAction (quote (botForward ())) (mkBotWorld 0 5))
              (mkARes True (mkBotWorld 1 4)))

;; 2b. and_seq runs children left->right, stops at first failure: three steps
;;     from 0 -> pos 3, fuel 2.
!(assertEqual (evalAction (quote (and_seq ((botForward ()) (botForward ()) (botForward ()))))
                          (mkBotWorld 0 5))
              (mkARes True (mkBotWorld 3 2)))

;; 2c. Same and_seq with only 1 fuel: first step works, second FAILS -> stops
;;     there (pos 1, fuel 0); the third child never runs.
!(assertEqual (evalAction (quote (and_seq ((botForward ()) (botForward ()) (botForward ()))))
                          (mkBotWorld 0 1))
              (mkARes False (mkBotWorld 1 0)))

;; 2d. action_bool_if: perception first, then exactly ONE branch --
;;     "if at goal do nothing, else step forward".
!(assertEqual (evalAction (quote (action_bool_if ((botAtGoal ()) (action_success ()) (botForward ()))))
                          (mkBotWorld 0 5))
              (mkARes True (mkBotWorld 1 4)))
!(assertEqual (evalAction (quote (action_bool_if ((botAtGoal ()) (action_success ()) (botForward ()))))
                          (mkBotWorld 3 5))
              (mkARes True (mkBotWorld 3 5)))

;; 2e. A real POLICY: "while not at goal, step forward". Works from ANY start
;;     -- the kind of general program we want evolution to find.
!(assertEqual (evalAction (quote (bool_while ((action_not ((botAtGoal ()))) (botForward ()))))
                          (mkBotWorld 0 9))
              (mkARes True (mkBotWorld 3 6)))
!(assertEqual (evalAction (quote (bool_while ((action_not ((botAtGoal ()))) (botForward ()))))
                          (mkBotWorld 2 9))
              (mkARes True (mkBotWorld 3 8)))

;; 2f. A NAIVE policy: "blindly step 3 times". Fine from 0, overshoots from 2.
!(assertEqual (evalAction (quote (repeat_n (3 (botForward ())))) (mkBotWorld 0 9))
              (mkARes True (mkBotWorld 3 6)))
!(assertEqual (evalAction (quote (repeat_n (3 (botForward ())))) (mkBotWorld 2 9))
              (mkARes True (mkBotWorld 5 6)))

;; 2g. Unknown operator -> defined-worst (mkARes False world), never a crash:
;;     this is how evolved garbage gets penalized instead of killing the run.
!(assertEqual (evalAction (quote (noSuchAction ())) (mkBotWorld 0 5))
              (mkARes False (mkBotWorld 0 5)))

;; ============================================================================
;; PART 3 -- SCORE programs. The evaluator above is generic; the FITNESS here
;; is yours: ONE function ($fn $exp $i) that says what episode ordinal $i means
;; and what a score is. Bind it with (set-param fitness <fn>) -- the whole
;; interface.
;; ============================================================================

;; The fitness: episode ordinal -> start position (PRIVATE mapping: even
;; ordinals start far from the goal at 0, odd ordinals near it at 2). Run the
;; program on that start world; 1.0 if the robot ends on the goal, else -1.0.
(= (botFitness $exp $i)
   (let* (($start (if (isEven $i) (mkBotWorld 0 9) (mkBotWorld 2 9)))
          ((mkARes $v (mkBotWorld $pos $fuel)) (evalAction $exp $start)))
     (if (== $pos 3) 1.0 -1.0)))

;; Best reachable raw score over $n episodes (the evolution target in PART 4).
(= (botBestScore $n) (* 1.0 $n))

!(set-param fitness botFitness)
!(set-param bestScore botBestScore)

;; The same two policies as TREES (what MOSES actually evolves).
(= (walkerTree)
   (mkTree (mkNode bool_while)
     (cons (mkTree (mkNode action_not) (cons (mkTree (mkNode botAtGoal) ()) ()))
     (cons (mkTree (mkNode botForward) ())
           ()))))
(= (naiveTree)
   (mkTree (mkNode repeat_n)
     (cons (mkTree (mkNode 3) ())
     (cons (mkTree (mkNode botForward) ())
           ()))))

;; 3a. Tree -> executable expression: same shape you hand-wrote in PART 2.
;; The expected side is (quote ...): bool_while is a live bare-head clause, so
;; an unquoted (bool_while ...) literal would reduce as a call instead of
;; comparing against actionExp's raw data output.
!(assertEqual (actionExp (walkerTree))
              (quote (bool_while ((action_not ((botAtGoal ()))) (botForward ())))))

;; 3b. Behavioural score = one number per episode, ordinals 0..3 in order
;;     (botFitness maps them far, near, far, near). Walker solves both starts;
;;     naive only the far one (it overshoots the near start).
!(assertEqual (scoreActionTree (walkerTree) 4 &actionScoreCache)
              (mkBScore (1.0 1.0 1.0 1.0)))
!(assertEqual (scoreActionTree (naiveTree) 4 &actionScoreCache)
              (mkBScore (1.0 -1.0 1.0 -1.0)))

;; 3c. Composite score = raw sum minus a complexity penalty, so between two
;;     equally-correct programs the SIMPLER one wins selection.
;;     (mkCscore <rawSum> <complexity> <penalty> <uniformity> <penalizedScore>)
!(assertEqual (getActionCscore (walkerTree) (mkActionCtx 4) 3.5 &actionScoreCache)
              (mkCscore 4.0 2 0.5714285714285714 0.0 3.428571428571429))
!(assertEqual (getActionCscore (naiveTree) (mkActionCtx 4) 3.5 &actionScoreCache)
              (mkCscore 0.0 2 0.5714285714285714 0.0 -0.5714285714285714))

;; ============================================================================
;; PART 4 -- EVOLVE a policy end to end with runMoses. This is the whole point:
;; PARTS 1-3 defined a domain and a fitness; MOSES now searches the program
;; space and returns an optimal policy, with ZERO edits to the pipeline (only
;; the four set-param bindings below). The run assembly mirrors
;; moses-run-action (moses/demo-problems.metta): empty-and_seq metapop seed at
;; the defined-worst score, tagged (mkActionCtx nTrials cpxPen) context, one
;; runMoses call. Tests never import moses.metta, so we call it by hand.
;;
;; DETERMINISM: seed 0, and PARTS 1-3 consume no RNG (the bot domain is
;; deterministic), so the run below is reproducible -- the seed pins both the
;; achieved score and the evolved tree.
;;
;; WHAT MOSES RETURNS (seed 0): the two asserts below pin the EXACT candidates
;; runMoses returns -- their evolved TREES and per-episode BSCOREs -- so the
;; outcome is visible without running. The TOP exemplar reaches raw 4.0, the
;; OPTIMUM (bscore (1.0 1.0 1.0 1.0)): the general solver
;;   (and_seq (and_seq botForward (action_bool_if botAtGoal botBackward botForward))
;;            botForward)
;; -- step, then hold-at-goal-else-step, then step, so it lands on 3 from both
;; the far (0) and near (2) starts, far past the -4.0 empty-exemplar seed. The
;; metapop is deterministic under seed 0; a diverging py-call draw order would
;; need it re-captured.
;; ============================================================================

!(py-call (random.seed 0))
!(set-param actions (quote (botForward botBackward)))
!(set-param perceptions (quote (botAtGoal)))
!(set-param maxCandOutput 3)
!(set-param hcMaxEvals 60)
!(set-param genCount 2)

(= (botMetaPop)
   ((mkExemplar (mkTree (mkNode and_seq) ()) (mkDemeId "1")
                (mkCscore -4.0 0 3.5 0 -4.0) (mkBScore (List.repeat 4 -1.0)))))

;; The EXACT candidates (3, best first), pinned as two lists: the evolved
;; program TREES (best first: the raw-4.0 solver, then a raw-4.0 variant with a
;; redundant extra conditional, then the retained single-step and_seq) and
;; their per-episode BSCOREs. These two fix the metapop exactly -- the raw score
;; is the bscore sum (4.0, 4.0, 0.0) and the complexity is the tree leaf count
;; (5, 7, 1). The two DERIVED fractional cscore fields (complexity penalty,
;; penalized score) are deliberately NOT asserted: PeTTaV1 float printing is not
;; round-trip-safe, so a pasted 1.4285714285714284 reconstructs a different
;; double that fails exact equality despite printing identically. The
;; extractors use the FULL mkCscore destructure -- a wildcard cscore pattern
;; hits a map-atom aliasing quirk that collapses every bscore to the last one.
;; ONE runMoses call, its result reused for both projections: the pair
;; (TREES BSCOREs).
(= (evolvedTree   (mkExemplar $t $id (mkCscore $r $c $p $u $ps) $b)) $t)
(= (evolvedBScore (mkExemplar $t $id (mkCscore $r $c $p $u $ps) $b)) $b)

!(assertEqual
   (let $m (runMoses 2 4.0 (botMetaPop) 0 1 (mkActionCtx 4 3.5) hillClimbing)
        ((map-atom $m evolvedTree) (map-atom $m evolvedBScore)))

   (((mkTree (mkNode and_seq)
                (
                  (mkTree (mkNode and_seq)
                     (
                       (mkTree (mkNode botForward) ())
                       (mkTree (mkNode action_bool_if)
                                  (
                                    (mkTree (mkNode botAtGoal) ())
                                    (mkTree (mkNode botBackward) ())
                                    (mkTree (mkNode botForward) ())))))
                  (mkTree (mkNode botForward) ())))
     (mkTree (mkNode and_seq) ((mkTree (mkNode and_seq) ((mkTree (mkNode botForward) ()) (mkTree (mkNode action_bool_if) ((mkTree (mkNode botAtGoal) ()) (mkTree (mkNode botBackward) ()) (mkTree (mkNode botForward) ()))))) (mkTree (mkNode action_bool_if) ((mkTree (mkNode botAtGoal) ()) (mkTree (mkNode botBackward) ()) (mkTree (mkNode botForward) ())))))
     (mkTree (mkNode and_seq) ((mkTree (mkNode botForward) ()))))
    ((mkBScore (1.0 1.0 1.0 1.0)) (mkBScore (1.0 1.0 1.0 1.0)) (mkBScore (-1.0 1.0 -1.0 1.0)))))
