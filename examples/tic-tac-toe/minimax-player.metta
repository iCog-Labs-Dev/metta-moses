;; ---------------------------------------------------------
;; MINIMAX PLAYER
;; ---------------------------------------------------------

;; Main entry point: Takes board and icon (player)
;; Returns the new board with the best move made
(= (minimax-player $bs $player)
   (let* (($opponent (get-opponent $player))
        ($_ (println! (opponent $opponent)))
          ($empty-indices (get-empty-cells $bs () 0))
          ($_ (println! (emptty indicesss $empty-indices)))
          ($best-idx (find-best-move-loop $bs $empty-indices -1000 -1 $player $opponent)))
     (replace-by-index $bs $player $best-idx)))

;; Loop through all empty indices to find the one with the highest Minimax score
(= (find-best-move-loop $bs $candidates $best-score $best-move $player $opponent)
   (if (== $candidates ())
       $best-move
       (let* ((($curr-idx $rest-candidates) (decons-atom $candidates))
              ;; 1. Make the move temporarily
              ($new-bs (replace-by-index $bs $player $curr-idx))
              ;; 2. Check if this move wins immediately
              ($immediate-score (evaluate-board $new-bs $player $opponent)))
         
         ;; 3. If this move wins immediately, return it right away!
         (if (== $immediate-score 10)
             $curr-idx
             ;; Otherwise, evaluate via minimax and continue
             (let* (($score (minimax $new-bs False $player $opponent)))
               ;; 4. Compare score. If better, update best-move.
               (if (> $score $best-score)
                   (find-best-move-loop $bs $rest-candidates $score $curr-idx $player $opponent)
                   (find-best-move-loop $bs $rest-candidates $best-score $best-move $player $opponent)))))))

;; ---------------------------------------------------------
;; THE CORE MINIMAX FUNCTION
;; ---------------------------------------------------------

(= (minimax $bs $isMax $player $opponent)
   (let $score (evaluate-board $bs $player $opponent)
     ;; BASE CASE: If game over (someone won), return score
     (if (not (== $score 0))
         $score
         ;; BASE CASE: If board full (draw), return 0
         (let $empty-cells (get-empty-cells $bs () 0) 
            (if (== $empty-cells ())
                0
                ;; RECURSIVE STEP
                (if $isMax
                    ;; Maximizer's turn (Player)
                    (run-minimax-loop $bs $empty-cells -1000 True $player $opponent)
                    ;; Minimizer's turn (Opponent)
                    (run-minimax-loop $bs $empty-cells 1000 False $player $opponent)))))))      

;; Helper to loop through moves inside the recursive Minimax
(= (run-minimax-loop $bs $candidates $best-val $isMax $player $opponent)
   (if (== $candidates ())
       $best-val
       (let* ((($idx $rest) (decons-atom $candidates))
              ($mover (if $isMax $player $opponent))
              ($new-bs (replace-by-index $bs $mover $idx))
              ;; Recurse: flip isMax
              ($val (minimax $new-bs (not $isMax) $player $opponent)))
         
         (if $isMax
             ;; If Maximizing, pick the higher value
             (let $new-best (max $best-val $val)
                  (run-minimax-loop $bs $rest $new-best $isMax $player $opponent))
             ;; If Minimizing, pick the lower value
             (let $new-best (min $best-val $val)
                  (run-minimax-loop $bs $rest $new-best $isMax $player $opponent))))))
