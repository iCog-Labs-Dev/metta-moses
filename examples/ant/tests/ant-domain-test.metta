!(import! &self ../../../utilities/general-helpers)
!(import! &self ../../../utilities/list-methods)
!(import! &self ../../../utilities/tree)

!(import! &self ../../../scoring/bscore)
!(import! &self ../../../scoring/cscore)

!(import! &self ../ant-domain)

(= (moveTree) (mkTree (mkNode move_forward) ()))
(= (turnLeftTree) (mkTree (mkNode turn_left) ()))
(= (turnRightTree) (mkTree (mkNode turn_right) ()))
(= (foodAheadTree) (mkTree (mkNode is_food_ahead) ()))

;; Exact program evolved by the historical seed-1 convergence experiment.
;; Keeping it as a cheap semantic fixture protects its behavior without making
;; the ordinary suite repeat a long search or promising the same current path.
(= (evolvedPerfectAntTree)
   (buildTree
     (and_seq
       (action_bool_if is_food_ahead
         (and_seq move_forward move_forward)
         (and_seq
           turn_left
           turn_left
           (action_bool_if is_food_ahead
             (and_seq move_forward)
             (and_seq turn_right))
           move_forward))
       turn_right)))

;; C++ `tree_complexity` assigns one to builtin ant actions and action-result
;; constants, but zero to perceptions and structural operators.  The
;; conditional therefore costs only its two action branches.
!(assertEqual
  ((antTreeComplexity (ant-exemplar))
   (antTreeComplexity (moveTree))
   (antTreeComplexity (turnLeftTree))
   (antTreeComplexity (turnRightTree))
   (antTreeComplexity (foodAheadTree))
   (antTreeComplexity (mkTree (mkNode action_success) ()))
   (antTreeComplexity (mkTree (mkNode action_failure) ()))
   (antTreeComplexity (mkTree (mkNode True) ()))
   (antTreeComplexity (mkTree (mkNode False) ()))
   (antTreeComplexity
     (mkTree (mkNode action_bool_if)
       ((foodAheadTree) (moveTree) (turnRightTree)))))
  (0 1 1 1 0 1 1 0 0 2))

!(assertEqual (List.length (ant-food-coords)) (ant-food-count))

;; Stateless Boolean junctors use the conventional empty identities and fold
;; every condition against the same ant state.
!(assertEqual
  ((evalBoolAnd antEvalBool () (antInitialState))
   (evalBoolOr antEvalBool () (antInitialState))
   (evalBoolAnd antEvalBool
     ((mkTree (mkNode True) ()) (foodAheadTree))
     (antInitialState))
   (evalBoolOr antEvalBool
     ((mkTree (mkNode False) ()) (foodAheadTree))
     (antInitialState)))
  (True False True True))


!(assertEqual
  (let (mkAntState $x $y $dir $time $food $eaten) (antStepMoveForward (antInitialState))
    ($x $y $dir $time $eaten (antHasFoodAt $food 1 0)))
  (1 0 1 1 1 False))

!(assertEqual (antForwardPosition 0 0 0) (0 31))
!(assertEqual (antForwardPosition 31 31 1) (0 31))
!(assertEqual (antForwardPosition 31 31 2) (31 0))
!(assertEqual (antForwardPosition 0 0 3) (31 0))

!(assertEqual
  (let (mkAntState $x $y $dir $time $food $eaten) (antStepTurnLeft (antInitialState))
    ($x $y $dir $time $eaten))
  (0 0 0 1 0))

!(assertEqual
  (let (mkAntState $x $y $dir $time $food $eaten) (antStepTurnRight (antInitialState))
    ($x $y $dir $time $eaten))
  (0 0 2 1 0))

!(assertEqual
  (let (mkAntState $x $y $dir $time $food $eaten)
       (antStepMoveForward
          (antStepMoveForward
             (antStepMoveForward (antInitialState))))
    (antFoodAhead (mkAntState $x $y $dir $time $food $eaten)))
  False)

!(assertEqual
  (let (mkAntEval (mkAntState $x $y $dir $time $food $eaten) $result)
       (antEvalTree
          (mkTree (mkNode and_seq) ((moveTree) (turnRightTree)))
          (antInitialState)
          600)
    ($x $y $dir $time $eaten $result))
  (1 0 2 2 1 True))

!(assertEqual
  (let (mkAntEval (mkAntState $x $y $dir $time $food $eaten) $result)
       (antEvalTree
          (mkTree (mkNode action_bool_if)
             ((foodAheadTree) (moveTree) (turnRightTree)))
          (antInitialState)
          600)
    ($x $y $dir $time $eaten $result))
  (1 0 1 1 1 True))

!(assertEqual
  (scoreAntTree (mkTree (mkNode action_success) ()) 600)
  (mkBScore (-89)))

!(assertEqual
  (scoreAntTree (mkTree (mkNode action_failure) ()) 600)
  (mkBScore (-89)))

!(assertEqual
  (scoreAntTree (moveTree) 600)
  (mkBScore (-86)))

;; A previously measured BScore must be sufficient to construct the complete
;; ant Cscore.  This is the no-resimulation path used for the initial exemplar.
!(assertEqual
  (getAntCscoreFromBScore
    (moveTree) 0.16 (mkBScore (-86)))
  (mkCscore -86 1 6.25 0.0 -92.25))

;; The evolved controller needs the configured 600-action allowance: it eats
;; 68 pellets by action 400 and all 89 by action 600.  Its Cscore independently
;; verifies the corrected action-only complexity convention.
!(assertEqual
  ((scoreAntTree (evolvedPerfectAntTree) 400)
   (scoreAntTree (evolvedPerfectAntTree) 600)
   (antTreeComplexity (evolvedPerfectAntTree))
   (getAntCscore (evolvedPerfectAntTree) 0.16 600))
  ((mkBScore (-21))
   (mkBScore (0))
   8
   (mkCscore 0 8 50.0 0.0 -50.0)))

!(assertEqual
  (scoreAntTree (mkTree (mkNode unknown_ant_action) ()) 600)
  (mkBScore (-89)))
