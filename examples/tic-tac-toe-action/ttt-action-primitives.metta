;; Tic-tac-toe domain primitives for the generic action evaluator: one
;; actionOp clause per action/perception, per the contract in
;; scoring/action-ops.metta --
;;     (= (actionOp <name> $children $world) (mkARes <Bool> <World'>))
;; All primitives here are leaves, so $children is ignored. The world is
;; (mkTTTWorld $board $player $moved) from ttt-action-world.
;;
;; ACTIONS delegate the move choice to the existing move finders in
;; examples/tic-tac-toe/moves.metta (index 0-8 or False) and route the
;; result through applyTTTMove (latch/noop/failure semantics live there).
;;
;; Loads after ttt-action-world and examples/tic-tac-toe/moves.

;; ---- Domain actions ----
(= (actionOp tttWin $children $world)
   (applyTTTMove $world (play-win (worldBoard $world) (worldPlayer $world))))
(= (actionOp tttBlock $children $world)
   (applyTTTMove $world (play-block (worldBoard $world) (worldPlayer $world))))
(= (actionOp tttCenter $children $world)
   (applyTTTMove $world (play-center (worldBoard $world) (worldPlayer $world))))
(= (actionOp tttCorner $children $world)
   (applyTTTMove $world (play-corner (worldBoard $world) (worldPlayer $world))))
(= (actionOp tttSide $children $world)
   (applyTTTMove $world (play-side (worldBoard $world) (worldPlayer $world))))

;; ---- Domain perceptions (read-only: world returned unchanged, the truth
;;      value is a pure board query; they never touch the $moved latch) ----

;; tttCanWin: the player has an immediate winning placement.
(= (actionOp tttCanWin $children $world)
   (mkARes (not (== (play-win (worldBoard $world) (worldPlayer $world)) False))
           $world))

;; tttCanBlock: the opponent has an immediate winning placement to block.
(= (actionOp tttCanBlock $children $world)
   (mkARes (not (== (play-block (worldBoard $world) (worldPlayer $world)) False))
           $world))

;; tttCenterFree: the center cell (index 4 in the 0-8 row-major board,
;; empty = E) is still empty.
(= (actionOp tttCenterFree $children $world)
   (mkARes (== (index-atom (worldBoard $world) 4) E) $world))
