;; THE FITNESS-PACKAGE INTERFACE -- this file is the template every future
;; action experiment copies (see README.md). It DEFINES the tic-tac-toe
;; fitness functions and nothing else: it sets NO params, so merely loading
;; it never turns a run into an action run. To RUN this experiment, bind the
;; four action params (parameters/defaults.metta):
;;
;;   !(set-param fitness tttActionFitness)
;;   !(set-param bestScore tttActionBestScore)
;;   !(set-param actions (quote (tttWin tttBlock tttCenter tttCorner tttSide)))
;;   !(set-param perceptions (quote (tttCanWin tttCanBlock tttCenterFree)))
;;
;; (probe-verified: quote strips at the set-param site, so the params hold
;; the plain tuples; quote is REQUIRED because the primitives are live
;; bare-head clauses and an unquoted tuple headed by one curries into a
;; `partial` term. The two function SYMBOLS can also ride the CLI:
;; --fitness=tttActionFitness --bestScore=tttActionBestScore --
;; the tuple params cannot, so set them in-script.)
;;
;; Loads after ttt-action-episode (tttActionEpisode) and the shared
;; tic-tac-toe players (random-player / minimax-player).

;; ---- Episode-ordinal -> opponent mapping (PRIVATE to this fitness) ----
;; The scoring layer hands the fitness only the episode ordinal 0..n-1;
;; which opponent (or anything else) an ordinal means is this experiment's
;; business. Here: even ordinals play minimax-player, odd ordinals play
;; random-player -- floor(n/2) random + ceil(n/2) minimax games over
;; ordinals 0..n-1, the legacy strategy domain's split. Parity comes from
;; the shared isEven helper (utilities/general-helpers, probe-verified in
;; this runtime) -- and a bare symbol returned from an if branch is inert
;; (only TUPLES headed by live symbols need quoting).
(= (tttOpponentFor $i) (if (isEven $i) minimax-player random-player))

;; ---- The fitness: ($fn $exp $i) -> Number, higher = better ----
;; $exp arrives ALREADY COMPILED (wrapped (op (children)) shape) from the
;; scoring layer; $i is the episode ordinal.
(= (tttActionFitness $exp $i)
   (tttActionEpisode $exp (tttOpponentFor $i)))

;; ---- Best reachable raw score for $n episodes: ($fn $n) -> Number ----
;; Odd episodes (random-player) are winnable (1.0 each); even episodes
;; (minimax-player) draw at best (0.0). Best = 1.0 * floor(n/2) -- the
;; legacy strategy example's reachable optimum. Computed with integer
;; floor (py-call idiom from strategy-scoring.metta:32-37), then scaled by
;; the exact float 1.0 -- no float drift.
(= (tttActionBestScore $nTrials)
   (* 1.0 (py-call (math.floor (/ $nTrials 2)))))
