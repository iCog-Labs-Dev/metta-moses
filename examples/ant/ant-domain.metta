;; ---------------------------------------------------------------------------
;; Classic Santa Fe ant domain
;; ---------------------------------------------------------------------------

;; The complete-run evaluator limit is ant-specific, so register it with the
;; domain instead of changing generic parameter-specialization state. CLI
;; overrides remain compatible because moses.metta applies them afterward.
!(add-atom &params (antMaxEvals 100000))

;; Shared state variables used below:
;; - $x, $y: current ant position on the 32x32 toroidal grid.
;; - $dir: current direction; 0=north, 1=east, 2=south, 3=west.
;; - $time: number of primitive ant actions already consumed.
;; - $food: remaining uneaten food coordinates, as a tuple/list of ($x $y).
;; - $eaten: number of food cells eaten so far.
;; - $state: `(mkAntState $x $y $dir $time $food $eaten)`.
;; - $steps: maximum allowed primitive actions, 600 in the classic setup.
;; - $tree: action/condition candidate tree being interpreted.
;;
;; ant-actions: return the primitive actions available to action ASK knobs.
;;           C++ note: `moses-ant-hillclimbing.cc` inserts these into
;;           `demeparms.actions`; MeTTa returns a tuple for the representation builder.

(= (ant-actions) (move_forward turn_left turn_right))

;; ant-perceptions: return the perceptions available in ant action conditionals.
;;           C++ note: C++ inserts `is_food_ahead` into `demeparms.perceptions`, while
;;           `AntFitnessFunction::eval` handles it implicitly inside `action_if`.

(= (ant-perceptions) (is_food_ahead))

;; ant-exemplar: return the initial exemplar tree used to start ant evolution.
;;          C++ note: C++ seeds the metapopulation with `sequential_and`; MeTTa uses the
;;          equivalent action operator name `and_seq`.

(= (ant-exemplar) (mkTree (mkNode and_seq) ()))

;; ant-width: domain constants for grid size, pellet count, and target raw score.
;;          C++ note: mirrors `ANT_X`, `ANT_Y`, the 89 pellets in `init_trail`, and
;;          `ant_bscore::best_possible_bscore()` returning `{0.0}`.

(= (ant-width) 32)
(= (ant-height) 32)
(= (ant-food-count) 89)
(= (ant-best-possible-score) 0)

;; antAlwaysSucceeds: report whether an action is guaranteed to succeed in this ant
;; world.
;;           $action is the primitive action symbol being queried.
;;           C++ note: ant combo vocabulary marks all three actions as always_succeeds.

(= (antAlwaysSucceeds $action)
   (is-member $action (move_forward turn_left turn_right)))

;; ant-food-coords: return the fixed Santa Fe trail food coordinates.
;;          each item is `($x $y)`, the coordinate of one initial pellet.
;;          C++ note: C++ `init_trail` stores a char grid; MeTTa stores only the food
;;          cells, which makes eating a pellet a list-removal operation.

(= (ant-food-coords)
   ((1 0) (2 0) (3 0) (3 1) (3 2) (25 2) (26 2) (27 2) (3 3) (24 3)
    (29 3) (3 4) (24 4) (29 4) (3 5) (4 5) (5 5) (6 5) (8 5) (9 5)
    (10 5) (11 5) (12 5) (21 5) (22 5) (12 6) (29 6) (12 7) (20 7) (12 8)
    (20 8) (12 9) (20 9) (29 9) (20 10) (12 11) (12 12) (29 12) (12 13) (20 13)
    (12 14) (20 14) (26 14) (27 14) (28 14) (17 15) (23 15) (12 17) (12 18) (16 18)
    (24 18) (12 19) (16 19) (27 19) (12 20) (16 20) (12 21) (16 21) (12 22) (26 22)
    (12 23) (23 23) (3 24) (4 24) (7 24) (8 24) (9 24) (10 24) (11 24) (16 24)
    (1 25) (16 25) (1 26) (16 26) (1 27) (8 27) (9 27) (10 27) (11 27) (12 27)
    (13 27) (14 27) (1 28) (7 28) (7 29) (2 30) (3 30) (4 30) (5 30)))

;; antInitialState: construct a fresh ant simulation state.
;;          uses x=0, y=0, dir=1/east, time=0, full initial food list, and
;;          eaten=0.

(= (antInitialState)
   (mkAntState 0 0 1 0 (ant-food-coords) 0))

