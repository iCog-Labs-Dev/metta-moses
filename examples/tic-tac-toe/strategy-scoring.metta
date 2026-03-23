;; ==========================================
;; Strategy Scoring
;; ==========================================
;; Evaluates the score of a Strategy by testing it against an Opponent Strategy.

;; Converts a game outcome into a score for the player being tested
;; Win = 1.0, Draw = 0.0, Loss = -1.0
(= (score-result $result $player)
    (case $result
        (($player 1.0)
         (Draw 0.0)
         ((get-opponent $player) -1.0)
         ($_ (Error "Invalid game result")))))

;; Plays $n games and tracks the performance of a strategy over $n trials
(= (evaluate-strategy $n $player-mark $player-policy $opponent-policy)
    (if (<= $n 0)
        Nil
        (let* (($result (eval (play-game $player-policy $opponent-policy)))
               ($current-score (score-result $result $player-mark)))
            (Cons $current-score (evaluate-strategy (- $n 1) $player-mark $player-policy $opponent-policy)))))

;; Sets the first player as X and returns the BScore
(= (score-strategy $n $player-policy $opponent-policy)
(mkBScore (evaluate-strategy $n X $player-policy $opponent-policy)))