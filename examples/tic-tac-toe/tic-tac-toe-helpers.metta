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

(= (get-winner $bs)
   ;; 1. Check Rows
   (let $r1 (check-line $bs 0 1 2) 
     (if (not (== $r1 E)) $r1
     (let $r2 (check-line $bs 3 4 5)
       (if (not (== $r2 E)) $r2
       (let $r3 (check-line $bs 6 7 8)
         (if (not (== $r3 E)) $r3

   ;; 2. Check Columns
   (let $c1 (check-line $bs 0 3 6)
     (if (not (== $c1 E)) $c1
     (let $c2 (check-line $bs 1 4 7)
       (if (not (== $c2 E)) $c2
       (let $c3 (check-line $bs 2 5 8)
         (if (not (== $c3 E)) $c3

   ;; 3. Check Diagonals
   (let $d1 (check-line $bs 0 4 8)
     (if (not (== $d1 E)) $d1
     (let $d2 (check-line $bs 2 4 6)
       (if (not (== $d2 E)) $d2
       
   ;; 4. No Winner
       E)))))))))))))))))

;; Helper: Checks if indices A, B, and C are identical and not Empty
(= (check-line $bs $a $b $c)
    (let* (($v1 (index-atom $bs $a))
           ($v2 (index-atom $bs $b))
           ($v3 (index-atom $bs $c)))
        
        ;; Logic: If v1 != E, AND v1 == v2, AND v2 == v3, then return v1. Else return E.
        (if (== $v1 E) 
            E
            (if (== $v1 $v2)
                (if (== $v2 $v3)
                    $v1
                    E)
                E))))

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
