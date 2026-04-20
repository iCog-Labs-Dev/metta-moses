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
        ()
        (let* (($result (eval (play-game $player-policy $opponent-policy)))
               ($current-score (score-result $result $player-mark)))
            (cons $current-score (evaluate-strategy (- $n 1) $player-mark $player-policy $opponent-policy)))))

;; Sets the first player as X and returns the BScore
(= (score-strategy $n $player-policy $opponent-policy)
(mkBScore (evaluate-strategy $n X $player-policy $opponent-policy)))

;; scoreStrategyTree - Cached version of score-strategy that accepts cache space
;; This is the strategy equivalent of scoreTree for boolean domain
;; Params:
;;   $tree: Strategy tree to score
;;   $nGames: Number of games to play
;;   $opponentPolicy: Opponent strategy function
;;   $scoreSpace: Cache space for storing results
;; Returns: BScore
;; Cache key: ($cleanStrategy $nGames $opponentPolicy $bscore)
(= (scoreStrategyTree $tree $nGames $opponentPolicy $scoreSpace)
    (let* (
            ($cleanStrategy (preOrder $tree))
            ($cached (collapse (match $scoreSpace ($cleanStrategy $nGames $opponentPolicy $bscore) $bscore)))
    )
    (if (== $cached ())
        ;; Cache miss - compute and store
        (let* (
            ($bscore (score-strategy $nGames $cleanStrategy $opponentPolicy))
            ($_ (println! (Bscore: $bscore)))
            ($_ (add-atom $scoreSpace ($cleanStrategy $nGames $opponentPolicy $bscore)))
        )
        $bscore)
        ;; Cache hit - return cached value
        (car-atom $cached))))
