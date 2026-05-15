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

;; Plays $n games against a specific opponent and tracks the results.
(= (evaluate-strategy $n $player-mark $player-policy $opponent-policy)
    (if (<= $n 0)
        ()
        (let* (($result (eval (play-game $player-policy $opponent-policy)))
               ($current-score (score-result $result $player-mark)))
            (cons $current-score (evaluate-strategy (- $n 1) $player-mark $player-policy $opponent-policy)))))

;; Default mixed-opponent evaluation: splits games between random and minimax.
(= (evaluate-strategy $n $player-mark $player-policy)
    (let* ((($random-games $minimax-games) (split-opponent-games $n))
           ($random-results (evaluate-strategy $random-games $player-mark $player-policy random-player))
           ($minimax-results (evaluate-strategy $minimax-games $player-mark $player-policy minimax-player)))
        (List.concat $random-results $minimax-results)))

;; Splits a game budget between random and minimax.
;; Pairs are distributed evenly; the odd leftover game goes to minimax.
(= (split-opponent-games $n)
    (let* (
        ($random-games (py-call (math.floor (/ $n 2))))
        ($minimax-games (- $n $random-games))
    )
    ($random-games $minimax-games)))

;; Backward-compatible single-opponent scoring.
(= (score-strategy $n $player-policy $opponent-policy)
    (mkBScore (evaluate-strategy $n X $player-policy $opponent-policy)))
    
;; Default mixed-opponent scoring.
(= (score-strategy $n $player-policy)
    (mkBScore (evaluate-strategy $n X $player-policy)))

;; Cached mixed-opponent scoring: splits games between random and minimax internally.
(= (scoreStrategyTree $tree $nGames $scoreSpace)
    (let* (($cleanStrategy (preOrder $tree))
           ($cached (collapse (match $scoreSpace ($cleanStrategy $nGames $bscore) $bscore))))
    (if (== $cached ())
        ;; Cache miss - compute and store
        (let* (($bscore (score-strategy $nGames $cleanStrategy))
               ($_ (add-atom $scoreSpace ($cleanStrategy $nGames $bscore))))
            $bscore)
        ;; Cache hit - return cached value
        (car-atom $cached))))