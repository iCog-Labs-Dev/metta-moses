;; ============================================================================
;; ACTION-DOMAIN PLAYGROUND -- single-file tour of the generic action evaluator.
;;
;; Run from the repo root:   sh run.sh examples/action-playground.metta -s
;;
;; No representation building, no knobs, no reduct. Just:
;;   PART 1: define a tiny world + actions + perceptions   (one clause each)
;;   PART 2: hand-write program expressions and RUN them   (evalAction)
;;   PART 3: define a scoring domain and SCORE programs    (scoreActionTree)
;; ============================================================================

;; --- minimal import stack (engine + scoring helpers), nothing else ----------
;; parameters/registry+defaults load before scoring/action-score: the scorer
;; reads the fitness from (param fitness), and PeTTa gates reduction
;; on load order.
!(import! &self ../utilities/general-helpers)
!(import! &self ../parameters/registry)
!(import! &self ../parameters/defaults)
!(import! &self ../utilities/list-methods)
!(import! &self ../scoring/cacheSpace)
!(import! &self ../scoring/fitness)
!(import! &self ../scoring/boolean-ops)
!(import! &self ../scoring/action-registry)
!(import! &self ../scoring/action-eval)
!(import! &self ../scoring/action-ops)
!(import! &self ../scoring/bscore)
!(import! &self ../scoring/cscore)
!(import! &self ../scoring/action-score)

;; ============================================================================
;; PART 1 -- THE DOMAIN: a robot in a 1-D corridor.
;;
;; World: (mkBotWorld $pos $fuel). The robot stands at $pos (0,1,2,...) and
;; the GOAL is position 3. Every move costs 1 fuel.
;;
;; The whole contract is: one clause per action/perception, shaped
;;     (= (<name> $children $world) (mkARes <Bool> <newWorld>))
;; The evaluator (scoring/action-eval.metta) knows NOTHING about robots --
;; it just dispatches these clauses. Delete one, add one, change one:
;; the engine never changes.
;; ============================================================================

;; ACTION botForward: step right. Fails (False) when out of fuel.
(= (botForward $children (mkBotWorld $pos $fuel))
   (if (> $fuel 0)
       (mkARes True  (mkBotWorld (+ $pos 1) (- $fuel 1)))
       (mkARes False (mkBotWorld $pos $fuel))))

;; ACTION botBackward: step left (floor at 0). Also costs fuel.
(= (botBackward $children (mkBotWorld $pos $fuel))
   (if (> $fuel 0)
       (if (> $pos 0)
           (mkARes True  (mkBotWorld (- $pos 1) (- $fuel 1)))
           (mkARes False (mkBotWorld $pos $fuel)))
       (mkARes False (mkBotWorld $pos $fuel))))

;; PERCEPTION botAtGoal: True iff standing on the goal. World untouched --
;; perceptions and actions share one result protocol, that's what lets
;; and_seq / action_bool_if treat any child alike.
(= (botAtGoal $children (mkBotWorld $pos $fuel))
   (mkARes (== $pos 3) (mkBotWorld $pos $fuel)))

;; ============================================================================
;; PART 2 -- RUN hand-written programs with evalAction.
;;
;; A program expression is nested (op (child1 child2 ...)) nodes; leaves are
;; (name ()). This is the "already generated" shape you asked to assume --
;; in a real run MOSES generates trees and actionExp compiles them to this.
;;
;; Every hand-written expression below sits under (quote ...): the operator
;; names are live bare-head clauses (scoring/action-ops quote rule), so an
;; unquoted literal in an evaluated position would compile as a CALL. Quote
;; strips on evaluation -- evalAction receives the raw expression.
;; ============================================================================

!(println! "---- PART 2: evalAction ------------------------------------------")

;; 2a. One action from pos 0 with 5 fuel -> success, robot now at 1.
!(println! (2a (evalAction (quote (botForward ())) (mkBotWorld 0 5))))

;; 2b. and_seq: run children left->right, STOP at first failure.
;;     Three steps from 0 -> pos 3, fuel 2.
!(println! (2b (evalAction (quote (and_seq ((botForward ()) (botForward ()) (botForward ()))))
                           (mkBotWorld 0 5))))

;; 2c. Same and_seq but only 1 fuel: first step works, second FAILS ->
;;     stops there (pos 1, fuel 0). The third child never runs.
!(println! (2c (evalAction (quote (and_seq ((botForward ()) (botForward ()) (botForward ()))))
                           (mkBotWorld 0 1))))

;; 2d. action_bool_if: perception first, then exactly ONE branch.
;;     "if at goal do nothing, else step forward"
!(println! (2d-not-at-goal (evalAction (quote (action_bool_if ((botAtGoal ()) (action_success ()) (botForward ()))))
                                       (mkBotWorld 0 5))))
!(println! (2d-at-goal     (evalAction (quote (action_bool_if ((botAtGoal ()) (action_success ()) (botForward ()))))
                                       (mkBotWorld 3 5))))

