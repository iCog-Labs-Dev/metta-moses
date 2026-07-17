;; ============================================================================
;; ANT-TRAIL PLAYGROUND -- the classic OpenCog "ant" experiment expressed as an
;; action domain over the generic evaluator. Same structure as
;; examples/action-playground.metta.
;;
;; Run from the repo root:   sh run.sh examples/ant-playground.metta -s
;;
;; Classic reference (OpenCog/Moses/examples/example-ant/):
;;   ant_scoring.h  -- 32x32 toroidal Santa Fe trail, ant starts (0,0) facing
;;                     east; '8' cells are food.
;;   ant_scoring.cc -- move/turn cost 1 time unit (600 budget); the program is
;;                     re-run in a do-while with a ZERO-PROGRESS guard (a pass
;;                     consuming no time breaks); score = pellets eaten.
;;                     NOTE: classic's action_if HARDCODES the food-ahead test
;;                     and ignores the condition child (ant_scoring.cc:103-124).
;;                     Here the condition subtree is genuinely evaluated by the
;;                     generic engine -- strictly more honest than classic.
;; This playground scales the world down (8-wide toroidal trails, fuel 20) so
;; every trace fits in your head; the mechanics are the classic ones.
;;
;;   PART 1: world + actions + perceptions       (one clause each)
;;   PART 2: hand-written programs, RUN          (evalAction)
;;   PART 3: the fitness + SCORING               (scoreActionTree)
;; ============================================================================

;; --- minimal import stack (identical to action-playground, plus pair) -------
;; parameters/registry+defaults load before scoring/action-score: the scorer
;; reads the fitness from (param actionFitness), and PeTTa gates reduction
;; on load order.
!(import! &self ../utilities/general-helpers)
!(import! &self ../parameters/registry)
!(import! &self ../parameters/defaults)
!(import! &self ../utilities/list-methods)
!(import! &self ../utilities/pair)
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
;; PART 1 -- THE DOMAIN: an ant on a toroidal grid, eating food.
;;
;; World: (mkAntWorld $grid $pos $dir $eaten $fuel)
;;   $grid  -- tuple of row tuples: F = food, E = empty, A = the ANT itself
;;             (the ant is drawn IN the world; look at any printed world and
;;             you see where it stands)
;;   $pos   -- (mkPair $x $y), the ant's position; (mkPair 0 0) is top-left,
;;             like the classic. Kept alongside the A marker so actions get
;;             O(1) access without scanning the grid; antMoveForward is the
;;             single writer that keeps marker and pair in sync.
;;   $dir   -- facing, one of (N E S W); classic starts facing east
;;   $eaten -- pellets eaten so far (THE score)
;;   $fuel  -- remaining time units; move/turn cost 1, perception is free
;;
;; Same contract as every domain: one bare-head clause per action/perception,
;;     (= (<name> $children $world) (mkARes <Bool> <newWorld>))
;; The engine knows nothing about ants.
;; ============================================================================

;; ---- grid helpers (domain-local, plain data plumbing) ----------------------
(= (antWrap $i $n) (if (< $i 0) (+ $i $n) (if (>= $i $n) (- $i $n) $i)))

(= (antCellAt $grid $pos)
   (index-atom (index-atom $grid (Pair.second $pos)) (Pair.first $pos)))

;; replace element $i of a tuple with $v -- cons both destructures the input
;; in the parameter position and rebuilds the result.
(= (antReplaceAt (cons $head $tail) $i $v)
   (if (== $i 0)
       (cons $v $tail)
       (cons $head (antReplaceAt $tail (- $i 1) $v))))

(= (antSetCell $grid $pos $v)
   (let* (($row (index-atom $grid (Pair.second $pos)))
          ($newRow (antReplaceAt $row (Pair.first $pos) $v)))
     (antReplaceAt $grid (Pair.second $pos) $newRow)))

;; position ahead of the ant, toroidal wrap (classic: (x+1) % ANT_X etc.)
(= (antAheadPos $grid $pos $dir)
   (let* (($w (size-atom (index-atom $grid 0)))
          ($h (size-atom $grid))
          ($x (Pair.first $pos))
          ($y (Pair.second $pos)))
     (case $dir
       ((E (mkPair (antWrap (+ $x 1) $w) $y))
        (W (mkPair (antWrap (- $x 1) $w) $y))
        (S (mkPair $x (antWrap (+ $y 1) $h)))
        (N (mkPair $x (antWrap (- $y 1) $h)))))))

(= (antLeftOf $dir)  (case $dir ((N W) (W S) (S E) (E N))))
(= (antRightOf $dir) (case $dir ((N E) (E S) (S W) (W N))))

;; ---- ACTIONS (cost 1 fuel; fail only when the budget is spent) -------------

