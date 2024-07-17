; Function to compare two Atoms based on their metatypes (less than or equal to)
    ; (grounded < symbol < expression < variable)
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

; Fnuction to sort an outer expression based on their metatypes
(= (sort $expr)
    (case $expr
        (
            (($OP $a $b) 
                (if (lte $a $b)
                    ($OP $a $b)
                    ($OP $b $a)
                )
            )
            ($else $expr)
        )
    )
)

(= (depth $exp $init)
    (case $exp
        (
            (($op $a $b)
                (if (or (== (get-metatype $a) Expression) (== (get-metatype $b) Expression))
                    (let* (
                            ($depth-a (depth $a (+ $init 1)))
                            ($depth-b (depth $b (+ $init 1)))
                        )
                        (if (> $depth-a $depth-b)
                            $depth-a
                            $depth-b
                        )
                    )
                    (+ $init 1)
                )
            )
            ($else $init)
        )
    )
)
(= (depth-sort $exp)
    (case $expr
        (
            (($OP $a $b) 
                (if (> (depth $a) (depth $b))
                    ($OP $b $a)
                    ($OP $a $b)
                )
            )
            ($else $expr)
        )
    )
)

; Function to check whether a certain sub-expression is part of another expression
(= (member $op $sub_exp $EXP)
    (if (== (get-metatype $EXP) Expression)
        (case $EXP
            (
                ( ($op $a $b) (or (member $op $sub_exp $a) (member $op $sub_exp $b)) )
                ( $else (== $sub_exp $EXP) )
            )
        )
        (== $sub_exp $EXP)
    )
)

;; !(member AND A A)                       ; True
;; !(member OR A A)                        ; True
;; !(member AND A (AND A B))               ; True

;; !(member AND A (AND C B))               ; False
;; !(member AND (NOT A) (AND A B))         ; False

;; !(member AND (NOT A) (AND (NOT A) B))   ; True
;; !(member AND (NOT A) (NOT A))           ; True
;; !(member OR (NOT A) (NOT A))            ; True

;; !(member OR A (AND A B))                ; False
;; !(member OR (NOT A) (OR A B))           ; False
;; !(member OR A (AND C B))                ; False
;; !(member OR (NOT A) (AND (NOT A) B))    ; False

;; !(member AND A (AND B (AND C (AND (AND A B) C))))           ; True
;; !(member OR (NOT A) (OR B (OR C (OR (OR A B) (NOT A)))))    ; True