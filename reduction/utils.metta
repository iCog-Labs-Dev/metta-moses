;; !(import! &self type-defs)

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

;; (: member (-> $a List Bool))
;; (= (member $a Nil) False)
;; (= (member $a (Cons $x $xs))
;;     (if (== $a $x)
;;         True
;;         (member $a $xs)
;;     )
;; )
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
;; (: lte (-> Atom Atom Bool))
(= (lte $a $b)
    (let* ( ($type-a (get-metatype $a))
            ($type-b (get-metatype $b)))
        (if (== $type-a $type-b)
            True
            (if (== $type-a Grounded)
                True
                (if (and (== $type-a Symbol) (or (== $type-b Expression) (== $type-b Variable)))
                    True
                    (if (and (== $type-a Expression) (== $type-b Variable))
                        True
                        False ;; add other conditions
                    )
                ))
        )
    )
)

(= (sort ($OP $a $b))
    (if (lte $a $b)
        ($OP $a $b)
        ($OP $b $a)
    )
)

(= (member $op $expr $EXPR)
    (if (== (get-metatype $EXPR) Expression)
        (case $EXPR
            (
                ( ($op $a $b) (or (member $op $expr $a) (member $op $expr $b)) )
                ( $else (== $expr $EXPR) )
            )
        )
        (== $expr $EXPR)
    )
)

(= (reduce-and (AND $a $b))
    (if (member AND $a $b)
        $b
        (if (member OR $a $b)
            $a
            (if (member AND (NOT $a) $b)
                False
                (AND $a $b)
            )
        )
    )
)

(= (reduce-or (OR $a $b))
    (if (member OR $a $b)
        $b
        (if (member AND $a $b)
            $a
            (if (member OR (NOT $a) $b)
                True
                (OR $a $b)
            )
        )
    )
)

;; !(reduce-and (AND B (AND C B)))
;; !(reduce-and (AND B (AND C (AND E B))))
;; !(reduce-and (AND B (AND C (NOT B))))
;; !(reduce-and (AND B (AND C (AND E (NOT B)))))

;; !(member AND A A)
;; !(member AND A (AND A B))

;; !(member AND (NOT A) (AND A B))
;; !(member AND A (AND C B))

;; !(member AND (NOT A) (AND (NOT A) B))
;; !(member AND (NOT A) (NOT A))

;; !(member OR A A)
;; !(member OR A (AND A B))

;; !(member OR (NOT A) (OR A B))
;; !(member OR A (AND C B))

;; !(member OR (NOT A) (AND (NOT A) B))
;; !(member OR (NOT A) (NOT A))