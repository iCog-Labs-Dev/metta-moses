!(import! &self ../../../utilities/general-helpers)
!(import! &self ../../tic-tac-toe/tic-tac-toe-helpers)

!(assertEqual (get-opponent X) O)
!(assertEqual (check-line (X X X E O E E E E) 0 1 2) X)
!(assertEqual (check-line (X O X E E E E E E) 0 1 2) E)

!(assertEqual 
    (replace-by-index (E E E) X 0) 
    (X E E))
!(assertEqual 
    (replace-by-index (X E E) O 1) 
    (X O E))

!(assertEqual 
    (get-empty-cells (E E E E E E E E E) () 0) 
    (0 1 2 3 4 5 6 7 8))
!(assertEqual 
    (get-empty-cells (X E E E O E E E X) () 0) 
    (1 2 3 5 6 7))
!(assertEqual 
    (get-empty-cells (X O X O X O X O X) () 0) 
    ())

;; 6. Testing find-first-empty
;; Should pick 4 (center) because it's first in preference list and empty
!(assertEqual 
    (find-first-empty (E E E E E E E E E) (4 0 2 6 8)) 
    4)
;; Center is taken (X), should pick next available preference (0)
!(assertEqual 
    (find-first-empty (E E E E X E E E E) (4 0 2 6 8)) 
    0)
;; No preferred cells are empty
!(assertEqual 
    (find-first-empty (X X X X X X X X X) (4 0 2 6 8)) 
    False)
;; Horizontal Win
!(assertEqual (get-winner (X X X O E O E E E)) X)
;; Vertical Win
!(assertEqual (get-winner (O X E O X E O E E)) O)
;; Diagonal Win
!(assertEqual (get-winner (X O E O X E E E X)) X)
;; No Winner
!(assertEqual (get-winner (X O X O X O E E E)) E)

;; Player X wins (Player=X, Opponent=O) -> Expect 10
!(assertEqual 
    (evaluate-board (X X X O O E E E E) X O) 
    10)
;; Opponent O wins (Player=X, Opponent=O) -> Expect -10
!(assertEqual 
    (evaluate-board (O O O X X E E E E) X O) 
    -10)
;; No winner yet -> Expect 0
!(assertEqual 
    (evaluate-board (X O X E E E E E E) X O) 
    0)
;; 7. testing is-board-full helper
;; empty board should return false
!(assertEqual (is-board-full (E E E E E E E E E)) False)
;; Partially filled board - should return False
!(assertEqual 
    (is-board-full (X O X E E E E E E)) 
    False)
;; Completely full board - should return True
!(assertEqual 
    (is-board-full (X O X O X O X O X)) 
    True)
;; 8. Test is-game-over helper
;; Game in progress - should return False
!(assertEqual (is-game-over (X O X E E E E E E)) False)
;; X wins - should return True
!(assertEqual (is-game-over (X X X O O E E E E)) True)
;; O wins - should return True
!(assertEqual (is-game-over (O O O X X E E E E)) True)
;; Board full (draw) - should return True
!(assertEqual (is-game-over (X O X O X O O X O)) True)
;; 9. Test get-game-result helper
;; X wins - should return X
!(assertEqual (get-game-result (X X X O O E E E E)) X)
;; O wins - should return O
!(assertEqual (get-game-result (O O O X X E E E E)) O)
;; Draw (board full, no winner) - should return Draw
!(assertEqual (get-game-result (X O X O X O O X O)) Draw)
;; Game in progress - should return E
!(assertEqual (get-game-result (X O X E E E E E E)) E)