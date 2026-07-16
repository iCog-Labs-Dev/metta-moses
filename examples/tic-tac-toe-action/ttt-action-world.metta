;; Tic-tac-toe ACTION-domain world state.
;;
;; World = (mkTTTWorld $board $player $moved)
;;   $board  -- the engine board tuple (E E E E E E E E E), indices 0-8
;;              row-major (see examples/tic-tac-toe/game-engine.metta).
;;   $player -- the mark the candidate tree plays (X in this package).
;;   $moved  -- the ONE-MOVE-PER-TURN LATCH. A tic-tac-toe turn admits
;;              exactly one placement, so every placement action becomes a
;;              success-NOOP once $moved is True. That makes both
;;              (and_seq tttWin tttBlock ...) and (or_seq ...) behave
;;              sensibly over multi-action trees: the first action that
;;              actually places a mark consumes the turn, later actions in
;;              the same turn succeed without touching the board. In
;;              particular (or_seq tttWin tttBlock tttCenter tttCorner
;;              tttSide) is semantically equal to the existing
;;              PRIORITIZED-OR strategy of the tic-tac-toe strategy example.
;;
;; Loads after examples/tic-tac-toe/tic-tac-toe-helpers (replace-by-index
;; must have clauses when applyTTTMove compiles).

;; Fresh per-turn world: no move made yet this turn.
(= (mkInitialTTTWorld $board $player) (mkTTTWorld $board $player False))

;; ---- Accessors ----
(= (worldBoard (mkTTTWorld $b $p $m)) $b)
(= (worldPlayer (mkTTTWorld $b $p $m)) $p)
(= (worldMoved (mkTTTWorld $b $p $m)) $m)

;; applyTTTMove: shared placement kernel for every domain action.
;;   $idx is the output of a moves.metta finder: a cell index 0-8, or False
;;   when that move is unavailable on the current board.
;;   - $moved already True -> success-NOOP (the turn is used up; see latch
;;     note above): board and latch unchanged.
;;   - $idx == False       -> this move is unavailable: failure, world
;;     unchanged (an or_seq falls through to its next alternative).
;;   - otherwise           -> place the mark and set the latch.
;; Nested ifs, not `and` (guards must not evaluate eagerly).
(= (applyTTTMove (mkTTTWorld $b $p $moved) $idx)
   (if (== $moved True)
       (mkARes True (mkTTTWorld $b $p $moved))
       (if (== $idx False)
           (mkARes False (mkTTTWorld $b $p $moved))
           (mkARes True (mkTTTWorld (replace-by-index $b $p $idx) $p True)))))