;; 2e. A real POLICY: "while not at goal, step forward".
;;     Works from ANY starting position -- this is the kind of general
;;     program we want evolution to find.
(= (walkerExp) (quote (bool_while ((action_not ((botAtGoal ()))) (botForward ())))))
!(println! (2e-from-0 (evalAction (walkerExp) (mkBotWorld 0 9))))
!(println! (2e-from-2 (evalAction (walkerExp) (mkBotWorld 2 9))))

;; 2f. A NAIVE policy: "blindly step 3 times". Fine from 0, overshoots from 2.
(= (naiveExp) (quote (repeat_n (3 (botForward ())))))
!(println! (2f-from-0 (evalAction (naiveExp) (mkBotWorld 0 9))))
!(println! (2f-from-2 (evalAction (naiveExp) (mkBotWorld 2 9))))

;; 2g. Unknown operator -> defined-worst (mkARes False world), never a crash.
;;     This is how evolved garbage gets penalized instead of killing the run.
!(println! (2g (evalAction (quote (noSuchAction ())) (mkBotWorld 0 5))))

;; ============================================================================
;; PART 3 -- SCORE programs. This is the split you asked about:
;;   * the evaluator above is domain-agnostic and generic;
;;   * the FITNESS below is yours: ONE ordinary function ($fn $exp $i) that
;;     says what episode ordinal $i means and what a score is. You bind it
;;     with (set-param fitness <fn>). That's the entire interface.
;; ============================================================================

;; (1)+(2) The fitness: episode ordinal -> start position (PRIVATE mapping:
;;     the scoring layer only hands us 0..n-1; here even ordinals start far
;;     from the goal, odd ordinals start near it). Run the program on that
;;     start world; score 1.0 if the robot ends on the goal, -1.0 otherwise.
;;     Higher = better. Parity via the shared isEven helper
;;     (utilities/general-helpers).
(= (botFitness $exp $i)
   (let $start (if (isEven $i) (mkBotWorld 0 9) (mkBotWorld 2 9))
        (let (mkARes $v (mkBotWorld $pos $fuel)) (evalAction $exp $start)
             (if (== $pos 3) 1.0 -1.0))))

;; (3) Best reachable raw score over $n episodes (used as the evolution
;;     termination target in a full run).
(= (botBestScore $n) (* 1.0 $n))

;; Bind the fitness: this playground IS an execution, so it sets the params
;; itself (a full moses.metta run would do the same in-script, plus
;; actions/perceptions for the knob vocabulary).
!(set-param fitness botFitness)
!(set-param bestScore botBestScore)

!(println! "---- PART 3: scoring ----------------------------------------------")

;; scoreActionTree takes the TREE form (what MOSES actually evolves) and
;; compiles it with actionExp. Here are the same two policies as trees:
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

;; 3a. Tree -> executable expression (proof it's the same shape as PART 2):
!(println! (3a-compiled (actionExp (walkerTree))))

;; 3b. Behavioural score = one number per episode. Episodes run IN ORDER,
;;     ordinals 0..3; botFitness privately maps them far, near, far, near.
;;     Walker solves both starts; naive only the far one.
!(println! (3b-walker (scoreActionTree (walkerTree) 4 &actionScoreCache)))
!(println! (3b-naive  (scoreActionTree (naiveTree)  4 &actionScoreCache)))

;; 3c. Composite score = raw sum minus a complexity penalty, so between two
;;     equally-correct programs the SIMPLER one wins selection.
;;     (mkCscore <rawSum> <complexity> <penalty> <uniformity> <penalizedScore>)
!(println! (3c-walker (getActionCscore (walkerTree) (mkActionCtx 4) 3.5 &actionScoreCache)))
!(println! (3c-naive  (getActionCscore (naiveTree)  (mkActionCtx 4) 3.5 &actionScoreCache)))

;; ============================================================================
;; THINGS TO TRY
;;  * Add an action: one clause, e.g. botJump (+2 pos, costs 3 fuel), then use
;;    it in a program in PART 2. No other file needs to change -- that's the
;;    whole point.
;;  * Break the walker: change the goal check to (== $pos 4) and watch 3b flip.
;;  * Starve it: give the walker (mkBotWorld 0 2) in 2e -- fuel runs out,
;;    bool_while exits when the body fails, robot stuck at 2.
;;  * Make an episode variant startBeyond -> (mkBotWorld 4 9): now walking
;;    forward can NEVER reach 3; only a program using botBackward can. Route
;;    some ordinals to it inside botFitness and see which programs survive --
;;    the ordinal->world mapping is entirely yours.
;;  * NOTE on caching: scoreActionTree memoizes per (fitness symbol, tree,
;;    nEpisodes) in &actionScoreCache. If you EDIT the fitness clause and
;;    rescore the same tree in one session, call !(resetActionScoreCache)
;;    first (a DIFFERENT fitness symbol keys fresh entries by itself).
;; ============================================================================
