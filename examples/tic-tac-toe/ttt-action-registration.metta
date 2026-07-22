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

;; ---- Episode-ordinal -> (seat, opponent) mapping (PRIVATE to this fitness) ----
;; The scoring layer hands the fitness only the episode ordinal 0..n-1; what
;; an ordinal MEANS is this experiment's business. The agent alternates BOTH
;; the seat it plays (X or O) AND the opponent it faces, cycling through the
;; four (seat x opponent) cells every 4 ordinals (i mod 4):
;;
;;   i%4=0: agent X vs minimax    i%4=1: agent O vs minimax
;;   i%4=2: agent X vs random     i%4=3: agent O vs random
;;
;; Seat and opponent are read off i with the shared isEven / % helpers
;; (utilities/general-helpers, probe-verified in this runtime): the agent is
;; X on even ordinals (i%4 in {0,2}) and O on odd ones; the opponent is
;; minimax while (i%4) < 2 and random otherwise. A bare symbol returned from
;; an if branch is inert (only TUPLES headed by live symbols need quoting).
;; This restores the deleted strategy path's seat-relative play -- its
;; interpreter (moses-player) and moves were already seat-parameterized --
;; while adding the seat alternation that path never actually wired up.
(= (tttSeatFor $i) (if (isEven $i) X O))
(= (tttOpponentFor $i) (if (< (% $i 4) 2) minimax-player random-player))

;; ---- The fitness: ($fn $exp $i) -> Number, higher = better ----
;; $exp arrives ALREADY COMPILED (wrapped (op (children)) shape) from the
;; scoring layer; $i is the episode ordinal.
(= (tttActionFitness $exp $i)
   (tttActionEpisode $exp (tttSeatFor $i) (tttOpponentFor $i)))

;; ---- Best reachable raw score for $n episodes: ($fn $n) -> Number ----
;; Only the random-opponent cells (i%4 in {2,3}) are winnable (1.0 each);
;; the minimax cells (i%4 in {0,1}) draw at best (0.0 each -- perfect play,
;; either seat, never loses tic-tac-toe). So the reachable optimum is 1.0
;; per random-opponent episode. Over ordinals 0..n-1 that is exactly two
;; random cells per full block of four, plus one more when the remainder is
;; 3 (the block ...,2 lands a random cell). Integer arithmetic (math.floor
;; via py-call), scaled by the exact float 1.0 -- no float drift.
(= (tttActionBestScore $nTrials)
   (let* (($q (py-call (math.floor (/ $nTrials 4))))
          ($r (- $nTrials (* 4 $q))))
     (* 1.0 (+ (* 2 $q) (if (> $r 2) 1 0)))))
