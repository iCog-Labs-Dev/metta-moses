(: List type)
(: Nil List)
(: Cons (-> $a List List))

; Function to find the length of a list
(: length (-> List Number))
(= (length Nil) 0)
(= (length (Cons $x $xs))
    (+ 1 (length $xs))
)
;; ! (length (Cons A (Cons B (Cons C Nil))))

;Function to find a list element given an index
(: index (-> Number List $a))
(= (index $a Nil) Nil)
;(= (index 0 (Cons $x $xs)) $x)
(= (index $a (Cons $x $xs))
    (if (== $a 0) 
        $x
        (index (- $a 1) $xs)
    )
)
;; ! (index 2 (Cons A (Cons B (Cons C Nil))))

; Function to apply a partial function to every element in a list
(: map (-> Atom List List))
(= (map $func Nil) Nil)
(= (map $func (Cons $x $xs))
    (Cons ($func $x) (map $func $xs))
)
;; (= (add1 $num) (+ $num 1))
;; ! (map add1 (Cons 1 (Cons 2 (Cons 3 Nil))))

; Function to check whether an Atom exists in a list
(: member (-> $a List Bool))
(= (member $a Nil) False)
(= (member $a (Cons $x $xs))
    (if (== $a $x)
        True
        (member $a $xs)
    )
)
;; ! (member B (Cons A (Cons B (Cons C Nil))))

; Function to remove duplicates from a list
(: remove-duplicates (-> List List))
(= (remove-duplicates Nil) Nil)
(= (remove-duplicates (Cons $x $xs))
  (if (member $x $xs)
    (remove-duplicates $xs)
    (Cons $x (remove-duplicates $xs))
  )
)
;; ! (remove-duplicates (Cons A (Cons B (Cons B Nil))))

; Function to append two lists
(: append (-> List List List))
(= (append Nil $ys) $ys)
(= (append (Cons $x $xs) $ys) (Cons $x (append $xs $ys)))

; Function to partition the list
(: partition (-> Atom List ( List List )))
(= (partition $_ Nil) ( Nil Nil ))
(= (partition $pivot (Cons $x $xs))
    (let ($left $right) (partition $pivot $xs)
        (let* ( ($cond  (<= $x $pivot))
        ;; (let* ( ($cond (lte $x $pivot))
                (() (println! ($x "<=" $pivot "=" $cond)))
                (() (println! ($left "---" $right)))
            )
        (if $cond
            ((Cons $x $left) $right)
            ($left (Cons $x $right))
        )
        )
    )
)

;A function that checks if at least one True exists from a Boolean list 
(: any (-> List Bool))
(= (any Nil) False) ;; return False if the list is empty
(= (any (Cons True $xs)) ;; return True if the item is True
    True
)
(= (any (Cons False $xs)) ;;go to the next list item if False
    (any $xs)
)
;;test cases
; ! (any (Cons False Nil)) ;; False
; ! (any (Cons True Nil)) ;; True
; ! (any (Cons True(Cons False (Cons True Nil)))) ;; True


; QuickSort implementation
(: quickSort (-> List List))
(= (quickSort Nil) Nil)
(= (quickSort (Cons $x $xs))
    (let ($left $right) (partition $x $xs)
        (append (quickSort $left) (Cons $x (quickSort $right)))
    )
)

