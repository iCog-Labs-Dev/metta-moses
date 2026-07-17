;; THE DOMAIN-PACKAGE INTERFACE -- this file is the template every future
;; action domain copies (see README.md, "Adding a new action domain").
;; Four numbered sections; the scoring layer discovers everything about
;; this domain through them and never names a tic-tac-toe symbol.
;;
;; Loads after scoring/action-registry (whose sentinel clauses make the
;; actionDomain* clauses below dispatch dynamically) and after
;; ttt-action-episode.

;; ---- 1. Domain configuration ----
;; The vocabulary clauses are the SINGLE source of the domain's actions and
;; perceptions -- the knob layer (create-representation) reads them through
;; configListSafe; there is no per-primitive registration.
;; quote is REQUIRED on both vocabulary tuples: every primitive is a live
;; bare-head clause (arity 2), so an unquoted tuple headed by one would
;; compile as a CALL (matching arity fires the clause; any other arity
;; curries into an inert `partial` term). Quote strips on evaluation, so
;; callers still receive the plain tuple.
(= (actionDomainActions tttAction) (quote (tttWin tttBlock tttCenter tttCorner tttSide)))
(= (actionDomainPerceptions tttAction) (quote (tttCanWin tttCanBlock tttCenterFree)))
;; quote is REQUIRED here: random-player/minimax-player are live 2-arity
;; functions, so an unquoted (random-player minimax-player) body compiles as
;; a CALL (this repo's standard data-site hazard) and the clause silently
;; yields nothing -- the scoring layer would see a misconfigured domain and
;; score every episode -1.0. actionDomainOpponentsSafe unwraps the quote.
(= (actionDomainOpponents tttAction) (quote (random-player minimax-player)))

;; ---- 2. Episode runner ----
;; $exp arrives ALREADY COMPILED (wrapped (op (children)) shape) from the
;; scoring layer; $opponent is one element of (actionDomainOpponents ...).
(= (actionDomainRunEpisode tttAction $exp $opponent)
   (tttActionEpisode $exp $opponent))

;; ---- 3. Best reachable raw score for $nGames episodes ----
;; The scoring layer interleaves opponents by episode index: episode i gets
;; opponent (i mod 2), so even episodes play random-player (winnable ->
;; 1.0 each) and odd episodes play minimax-player (a draw, 0.0, at best).
;; Best = 1.0 * ceil(nGames/2) = nGames - floor(nGames/2). Computed with
;; integer floor (py-call idiom from strategy-scoring.metta:32-37), then
;; scaled by the exact float 1.0 -- no float drift.
(= (actionDomainBestScore tttAction $nGames)
   (* 1.0 (- $nGames (py-call (math.floor (/ $nGames 2))))))

;; ---- 4. Register the domain (name only -- CLI routing) ----
!(registerActionDomain tttAction)
