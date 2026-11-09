;; ---------------------------------------------------------
;; MINIMAX PLAYER
;; ---------------------------------------------------------

;; Main entry point: Takes board and icon (player)
;; Returns the new board with the best move made
(= (minimax-player $bs $player)
   (let* (($opponent (get-opponent $player))
          ;; ($_ (println! (opponent $opponent)))
          ($emptyIndices (get-empty-cells $bs () 0))
          ;; ($_ (println! (emptty indicesss $emptyIndices)))
          ($bestIdx (find-best-move-loop $bs $emptyIndices -1000 -1 $player $opponent)))
     (replace-by-index $bs $player $bestIdx)))

;; Loop through all empty indices to find the one with the highest Minimax score
(= (find-best-move-loop $bs $candidates $bestScore $bestMove $player $opponent)
   (if (== $candidates ())
       $bestMove
       (let* ((($currIdx $restCandidates) (decons-atom $candidates))
              ;; 1. Make the move temporarily
              ($newBs (replace-by-index $bs $player $currIdx))
              ;; 2. Check if this move wins immediately
              ($immediateScore (evaluate-board $newBs $player $opponent)))
         
         ;; 3. If this move wins immediately, return it right away!
         (if (== $immediateScore 10)
             $currIdx
             ;; Otherwise, evaluate via minimax and continue
             (let $score (minimax $newBs False $player $opponent)
               ;; 4. Compare score. If better, update best-move.
               (if (> $score $bestScore)
                   (find-best-move-loop $bs $restCandidates $score $currIdx $player $opponent)
                   (find-best-move-loop $bs $restCandidates $bestScore $bestMove $player $opponent)))))))

;; ---------------------------------------------------------
;; THE CORE MINIMAX FUNCTION
;; ---------------------------------------------------------

(= (minimax $bs $isMax $player $opponent)
   (let $score (evaluate-board $bs $player $opponent)
     ;; BASE CASE: If game over (someone won), return score
     (if (!= $score 0)
         $score
         ;; BASE CASE: If board full (draw), return 0
         (let $emptyCells (get-empty-cells $bs () 0) 
            (if (== $emptyCells ())
                0
                ;; RECURSIVE STEP
                (if $isMax
                    ;; Maximizer's turn (Player)
                    (run-minimax-loop $bs $emptyCells -1000 True $player $opponent)
                    ;; Minimizer's turn (Opponent)
                    (run-minimax-loop $bs $emptyCells 1000 False $player $opponent)))))))      

;; Helper to loop through moves inside the recursive Minimax
(= (run-minimax-loop $bs $candidates $bestVal $isMax $player $opponent)
   (if (== $candidates ())
       $bestVal
       (let* ((($idx $rest) (decons-atom $candidates))
              ($mover (if $isMax $player $opponent))
              ($newBs (replace-by-index $bs $mover $idx))
              ;; Recurse: flip isMax
              ($val (minimax $newBs (not $isMax) $player $opponent)))
         
         (if $isMax
             ;; If Maximizing, pick the higher value
             (let $newBest (max $bestVal $val)
                  (run-minimax-loop $bs $rest $newBest $isMax $player $opponent))
             ;; If Minimizing, pick the lower value
             (let $newBest (min $bestVal $val)
                  (run-minimax-loop $bs $rest $newBest $isMax $player $opponent))))))
