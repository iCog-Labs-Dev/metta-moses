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