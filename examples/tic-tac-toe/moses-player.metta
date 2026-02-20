(= (moses-player $strategy $board $player)
    (let $result (exec-strategy $strategy $board $player)
        (if (== $result False)
            $board ;; return the same board if it cannot make a move
            (replace-by-index $board $player $result))))

(= (exec-strategy $strategy $board $player)
    (if (== (get-metatype $strategy) Expression)
        (let ($op $args) (decons-atom $strategy)
          (if (== $op PRIORITIZED-OR)
              (exec-prioritized-or $args $board $player)
              (exec-leaf $op $board $player)
          ))
        (exec-leaf $strategy $board $player)))

;; ---------------------------------------------------------
;; PRIORITIZED-OR
;; ---------------------------------------------------------
;; Recursively tries each child strategy.
;; Returns the result of the first one that does NOT return False.

(= (exec-prioritized-or $children $board $player)
   (if (== $children ())
       False ;; No children left, strategy failed
       (let* ((($head-strat $rest) (decons-atom $children))
              ($result (exec-strategy $head-strat $board $player)))
             
             (if (not (== $result False))
                 $result ;; Success! Return the new index
                 (exec-prioritized-or $rest $board $player))))) ;; Fail, try next

;; ---------------------------------------------------------
;; ATOMIC MOVES (LEAVES)
;; ---------------------------------------------------------
;; Dispatcher for atomic moves

(= (exec-leaf $strategy $board $player)
   (case $strategy
     (
       (playwin    (play-win $board $player))
       (playblock  (play-block $board $player))
       (playcenter (play-center $board $player))
       (playcorner (play-corner $board $player))
       (playside   (play-side $board $player))
       ($else       9 )
     )))            
