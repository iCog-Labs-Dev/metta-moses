;; THE DOMAIN-PACKAGE INTERFACE -- this file is the template every future
;; action domain copies (see README.md, "Adding a new action domain").
;; Five numbered sections; the scoring layer discovers everything about
;; this domain through them and never names a tic-tac-toe symbol.
;;
;; Loads after scoring/action-registry (registration API + the sentinel
;; clauses that make the actionDomain* clauses below dispatch dynamically)
;; and after ttt-action-episode.

;; ---- 1. Register the primitives (knob layer vocabulary) ----
!(registerDomainAction tttWin)
!(registerDomainAction tttBlock)
!(registerDomainAction tttCenter)
!(registerDomainAction tttCorner)
!(registerDomainAction tttSide)
!(registerDomainPerception tttCanWin)
!(registerDomainPerception tttCanBlock)
!(registerDomainPerception tttCenterFree)

;; ---- 2. Domain configuration ----
(= (actionDomainActions tttAction) (tttWin tttBlock tttCenter tttCorner tttSide))
(= (actionDomainPerceptions tttAction) (tttCanWin tttCanBlock tttCenterFree))
;; quote is REQUIRED here: random-player/minimax-player are live 2-arity
;; functions, so an unquoted (random-player minimax-player) body compiles as
;; a CALL (this repo's standard data-site hazard) and the clause silently
;; yields nothing -- the scoring layer would see a misconfigured domain and
;; score every episode -1.0. actionDomainOpponentsSafe unwraps the quote.
(= (actionDomainOpponents tttAction) (quote (random-player minimax-player)))

;; ---- 3. Episode runner ----
;; $exp arrives ALREADY COMPILED (wrapped (op (children)) shape) from the
;; scoring layer; $opponent is one element of (actionDomainOpponents ...).
(= (actionDomainRunEpisode tttAction $exp $opponent)
   (tttActionEpisode $exp $opponent))

;; ---- 4. Best reachable raw score for $nGames episodes ----
;; The scoring layer interleaves opponents by episode index: episode i gets
;; opponent (i mod 2), so even episodes play random-player (winnable ->
;; 1.0 each) and odd episodes play minimax-player (a draw, 0.0, at best).
;; Best = 1.0 * ceil(nGames/2) = nGames - floor(nGames/2). Computed with
;; integer floor (py-call idiom from strategy-scoring.metta:32-37), then
;; scaled by the exact float 1.0 -- no float drift.
(= (actionDomainBestScore tttAction $nGames)
   (* 1.0 (- $nGames (py-call (math.floor (/ $nGames 2))))))

;; ---- 5. Register the domain ----
!(registerActionDomain tttAction)
