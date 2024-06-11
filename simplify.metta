; Original lisp version: https://web.cecs.pdx.edu/~mperkows/class478-2005/tsewen-midterm.pdf

(= (simplify $EXPR)
    (simplify-expr Nothing $EXPR)
)

(= (simplify-expr $EXPR1 $EXPR2)
    (let $cond  (or (not (== (get-metatype $EXPR2) Expression)) (== $EXPR1 $EXPR2))
        (if $cond
            ;;; Terminates if (EXPR1 == EXPR2 || CONSTANT).
            ($EXPR2)
            ;;; Continues simplifying, otherwise.
            (simplify-expr $EXPR2 (simplify-boolean-expr $EXPR2))
        )
    )
)

(= (simplify-boolean-expr $EXPR)
    (case $EXPR
        (
            ((and $EXPR1 $EXPR2) (simplify-and-expr $EXPR))
            ((or $EXPR1 $EXPR2) (simplify-or-expr $EXPR))
            ((not $EXPR1) (simplify-not-expr $EXPR))
            ($else (Error "Invalid boolean expression"))
        )
    )
)

(= (simplify-and-expr $EXPR)
    (let $cond (== (get-metatype $EXPR) Expression)
        (if $cond
            (case $EXPR
                (
                    ( ($a False) False)         ; (a and False)  -->  False
                    ( ($a True) $a)             ; (a and True)  -->  a
                    ( ($a $a) $a)               ; (a and a)  -->  a
                    ( ($a (not $a)) False)      ; (a and -a)  -->  False
                    ( ($a (or $a $b)) $a)       ; a and (a or b)  -->  a
                    ( $else (simplify-operand $EXPR))
                )
            )
            ($EXPR)
        )
    )
)

(= (simplify-or-expr $EXPR)
 ....
)

(= (simplify-not-expr $EXPR)
 ....
)

(= (simplify-operand $SUB_EXP)
    (let $cond (== (get-metatype $SUB_EXP) Expression)
        (if $cond
            (case $EXPR
                (
                    (($EXP1 $EXP2) 
                        (if (not (== (get-metatype $EXP1) Expression))
                            ($EXP1 (simplify-operand $EXP2))
                            ((simplify-expr Nothing $EXPR1) (simplify-operand $EXP2))
                        )
                    )
                    ;; (($EXP1)
                    ;;     (if (not (== (get-metatype $EXP1) Expression))
                    ;;         ($EXP1)
                    ;;         ((simplify-expr Nothing $EXPR1))
                    ;;     )
                    ;; )
                )
            )
            ($SUB_EXP)
        )
    )
)

!(simplify (and a True))