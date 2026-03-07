;; Strategy Score Cache
!(bind! &strategyScoreCache (new-space))

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
        ($cleanStrategy (eval (preOrder $tree)))
        ($cached (collapse (match $scoreSpace ($cleanStrategy $nGames $opponentPolicy $bscore) $bscore)))
    )
    (if (== $cached ())
        ;; Cache miss - compute and store
        (let* (
            ($bscore (eval (score-strategy $nGames $cleanStrategy $opponentPolicy)))
            ($_ (add-atom $scoreSpace ($cleanStrategy $nGames $opponentPolicy $bscore)))
        )
        $bscore)
        ;; Cache hit - return cached value
        (car-atom $cached))))