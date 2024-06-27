;; !(import! &self type-defs)

; Function to compare two Atoms (less than or equal to)
;; (: lte (-> Atom Atom Bool))
(= (lte $a $b)
    (let* ( ($type-a (get-metatype $a))
            ($type-b (get-metatype $b)))
        ;; (if (== $type-a $type-b)
        ;;     True
            (if (== $type-a Grounded)
                True
                (if (and (== $type-a Symbol) (or (== $type-b Expression) (== $type-b Variable)))
                    True
                    (if (and (== $type-a Expression) (== $type-b Variable))
                        True
                        False ;; add other conditions
                    )
                ))
        ;; )
    )
)

(= (sort ($OP $a $b))
    (if (lte $a $b)
        ($OP $a $b)
        ($OP $b $a)
    )
)

(sort (AND a b))
(sort (AND b a))

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