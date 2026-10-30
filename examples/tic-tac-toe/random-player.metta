;; random player
;; takes a board state and returns another board state
;; chooses the moves randomly
;;      $icon -- player symbol X or O

(= (random-player $bs $icon)
    (let* (($emptyIndices (get-empty-cells $bs () 0))
            ($count (length $emptyIndices))
            ($pick (py-call (random.randint 0 (- $count 1))))
            ($indexToPlay (index-atom $emptyIndices $pick)))

            (replace-by-index $bs $icon $indexToPlay)))
