!(import! &self ../../../utilities/general-helpers)
;; parameters load BEFORE scoring/action-score below: the scorer reads
;; (param fitness), and PeTTa gates reduction on load order.
!(import! &self ../../../parameters/registry)
!(import! &self ../../../parameters/defaults)
!(import! &self ../../../utilities/list-methods)
!(import! &self ../../../utilities/tree)
!(import! &self ../../../scoring/cacheSpace)
!(import! &self ../../../scoring/fitness)
!(import! &self ../../../scoring/boolean-ops)
!(import! &self ../../../scoring/action-registry)
!(import! &self ../../../scoring/action-eval)
!(import! &self ../../../scoring/action-ops)
!(import! &self ../../../scoring/bscore)
!(import! &self ../../../scoring/cscore)
!(import! &self ../../../scoring/action-score)
!(import! &self ../../tic-tac-toe/tic-tac-toe-helpers)
!(import! &self ../../tic-tac-toe/moves)
!(import! &self ../../tic-tac-toe/random-player)
!(import! &self ../../tic-tac-toe/minimax-player)
!(import! &self ../ttt-action-world)
!(import! &self ../ttt-action-primitives)
!(import! &self ../ttt-action-episode)
!(import! &self ../ttt-action-registration)

!(py-call (random.seed 42))

;; Conversion of examples/tic-tac-toe/tests/strategy-scoring-test (9 asserts)
;; plus scoring/test/cscore-test's strategy assert, onto the generic action
;; scoring stack. The legacy matchups carry over via TEST-LOCAL plug-in action
;; primitives that WRAP the real players: ssRandomAct plays random-player's
;; move as an action, ssMinimaxAct plays minimax-player's move. Two test-local
;; fitnesses fix the opponent (ignoring the ordinal): ssVsMinimax always faces
;; minimax-player, ssVsRandom always faces random-player -- the direct analog
;; of the old (evaluate-strategy n X <me> <opponent>) matchups. NO source edits.
;; Candidates ride under quote at data sites: this file loads action-ops'
;; or_seq clause, so a bare (or_seq (...)) would compile as a call.
;;
;; SEED: 42 for the whole file. The stochastic pins below (random-opponent /
;; random-candidate games) were RUN FIRST under this seed; each such assert
;; carries the legacy assumption it re-pins.

;; ---- Plug-in action primitives (wrap the real players; idioms copied from
;;      random-player.metta / minimax-player.metta) ----
(= (ssRandomIdx $board)
   (let* (($empty (get-empty-cells $board () 0))
          ($count (length $empty))
          ($pick  (py-call (random.randint 0 (- $count 1)))))
     (index-atom $empty $pick)))
(= (ssRandomAct $params $world) (applyTTTMove $world (ssRandomIdx (worldBoard $world))))
(= (ssMinimaxIdx $board $player)
   (let $empty (get-empty-cells $board () 0)
        (find-best-move-loop $board $empty -1000 -1 $player (get-opponent $player))))
(= (ssMinimaxAct $params $world) (applyTTTMove $world (ssMinimaxIdx (worldBoard $world) (worldPlayer $world))))

;; ---- Test-local fitnesses (fix the opponent; ordinal ignored) ----
(= (ssVsMinimax $exp $i) (tttActionEpisode $exp minimax-player))
(= (ssVsRandom  $exp $i) (tttActionEpisode $exp random-player))

;; ---- Outcome -> raw score (was: score-result X X / X O / Draw X) ----
!(assertEqual (tttOutcomeScore X) 1.0)
!(assertEqual (tttOutcomeScore O) -1.0)
!(assertEqual (tttOutcomeScore Draw) 0.0)

;; ---- Episode lists (was: evaluate-strategy ...) ----
;; random candidate vs minimax: minimax never LOSES, but a random candidate
;; can luck into a draw -- legacy pinned 5x-1.0 (game-engine flow); under
;; seed 42 on the action path the 5th game happens to draw.
!(assertEqual (runActionEpisodes ssVsMinimax (quote (or_seq ((ssRandomAct ())))) 5)
              (-1.0 -1.0 -1.0 -1.0 0.0))
;; random candidate vs random (legacy pinned 3x-1.0 UNSEEDED, statistically
;; unsound; re-pinned under seed 42: one draw then two wins).
!(assertEqual (runActionEpisodes ssVsRandom (quote (or_seq ((ssRandomAct ())))) 3)
              (0.0 1.0 1.0))
;; minimax candidate vs random: candidate wins every game (was:
;; evaluate-strategy 3 X minimax random -> 3x1.0).
!(assertEqual (runActionEpisodes ssVsRandom (quote (or_seq ((ssMinimaxAct ())))) 3)
              (1.0 1.0 1.0))

;; ---- Cached behavioral score (was: score-strategy ...) ----
;; minimax candidate vs random -> (1.0 1.0 1.0) (seed-pinned; fresh triple).
!(set-param fitness ssVsRandom)
!(assertEqual (scoreActionTree (mkTree (mkNode or_seq) ((mkTree (mkNode ssMinimaxAct) ()))) 3 &actionScoreCache)
              (mkBScore (1.0 1.0 1.0)))
;; random candidate vs minimax: minimax never loses, but this random triple
;; drew games 2-3 under seed 42 (legacy assumed 3x-1.0; re-pinned).
!(set-param fitness ssVsMinimax)
!(assertEqual (scoreActionTree (mkTree (mkNode or_seq) ((mkTree (mkNode ssRandomAct) ()))) 3 &actionScoreCache)
              (mkBScore (-1.0 0.0 0.0)))
;; minimax candidate vs minimax -> deterministic draws (0.0 0.0 0.0).
!(assertEqual (scoreActionTree (mkTree (mkNode or_seq) ((mkTree (mkNode ssMinimaxAct) ()))) 3 &actionScoreCache)
              (mkBScore (0.0 0.0 0.0)))

;; ---- Composite score (was: cscore-test @122-130, the PRIORITIZED-OR
;;      playcenter/playside/playcorner strategy scored over 5 mixed-opponent
;;      games). Here the center-first action tree scored via tttActionFitness:
;;      even ordinals face minimax (draw 0.0), odd ordinals face random
;;      (2 winnable games -> 2.0). complexity = 3 leaves. ----
!(set-param fitness tttActionFitness)
(= (ActionStrategyTree)
   (mkTree (mkNode or_seq)
     (cons (mkTree (mkNode tttCenter) ())
           (cons (mkTree (mkNode tttSide) ())
                 (cons (mkTree (mkNode tttCorner) ()) ())))))
!(assertEqual (getActionCscore (ActionStrategyTree) (mkActionCtx 5) 3.5 &actionScoreCache)
              (mkCscore 2.0 3 0.8571428571428571 0.0 1.1428571428571428))
