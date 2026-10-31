!(import! &self ../../../utilities/general-helpers)
!(import! &self ../../../utilities/list-methods)
!(import! &self ../../../utilities/tree)
!(import! &self ../../../scoring/action-registry)
!(import! &self ../../../scoring/action-eval)
!(import! &self ../../../scoring/action-ops)
!(import! &self ../tic-tac-toe-helpers)
!(import! &self ../moves)
!(import! &self ../ttt-action-world)
!(import! &self ../ttt-action-primitives)

;; Deterministic unit tests for the tic-tac-toe action-domain primitives.
;; NO randomness; every board is hand-built. Board indices 0-8, row-major:
;;   0 | 1 | 2
;;   3 | 4 | 5
;;   6 | 7 | 8
;; Reference threat board used throughout: (X X E E O O E E E)
;;   X wins at 2 (row 0-1-2); O wins at 3 (row 3-4-5) so X must block at 3.

;; ---- applyTTTMove directly: all three arms ----
;; latch already set -> success-NOOP, board and latch unchanged
!(assertEqual (applyTTTMove (mkTTTWorld (X X E E O O E E E) X True) 2)
              (mkARes True (mkTTTWorld (X X E E O O E E E) X True)))
;; unavailable move (finder returned False) -> failure, world unchanged
!(assertEqual (applyTTTMove (mkTTTWorld (X X E E O O E E E) X False) False)
              (mkARes False (mkTTTWorld (X X E E O O E E E) X False)))
;; fresh turn + real index -> mark placed, latch set
!(assertEqual (applyTTTMove (mkTTTWorld (X X E E O O E E E) X False) 2)
              (mkARes True (mkTTTWorld (X X X E O O E E E) X True)))

;; ---- World constructor / accessors ----
!(assertEqual (mkInitialTTTWorld (E E E E E E E E E) X)
              (mkTTTWorld (E E E E E E E E E) X False))
!(assertEqual (worldBoard (mkTTTWorld (X X E E O O E E E) X False)) (X X E E O O E E E))
!(assertEqual (worldPlayer (mkTTTWorld (X X E E O O E E E) X False)) X)
!(assertEqual (worldMoved (mkTTTWorld (X X E E O O E E E) X True)) True)

;; ---- tttWin: places the winning index / fails when none exists ----
!(assertEqual (evalAction (quote (tttWin ())) (mkTTTWorld (X X E E O O E E E) X False))
              (mkARes True (mkTTTWorld (X X X E O O E E E) X True)))
;; no winning move on an empty board
!(assertEqual (evalAction (quote (tttWin ())) (mkTTTWorld (E E E E E E E E E) X False))
              (mkARes False (mkTTTWorld (E E E E E E E E E) X False)))

;; ---- tttBlock: blocks the opponent's winning cell ----
!(assertEqual (evalAction (quote (tttBlock ())) (mkTTTWorld (X X E E O O E E E) X False))
              (mkARes True (mkTTTWorld (X X E X O O E E E) X True)))
;; nothing to block on an empty board
!(assertEqual (evalAction (quote (tttBlock ())) (mkTTTWorld (E E E E E E E E E) X False))
              (mkARes False (mkTTTWorld (E E E E E E E E E) X False)))

;; ---- tttCenter / tttCorner / tttSide: the finders' documented priority
;;      (play-center: (4); play-corner: (0 2 6 8); play-side: (1 3 5 7)) ----
!(assertEqual (evalAction (quote (tttCenter ())) (mkTTTWorld (E E E E E E E E E) X False))
              (mkARes True (mkTTTWorld (E E E E X E E E E) X True)))
;; center taken -> unavailable -> failure
!(assertEqual (evalAction (quote (tttCenter ())) (mkTTTWorld (E E E E O E E E E) X False))
              (mkARes False (mkTTTWorld (E E E E O E E E E) X False)))
;; first free corner in order 0,2,6,8
!(assertEqual (evalAction (quote (tttCorner ())) (mkTTTWorld (E E E E E E E E E) X False))
              (mkARes True (mkTTTWorld (X E E E E E E E E) X True)))