;; antMoveForward: step onto the cell ahead; eat if it holds food. Classic
;; move_forward always "succeeds"; eating is a side effect. Placing the A
;; marker on the target cell consumes any food there, and the vacated cell
;; becomes E -- marker and (mkPair $x $y) move together.
(= (antMoveForward $children (mkAntWorld $grid $pos $dir $eaten $fuel))
   (if (<= $fuel 0)
       (mkARes False (mkAntWorld $grid $pos $dir $eaten $fuel))
       (let* (($ahead (antAheadPos $grid $pos $dir))
              ($target (antCellAt $grid $ahead))
              ($moved (antSetCell (antSetCell $grid $pos E) $ahead A)))
         (if (== $target F)
             (mkARes True (mkAntWorld $moved $ahead $dir (+ $eaten 1) (- $fuel 1)))
             (mkARes True (mkAntWorld $moved $ahead $dir $eaten (- $fuel 1)))))))

(= (antTurnLeft $children (mkAntWorld $grid $pos $dir $eaten $fuel))
   (if (<= $fuel 0)
       (mkARes False (mkAntWorld $grid $pos $dir $eaten $fuel))
       (mkARes True (mkAntWorld $grid $pos (antLeftOf $dir) $eaten (- $fuel 1)))))

(= (antTurnRight $children (mkAntWorld $grid $pos $dir $eaten $fuel))
   (if (<= $fuel 0)
       (mkARes False (mkAntWorld $grid $pos $dir $eaten $fuel))
       (mkARes True (mkAntWorld $grid $pos (antRightOf $dir) $eaten (- $fuel 1)))))

;; ---- PERCEPTION (free, read-only -- classic is_food_ahead) -----------------
(= (antFoodAhead $children (mkAntWorld $grid $pos $dir $eaten $fuel))
   (let $ahead (antAheadPos $grid $pos $dir)
        (mkARes (== (antCellAt $grid $ahead) F) (mkAntWorld $grid $pos $dir $eaten $fuel))))

