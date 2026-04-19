;; random player
;; takes a board state and returns another board state
;; chooses the moves randomly
;;      $icon -- player symbol X or O

(= (random-player $bs $icon)
    (let* (($empty-indices (get-empty-cells $bs () 0))
            ($count (length $empty-indices))
            ($pick (py-call (random.randint 0 (- $count 1))))
            ($index-to-play (index-atom $empty-indices $pick)))

            (replace-by-index $bs $icon $index-to-play)))