;; antTurnLeft: map a direction to the direction after a left turn.
;;          `$dir` is the current direction, using 0=north, 1=east, 2=south, 3=west.
;;          C++ note: mirrors `AntFitnessFunction::turn_left`, `(d + 3) % 4`.

(= (antTurnLeft $dir) (% (+ $dir 3) 4))

;; antTurnRight: map a direction to the direction after a right turn.
;;          `$dir` is the current direction, using 0=north, 1=east, 2=south, 3=west.
;;          mirrors `AntFitnessFunction::turn_right`, `(d + 1) % 4`.

(= (antTurnRight $dir) (% (+ $dir 1) 4))

;; antForwardPosition: compute the wrapped cell one step ahead of ($x, $y) in `$dir`.
;;          $x/$y are the current position; the numeric final pattern is $dir. The returned tuple is `($nx $ny)`, the next wrapped position.
;;          mirrors the direction switch used for both perception and movement in `AntFitnessFunction::eval`.

(= (antForwardPosition $x $y 0) ($x (% (+ $y (- (ant-height) 1)) (ant-height))))
(= (antForwardPosition $x $y 1) ((% (+ $x 1) (ant-width)) $y))
(= (antForwardPosition $x $y 2) ($x (% (+ $y 1) (ant-height))))
(= (antForwardPosition $x $y 3) ((% (+ $x (- (ant-width) 1)) (ant-width)) $y))

;; antHasFoodAt: test whether the remaining food set contains coordinate ($x, $y).
;;          $food is the remaining coordinate list; $x/$y is the queried coordinate.
;;          C++ note: equivalent to checking `trail[y][x] != ' '` in the char grid.

(= (antHasFoodAt $food $x $y)
   (once (is-member ($x $y) $food)))

;; antRemoveFoodAt: remove coordinate ($x, $y) from the remaining food list.

(= (antRemoveFoodAt $foods $x $y) (filter-atom $foods $food (!= $food ($x $y))))

;; antFoodAhead: evaluate the `is_food_ahead` perception for `$state`.
;;          state fields are from the shared guide;
;;          `$nx`/`$ny` is the cell directly ahead after toroidal wrapping.
;;          C++ note: mirrors the food-ahead check inside C++ `action_if`

(= (antFoodAhead (mkAntState $x $y $dir $time $food $eaten))
   (let ($nx $ny) (antForwardPosition $x $y $dir)
     (antHasFoodAt $food $nx $ny)))

;; antStepMoveForward: execute one `move_forward` action and return the updated state.
;;          state fields are from the shared guide;
;;          `$nx`/`$ny` is the destination cell. If food is present there, `$food` loses that coordinate and `$eaten` increments.

(= (antStepMoveForward (mkAntState $x $y $dir $time $food $eaten))
   (let ($nx $ny) (antForwardPosition $x $y $dir)
     (if (antHasFoodAt $food $nx $ny)
         (mkAntState $nx $ny $dir (+ $time 1) (antRemoveFoodAt $food $nx $ny) (+ $eaten 1))
         (mkAntState $nx $ny $dir (+ $time 1) $food $eaten))))

;; antStepTurnLeft: execute one `turn_left` action and return the updated state.
;;          state fields are from the shared guide; only `$dir` and `$time` change.

(= (antStepTurnLeft (mkAntState $x $y $dir $time $food $eaten))
   (mkAntState $x $y (antTurnLeft $dir) (+ $time 1) $food $eaten))

;; antStepTurnRight: execute one `turn_right` action and return the updated state.
;;          state fields are from the shared guide; only `$dir` and `$time` change.

(= (antStepTurnRight (mkAntState $x $y $dir $time $food $eaten))
   (mkAntState $x $y (antTurnRight $dir) (+ $time 1) $food $eaten))

;; antStepAction: dispatch a primitive action symbol to its state transition.
;;          `$action` is the primitive symbol;
;;          `$state` is the current ant state.
;;          `$other` catches unsupported action symbols.

(= (antStepAction $action $state)
   (case $action
      ((move_forward (antStepMoveForward $state))
       (turn_left (antStepTurnLeft $state))
       (turn_right (antStepTurnRight $state))
       ($other $state))))

;; antEvalPrimitive: evaluate one primitive action leaf against the current state.
;;          `$action` is the primitive symbol;
;;          state fields are from the shared guide;
;;          `$steps` is the execution limit. The return value `(mkAntEval $state $result)` carries the updated state and the action-result
;;          boolean.
;;          C++ note: mirrors the builtin-action leaf branch of
;;          `AntFitnessFunction::eval`; MeTTa returns state plus result instead of an integer pellet increment.

