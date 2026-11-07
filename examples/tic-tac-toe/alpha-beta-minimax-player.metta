;; ---------------------------------------------------------
;; MINIMAX PLAYER (Optimized Entry Point)
;; ---------------------------------------------------------

(= (ab-minimax-player $bs $player)
   (let* (($opponent (get-opponent $player)) 
          ($emptyIndices (get-empty-cells $bs () 0)) 
          ;; OPTIMIZATION: Sort moves (Center > Corners > Edges)
          ($sortedIndices (sort-moves $emptyIndices)) 
          ($bestIdx (find-best-move-loop $bs $sortedIndices -1000 -1 -1000 1000 $player $opponent)))
     
     (replace-by-index $bs $player $bestIdx)))

;; Root Loop with EARLY EXIT
(= (find-best-move-loop $bs $candidates $bestScore $bestMove $alpha $beta $player $opponent)
   (if (== $candidates ())
       $bestMove
       (let* ((($currIdx $restCandidates) (decons-atom $candidates))
              ($newBs (replace-by-index $bs $player $currIdx))
              ($immediateScore (evaluate-board $newBs $player $opponent)))
         
         ;; EARLY EXIT: If we found a winning move (10), take it and STOP.
         (if (== $immediateScore 10)
             $currIdx
             ;; Standard Update
	     (let $score (minimax $newBs False $alpha $beta $player $opponent)
             (if (> $score $bestScore)
                 (let $newAlpha (max $alpha $score)
                      (find-best-move-loop $bs $restCandidates $score $currIdx $newAlpha $beta $player $opponent))
                 (find-best-move-loop $bs $restCandidates $bestScore $bestMove $alpha $beta $player $opponent)))))))

;; ---------------------------------------------------------
;; CORE MINIMAX (Alpha-Beta)
;; ---------------------------------------------------------

(= (minimax $bs $isMax $alpha $beta $player $opponent)
   (let $score (evaluate-board $bs $player $opponent)
     (if (!= $score 0)
         $score
         (let $emptyCells (get-empty-cells $bs () 0)
            (if (== $emptyCells ())
                0
                (if $isMax
                    (run-max-loop $bs $emptyCells -1000 $alpha $beta $player $opponent)
                    (run-min-loop $bs $emptyCells 1000 $alpha $beta $player $opponent)))))))

;; Maximizer Loop
(= (run-max-loop $bs $candidates $bestVal $alpha $beta $player $opponent)
   (if (== $candidates ())
       $bestVal
       (let* ((($idx $rest) (decons-atom $candidates))
              ($newBs (replace-by-index $bs $player $idx))
              ($val (minimax $newBs False $alpha $beta $player $opponent))
              ($newBest (max $bestVal $val))
              ($newAlpha (max $alpha $newBest)))
         
         (if (<= $beta $newAlpha)
             $newBest ;; Prune
             (run-max-loop $bs $rest $newBest $newAlpha $beta $player $opponent)))))

;; Minimizer Loop
(= (run-min-loop $bs $candidates $bestVal $alpha $beta $player $opponent)
   (if (== $candidates ())
       $bestVal
       (let* ((($idx $rest) (decons-atom $candidates))
              ($newBs (replace-by-index $bs $opponent $idx))
              ($val (minimax $newBs True $alpha $beta $player $opponent))
              ($newBest (min $bestVal $val))
              ($newBeta (min $beta $newBest)))
         
         (if (<= $newBeta $alpha)
             $newBest ;; Prune
             (run-min-loop $bs $rest $newBest $alpha $newBeta $player $opponent)))))