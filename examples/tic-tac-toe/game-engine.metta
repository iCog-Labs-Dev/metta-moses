
;; =============================================================================
;; TIC-TAC-TOE GAME ENGINE
;; =============================================================================
;; This is a complete Tic-Tac-Toe game engine written in MeTTa that can run
;; games between different strategies. The engine handles:
;; - Game state management (board representation and updates)
;; - Turn-based gameplay between two players (X and O)
;; - Win/draw detection and game termination
;; - Strategy execution and result handling
;;
;; Board Representation: (E E E E E E E E E) where E=empty, X/O=players
;; Positions are indexed 0-8 in row-major order:
;;   0 | 1 | 2
;;   ---------
;;   3 | 4 | 5  
;;   ---------
;;   6 | 7 | 8

;; Entry point: Start a new game between two strategies
;; Parameters:
;;   $strategy-x: Strategy function for player X
;;   $strategy-o: Strategy function for player O
;; Returns: Game result (X, O, or Draw)
(= (play-game $strategy-x $strategy-o)
   (let $_ (println! "========== NEW GAME ==========")
   (play-game-loop $strategy-x $strategy-o (E E E E E E E E E) X)))

;; Main game loop: Handles turn-based gameplay until game ends
;; Parameters:
;;   $strategy-x: Strategy function for player X
;;   $strategy-o: Strategy function for player O  
;;   $board: Current board state
;;   $current-player: Current player (X or O)
;; Returns: Final game result (X, O, or Draw)
(= (play-game-loop $strategy-x $strategy-o $board $current-player)
   (let $_ (println! ("Turn:" $current-player "Board:" $board))
   (if (is-game-over $board)
       (let $result (get-game-result $board)
          (let $_ (println! ("GAME OVER - Result:" $result))
          $result))
       (let* (($strategy (if (== $current-player X) $strategy-x $strategy-o))
              ($new-board (if (== (get-metatype $strategy) Grounded)
                              (eval ($strategy $board $current-player))
                              (eval (moses-player $strategy $board $current-player))))
              ($_ (println! ($current-player "->" $new-board)))
             )
             (if (== $board $new-board)
                 (get-opponent $current-player)
                 (play-game-loop $strategy-x $strategy-o $new-board (get-opponent $current-player)))))))