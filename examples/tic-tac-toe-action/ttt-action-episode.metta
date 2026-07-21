;; Episode runner: play ONE full tic-tac-toe game with a compiled action
;; tree seated as $agent (X or O) against an opponent policy on the other
;; seat, and return the raw score on the standard scale (win 1.0 / draw 0.0
;; / loss -1.0, re-implemented locally as tttOutcomeScore -- this package
;; carries its own outcome scoring).
;;
;; The agent is NOT hard-wired to X: the action primitives are seat-agnostic
;; (they play for whichever mark the world carries), so a compiled tree can
;; play either seat. The fitness (ttt-action-registration) alternates the
;; agent between X and O across episodes; X still always MOVES FIRST, per the
;; engine convention, so an O-seated agent responds to the opponent's opener.
;; This mirrors the deleted strategy path, whose score-result was likewise
;; SEAT-RELATIVE ((score-result $result $playerMark)) rather than X-hardcoded.
;;
;; Loads after ttt-action-world, ttt-action-primitives,
;; scoring/action-eval and the tic-tac-toe helpers/players.

;; Outcome -> raw score, RELATIVE to the agent's seat $agent (X or O):
;; the agent's own mark wins (1.0), Draw is 0.0, the opponent's mark loses
;; (-1.0). get-game-result returns X, O, or Draw. (Was: the X-hardcoded
;; unary tttOutcomeScore; this restores the strategy path's score-result
;; perspective-relativity now that the agent alternates seats.)
(= (tttOutcomeScore $result $agent)
   (if (== $result $agent)
       1.0
       (if (== $result Draw) 0.0 -1.0)))

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
;; WITHOUT the printing. X always moves first, per the engine's convention;
;; the tree occupies the $agent seat (X or O) and the opponent policy plays
;; whichever seat is current on its turn. Forfeit convention (same as the
;; engine): a turn that leaves the board unchanged loses the game -- here
;; that is the AGENT's turn only, since the built-in opponents always move
;; when the game is not over. Nested ifs, not `and`.
;; WHY hand recursion: the loop alternates two different step shapes (agent
;; turn / opponent turn) and has a mid-step exit with its own result (the
;; forfeit -1.0), so an `until` encoding would need a packed state plus a
;; synthetic terminal marker; the recursion states the game rules directly.
(= (tttActionGameLoop $exp $agent $opponent $board $current)
   (if (is-game-over $board)
       (tttOutcomeScore (get-game-result $board) $agent)
       (if (== $current $agent)
           (let $newBoard (tttActionTreeMove $exp $board $agent)
                (if (== $newBoard $board)
                    -1.0
                    (tttActionGameLoop $exp $agent $opponent $newBoard (get-opponent $current))))
           (let $newBoard (eval ($opponent $board $current))
                (tttActionGameLoop $exp $agent $opponent $newBoard (get-opponent $current))))))

;; tttActionEpisode: one game from the empty board, tree seated as $agent,
;; X first. $opponent is a policy symbol called as ($opponent $board $mark)
;; -> new board (random-player / minimax-player from examples/tic-tac-toe).
(= (tttActionEpisode $exp $agent $opponent)
   (tttActionGameLoop $exp $agent $opponent (E E E E E E E E E) X))
