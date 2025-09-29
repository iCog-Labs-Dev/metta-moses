(: Nil (List $t))
(: Cons (-> $t (List $t) (List $t)))




; --------------------- Length -------------------------------------------- 
(: length (-> (List $t) Number))
(= (length Nil) 0)
(= (length (Cons $x $xs)) 
    (+ 1 (length $xs))
)

(get-type (length (Cons 1 Nil)))
(length (Cons 1 (Cons 2 (Cons 3 Nil)))) 
(length (Cons True (Cons False (Cons True (Cons True (Cons False Nil)))))) ; [5]

; -------------------- Is Member ---------------------------------------
(: isMember (-> $t (List $t) Bool))
(= (isMember $x Nil) False)
(= (isMember $x (Cons $y $ys))
    (if (== $x $y) True (isMember $x $ys))
)

; !(isMember 0 (Cons 1 (Cons 2 (Cons 3 Nil))))
; !(isMember "Nasi" (Cons "Abebe" (Cons "Kebede" (Cons 0 Nil)))) 


;--------------------- Append ---------------------------------------
(: append (-> $t (List $t) (List $t)))
(= (append $element Nil) (Cons $element Nil))
(= (append $element (Cons $x $xs))
    (Cons $x (append $element $xs))
)

(append 10 (Cons 1 (Cons 2 (Cons 3 (Cons -5 Nil)))))


;--------------------- Max Value ---------------------------------------
(: max-value (-> (List Number) Number Number ))
(= (max-value Nil $num) $num)
(= (max-value (Cons $x $xs) $num)
   (if (> $x $num) (max-value $xs $x) (max-value $xs $num))
)

(max-value (Cons 1 (Cons 2 (Cons 3 Nil))) True)


;--------------------- Min Value ---------------------------------------
(: min-value (-> (List Number) Number Number ))
(= (min-value Nil $num) $num)
(= (min-value (Cons $x $xs) $num)
   (if (< $x $num) (min-value $xs $x) (min-value $xs $num))
)

(min-value (Cons 1 (Cons 2 (Cons 3 (Cons -43 Nil)))) 100) ; -43
(min-value (Cons True (Cons True (Cons False (Cons True Nil)))) False) ; Bad Type


;--------------------- Push ---------------------------------------
(: push (-> $t (List $t) (List $t)))
(= (push $x Nil) (Cons $x Nil))
(= (push $element (Cons $x $xs))
    (Cons $element (push $x $xs))
)

(push 10 (Cons 1 (Cons 2 (Cons 3 (Cons -5 Nil))))) 


;--------------------- Pop ---------------------------------------
(: pop (-> (List $t) (List $t) (List $t))) ; this will return a list now
(= (pop  Nil $acc) $acc)
(= (pop (Cons $x $xs) $acc) 
    (if (== $xs Nil) $acc (pop $xs (Cons $x $acc)))
)

(pop (Cons 1 (Cons 2 (Cons 3 (Cons -5 Nil)))) Nil) ; 

;--------------------- Reverse ---------------------------------------
(: reverse (-> (List $t) (List $t) (List $t)))
(= (reverse Nil $res) $res)
(= (reverse (Cons $x $xs) $res) 
    (reverse $xs (Cons $x $res))
)

; !(reverse (Cons 1 (Cons 2 (Cons 3 Nil))) Nil)

;--------------------- Remove Element ---------------------------------------
(: remove-element (-> $t (List $t) (List $t) (List $t)))
(= (remove-element $e Nil $res) (reverse $res Nil))
(= (remove-element $e (Cons $x $xs ) $res)
    (if (== $x $e) 
        (remove-element $e $xs $res) 
        (remove-element $e $xs (Cons $x $res)))
)

; !(remove-element 2 (Cons 1 (Cons 2 (Cons 3 (Cons -5 (Cons 2 Nil))))) Nil) 

;--------------------- Remove Duplicate ---------------------------------------
(: remove-duplicate (-> (List $t) (List $t) (List $t)))
(= (remove-duplicate Nil $res) (reverse $res Nil))
(= (remove-duplicate (Cons $x $xs) $res)
    (if (isMember $x $xs) 
        (remove-duplicate $xs $res) 
        (remove-duplicate $xs (Cons $x $res)))
)

; !(remove-duplicate (Cons 1 (Cons 2 (Cons 3 (Cons -5 (Cons 2 (Cons 3 Nil)))))) Nil) 


; --------------------- Map -------------------------------------------- 
(: square (-> Number Number))
(= (square $x) (* $x $x))

(: negate (-> Bool Bool) )
(= (negate $x) (not $x))


(: map (-> (List $t) (-> $t $t) (List $t) (List $t)))
(= (map Nil $f $res) (reverse $res Nil))
(= (map (Cons $x $xs) $f $res)
    (let $r ($f $x) (map $xs $f (Cons $r $res)))
)

!(map (Cons 1 (Cons 2 (Cons 3 (Cons -10 Nil)))) square Nil) 
!(map (Cons True (Cons False (Cons True (Cons False Nil)))) negate Nil)



; --------------------- Filter -------------------------------------------- 
(: gr-than-ten (-> Number Bool))
(= (gr-than-ten $x)
    (if (> $x 10) True False)
)

(: filter (-> (List $t) (-> Number Bool) (List $t) (List $t)) )
(= (filter Nil $f $res) (reverse $res Nil))
(= (filter (Cons $x $xs) $f $res)
    (if ($f $x) 
        (filter $xs $f (Cons $x $res))
        (filter $xs $f $res)
    )
)

(filter (Cons 12 (Cons 20 (Cons 3 (Cons -10 Nil)))) gr-than-ten Nil) 


; --------------------- Fold Left --------------------------------------------
(: add (-> Number Number Number))
(: mul (-> Number Number Number))
(= (add $x $y) (+ $x $y))
(= (mul $x $y) (* $x $y))


(: foldl (-> (List Number) (-> Number Number Number ) Number (List Number)))
(= (foldl Nil $f $res) $res)
(= (foldl (Cons $x $xs) $f $res) 
    (foldl $xs $f ($f $x $res))
)
 
(foldl (Cons 12 (Cons -11 (Cons 5 Nil))) add 0) ; [6]
(foldl (Cons 12 (Cons -11 (Cons 5 Nil))) mul 1) ; [-660]


;--------------------- Insertion Sort ---------------------------------------
(: insert (-> Number (List Number) (List Number)))
(= (insert $x Nil) (Cons $x Nil))
(= (insert $x (Cons $y $ys))
    (
        if (< $x $y)
            (Cons $x (Cons $y $ys))
            (Cons $y (insert $x $ys))
    )
)

(: sort (-> (List Number) (List Number) (List Number)))
(= (sort Nil $sorted) $sorted)
(= (sort (Cons $x $xs) $sorted)
    (insert $x (sort $xs $sorted))
)

(sort (Cons 3 (Cons 6 (Cons 5 (Cons -5 Nil)))) Nil)