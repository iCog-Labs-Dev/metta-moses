(: List type)
(: Nil List)
(: Cons (-> $a List List))

(: length (-> List Number))
(= (length Nil) 0)
(= (length (Cons $x $xs))
    (+ 1 (length $xs))
)
;; ! (length (Cons A (Cons B (Cons C Nil))))

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

;; (: map (-> Atom List List))
;; (= (map $func Nil) Nil)
;; (= (map $func (Cons $x $xs))
;;     (Cons ($func $x) (map $func $xs))
;; )
;; ! (map (+ 1) (Cons 1 (Cons 2 (Cons 3 Nil))))

(: member (-> $a List Bool))
(= (member $a Nil) False)
(= (member $a (Cons $x $xs))
    (if (== $a $x)
        True
        (member $a $xs)
    )
)
;; ! (member B (Cons A (Cons B (Cons C Nil))))

(: remove-duplicates (-> List List))
(= (remove-duplicates Nil) Nil)
(= (remove-duplicates (Cons $x $xs))
  (if (member $x $xs)
    (remove-duplicates $xs)
    (Cons $x (remove-duplicates $xs))
  )
)
;; ! (remove-duplicates (Cons A (Cons B (Cons B Nil))))

; Function to compare two Atoms (less than or equal to)
;; (: atom-lte (-> Atom Atom Bool))
(= (atom-lte $a $b)
    (let* (
            ($type-a (get-metatype $a))
            ($type-b (get-metatype $b))
        )
        (
            (if (== $type-a Grounded)
                True
                (if (and (== $type-a Symbol) (== $type-b Expression))
                    True
                    False ;; add other conditions
                )
            )
        )
    )
)

; Function to append two lists
(: append (-> List List List))
(= (append Nil $ys) $ys)
(= (append (Cons $x $xs) $ys) (Cons $x (append $xs $ys)))

; Function to partition the list
(: partition (-> Symbol List ( List List )))
(= (partition $_ Nil) ( Nil Nil ))
(= (partition $pivot (Cons $x $xs))
    (let ($left $right) (partition $pivot $xs)
        (if (<= $x $pivot)
            ((Cons $x $left) $right)
            ($left (Cons $x $right))
        )
    )
)
; QuickSort implementation
(: quickSort (-> List List))
(= (quickSort Nil) Nil)
(= (quickSort (Cons $x $xs))
    (let ($left $right) (partition $x $xs)
        (append (quickSort $left) (Cons $x (quickSort $right)))
    )
)
;; !(quickSort (Cons 2 (Cons 1 (Cons 3 Nil))))

