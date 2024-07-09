; Function to compare two Atoms (less than or equal to)
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

; Fnuction to sort an outer expression
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

;; (: member (-> Symbol Expression Expression Bool))
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