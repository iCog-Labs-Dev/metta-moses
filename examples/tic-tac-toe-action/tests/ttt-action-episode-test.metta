!(import! &self ../../../utilities/general-helpers)
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
!(import! &self ../../tic-tac-toe/tic-tac-toe-helpers)
!(import! &self ../../tic-tac-toe/moves)
!(import! &self ../../tic-tac-toe/random-player)
!(import! &self ../../tic-tac-toe/minimax-player)
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

;; ---- 1. Flagship vs firstEmptyPlayer: hand-traced win ----
;; X:center(4) -> O:0 -> X:corner(2) -> O:1 -> X:win at 6 (diagonal 2-4-6)
;;   (E E E E X E E E E) -> (O E E E X E E E E) -> (O E X E X E E E E)
;;   -> (O O X E X E E E E) -> (O O X E X E X E E)  => X wins -> 1.0
!(assertEqual (tttActionEpisode (quote (or_seq ((tttWin ()) (tttBlock ()) (tttCenter ()) (tttCorner ()) (tttSide ()))))
                                firstEmptyPlayer)
              1.0)

;; ---- 3. Empty tree forfeits ----
;; (and_seq ()) succeeds vacuously but never places a mark: the $moved
;; latch stays False, tttActionTreeMove returns the old board, and the
;; loop scores it as a forfeit. The empty exemplar can never score.
!(assertEqual (tttActionEpisode (quote (and_seq ())) firstEmptyPlayer) -1.0)

;; ---- 4. Sole action becomes unavailable mid-game -> forfeit then ----
;; X takes the center on turn 1; on X's second turn the center is occupied
;; (by X itself), play-center returns False, the or_seq fails with the
;; latch unset -> forfeit -> -1.0.
!(assertEqual (tttActionEpisode (quote (or_seq ((tttCenter ())))) firstEmptyPlayer) -1.0)

;; ---- 5. Flagship vs random-player, seed 12, two games ----
;; Pinned after verifying both land in {1.0, 0.0, -1.0} and the policy
;; wins both under this seed.
!(assertEqual (tttActionEpisode (quote (or_seq ((tttWin ()) (tttBlock ()) (tttCenter ()) (tttCorner ()) (tttSide ()))))
                                random-player)
              1.0)
!(assertEqual (tttActionEpisode (quote (or_seq ((tttWin ()) (tttBlock ()) (tttCenter ()) (tttCorner ()) (tttSide ()))))
                                random-player)
              1.0)

;; ---- 2. Flagship vs minimax-player (deterministic; ONE game, it is the
;;         slow opponent): perfect play forces the draw, and the flagship
;;         (win/block first) never loses it -> 0.0 ----
!(assertEqual (tttActionEpisode (quote (or_seq ((tttWin ()) (tttBlock ()) (tttCenter ()) (tttCorner ()) (tttSide ()))))
                                minimax-player)
              0.0)

;; ---- Registration file sanity (the domain-package interface) ----
!(assertEqual (isRegisteredActionDomain tttAction) True)
!(assertEqual (registeredDomainActions) (quote (tttWin tttBlock tttCenter tttCorner tttSide)))
!(assertEqual (registeredDomainPerceptions) (quote (tttCanWin tttCanBlock tttCenterFree)))
!(assertEqual (actionDomainActions tttAction) (quote (tttWin tttBlock tttCenter tttCorner tttSide)))
!(assertEqual (actionDomainPerceptions tttAction) (quote (tttCanWin tttCanBlock tttCenterFree)))
;; opponents: the registration clause is quote-wrapped (the player symbols
;; are live functions -- bare, the tuple would compile as a CALL and the
;; clause would silently yield nothing). Both sides sit under quote so
;; neither ever calls random-player.
!(assertEqual (actionDomainOpponents tttAction) (quote (random-player minimax-player)))
;; ...and the scoring layer's retrieval helper hands the episode loop the
;; plain unwrapped tuple (THE seam: misconfiguration here silently scores
;; every episode -1.0)
!(assertEqual (actionDomainOpponentsSafe tttAction) (quote (random-player minimax-player)))
;; runEpisode routes through tttActionEpisode ($exp already compiled)
!(assertEqual (actionDomainRunEpisode tttAction (quote (and_seq ())) firstEmptyPlayer) -1.0)
;; best score = 1.0 * ceil(n/2): even episodes (random-player) winnable,
;; odd episodes (minimax-player) draw at best
!(assertEqual (actionDomainBestScore tttAction 4) 2.0)
!(assertEqual (actionDomainBestScore tttAction 5) 3.0)
!(assertEqual (actionDomainBestScore tttAction 1) 1.0)
