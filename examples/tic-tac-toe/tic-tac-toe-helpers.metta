; !(import! &self ../../utilities/general-helpers)
(= (get-empty-cells $bs $acc $counter)
    (if (== $bs ())
        $acc
        (let ($h $t) (decons-atom $bs)
            (if (== $h E)
                (let $carry (union-atom $acc ($counter))
                    (get-empty-cells $t $carry (+ $counter 1)))
                (get-empty-cells $t $acc (+ $counter 1))))))

(=  (replace-by-index $bs $icon $index)
    (let ($h $t) (decons-atom $bs)
        (if (== $index 0)
            (cons-atom $icon $t)
            (let $rest (replace-by-index $t $icon (- $index 1))
                (cons-atom $h $rest)))))

;; all the winning states encoded as patterns             
(= (winning-states) ((($x $x $x $a $b $c $d $e $f) $x) 
                    (($a $b $c $x $x $x $d $e $f) $x)
                    (($a $b $c $d $e $f $x $x $x) $x) 
                    (($x $a $b $x $c $d $x $e $f) $x)
                    (($a $x $b $c $x $d $e $x $f) $x)
                    (($a $b $x $c $d $x $e $f $x) $x)
                    (($x $a $b $c $x $d $e $f $x) $x)
                    (($a $b $x $c $x $d $x $e $f) $x)
                )) 

(= (get-winner $board) 
    (let $states (winning-states) 
        (let $result (collapse (let $state (superpose $states) (if (= $state ($board $x)) (if (= $x E) (empty) $x) (empty))))
            (if (= $result ())
                E
                (car-atom $result)))))  

;; Returns 10 if player wins, -10 if opponent wins, 0 otherwise
(= (evaluate-board $bs $player $opponent)
   (let $w (get-winner $bs) 
      (if (== $w $player) 10
      (if (== $w $opponent) -10
      0))))

;; Switcher
(= (get-opponent $icon)
   (if (== $icon X) O X))            

;; These are simple positional strategies. Unlike winning or blocking, they don't depend on the opponent's moves, but simply look for advantageous spots on the board.   
;; Since all 3 strategies essentially do the same thing (look for an empty spot from a specific list of preferred indices), we can create a single helper function to handle the checking.

;; Helper: Returns the first index from $indices that is Empty (E) in $board
(= (find-first-empty $board $indices)
   (if (== $indices ())
       False
       (let ($idx $rest) (decons-atom $indices)
            (if (== (index-atom $board $idx) E)
                $idx
                (find-first-empty $board $rest)))))

;; Check if the board is full (no empty cells)
(= (is-board-full $board)
   (foldl-atom $board True $acc $cell
      (if (== $cell E) False $acc)))

;; Check if the game has ended (either someone won or board is full)
(= (is-game-over $board)
    (or ( != (get-winner $board) E) (is-board-full $board)))

;; Get the final result of a completed game
(= (get-game-result $board)
    (let $winner (get-winner $board)  
         (if (== $winner E)
             (if (is-board-full $board) Draw E) $winner)))


; !(get-winner (E E E E E E X X X))             