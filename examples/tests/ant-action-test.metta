;; ============================================================================
;; ant-action-test.metta -- the classic OpenCog "ant" trail as an ACTION domain,
;; end to end.
;;
;; This file is BOTH a readable tour of the generic action evaluator AND a real
;; regression test: every step below is an assertEqual, so the expected world /
;; score is visible without running the file, and the suite checks it.
;;
;;   PART 1: the domain -- world + actions + perception, one bare-head clause each
;;   PART 2: RUN hand-written programs            (evalAction)
;;   PART 3: SCORE programs                        (scoreActionTree / cscore)
;;   PART 4: EVOLVE a program end to end           (runMoses) and show the
;;           optimal policy MOSES returns
;;
;; The evaluator, scorer, and pipeline are domain-agnostic: everything
;; ant-specific lives in PART 1 and the fitness in PART 3. Adding this whole
;; domain to MOSES took ZERO pipeline edits -- only the four set-param bindings
;; in PART 4.
;;
;; Classic reference (OpenCog/Moses/examples/example-ant/): 32x32 toroidal Santa
;; Fe trail, ant starts (0,0) facing east, move/turn cost 1 (600 budget), the
;; program re-runs in a do-while with a zero-progress guard, score = pellets
;; eaten. This test scales the world down (8-wide toroidal trails, fuel 20) so
;; every trace fits in your head; the mechanics are the classic ones.
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
;; PART 1 -- THE DOMAIN: an ant on a toroidal grid, eating food.
;;
;; World: (mkAntWorld $grid $pos $dir $eaten $fuel)
;;   $grid  -- tuple of row tuples: F = food, E = empty, A = the ANT itself
;;             (the ant is drawn IN the world; a printed world shows where it
;;             stands)
;;   $pos   -- (mkPair $x $y), the ant's position; (mkPair 0 0) is top-left.
;;             Kept alongside the A marker so actions get O(1) access without
;;             scanning the grid; antMoveForward is the single writer keeping
;;             marker and pair in sync.
;;   $dir   -- facing, one of (N E S W); classic starts facing east
;;   $eaten -- pellets eaten so far (THE score)
;;   $fuel  -- remaining time units; move/turn cost 1, perception is free
;;
;; Same contract as every domain: one bare-head clause per action/perception,
;;     (= (<name> $params $world) (mkARes <Bool> <newWorld>))
;; the evaluator dispatches these clauses and knows nothing about ants.
;; ============================================================================

;; ---- grid helpers (domain-local, plain data plumbing) ----------------------
(= (antWrap $i $n) (if (< $i 0) (+ $i $n) (if (>= $i $n) (- $i $n) $i)))

(= (antCellAt $grid (mkPair $x $y))
   (index-atom (index-atom $grid $y) $x))

;; cell replacement = List.replaceAt (positions are toroidally wrapped, so
;; indices are always in range).
(= (antSetCell $grid (mkPair $x $y) $v)
   (let* (
          ($row (index-atom $grid $y))
          ($newRow (List.replaceAt $row $x $v)))
     (List.replaceAt $grid $y $newRow)))

