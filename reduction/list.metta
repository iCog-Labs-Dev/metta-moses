(: List type)
(: Nil List)
(: Cons (-> $a List List))

; Function to find the length of a list
;; (: length (-> List Number))
;; (= (length Nil) 0)
;; (= (length (Cons $x $xs))
;;     (+ 1 (length $xs))
;; )
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
;; (: map (-> Atom List List))
(= (map $func Nil) Nil)
(= (map $func (Cons $x $xs))
    (Cons ($func $x) (map $func $xs))
)
;; (= (add1 $num) (+ $num 1))
;; ! (map add1 (Cons 1 (Cons 2 (Cons 3 Nil))))

; Function to check whether an Atom exists in a list
;; (: member (-> $a List Bool))
;; (= (member $a Nil) False)
;; (= (member $a (Cons $x $xs))
;;     (if (== $a $x)
;;         True
;;         (member $a $xs)
;;     )
;; )
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
        ;; (if (<= $x $pivot)
        ;; (let* ( ($cond  (<= $x $pivot))
        (let* ( ($cond (lte $x $pivot))
                (() (println! ($x "<=" $pivot "=" $cond)))
                (() (println! ($left "---" $right)))
            )
        (if $cond ;(lte $x $pivot)
            ((Cons $x $left) $right)
            ($left (Cons $x $right))
        )
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
;; !(quickSort (Cons "False" (Cons "A" (Cons "True" (Cons "B" Nil)))))
;; !(quickSort (Cons A (Cons True Nil)))
;; !(quickSort (Cons A (Cons B Nil)))

; -----------------------------------------------------
;; (NOT a b) ~~ (AND b a)                                   || (Cons-and a (Cons-and b Nil)
;; (AND (OR a b) (OR c d)) ~~ (AND (OR d c) (OR b a))       || (Cons-and (Cons-or a (Cons-or b Nil)) (Cons-and (Cons-or c (Cons-or d Nil)) Nil))

(= (flatten $exp)
    (case $exp
        (
            ((AND $a $b) (Cons-and (flatten-and $a) (Cons-and (flatten $b) Nil)))
            ((OR $a $b) (Cons-or (flatten $a) (Cons-or (flatten $b) Nil)))
            ($symbol $symbol)
        )
    )
)

(= (length $exp)
    (case $exp
        (
            (Nil 0)
            (($Cons $x $xs) (+ 1 (length $xs)))
        )
    )
)
;; ! (flatten (AND a b))
;; ! (flatten (AND a (AND b (AND c d))))
;; ! (flatten (AND a (OR b c)))
;; ! (flatten (AND a (OR b (AND c (NOT d)))))
;; ! (flatten (NOT a))
;; ! (flatten (AND (NOT a) (NOT b)))

(= (equal $list1 $list2)
    (if (== (length $list1) (length $list2))
        (case $list1
            (Nil False)
            ((Cons $x $xs)

            )
        )
        False
    )
)


(= (exp-type $exp)
    (case $exp
        (
            ((AND $a $b) AND)
            ((OR $a $b) OR)
            ((NOT $a) NOT)
            ($else Literal)
        )
    )
)

(= (equal-exp $exp1 $exp2)
    (if (and (== (get-metatype $exp1) Expression) (== (get-metatype $exp2) Expression))
        (if (== (exp-type $exp1) (exp-type $exp2))
            (if (== (exp-type $exp1) NOT)
                (== $exp1 $exp2)
                (let*
                    (
                        (($op1 $a1 $b1) $exp1)
                        (($op2 $a2 $b2) $exp2)
                    )
                    (and
                        (or (equal-exp $a1 $a2) (equal-exp $a1 $b2))
                        (or (equal-exp $b1 $a2) (equal-exp $b1 $b2))
                    )
                )
            )
            False
        )
        (if (and (== (get-metatype $exp1) Symbol) (== (get-metatype $exp2) Symbol))
            (== $exp1 $exp2)
            False
        )
    )
)
;; (: Blah type)
;; (: a Blah)
;; !(== a a)
;; !((get-metatype a))
;; !((get-type a))
;; !(== (get-metatype a) Symbol)
;; !(== (get-type a) Blah)
;; !(== (get-metatype a) (get-metatype a)) ; ???
;; !(== (get-type a) (get-type a)) ; ???

;; !(equal-exp a a)
!(equal-exp (AND a b) (AND a b))
!(equal-exp (AND a b) (AND b a))
; The problem is that it doesn't reduce (OR (AND c a) (OR (AND a (AND c d)))) to (AND c a)
;; !(equal-exp (AND a b) (AND b c))
;; !(equal-exp (AND (OR a (NOT b)) (OR c d)) (AND (OR d c) (OR (NOT b) a)))

(= (subset $list1 $list2)
    pass
)

(= (member $op $sub_exp $EXP)
    (if (== (get-metatype $EXP) Expression)
        (case $EXP
            (
                ( ($op $a $b) (or (member $op $sub_exp $a) (member $op $sub_exp $b)) )
                ( $else (equal-exp $sub_exp $EXP) )
            )
        )
        (equal-exp $sub_exp $EXP)
    )
)
; (OR (AND a b) (AND a c))
; The problem is that it doesn't reduce (OR (AND c a) (OR (AND a (AND c d)))) to (AND c a)
; The problem is that it doesn't reduce (AND (OP c a) (OR (AND a (AND c d)))) to (AND c a)
;;  (OR (AND a (AND c d)) (OR (AND a (AND c e)) (AND c a)))
;; !(member OR (AND c a) (OR (AND a (AND c d))))