(= (antEvalPrimitive $action (mkAntState $x $y $dir $time $food $eaten) $steps)
   (if (>= $time $steps)
       (mkAntEval (mkAntState $x $y $dir $time $food $eaten) True)
       (if (antAlwaysSucceeds $action)
           (mkAntEval (antStepAction $action (mkAntState $x $y $dir $time $food $eaten)) True)
           (mkAntEval (mkAntState $x $y $dir $time $food $eaten) False))))

;; antEvalBool: evaluate a boolean condition tree in the current ant state.
;;          `$tree` is the condition tree being evaluated;
;;          `$state` is the current ant state;
;;          `$child` is the single operand of `NOT`;
;;          `$children` is the tuple/list of operands for `AND` or `OR`;
;;          `$other` is any unsupported  condition tree and evaluates to False.

(= (antEvalBool $tree $state)
   (case $tree
      (((mkTree (mkNode True) ()) True)
       ((mkTree (mkNode False) ()) False)
       ((mkTree (mkNode is_food_ahead) ()) (antFoodAhead $state))
       ((mkTree (mkNode NOT) (cons $child ())) (not (antEvalBool $child $state)))
       ((mkTree (mkNode AND) $children) (antEvalBoolAnd $children $state))
       ((mkTree (mkNode OR) $children) (antEvalBoolOr $children $state))
       ($other False))))

;; antEvalBoolAnd evaluates the condition list recursively. Explicit recursion
;; preserves PeTTa's evaluator-safe reduction and short-circuit behavior.
(= (antEvalBoolAnd () $state) True)
(= (antEvalBoolAnd (cons $child $rest) $state)
   (and (antEvalBool $child $state)
        (antEvalBoolAnd $rest $state)))

;; antEvalBoolOr follows the same evaluator-safe recursive shape as AND.
;;          C++ note: no direct C++ helper; this is the OR counterpart to `antEvalBoolAnd`.
(= (antEvalBoolOr () $state) False)
(= (antEvalBoolOr (cons $child $rest) $state)
   (or (antEvalBool $child $state)
       (antEvalBoolOr $rest $state)))

;; antEvalTree: interpret an action tree once, returning updated state and action
;; result.
;;          `$tree` is the action tree for one interpreter pass;
;;          `$state` is the current ant state;
;;          `$steps` is the maximum primitive-action budget;
;;          `$children` is the tuple/list of sequence children;
;;          `$condition` is the boolean guard of `action_bool_if`;
;;          `$thenBranch` and `$elseBranch` are the selected action subtrees;
;;          `$action` is a primitive leaf symbol;
;;          `$other` is any malformed or unsupported action tree and produces failure.
;;          C++ note: mirrors `AntFitnessFunction::eval`. MeTTa also handles `or_seq`,
;;          `exec_seq`, and `action_failure` because generic action reduction may
;;          produce them.

(= (antEvalTree $tree $state $steps)
   (case $tree
      (((mkNullVex $children) (mkAntEval $state True))
       ((mkTree (mkNode action_success) ()) (mkAntEval $state True))
       ((mkTree (mkNode action_failure) ()) (mkAntEval $state False))
       ((mkTree (mkNode and_seq) $children) (antEvalAndSeq $children $state $steps))
       ((mkTree (mkNode or_seq) $children) (antEvalOrSeq $children $state $steps))
       ((mkTree (mkNode exec_seq) $children) (antEvalExecSeq $children $state $steps))
       ((mkTree (mkNode action_bool_if)
                (cons $condition (cons $thenBranch (cons $elseBranch ()))))
                  (if (antEvalBool $condition $state)
                      (antEvalTree $thenBranch $state $steps)
                      (antEvalTree $elseBranch $state $steps)))
       ((mkTree (mkNode $action) ()) (antEvalPrimitive $action $state $steps))
       ($other (mkAntEval $state False)))))

;; antEvalAndSeq: evaluate an `and_seq` child list from left to right.
;;          `$child` is the current action subtree;
;;          `$rest` is the remaining children;
;;          `$state` is the input state for the current child;
;;          `$steps` is the primitive-action budget;
;;          `$nextState` is the state after `$child`;
;;          `$result` is that child's success/failure result.
;;          C++ note: mirrors C++ sequential_and traversal. MeTTa explicitly
;;          short-circuits on False to match action-result semantics.

