;; ---------------------------------------------------------
;; MINIMAX PLAYER (Optimized Entry Point)
;; ---------------------------------------------------------

(= (ab-minimax-player $bs $player)
   (let* (($opponent (get-opponent $player)) 
          ($empty-indices (get-empty-cells $bs () 0)) 
          ;; OPTIMIZATION: Sort moves (Center > Corners > Edges)
          ($sorted-indices (sort-moves $empty-indices)) 
          ($best-idx (find-best-move-loop $bs $sorted-indices -1000 -1 -1000 1000 $player $opponent)))
     
     (replace-by-index $bs $player $best-idx)))

;; Root Loop with EARLY EXIT
(= (find-best-move-loop $bs $candidates $best-score $best-move $alpha $beta $player $opponent)
   (if (== $candidates ())
       $best-move
       (let* ((($curr-idx $rest-candidates) (decons-atom $candidates))
              ($new-bs (replace-by-index $bs $player $curr-idx))
              ($immediate-score (evaluate-board $new-bs $player $opponent)))
         
         ;; EARLY EXIT: If we found a winning move (10), take it and STOP.
         (if (== $immediate-score 10)
             $curr-idx
             ;; Standard Update
	     (let $score (minimax $new-bs False $alpha $beta $player $opponent)
             (if (> $score $best-score)
                 (let $new-alpha (max $alpha $score)
                      (find-best-move-loop $bs $rest-candidates $score $curr-idx $new-alpha $beta $player $opponent))
                 (find-best-move-loop $bs $rest-candidates $best-score $best-move $alpha $beta $player $opponent)))))))

;; ---------------------------------------------------------
;; CORE MINIMAX (Alpha-Beta)
;; ---------------------------------------------------------

(= (minimax $bs $isMax $alpha $beta $player $opponent)
   (let $score (evaluate-board $bs $player $opponent)
     (if (not (== $score 0))
         $score
         (let $empty-cells (get-empty-cells $bs () 0)
            (if (== $empty-cells ())
                0
                (if $isMax
                    (run-max-loop $bs $empty-cells -1000 $alpha $beta $player $opponent)
                    (run-min-loop $bs $empty-cells 1000 $alpha $beta $player $opponent)))))))

;; Maximizer Loop
(= (run-max-loop $bs $candidates $best-val $alpha $beta $player $opponent)
   (if (== $candidates ())
       $best-val
       (let* ((($idx $rest) (decons-atom $candidates))
              ($new-bs (replace-by-index $bs $player $idx))
              ($val (minimax $new-bs False $alpha $beta $player $opponent))
              ($new-best (max $best-val $val))
              ($new-alpha (max $alpha $new-best)))
         
         (if (<= $beta $new-alpha)
             $new-best ;; Prune
             (run-max-loop $bs $rest $new-best $new-alpha $beta $player $opponent)))))

;; Minimizer Loop
(= (run-min-loop $bs $candidates $best-val $alpha $beta $player $opponent)
   (if (== $candidates ())
       $best-val
       (let* ((($idx $rest) (decons-atom $candidates))
              ($new-bs (replace-by-index $bs $opponent $idx))
              ($val (minimax $new-bs True $alpha $beta $player $opponent))
              ($new-best (min $best-val $val))
              ($new-beta (min $beta $new-best)))
         
         (if (<= $new-beta $alpha)
             $new-best ;; Prune
             (run-min-loop $bs $rest $new-best $alpha $new-beta $player $opponent)))))