;; Strategy Score Cache
;; Caches BScore results for game strategy instances to avoid redundant game playing
;; Similar to Cscore caching in boolean logic

;; Create global cache space for strategy scores
!(bind! &strategyScoreCache (new-space))

;; getCachedBScore - Cached version of strategy scoring
;; Checks cache first, calculates and caches if miss
;; Params:
;;   $instance: Instance to score
;;   $rep: Representation (for converting instance to strategy)
;;   $nGames: Number of games to play
;;   $opponentPolicy: Opponent strategy function
;;   $scoreSpace: Cache space (typically &strategyScoreCache)
;; Returns: BScore
;; Cache key: ($strategyTree $nGames $opponentPolicy) - same as Cscore pattern
;; (: getCachedBScore (-> Instance Representation Number $opponentPolicy Space BScore))
(= (getCachedBScore $instance $rep $nGames $opponentPolicy $scoreSpace)
    (chain (eval (getCandidate $rep $instance)) $strategyTree
    (if (== (get-metatype $strategyTree) Error)
        (mkBScore (Cons -1.0 Nil))
        (chain (eval (preOrder $strategyTree)) $cleanStrategy
        (let* (
            ($matches (collapse (match $scoreSpace 
                ($cleanStrategy $score) 
                $score)))
        )
        (chain $matches
        $val (if (== $val ()) 
                    (chain (eval (score-strategy $nGames $cleanStrategy $opponentPolicy)) $bscore
                        (let* (
                            ($_ (add-atom $scoreSpace ($cleanStrategy $bscore)))
                        )
                        $bscore))
                    (car-atom $val)
                )))))))