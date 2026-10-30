;; Returns the index of a winning move for $player, or False.
(= (play-win $board $player)
   (let $candidates (get-empty-cells $board () 0) 
        (find-winning-move $board $player $candidates)))

(= (find-winning-move $board $player $indices)
   (if (= $indices ())
         False
         (let $result 
                (collapse 
                    (let* (($index (superpose $indices))
                            ($new-board (replace-by-index $board $player $index))
                            ($winner (get-winner $new-board)))
                                (if (= $winner $player)
                                    $index
                                    (empty))))
                (if (= $result ())
                    False
                    (car-atom $result)))))

;; Reuse play-win. If play-win returns an index for the opponent, that is the index we must block.
(= (play-block $board $player)
   (let $opponent (get-opponent $player)
        (play-win $board $opponent)))                       

;; play-corner                  
(= (play-corner $board $player)
   (find-first-empty $board (0 2 6 8)))

;; play-center   
(= (play-center $board $player)
   (find-first-empty $board (4)))

;; play-side   
(= (play-side $board $player)
   (find-first-empty $board (1 3 5 7)))
              
