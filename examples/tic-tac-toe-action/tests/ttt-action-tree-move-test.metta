!(import! &self ../../../utilities/general-helpers)
!(import! &self ../../../utilities/list-methods)
!(import! &self ../../../utilities/tree)
!(import! &self ../../../scoring/action-registry)
!(import! &self ../../../scoring/action-eval)
!(import! &self ../../../scoring/action-ops)
!(import! &self ../../tic-tac-toe/tic-tac-toe-helpers)
!(import! &self ../../tic-tac-toe/moves)
!(import! &self ../ttt-action-world)
!(import! &self ../ttt-action-primitives)
!(import! &self ../ttt-action-episode)

;; Carries moses-player-test's tree-interpretation pins onto the action path:
;; the old test asserted moses-player reads a PRIORITIZED-OR strategy into the
;; right first move; here tttActionTreeMove reads the COMPILED wrapped tree
;; (op (children)) for one turn against a fresh (mkTTTWorld $board X False)
;; world and returns the placed board. All deterministic -- no opponent, no
;; randomness. Candidates ride under quote: this file loads action-ops'
;; or_seq clause, so a bare (or_seq (...)) at a call site would compile as a
;; call (see the quote rule in scoring/action-ops.metta / the fixtures in
;; ttt-action-primitives-test.metta).

;; play-side first: first empty of (1 3 5 7) -> index 1 (was: PRIORITIZED-OR
;; playside on the empty board -> (E X E E E E E E E))
!(assertEqual (tttActionTreeMove (quote (or_seq ((tttSide ())))) (E E E E E E E E E) X)
              (E X E E E E E E E))

;; win unavailable on the empty board -> the or_seq falls through to play-side
;; (was: PRIORITIZED-OR playwin playside -> (E X E E E E E E E))
!(assertEqual (tttActionTreeMove (quote (or_seq ((tttWin ()) (tttSide ())))) (E E E E E E E E E) X)
              (E X E E E E E E E))

;; play-corner first: first empty of (0 2 6 8) -> index 0 (was: PRIORITIZED-OR
;; playcorner playside -> (X E E E E E E E E))
!(assertEqual (tttActionTreeMove (quote (or_seq ((tttCorner ()) (tttSide ())))) (E E E E E E E E E) X)
              (X E E E E E E E E))
