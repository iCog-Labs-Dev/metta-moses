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

;; C++ treats the empty sequential seed as zero complexity, while primitive
;; action and perception leaves continue to contribute one each.
!(assertEqual
  ((antTreeComplexity (ant-exemplar))
   (antTreeComplexity (moveTree))
   (antTreeComplexity (foodAheadTree))
   (antTreeComplexity
     (mkTree (mkNode action_bool_if)
       ((foodAheadTree) (moveTree) (turnRightTree)))))
  (0 1 1 3))

!(assertEqual (List.length (ant-food-coords)) (ant-food-count))


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
  (mkBScore (-89 0)))

!(assertEqual
  (scoreAntTree (mkTree (mkNode action_failure) ()) 600)
  (mkBScore (-89 0)))

!(assertEqual
  (scoreAntTree (moveTree) 600)
  (mkBScore (-89 3)))

!(assertEqual
  (scoreAntTree (mkTree (mkNode unknown_ant_action) ()) 600)
  (mkBScore (-89 0)))
