

(: List (-> $a Type))
(: Nil (List $a))
(: Cons (-> $a (List $a) (List $a)))


;; Define List.foldr
;; Fold a tuple from right to left
; (: List.foldr (-> (-> $a $b $b) $b (List $a) $b))
(= (List.foldr $f $i Nil) $i)
(= (List.foldr $f $i (Cons $h $t)) ($f $h (List.foldr $f $i $t)))
;; ! (List.foldr * 1 (Cons 1 (Cons 2 (Cons 3 (Cons 4 (Cons 5 Nil))))))

;; Define List.sum
(: List.sum (-> (List Number) Number))
(= (List.sum $xs) (List.foldr + 0 $xs))
;; ! (List.sum (Cons 1 (Cons 2 (Cons 3 (Cons 2 (Cons 3 Nil)))))) ;; [11]



(: List.append (-> $a (List $a) (List $a)))
(= (List.append $val Nil) (Cons $val Nil))
(= (List.append $val (Cons $head $tail)) (Cons $head (List.append $val $tail)))
;; ! (List.append 3 (Cons 1 (Cons 2 Nil))) ;; [(Cons 1 (Cons 2 (Cons 3 Nil)))]

(: List.getByIdx (-> (List $a) Number $a))
(= (List.getByIdx $xs $idx)
    (if (== $xs Nil)
        (Error (Index out of range))
        (let (Cons $head $tail) $xs 
        (if (== $idx 0)
            $head
            (List.getByIdx $tail (- $idx 1)))
        )
    )
)
;; ! (List.getByIdx (Cons 1 (Cons 2 (Cons 3 Nil))) 2) ;; [3]

;; Insert an element to a presumably sorted list, remains sorted.
(: List.insert (-> $a (List $a) (List $a)))
(= (List.insert $x Nil) (Cons $x Nil))
(= (List.insert $x (Cons $head $tail))
   (if (< $x $head)
       (Cons $x (Cons $head $tail))
       (Cons $head (List.insert $x $tail))))

;; Sort a List in ascending order
(: List.sort (-> (List $a) (List $a)))
(= (List.sort Nil) Nil)
(= (List.sort (Cons $head $tail)) (List.insert $head (List.sort $tail)))

;; ! (List.sort (Cons 3 (Cons 2 (Cons 3 Nil))) )
