!(import! &self ../tic-tac-toe-helpers)
!(import! &self ../../../utilities/general-helpers)
!(import! &self ../random-player)
!(import! &self ../minimax-player)
!(import! &self ../alpha-beta-minimax-player)

;; Tests the surviving PLAYERS (random / minimax / alpha-beta minimax) by
;; running them head-to-head. The game engine's tree-as-player arm
;; (moses-player) is gone; interpreting a tree as X is now pinned by
;; examples/tic-tac-toe-action/tests/ttt-action-episode-test. This file keeps
;; a test-local two-policy loop -- play-game-loop (game-engine.metta:36-50)
;; minus the printing -- so the seed-42 draw stream is unchanged (one draw
;; per random move, players applied in the same X-then-O order).
;;
;; WHY hand recursion: the loop alternates two step shapes (X's turn / O's
;; turn) and has a mid-step forfeit exit with its own result (the unchanged
;; board hands the win to the opponent), so an `until` encoding would need a
;; packed state plus a synthetic terminal marker; the recursion states the
;; game rules directly.
(= (policyGame $px $po) (policyGameLoop $px $po (E E E E E E E E E) X))
(= (policyGameLoop $px $po $board $current)
   (if (is-game-over $board)
       (get-game-result $board)
       (let $new (if (== $current X) (eval ($px $board X)) (eval ($po $board O)))
            (if (== $new $board)
                (get-opponent $current)
                (policyGameLoop $px $po $new (get-opponent $current))))))

!(py-call (random.seed 42))
;; play a game between random and random stratagies
!(assertEqual (policyGame random-player random-player) Draw)
;; play a game between minimax and random stratagies
!(assertEqual (policyGame minimax-player random-player) X)
;; play a game between minimax and minimax stratagies
!(assertEqual (policyGame minimax-player minimax-player) Draw)

!(assertEqual (policyGame ab-minimax-player minimax-player) Draw)
!(assertEqual (policyGame ab-minimax-player random-player) X)