!(assertEqual (evalAction (quote (tttCorner ())) (mkTTTWorld (O E E E E E E E E) X False))
              (mkARes True (mkTTTWorld (O E X E E E E E E) X True)))
;; all corners taken -> failure
!(assertEqual (evalAction (quote (tttCorner ())) (mkTTTWorld (O E X E E E X E O) X False))
              (mkARes False (mkTTTWorld (O E X E E E X E O) X False)))
;; first free side in order 1,3,5,7
!(assertEqual (evalAction (quote (tttSide ())) (mkTTTWorld (E E E E E E E E E) X False))
              (mkARes True (mkTTTWorld (E X E E E E E E E) X True)))
!(assertEqual (evalAction (quote (tttSide ())) (mkTTTWorld (E X E O E E E E E) X False))
              (mkARes True (mkTTTWorld (E X E O E X E E E) X True)))

;; ---- The latch: EVERY placement action is a success-NOOP once $moved=True
;;      (board unchanged, moved stays True) -- even a winning move ----
!(assertEqual (evalAction (quote (tttWin ())) (mkTTTWorld (X X E E O O E E E) X True))
              (mkARes True (mkTTTWorld (X X E E O O E E E) X True)))
!(assertEqual (evalAction (quote (tttBlock ())) (mkTTTWorld (X X E E O O E E E) X True))
              (mkARes True (mkTTTWorld (X X E E O O E E E) X True)))
!(assertEqual (evalAction (quote (tttCenter ())) (mkTTTWorld (E E E E E E E E E) X True))
              (mkARes True (mkTTTWorld (E E E E E E E E E) X True)))
!(assertEqual (evalAction (quote (tttCorner ())) (mkTTTWorld (E E E E E E E E E) X True))
              (mkARes True (mkTTTWorld (E E E E E E E E E) X True)))
!(assertEqual (evalAction (quote (tttSide ())) (mkTTTWorld (E E E E E E E E E) X True))
              (mkARes True (mkTTTWorld (E E E E E E E E E) X True)))

;; ---- Perceptions: True and False cases; the world (including the latch)
;;      is NEVER changed ----
!(assertEqual (evalAction (quote (tttCanWin ())) (mkTTTWorld (X X E E O O E E E) X False))
              (mkARes True (mkTTTWorld (X X E E O O E E E) X False)))
!(assertEqual (evalAction (quote (tttCanWin ())) (mkTTTWorld (E E E E E E E E E) X False))
              (mkARes False (mkTTTWorld (E E E E E E E E E) X False)))
!(assertEqual (evalAction (quote (tttCanBlock ())) (mkTTTWorld (X X E E O O E E E) X False))
              (mkARes True (mkTTTWorld (X X E E O O E E E) X False)))
!(assertEqual (evalAction (quote (tttCanBlock ())) (mkTTTWorld (E E E E E E E E E) X False))
              (mkARes False (mkTTTWorld (E E E E E E E E E) X False)))
!(assertEqual (evalAction (quote (tttCenterFree ())) (mkTTTWorld (E E E E E E E E E) X False))
              (mkARes True (mkTTTWorld (E E E E E E E E E) X False)))
!(assertEqual (evalAction (quote (tttCenterFree ())) (mkTTTWorld (E E E E O E E E E) X False))
              (mkARes False (mkTTTWorld (E E E E O E E E E) X False)))
;; perceptions read through a set latch without touching it
!(assertEqual (evalAction (quote (tttCanWin ())) (mkTTTWorld (X X E E O O E E E) X True))
              (mkARes True (mkTTTWorld (X X E E O O E E E) X True)))

;; ---- End-to-end through the generic evaluator: or_seq falls through the
;;      unavailable win to the center ----
!(assertEqual (evalAction (quote (or_seq ((tttWin ()) (tttCenter ()))))
                          (mkTTTWorld (E E E E E E E E E) X False))
              (mkARes True (mkTTTWorld (E E E E X E E E E) X True)))
