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
!(import! &self ../../../scoring/bscore)
!(import! &self ../../../scoring/cscore)
!(import! &self ../../../scoring/action-registry)
!(import! &self ../../../scoring/action-eval)
!(import! &self ../../../scoring/action-ops)
!(import! &self ../../../scoring/action-score)
!(import! &self ../tic-tac-toe-helpers)
!(import! &self ../moves)
!(import! &self ../random-player)
!(import! &self ../minimax-player)
!(import! &self ../ttt-action-world)
!(import! &self ../ttt-action-primitives)
!(import! &self ../ttt-action-episode)
!(import! &self ../ttt-action-registration)

!(py-call (random.seed 12))

;; Episode-runner tests. The flagship hand-compiled policy (wrapped shape,
;; exactly what actionExp would emit for the PRIORITIZED-OR strategy):
;;   (or_seq ((tttWin ()) (tttBlock ()) (tttCenter ()) (tttCorner ()) (tttSide ())))
;; Assertion ORDER matters for the random-player games below: they are the
;; only random consumers, pinned as the first two draws after seed 12.

;; Trivial deterministic opponent, built here for exact hand-traceable
;; games: always fills the lowest-indexed empty cell.
(= (firstEmptyPlayer $board $player)
   (let $idx (find-first-empty $board (0 1 2 3 4 5 6 7 8))
        (if (== $idx False)
            $board
            (replace-by-index $board $player $idx))))

;; The agent seat is an EXPLICIT argument now (tttActionEpisode $exp $agent
;; $opponent): these episode-mechanics asserts seat the agent as X (X moves
;; first, matching the hand-traced games below); the seat-alternation logic
;; itself is exercised by tttSeatFor and the O-seat assert further down.

;; ---- 1. Flagship (X) vs firstEmptyPlayer: hand-traced win ----
;; X:center(4) -> O:0 -> X:corner(2) -> O:1 -> X:win at 6 (diagonal 2-4-6)
;;   (E E E E X E E E E) -> (O E E E X E E E E) -> (O E X E X E E E E)
;;   -> (O O X E X E E E E) -> (O O X E X E X E E)  => X wins -> 1.0
!(assertEqual (tttActionEpisode (quote (or_seq ((tttWin ()) (tttBlock ()) (tttCenter ()) (tttCorner ()) (tttSide ()))))
                                X firstEmptyPlayer)
              1.0)

;; ---- 3. Empty tree forfeits ----
;; (and_seq ()) succeeds vacuously but never places a mark: the $moved
;; latch stays False, tttActionTreeMove returns the old board, and the
;; loop scores it as a forfeit. The empty exemplar can never score.
!(assertEqual (tttActionEpisode (quote (and_seq ())) X firstEmptyPlayer) -1.0)

;; ---- 4. Sole action becomes unavailable mid-game -> forfeit then ----
;; X takes the center on turn 1; on X's second turn the center is occupied
;; (by X itself), play-center returns False, the or_seq fails with the
;; latch unset -> forfeit -> -1.0.
!(assertEqual (tttActionEpisode (quote (or_seq ((tttCenter ())))) X firstEmptyPlayer) -1.0)

;; ---- 6. Flagship seated as O vs firstEmptyPlayer (deterministic; proves
;;         the agent plays the OTHER seat correctly). X (firstEmptyPlayer)
;;         opens; the flagship responds as O. Seat-relative scoring reports
;;         the result from O's perspective. Value pinned by running (no RNG:
;;         both players are deterministic here). ----
!(assertEqual (tttActionEpisode (quote (or_seq ((tttWin ()) (tttBlock ()) (tttCenter ()) (tttCorner ()) (tttSide ()))))
                                O firstEmptyPlayer)
              1.0)