(= (antEvalAndSeq () $state $steps) (mkAntEval $state True))
(= (antEvalAndSeq (cons $child $rest) $state $steps)
   (let (mkAntEval $nextState $result) (antEvalTree $child $state $steps)
     (if $result
         (antEvalAndSeq $rest $nextState $steps)
         (mkAntEval $nextState False))))

;; antEvalOrSeq: evaluate an `or_seq` child list until the first successful child.
;;          `$child` is the current action subtree;
;;          `$rest` is the remaining children;
;;          `$state` is the input state for the current child;
;;          `$steps` is the primitive-action budget;
;;          `$nextState` is the state after `$child`;
;;          `$result` is that child's success/failure result.
;;          C++ note: no ant-scoring.cc branch; this supports the generic MeTTa action
;;          operator `or_seq`.

(= (antEvalOrSeq () $state $steps) (mkAntEval $state False))
(= (antEvalOrSeq (cons $child $rest) $state $steps)
   (let (mkAntEval $nextState $result) (antEvalTree $child $state $steps)
     (if $result
         (mkAntEval $nextState True)
         (antEvalOrSeq $rest $nextState $steps))))

;; antEvalExecSeq: evaluate an `exec_seq` child list, preserving effects and ignoring
;; child success/failure.
;;          `$child` is the current action subtree;
;;          `$rest` is the remaining children;
;;          `$state` is the input state for the current child;
;;          `$steps` is the primitive-action budget;
;;          `$nextState` is the state after `$child`;
;;          `$result` is that child's success/failure result and is intentionally ignored.
;;          C++ note: no ant-scoring.cc branch; this supports the generic MeTTa action
;;          operator `exec_seq`.

(= (antEvalExecSeq () $state $steps) (mkAntEval $state True))
(= (antEvalExecSeq (cons $child $rest) $state $steps)
   (let (mkAntEval $nextState $result) (antEvalTree $child $state $steps)
     (antEvalExecSeq $rest $nextState $steps)))

;; antStateTime: extract elapsed primitive-action time from an ant state.
;;          state fields are from the shared guide; only `$time` is returned.
;;          C++ note: corresponds to reading `at_time` in C++.

(= (antStateTime (mkAntState $x $y $dir $time $food $eaten)) $time)

;; antRunTree: run a candidate tree from a fresh initial ant state.
;;          `$tree` is the candidate action tree;
;;          `$steps` is the time limit.
;;          C++ note: corresponds to entering `AntFitnessFunction::operator()`, but
;;          returns final state rather than the raw food score.

(= (antRunTree $tree $steps)
   (antRunTreeLoop $tree (antInitialState) $steps))

;; antRunTreeLoop: repeatedly evaluate the whole candidate until time reaches
;; `$steps` or one full pass consumes no time.
;;          `$tree` is the candidate action tree;
;;          `$state` is the current ant state;
;;          `$steps` is the primitive-action limit;
;;          `$beforeTime` is the state's time before one full candidate pass;
;;          `$afterTime` is the time afterward;
;;          `$nextState` is the state after that pass;
;;          `$result` is the pass result and is ignored for loop control,
;;          matching the C++ score loop.
;;          C++ note: mirrors the do/while loop in `AntFitnessFunction::operator()`;
;;          MeTTa recurses with immutable state values.

(= (antRunTreeLoop $tree $state $steps)
   (let $beforeTime (antStateTime $state)
     (if (>= $beforeTime $steps)
         $state
         (let* (((mkAntEval $nextState $result) (antEvalTree $tree $state $steps))
                  ($afterTime (antStateTime $nextState)))
             (if (== $afterTime $beforeTime)
                 $nextState
                 (antRunTreeLoop $tree $nextState $steps))))))

;; antFoodEaten: extract the number of pellets eaten from an ant state.
;;          state fields are from the shared guide; only `$eaten` is returned.
;;          C++ note: corresponds to accumulated `sc`; MeTTa stores this total in state.

(= (antFoodEaten (mkAntState $x $y $dir $time $food $eaten)) $eaten)

;; scoreAntTree: compute the behavioral score vector for an ant candidate.
;;          `$tree` is the candidate action tree to simulate;
;;          `$steps` is the primitive-action limit. The first score component is
;;          `-antFoodCount`; the second component is the food count from `antFoodEaten`.
;;          C++ note: mirrors `ant_bscore::operator()`, `{-89, _aff(tr)}`.

(= (scoreAntTree $tree $steps)
   (mkBScore ((- 0 (ant-food-count)) (antFoodEaten (antRunTree $tree $steps)))))

