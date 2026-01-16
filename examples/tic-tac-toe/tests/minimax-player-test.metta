!(import! &self ../../../utilities/general-helpers)
!(import! &self ../tic-tac-toe-helpers)
!(import! &self ../minimax-player)

;; Test case for issue: Minimax should exploit opponent's mistakes
;; When opponent fails to block, minimax should take the immediate win
;; rather than assuming opponent will play optimally in future moves

;; Test 1: O should win immediately at position 7 (column win)
;; Board: X O X
;;        E O E
;;        X E E
!(assertEqual 
    (minimax-player (X O X E O E X E E) O)
    (X O X E O E X O E))

;; Test 2: X should win immediately at position 8 (diagonal win)
;; Board: X O E
;;        O X E
;;        E E E
!(assertEqual 
    (minimax-player (X O E O X E E E E) X)
    (X O E O X E E E X))

;; Test 3: O should win immediately at position 8 (row win)
;; Board: X X E
;;        E E E
;;        O O E
!(assertEqual 
    (minimax-player (X X E E E E O O E) O)
    (X X E E E E O O O))