;; ---- 5. Flagship (X) vs random-player, seed 12, two games ----
;; Pinned after verifying both land in {1.0, 0.0, -1.0} and the policy
;; wins both under this seed. These are the first RNG consumers in the file
;; (assert order fixes the draws) -- keep them ahead of any later random.
!(assertEqual (tttActionEpisode (quote (or_seq ((tttWin ()) (tttBlock ()) (tttCenter ()) (tttCorner ()) (tttSide ()))))
                                X random-player)
              1.0)
!(assertEqual (tttActionEpisode (quote (or_seq ((tttWin ()) (tttBlock ()) (tttCenter ()) (tttCorner ()) (tttSide ()))))
                                X random-player)
              1.0)

;; ---- 2. Flagship (X) vs minimax-player (deterministic; ONE game, it is the
;;         slow opponent): perfect play forces the draw, and the flagship
;;         (win/block first) never loses it -> 0.0 ----
!(assertEqual (tttActionEpisode (quote (or_seq ((tttWin ()) (tttBlock ()) (tttCenter ()) (tttCorner ()) (tttSide ()))))
                                X minimax-player)
              0.0)

;; ---- Registration file sanity (the fitness-package interface) ----
;; The params-based redesign deleted the actionDomain* config-clause family
;; (actionDomainActions/Perceptions/Opponents, actionDomainOpponentsSafe,
;; registerActionDomain): the vocabulary now binds via set-param (asserted
;; in representation/tests/create-representation-action-test) and the
;; seat/opponent mapping is PRIVATE to tttActionFitness. What the file
;; exports is the 4-way (seat x opponent) cycle on i mod 4:
;;   i%4=0 X/minimax, 1 O/minimax, 2 X/random, 3 O/random.
;; tttSeatFor -- agent is X on even ordinals, O on odd ones:
!(assertEqual (tttSeatFor 0) X)
!(assertEqual (tttSeatFor 1) O)
!(assertEqual (tttSeatFor 2) X)
!(assertEqual (tttSeatFor 3) O)
;; tttOpponentFor -- minimax while (i%4) < 2, random otherwise (so ordinals
;; 4/5 re-prove the wraparound back to minimax):
!(assertEqual (tttOpponentFor 0) minimax-player)
!(assertEqual (tttOpponentFor 1) minimax-player)
!(assertEqual (tttOpponentFor 2) random-player)
!(assertEqual (tttOpponentFor 3) random-player)
!(assertEqual (tttOpponentFor 4) minimax-player)
;; tttActionFitness routes through tttActionEpisode ($exp already
;; compiled). Ordinal 0 -> agent X vs minimax (deterministic, no random draw
;; consumed): the empty tree forfeits -> -1.0.
!(assertEqual (tttActionFitness (quote (and_seq ())) 0) -1.0)
;; ...and the same call through the param binding (the exact seam the
;; scoring layer uses -- the header's set-param line, then var-head apply)
!(set-param fitness tttActionFitness)
!(assertEqual (let $fn (param fitness) ($fn (quote (and_seq ())) 0)) -1.0)
;; best score = 1.0 per random-opponent cell (i%4 in {2,3}); minimax cells
;; (i%4 in {0,1}) draw at best. n=4 -> cells {0,1,2,3}, 2 random -> 2.0;
;; n=5 adds cell 0 (minimax) -> still 2.0; n=1 is minimax-only -> 0.0. The
;; cases below distinguish this count from the old floor(n/2): n=2 is two
;; minimax cells -> 0.0 (floor would give 1); n=3 reaches cell 2 -> 1.0;
;; n=6 has cells {2,3} random -> 2.0 (floor would give 3).
!(assertEqual (tttActionBestScore 4) 2.0)
!(assertEqual (tttActionBestScore 5) 2.0)
!(assertEqual (tttActionBestScore 1) 0.0)
!(assertEqual (tttActionBestScore 2) 0.0)
!(assertEqual (tttActionBestScore 3) 1.0)
!(assertEqual (tttActionBestScore 6) 2.0)