;; antTreeComplexity: match C++ `tree_complexity`.  The empty sequential_and
;; seed and structural/Boolean/perception nodes cost zero.  Only primitive ant
;; actions and action-result constants cost one in this domain.  In particular,
;; `is_food_ahead` is an ant perception, not a C++ builtin action, so charging it
;; would over-penalize the conditional structure needed to follow the trail.
(= (antTreeComplexity (mkNullVex $children)) 0)
;; C++ counts ant builtin actions and `action_result` leaves.  Keep the
;; structural recursion unchanged so operators such as `action_bool_if`,
;; `and_seq`, `AND`, and `NOT` contribute only their qualifying descendants.
(= (antTreeComplexity (mkTree (mkNode $op) $children))
   (if (== $children ())
       (if (is-member $op
             (move_forward turn_left turn_right action_success action_failure))
           1
           0)
       (foldl-atom $children 0 $total $child
         (+ $total (antTreeComplexity $child)))))

;; getAntCscoreFromBScore: construct the ant composite score from a behavioral
;;          score that has already been measured.  Keeping simulation outside
;;          this helper lets the pipeline score its initial exemplar exactly
;;          once and account for that one real evaluator call.
(= (getAntCscoreFromBScore $tree $complexityRatio $bscore)
   (let* (
          ($rawScore (sumBScore $bscore))
          ($complexity (antTreeComplexity $tree))
          ($complexityPenalty (* $complexity (getComplexityCoef $complexityRatio)))
         )
     (updatePenalizedScore
       (mkCscore $rawScore $complexity $complexityPenalty 0.0
                 (* -1 (pow-math 10 308)))
       False)))

;; getAntCscore: compute composite score for an ant candidate.
;;          `$tree` is the already-cleaned candidate action tree;
;;          `$complexityRatio` controls the generic complexity penalty coefficient;
;;          `$steps` is the primitive-action limit passed to ant simulation.
;;          C++ note: corresponds to `behave_cscore` over `ant_bscore`; MeTTa reuses
;;          generic `getCscore`.
;; The public scorer delegates score conversion to the no-simulation helper so
;; callers that already hold a BScore can avoid a duplicate simulation.
(= (getAntCscore $tree $complexityRatio $steps)
   (getAntCscoreFromBScore
     $tree $complexityRatio (scoreAntTree $tree $steps)))

;; antBasedScorer: score one instance in an ant representation.
;;          `$rep` is the representation with embedded ASK knobs;
;;          `$id` is the deme/cache id used by `getCandidate`;
;;          `$inst` is the knob-setting vector;
;;          `$steps` is the primitive-action limit;
;;          `$complexityRatio` is the composite score penalty ratio;
;;          `$actions` is the ant primitive-action vocabulary;
;;          `$perceptions` is the ant condition vocabulary;
;;          `$tree` is the materialized candidate;
;;          `$cleanedTree` is `$tree` after action reduction.
;;          C++ note: corresponds to materialize -> action_reduction -> behave_cscore.
;;          Every call starts from the same fresh trail state, so the score is
;;          deterministic for a cleaned tree. The hill climber may safely
;;          reuse that result within a scoring batch; this primitive scorer still
;;          performs one independent simulation when called directly.

(= (antBasedScorer $rep $id $inst (mkAntContext $steps $complexityRatio $actions $perceptions))
   (let* (($tree (getCandidate $rep $id $inst))
          ($cleanedTree (cleanActionTree $tree)))
     (getAntCscore $cleanedTree $complexityRatio $steps)))

;; applyAntBasedScore: score a list of generated ant instances.
;;          `$rep` is the representation with embedded ASK knobs;
;;          `$id` is the deme/cache id used by `getCandidate`;
;;          `$instances` is the list of unscored `mkInst` values;
;;          `$steps` is the primitive-action limit;
;;          `$complexityRatio` is the composite score penalty ratio;
;;          `$actions` is the ant primitive-action vocabulary;
;;          `$perceptions` is the ant condition vocabulary;
;;          `$inst` is the current instance being mapped into `mkSInst`.
;;          C++ note: corresponds to scoring generated instances during deme expansion.
;;          MeTTa uses `mkAntContext` to avoid tuple ambiguity with strategy scoring.

(= (applyAntBasedScore $rep $id $instances (mkAntContext $steps $complexityRatio $actions $perceptions))
   (map-atom $instances $inst
     (mkSInst
       (mkPair $inst
               (antBasedScorer $rep $id $inst
                               (mkAntContext $steps $complexityRatio $actions $perceptions))))))
