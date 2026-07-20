;; Episode runner: play ONE full tic-tac-toe game with a compiled action
;; tree as the X player and an opponent policy as O, and return the raw
;; score on the standard scale (win 1.0 / draw 0.0 / loss -1.0,
;; re-implemented locally as tttOutcomeScore -- this package carries its
;; own outcome scoring).
;;
;; Loads after ttt-action-world, ttt-action-primitives,
;; scoring/action-eval and the tic-tac-toe helpers/players.

;; Outcome -> raw score (get-game-result returns X, O, or Draw).
(= (tttOutcomeScore X) 1.0)
(= (tttOutcomeScore O) -1.0)
(= (tttOutcomeScore Draw) 0.0)

;; tttActionTreeMove: run the COMPILED wrapped expression $exp for one turn
;; against a fresh per-turn world (latch reset to False) and return the new
;; board -- or the OLD board when the tree made no placement.
;;
;; The $moved check (not the ARes status) decides whether a move happened:
;; it covers both outright failure (every alternative unavailable) AND
;; vacuous success such as the empty (and_seq ()) exemplar, which succeeds
;; without placing anything -- returning the old board makes the game loop
;; below count it as a forfeit. This closes the empty-exemplar loophole:
;; a tree cannot score by doing nothing.
(= (tttActionTreeMove $exp $board $player)
   (let (mkARes $v (mkTTTWorld $newBoard $p $moved))
        (evalAction $exp (mkTTTWorld $board $player False))
        (if (== $moved True)
            $newBoard
            $board)))

;; tttActionGameLoop: mirrors play-game-loop (game-engine.metta:36-50)
;; WITHOUT the printing. X (the tree) always moves first, per the engine's
;; convention. Forfeit convention (same as the engine): a turn that leaves
;; the board unchanged loses the game -- here that is the tree's turn only,
;; since the built-in opponents always move when the game is not over.
;; Nested ifs, not `and`.
;; WHY hand recursion: the loop alternates two different step shapes (tree
;; turn / opponent turn) and has a mid-step exit with its own result (the
;; forfeit -1.0), so an `until` encoding would need a packed 4-piece state
;; plus a synthetic terminal marker; the recursion states the game rules
;; directly.
(= (tttActionGameLoop $exp $opponent $board $current)
   (if (is-game-over $board)
       (tttOutcomeScore (get-game-result $board))
       (if (== $current X)
           (let $newBoard (tttActionTreeMove $exp $board X)
                (if (== $newBoard $board)
                    -1.0
                    (tttActionGameLoop $exp $opponent $newBoard O)))
           (let $newBoard (eval ($opponent $board O))
                (tttActionGameLoop $exp $opponent $newBoard X)))))

;; tttActionEpisode: one game from the empty board, tree = X, X first.
;; $opponent is a policy symbol called as ($opponent $board O) -> new board
;; (random-player / minimax-player from examples/tic-tac-toe).
(= (tttActionEpisode $exp $opponent)
   (tttActionGameLoop $exp $opponent (E E E E E E E E E) X))
