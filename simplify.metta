; Original lisp version: https://web.cecs.pdx.edu/~mperkows/class478-2005/tsewen-midterm.pdf

(= (simplify $EXPR)
    (simplify-expr Nothing $EXPR)
)

(= (simplify-expr $EXPR1 $EXPR2)
    (let $cond  (or (NOT (== (get-metatype $EXPR2) Expression)) (== $EXPR1 $EXPR2))
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
            ((AND $EXPR1 $EXPR2) (simplify-and-expr $EXPR))
            ((OR $EXPR1 $EXPR2) (simplify-or-expr $EXPR))
            ((NOT $EXPR1) (simplify-not-expr $EXPR))
            ($else (Error "Invalid boolean expression"))
        )
    )
)

(= (simplify-and-expr $EXPR)
    (let $cond (== (get-metatype $EXPR) Expression)
        (if $cond
            (case $EXPR
                (
                    ( ($a False) False)         ; (a AND False)  -->  False
                    ( ($a True) $a)             ; (a AND True)  -->  a
                    ( ($a $a) $a)               ; (a AND a)  -->  a
                    ( ($a (NOT $a)) False)      ; (a AND -a)  -->  False
                    ( ($a (OR $a $b)) $a)       ; a AND (a OR b)  -->  a
                    ( $else (simplify-operand $EXPR))
                )
            )
            ($EXPR)
        )
    )
)

(= (simplify-or-expr EXPR)
 ....
)

(= (simplify-not-expr EXPR)
 ....
)

(= (simplify-operand $SUB_EXP)
    (let $cond (== (get-metatype $SUB_EXP) Expression)
        (if $cond
            (case $EXPR
                (
                    (($EXP1 $EXP2) 
                        (if (NOT (== (get-metatype $EXP1) Expression))
                            ($EXP1 (simplify-operand $EXP2))
                            ((simplify-expr Nothing $EXPR1) (simplify-operand $EXP2))
                        )
                    )
                    ;; (($EXP1)
                    ;;     (if (NOT (== (get-metatype $EXP1) Expression))
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

!(simplify (AND a True))