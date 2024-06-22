(: List type)
(: Nil List)
(: Cons (-> $a List))

(: length (-> List Number))
(= (length Nil) 0)
(= (length (Cons $x $xs))
    (+1 (length $xs))
)

(: index (-> Number List $a))
(= (index $a Nil) -1)
(= (index 0 (Cons $x $xs)) $x)
(= (index $a (Cons $x $xs))
    (index (-1 $a) $xs)
)

! (length (Cons A (Cons B (Cons C Nil))))
;; ! (index 2 (Cons A (Cons B (Cons C Nil))))


(= (length ()) 0)
(= (length (:: $x $xs))
   (+ 1 (length $xs))
)
! (length (:: A (:: B (:: C ()))))