;; position ahead of the ant, toroidal wrap (classic: (x+1) % ANT_X etc.)
(= (antAheadPos $grid $pos $dir)
   (let* (
          ($w (size-atom (index-atom $grid 0)))
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
;; move_forward always "succeeds"; eating is a side effect. Placing the A marker
;; on the target cell consumes any food there, and the vacated cell becomes E --
;; marker and (mkPair $x $y) move together.
(= (antMoveForward $params (mkAntWorld $grid $pos $dir $eaten $fuel))
   (if (<= $fuel 0)
       (mkARes False (mkAntWorld $grid $pos $dir $eaten $fuel))
       (let* (($ahead (antAheadPos $grid $pos $dir))
              ($target (antCellAt $grid $ahead))
              ($moved (antSetCell (antSetCell $grid $pos E) $ahead A)))
         (if (== $target F)
             (mkARes True (mkAntWorld $moved $ahead $dir (+ $eaten 1) (- $fuel 1)))
             (mkARes True (mkAntWorld $moved $ahead $dir $eaten (- $fuel 1)))))))

(= (antTurnLeft $params (mkAntWorld $grid $pos $dir $eaten $fuel))
   (if (<= $fuel 0)
       (mkARes False (mkAntWorld $grid $pos $dir $eaten $fuel))
       (mkARes True (mkAntWorld $grid $pos (antLeftOf $dir) $eaten (- $fuel 1)))))

(= (antTurnRight $params (mkAntWorld $grid $pos $dir $eaten $fuel))
   (if (<= $fuel 0)
       (mkARes False (mkAntWorld $grid $pos $dir $eaten $fuel))
       (mkARes True (mkAntWorld $grid $pos (antRightOf $dir) $eaten (- $fuel 1)))))

;; ---- PERCEPTION (free, read-only -- classic is_food_ahead) -----------------
(= (antFoodAhead $params (mkAntWorld $grid $pos $dir $eaten $fuel))
   (let $ahead (antAheadPos $grid $pos $dir)
        (mkARes (== (antCellAt $grid $ahead) F) (mkAntWorld $grid $pos $dir $eaten $fuel))))

;; ============================================================================
;; PART 2 -- RUN hand-written programs with evalAction.
;;
;; A program is nested (op (child ...)) nodes; leaves are (name ()). Every
;; literal sits under (quote ...): the operator names are live bare-head
;; clauses, so an unquoted literal in an evaluated position would compile as a
;; CALL. Quote strips on evaluation -- evalAction receives the raw expression.
;; Watch the A marker travel through the grids.
;; ============================================================================

;; a 3x8 test strip: the ant at (0 0) facing E, one food pellet directly ahead.
(= (antTestWorld) (mkAntWorld ((A F E E E E E E)
                               (E E E E E E E E)
                               (E E E E E E E E)) (mkPair 0 0) E 0 9))

;; 2a. Move onto food: the A marker advances to (1 0), pellet eaten, fuel spent.
!(assertEqual (evalAction (quote (antMoveForward ())) (antTestWorld))
              (mkARes True (mkAntWorld ((E A E E E E E E)
                                        (E E E E E E E E)
                                        (E E E E E E E E)) (mkPair 1 0) E 1 8)))

;; 2b. Turn right then move: now facing S, the A marker drops to (0 1) and the
;;     food at (1 0) is NOT eaten.
!(assertEqual (evalAction (quote (and_seq ((antTurnRight ()) (antMoveForward ()))))
                          (antTestWorld))
              (mkARes True (mkAntWorld ((E F E E E E E E)
                                        (A E E E E E E E)
                                        (E E E E E E E E)) (mkPair 0 1) S 0 7)))

;; 2c. Perception is free and read-only: True at start (food at (1 0)), world
;;     unchanged, no fuel spent.
!(assertEqual (evalAction (quote (antFoodAhead ())) (antTestWorld))
              (mkARes True (mkAntWorld ((A F E E E E E E)
                                        (E E E E E E E E)
                                        (E E E E E E E E)) (mkPair 0 0) E 0 9)))

;; 2d. The trail-follower step, classic's famous conditional: "if food ahead,
;;     move (eat it); else turn right and look elsewhere". From the start: food
;;     ahead -> the move runs, the turn never does.
!(assertEqual (evalAction (quote (action_bool_if ((antFoodAhead ()) (antMoveForward ()) (antTurnRight ()))))
                          (antTestWorld))
              (mkARes True (mkAntWorld ((E A E E E E E E)
                                        (E E E E E E E E)
                                        (E E E E E E E E)) (mkPair 1 0) E 1 8)))

;; 2e. Toroidal wrap, as in the classic: two left turns face W, then moving from
;;     (0 0) wraps to (7 0).
!(assertEqual (evalAction (quote (and_seq ((antTurnLeft ()) (antTurnLeft ()) (antMoveForward ()))))
                          (antTestWorld))
              (mkARes True (mkAntWorld ((E F E E E E E A)
                                        (E E E E E E E E)
                                        (E E E E E E E E)) (mkPair 7 0) W 0 6)))

;; 2f. Budget exhaustion: with fuel 1 the second move FAILS and and_seq stops
;;     (this is what ends an episode mid-program).
!(assertEqual (evalAction (quote (and_seq ((antMoveForward ()) (antMoveForward ()))))
                          (mkAntWorld ((A F E E E E E E)) (mkPair 0 0) E 0 1))
              (mkARes False (mkAntWorld ((E A E E E E E E)) (mkPair 1 0) E 1 0)))

;; ============================================================================
;; PART 3 -- SCORE programs. The evaluator above is generic; the FITNESS here is
;; yours: it defines what an episode is (run the program repeatedly under a fuel
;; budget, classic do-while + zero-progress guard), which worlds it is scored
;; on, and what the best score is. Bind it with (set-param fitness <fn>) -- the
;; scoring layer supplies the loop, the cache, and the bscore/cscore math.
;; ============================================================================

;; Two 5-pellet trails, ant at (0 0). Which trail an episode runs on is PRIVATE
;; to the fitness below: the scoring layer only hands it the episode ordinal
;; 0..n-1, and antFitness alternates the trails by ordinal parity, so a
;; candidate is rewarded for following trails IN GENERAL, not for memorizing one
;; map.
(= (antTrailStraight) ((A F F F F F E E)
                       (E E E E E E E E)
                       (E E E E E E E E)))

(= (antTrailCorner) ((A F F F E E E E)
                     (E E E F E E E E)
                     (E E E F E E E E)
                     (E E E E E E E E)
                     (E E E E E E E E)))

(= (antFuelBudget) 20)

;; One episode: classic's operator() do-while -- re-run the whole program on the
;; world it produced, stop when fuel is spent or a pass makes no progress
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
;; ($fn $exp $i) -> Number: even ordinals run the straight trail, odd ones the
;; corner trail (parity via the shared isEven helper). Every trail holds 5
;; pellets, so the best over $n episodes is 5 each.
(= (antFitness $exp $i)
   (antRunEpisode $exp
     (mkAntWorld (if (isEven $i) (antTrailStraight) (antTrailCorner))
                 (mkPair 0 0) E 0 (antFuelBudget))))
(= (antBestScore $n) (* 5 $n))

!(set-param fitness antFitness)
!(set-param bestScore antBestScore)

;; The two policies as TREES (what MOSES actually evolves). The follower is the
;; classic Santa Fe conditional; the naive one marches blindly forward.
(= (antFollowerTree)
   (mkTree (mkNode and_seq)
     (cons (mkTree (mkNode action_bool_if)
             (cons (mkTree (mkNode antFoodAhead) ())
             (cons (mkTree (mkNode antMoveForward) ())
             (cons (mkTree (mkNode antTurnRight) ()) ()))))
           ())))
(= (antNaiveTree)
   (mkTree (mkNode and_seq) (cons (mkTree (mkNode antMoveForward) ()) ())))

;; 3a. Tree -> executable expression: same shape you hand-wrote in PART 2.
!(assertEqual (actionExp (antFollowerTree))
              (quote (and_seq ((action_bool_if ((antFoodAhead ()) (antMoveForward ()) (antTurnRight ())))))))

;; 3b. Behavioural score = one number per episode, ordinals 0..3 IN ORDER
;;     (antFitness maps them straight, corner, straight, corner). The follower
;;     solves both trails (5 each); the naive ant eats only the straight run of
;;     the corner trail (it marches past the turn, classic behaviour).
!(assertEqual (scoreActionTree (antFollowerTree) 4 &actionScoreCache)
              (mkBScore (5 5 5 5)))
!(assertEqual (scoreActionTree (antNaiveTree) 4 &actionScoreCache)
              (mkBScore (5 3 5 3)))

;; 3c. Composite score = raw sum minus a complexity penalty, so between two
;;     equally-correct programs the SIMPLER one wins selection.
;;     (mkCscore <rawSum> <complexity> <penalty> <uniformity> <penalizedScore>)
;;     The follower's raw 20 beats naive's 16, and its 3-leaf complexity
;;     (conditional + perception + 2 actions; structural ops are free) is priced
;;     against it by the usual penalty math.
!(assertEqual (getActionCscore (antFollowerTree) (mkActionCtx 4) 3.5 &actionScoreCache)
              (mkCscore 20 3 0.8571428571428571 0.0 19.142857142857142))
!(assertEqual (getActionCscore (antNaiveTree) (mkActionCtx 4) 3.5 &actionScoreCache)
              (mkCscore 16 1 0.2857142857142857 0.0 15.714285714285714))

;; ============================================================================
;; PART 4 -- EVOLVE a policy end to end with runMoses. This is the whole point:
;; PARTS 1-3 defined a domain and a fitness; MOSES now searches the program
;; space and returns an optimal policy, with ZERO edits to the pipeline (only
;; the four set-param bindings below). The run assembly mirrors moses-run-action
;; (moses/demo-problems.metta): empty-and_seq metapop seed at the defined-worst
;; score, tagged (mkActionCtx nTrials cpxPen) context, one runMoses call. Tests
;; never import moses.metta, so we call it by hand.
;;
;; DETERMINISM: seed 0, and PARTS 1-3 consume no RNG (the ant domain is
;; deterministic), so the run below is reproducible -- the seed pins both the
;; achieved score and the evolved tree.
;;
;; WHAT MOSES RETURNS (seed 0): the assert below pins the EXACT metapopulation
;; runMoses returns -- every surviving candidate with its tree + complexity +
;; cscore + bscore -- so the outcome is visible without running. The top
;; exemplar reaches raw 20, the OPTIMUM (bscore (5 5 5 5)), with the evolved
;; policy
;;   (and_seq (action_bool_if antFoodAhead (and_seq antMoveForward)
;;                                          (and_seq antTurnRight)))
;; i.e. the classic Santa Fe trail-follower: "if food ahead, move (eat); else
;; turn right and look elsewhere", re-run under the do-while until the trail is
;; consumed. Far past the -4.0 empty-exemplar seed. (Raw is an integer here --
;; antFitness returns pellet counts. The metapop is deterministic under seed 0;
;; a runtime with a diverging py-call draw order would need it re-captured.)
;; ============================================================================

!(py-call (random.seed 0))
!(set-param actions (quote (antMoveForward antTurnLeft antTurnRight)))
!(set-param perceptions (quote (antFoodAhead)))
!(set-param maxCandOutput 3)
!(set-param hcMaxEvals 60)
!(set-param genCount 2)

(= (antMetaPop)
   ((mkExemplar (mkTree (mkNode and_seq) ()) (mkDemeId "1")
                (mkCscore -4.0 0 3.5 0 -4.0) (mkBScore (List.repeat 4 -1.0)))))

;; The EXACT candidates (3), pinned as two lists: the evolved program TREES and
;; their per-episode BSCOREs. All three reach raw 20 -- the OPTIMUM (every
;; bscore (5 5 5 5)) -- and are Santa Fe follower variants; complexity 3 (the
;; two-move conditional) is priced lowest, so the canonical follower tops the
;; population. Raw score is the bscore sum (20 each), complexity the tree leaf
;; count (3, 3, 4). The two DERIVED fractional cscore fields are NOT asserted:
;; PeTTaV1 float printing is not round-trip-safe, so a pasted penalty
;; reconstructs a different double that fails exact equality despite printing
;; identically. The extractors use the FULL mkCscore destructure -- a wildcard
;; cscore pattern hits a map-atom aliasing quirk that collapses every bscore.
;; ONE runMoses call, its result reused for both projections: the pair
;; (TREES BSCOREs).
(= (evolvedTree   (mkExemplar $t $id (mkCscore $r $c $p $u $ps) $b)) $t)
(= (evolvedBScore (mkExemplar $t $id (mkCscore $r $c $p $u $ps) $b)) $b)
!(assertEqual
   (let $m (runMoses 2 20.0 (antMetaPop) 0 1 (mkActionCtx 4 3.5) hillClimbing)
        ((map-atom $m evolvedTree) (map-atom $m evolvedBScore)))
   (((mkTree (mkNode and_seq) ((mkTree (mkNode action_bool_if) ((mkTree (mkNode antFoodAhead) ()) (mkTree (mkNode and_seq) ((mkTree (mkNode antMoveForward) ()))) (mkTree (mkNode and_seq) ((mkTree (mkNode antTurnRight) ())))))))
     (mkTree (mkNode and_seq) ((mkTree (mkNode action_bool_if) ((mkTree (mkNode antFoodAhead) ()) (mkTree (mkNode antMoveForward) ()) (mkTree (mkNode antTurnRight) ())))))
     (mkTree (mkNode and_seq) ((mkTree (mkNode action_bool_if) ((mkTree (mkNode antFoodAhead) ()) (mkTree (mkNode and_seq) ((mkTree (mkNode antMoveForward) ()) (mkTree (mkNode antTurnLeft) ()))) (mkTree (mkNode and_seq) ((mkTree (mkNode antTurnRight) ()))))))))
    ((mkBScore (5 5 5 5)) (mkBScore (5 5 5 5)) (mkBScore (5 5 5 5)))))

;; ============================================================================
;; CLASSIC EQUIVALENCE -- runMoses SCORE check (commented out -- uncomment to
;; test). Does the CLASSIC demonstration hold: can MOSES EVOLVE a program that
;; attains the BEST possible score (eat every pellet)?
;;
;; Like PART 4 this evolves with runMoses, but it pins the SCORE, not the tree:
;; it reads the top exemplar's raw score and asserts it equals the optimum. The
;; classic OpenCog/Koza ant is the 32x32 Santa Fe trail whose optimum is 89
;; (all food, 600-step budget); here (the scaled trails) the optimum is
;;   antBestScore(4) = 5 pellets x 4 episodes = 20,
;; and the seeded run reaches it -- so this is the "reaches the best score"
;; demonstration for the scaled domain. Re-seed to 0 so the run is reproducible
;; (PARTS 1-3 consume no RNG; the ant fitness is deterministic).
;;
;; FOR THE TRUE CLASSIC: swap the scaled trails for the full 32x32 Santa Fe grid
;; (antBestScore per episode = 89), set the target and the asserted score to 89,
;; and give runMoses a larger maxGen / nDeme -- reaching 89 is the hard search
;; the classic is famous for, so a 2-generation run will NOT attain it.
;; ============================================================================
;; ---- antCountFood: count food cells across a grid (F/E/A rows). Used by the
;; classic-scale run below and by the commented Santa Fe block. ----
(= (antCountFood $grid)
   (foldl-atom $grid 0 $acc $row
      (+ $acc (foldl-atom $row 0 $a $c (if (== $c F) (+ $a 1) $a)))))

;; ---- OPTIMAL classic-scale test: an 89-pellet trail (the classic optimum). ----
;; 3 full rows of food (89 cells); single episode, 120-step budget. runMoses
;; ATTAINS the full 89 here -- because the rows are GAPLESS, a "turn right when
;; no food ahead" sweep never gets stranded, so MOSES finds a program that
;; eats every pellet. NOTE this makes it EASIER than the literal Santa Fe,
;; whose 1-3 cell GAPS strand a reflex sweeper; on that trail a 2-generation
;; run would score well below 89. So 89 here = "MOSES solved this 89-pellet
;; trail", not "MOSES solved the classic Santa Fe".
(= (antClassicTrail)
   ((A F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F)
    (F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F)
    (F F F F F F F F F F F F F F F F F F F F F F F F F F E E E E E E)))
(= (antClassicFitness $exp $i)
   (antRunEpisode $exp (mkAntWorld (antClassicTrail) (mkPair 0 0) E 0 120)))
(= (antClassicMetaPop)
   ((mkExemplar (mkTree (mkNode and_seq) ()) (mkDemeId "1")
                (mkCscore -1.0 0 3.5 0 -1.0) (mkBScore (-1.0)))))
;; validate the trail holds exactly 89 pellets (the classic optimum)
!(assertEqual (antCountFood (antClassicTrail)) 89)
!(py-call (random.seed 0))
!(set-param fitness antClassicFitness)
!(assertEqual
   (let $m (runMoses 2 89.0 (antClassicMetaPop) 0 1 (mkActionCtx 1 3.5) hillClimbing)
        (getScore (getExemplarCscore (OS.getByIdx 0 $m))))
   89)
;; ============================================================================

;; ============================================================================
;; CLASSIC SANTA FE -- the EXACT OpenCog board (commented; a full-budget run
;; takes ~2.6 min, too slow for the suite -- uncomment to reproduce).
;;
;; The literal 32x32 Santa Fe trail from OpenCog's example-ant (ant_scoring.h):
;; 89 food pellets, ant at (0,0) facing East, 600-step budget. OpenCog's MOSES
;; SOLVES it (best = 89/89). OURS on the SAME board:
;;   short run  (maxGen 2,  60 evals):            17/89
;;   full budget(maxGen 15, 500 evals, ~2.6 min): 70/89
;; -- metta-moses climbs toward the optimum as the search budget grows; the
;; remaining gap to 89 is search budget + OpenCog's richer ant ops/reduction.
;; antCountFood is defined above (before the classic-scale test).
;; ============================================================================
(= (antSantaFe)
  (
    (A F F F E E E E E E E E E E E E E E E E E E E E E E E E E E E E)
    (E E E F E E E E E E E E E E E E E E E E E E E E E E E E E E E E)
    (E E E F E E E E E E E E E E E E E E E E E E E E E F F F E E E E)
    (E E E F E E E E E E E E E E E E E E E E E E E E F E E E E F E E)
    (E E E F E E E E E E E E E E E E E E E E E E E E F E E E E F E E)
    (E E E F F F F E F F F F F E E E E E E E E F F E E E E E E E E E)
    (E E E E E E E E E E E E F E E E E E E E E E E E E E E E E F E E)
    (E E E E E E E E E E E E F E E E E E E E F E E E E E E E E E E E)
    (E E E E E E E E E E E E F E E E E E E E F E E E E E E E E E E E)
    (E E E E E E E E E E E E F E E E E E E E F E E E E E E E E F E E)
    (E E E E E E E E E E E E E E E E E E E E F E E E E E E E E E E E)
    (E E E E E E E E E E E E F E E E E E E E E E E E E E E E E E E E)
    (E E E E E E E E E E E E F E E E E E E E E E E E E E E E E F E E)
    (E E E E E E E E E E E E F E E E E E E E F E E E E E E E E E E E)
    (E E E E E E E E E E E E F E E E E E E E F E E E E E F F F E E E)
    (E E E E E E E E E E E E E E E E E F E E E E E F E E E E E E E E)
    (E E E E E E E E E E E E E E E E E E E E E E E E E E E E E E E E)
    (E E E E E E E E E E E E F E E E E E E E E E E E E E E E E E E E)
    (E E E E E E E E E E E E F E E E F E E E E E E E F E E E E E E E)
    (E E E E E E E E E E E E F E E E F E E E E E E E E E E F E E E E)
    (E E E E E E E E E E E E F E E E F E E E E E E E E E E E E E E E)
    (E E E E E E E E E E E E F E E E F E E E E E E E E E E E E E E E)
    (E E E E E E E E E E E E F E E E E E E E E E E E E E F E E E E E)
    (E E E E E E E E E E E E F E E E E E E E E E E F E E E E E E E E)
    (E E E F F E E F F F F F E E E E F E E E E E E E E E E E E E E E)
    (E F E E E E E E E E E E E E E E F E E E E E E E E E E E E E E E)
    (E F E E E E E E E E E E E E E E F E E E E E E E E E E E E E E E)
    (E F E E E E E E F F F F F F F E E E E E E E E E E E E E E E E E)
    (E F E E E E E F E E E E E E E E E E E E E E E E E E E E E E E E)
    (E E E E E E E F E E E E E E E E E E E E E E E E E E E E E E E E)
    (E E F F F F E E E E E E E E E E E E E E E E E E E E E E E E E E)
    (E E E E E E E E E E E E E E E E E E E E E E E E E E E E E E E E)
  ))

(= (antSantaFeFitness $exp $i)
   (antRunEpisode $exp (mkAntWorld (antSantaFe) (mkPair 0 0) E 0 600)))
(= (antSantaFeMetaPop)
   ((mkExemplar (mkTree (mkNode and_seq) ()) (mkDemeId "1")
                (mkCscore -1.0 0 3.5 0 -1.0) (mkBScore (-1.0)))))
!(assertEqual (antCountFood (antSantaFe)) 89)
!(py-call (random.seed 0))
!(set-param fitness antSantaFeFitness)
!(set-param actions (quote (antMoveForward antTurnLeft antTurnRight)))
!(set-param perceptions (quote (antFoodAhead)))
!(set-param maxCandOutput 3)
!(set-param hcMaxEvals 500)
!(set-param genCount 15)
!(assertEqual
   (let $m (runMoses 15 89.0 (antSantaFeMetaPop) 0 1 (mkActionCtx 1 3.5) hillClimbing)
        (getScore (getExemplarCscore (OS.getByIdx 0 $m))))
   70)
;; ============================================================================