;; ============================================================================
;; PART 2 -- RUN hand-written programs with evalAction.
;; Wrapped-shape literals are quote-wrapped (bare heads: an unquoted literal
;; in evaluated position would compile as a call -- the repo's quote rule).
;; Watch the A marker travel through the printed grids.
;; ============================================================================

;; a 3x8 test strip: the ant at (0 0), one food pellet directly ahead
(= (antTestWorld) (mkAntWorld ((A F E E E E E E)
                               (E E E E E E E E)
                               (E E E E E E E E)) (mkPair 0 0) E 0 9))

!(println! "---- PART 2: evalAction ------------------------------------------")

;; 2a. Move onto food: the A marker advances to (1 0), pellet eaten, fuel spent.
!(println! (2a (evalAction (quote (antMoveForward ())) (antTestWorld))))

;; 2b. Turn right then move: now facing S, the A marker drops to (0 1) and the
;;     food at (1 0) is NOT eaten.
!(println! (2b (evalAction (quote (and_seq ((antTurnRight ()) (antMoveForward ()))))
                           (antTestWorld))))

;; 2c. Perception is free and read-only: True at start (food at (1 0)), world
;;     unchanged, no fuel spent.
!(println! (2c (evalAction (quote (antFoodAhead ())) (antTestWorld))))

;; 2d. The trail-follower step, classic's famous conditional:
;;     "if food ahead, move (eat it); else turn right and look elsewhere".
;;     From the start: food ahead -> the move runs, the turn never does.
!(println! (2d (evalAction (quote (action_bool_if ((antFoodAhead ()) (antMoveForward ()) (antTurnRight ()))))
                           (antTestWorld))))

;; 2e. Toroidal wrap, as in the classic: facing W from (0 0) moves to (7 0).
!(println! (2e (evalAction (quote (and_seq ((antTurnLeft ()) (antTurnLeft ()) (antMoveForward ()))))
                           (antTestWorld))))

;; 2f. Budget exhaustion: with fuel 1 the second move FAILS and and_seq stops
;;     (this is what ends an episode mid-program).
!(println! (2f (evalAction (quote (and_seq ((antMoveForward ()) (antMoveForward ()))))
                           (mkAntWorld ((A F E E E E E E)) (mkPair 0 0) E 0 1))))

;; ============================================================================
;; PART 3 -- THE FITNESS. The domain defines: what an episode is (run the
;; program repeatedly under a fuel budget, classic do-while + zero-progress
;; guard), which worlds it is scored on, and what the best score is. The
;; scoring layer supplies the loop, the cache, and the bscore/cscore math.
;; ============================================================================

;; Two 5-pellet trails, ant at (0 0). Which trail an episode runs on is
;; PRIVATE to the fitness below: the scoring layer only hands it the episode
;; ordinal 0..n-1, and antFitness alternates the trails by ordinal parity,
;; so a candidate is rewarded for following trails IN GENERAL, not for
;; memorizing one map.
(= (antTrailStraight) ((A F F F F F E E)
                       (E E E E E E E E)
                       (E E E E E E E E)))

(= (antTrailCorner) ((A F F F E E E E)
                     (E E E F E E E E)
                     (E E E F E E E E)
                     (E E E E E E E E)
                     (E E E E E E E E)))

(= (antFuelBudget) 20)

;; One episode: classic's operator() do-while -- re-run the whole program on
;; the world it produced, stop when fuel is spent or a pass makes no progress
;; (ant_scoring.cc:55-62: `if (at_time == tmp) break;`). Score = pellets.
(= (antRunEpisode $exp $world)
   (let (mkAntWorld $g $p $d $eaten $fuel) $world
        (if (<= $fuel 0)
            $eaten
            (let (mkARes $v (mkAntWorld $g2 $p2 $d2 $e2 $f2)) (evalAction $exp $world)
                 (if (== $f2 $fuel)
                     $e2                                   ;; zero-progress pass -> stop
                     (antRunEpisode $exp (mkAntWorld $g2 $p2 $d2 $e2 $f2)))))))

;; ---- the fitness binding (the whole shared contract) -----------------------
;; ($fn $exp $i) -> Number: even ordinals run the straight trail, odd ones
;; the corner trail (parity by flip-recursion -- no mod-math here). Bound
;; globally via set-param; this playground IS an execution, so it sets the
;; params itself.
(= (antOrdinalEven $n) (if (== $n 0) True (not (antOrdinalEven (- $n 1)))))
(= (antFitness $exp $i)
   (antRunEpisode $exp
     (mkAntWorld (if (antOrdinalEven $i) (antTrailStraight) (antTrailCorner))
                 (mkPair 0 0) E 0 (antFuelBudget))))
;; every trail holds 5 pellets, so the best over $n episodes is 5 each
(= (antBestScore $n) (* 5 $n))
!(set-param actionFitness antFitness)
!(set-param actionBestScore antBestScore)

!(println! "---- PART 3: scoring ----------------------------------------------")

;; The two policies as TREES (what MOSES evolves). The follower is the classic
;; Santa Fe conditional; the naive one marches blindly forward.
(= (antFollowerTree)
   (mkTree (mkNode and_seq)
     (cons (mkTree (mkNode action_bool_if)
             (cons (mkTree (mkNode antFoodAhead) ())
             (cons (mkTree (mkNode antMoveForward) ())
             (cons (mkTree (mkNode antTurnRight) ()) ()))))
           ())))
(= (antNaiveTree)
   (mkTree (mkNode and_seq) (cons (mkTree (mkNode antMoveForward) ()) ())))

;; 3a. Tree -> executable shape (same shape you hand-wrote in PART 2).
!(println! (3a-compiled (actionExp (antFollowerTree))))

;; 3b. Behavioral scores over 4 episodes, ordinals 0..3 IN ORDER (antFitness
;;     privately maps them straight, corner, straight, corner): the follower
;;     solves both trails; the naive ant eats only the straight run of the
;;     corner trail (it marches past the turn, classic behavior).
!(println! (3b-follower (scoreActionTree (antFollowerTree) 4 &actionScoreCache)))
!(println! (3b-naive    (scoreActionTree (antNaiveTree)    4 &actionScoreCache)))

;; 3c. Composite scores: the follower's raw 20 beats naive's 16, and its
;;     3-leaf complexity (conditional + perception + 2 actions; structural ops
;;     are free) is priced against it by the usual penalty math.
!(println! (3c-follower (getActionCscore (antFollowerTree) (mkActionCtx 4) 3.5 &actionScoreCache)))
!(println! (3c-naive    (getActionCscore (antNaiveTree)    (mkActionCtx 4) 3.5 &actionScoreCache)))

;; ============================================================================
;; THINGS TO TRY
;;  * The zero-progress guard: score (and_seq ()) or a pure-perception tree --
;;    the first pass consumes no fuel, the episode ends at 0 eaten.
;;  * Starve the follower: shrink (antFuelBudget) below 7 and watch the corner
;;    trail become unsolvable while the straight one still is.
;;  * Add a gap to a trail (food, hole, food): the greedy follower stalls at
;;    the gap -- exactly why evolved Santa Fe solutions need richer programs
;;    than one conditional (in classic, programs with nested conditionals and
;;    turn-scanning evolve).
;;  * Add an action: one clause, e.g. antTurnAround (2 fuel, reverse facing),
;;    and use it in a program. Nothing else changes.
;;  * Add a perception the classic never had: antOnTrailEdge, or antSeeAnt --
;;    with the ant drawn IN the grid, a second ant is just another A marker
;;    and a perception away.
;;  * To make this a runnable MOSES problem (like the ttt experiment), the
;;    missing pieces are only a moses.metta import for this file plus the
;;    four set-param bindings (actionFitness/actionBestScore + the
;;    actionActions/actionPerceptions vocabulary tuples) -- the pipeline,
;;    evaluator, and scorer need no edits (see the tic-tac-toe-action README).
;; ============================================================================
