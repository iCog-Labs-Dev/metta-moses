; Original lisp version: https://web.cecs.pdx.edu/~mperkows/class478-2005/tsewen-midterm.pdf

(= (simplify $EXPR)
    (simplify-expr empty $EXPR)
)

(= (simplify-expr $EXPR1 $EXPR2)
    (let $cond  (or (not (== (get-metatype $EXPR2) Expression)) (== $EXPR1 $EXPR2))
        (if $cond
            ;;; Terminates if (EXPR1 == EXPR2 || CONSTANT).
            $EXPR2
            ;;; Continues simplifying, otherwise.
            (simplify-expr $EXPR2 (simplify-boolean-expr $EXPR2))
        )
    )
)

(= (simplify-boolean-expr $EXPR)
    (let $cond (== (get-metatype $EXPR) Expression)
        (if $cond
            (case $EXPR
                (
                    ((AND $EXPR1 $EXPR2) (simplify-and-expr $EXPR))
                    ((OR $EXPR1 $EXPR2) (simplify-or-expr $EXPR))
                    ((NOT $EXPR1) (simplify-not-expr $EXPR))
                    ($else (Error "Invalid boolean expression"))
                )
            )

            $EXPR
        )
    )
)

(= (simplify-and-expr $EXPR)
    (let $cond (== (get-metatype $EXPR) Expression)
        (if $cond
            (case $EXPR
                (
                    ( (AND $a False) False)         ; (a and False)  -->  False
                    ( (AND $a True) $a)             ; (a and True)  -->  a
                    ( (AND $a $a) $a)               ; (a and a)  -->  a
                    ( (AND $a (NOT $a)) False)      ; (a and -a)  -->  False
                    ( (AND $a (OR $a $b)) $a)       ; a and (a or b)  -->  a
                    ( (AND $a $b) (if (== (get-metatype $b) Expression)
                                    (simplify-operand $EXPR)
                                    $EXPR
                                ))
                    ( $else (Error "Invalid AND expression")) ;(simplify-operand $EXPR)
                )
            )
            $EXPR
        )
    )
)

(= (simplify-or-expr $EXPR)
    (case $EXPR
        (
            ( (OR $a True) True)                ; (a OR True)  -->  True
            ( (OR $a False) $a)                 ; (a OR False)  -->  a
            ( (OR $a $a) $a)                    ; (a OR a)  -->  a
            ( (OR $a (NOT $a)) True)            ; (a OR -a)  -->  True
            ( (OR $a (AND $a $b)) $a)           ; a OR (a AND b)  -->  a
            ( $else (simplify-operand $EXPR))
        )
    )
)

(= (simplify-not-expr $EXPR)
    (case $EXPR
        (
            ( (NOT (NOT $a)) $a)                            ; (-(-a))  -->  a
            ( (NOT (AND $a $b)) (OR (NOT $a) (NOT $b)) )    ; -(a AND b)  -->  (-a OR -b)
            ( (NOT (OR $a $b)) (AND (NOT $a) (NOT $b)) )    ; -(a OR b)  -->  (-a AND -b)
            ( $else (simplify-operand $EXPR))
        )
    )
)

(= (simplify-operand $SUB_EXP)
    (let $cond (== (get-metatype $SUB_EXP) Expression)
        (if $cond
            (case $EXPR
                (
                    (($OP $EXP1 $EXP2) 
                        (if (not (== (get-metatype $EXP1) Expression))
                            ($EXP1 (simplify-operand $EXP2))        ;;;;;;;;;;;;;;;;;;;;;;;;;;
                            ((simplify-expr empty $EXPR1) (simplify-operand $EXP2))
                        )
                    )
                )
            )
            $SUB_EXP
        )
    )
)

!(simplify (AND a True))
!(simplify (AND a b))
!(simplify (NOT (NOT a)))
!(simplify (NOT (AND a b)))

!(simplify (AND a (AND a b)))
!(simplify (OR a (OR b True)))
;; !(simplify (AND a (AND b (AND a (AND a (AND a True))))))

;; !(simplify (OR a (OR b (OR c (OR d True)))))
;; !(simplify (OR a  True))
;; !(simplify (OR a (OR b True)))
;; !(simplify (OR a (AND b (AND c (AND d False)))))