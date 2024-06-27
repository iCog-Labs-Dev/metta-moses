; Original lisp version: https://web.cecs.pdx.edu/~mperkows/class478-2005/tsewen-midterm.pdf
;; !(import! &self type-defs)
!(import! &self ../utilities/utils.metta)

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
    ;; (let $cond (== (get-metatype $EXPR) Expression)
        (if (== (get-metatype $EXPR) Expression); $cond
            (case $EXPR
                (
                    ((AND $EXPR1 $EXPR2) (simplify-and-expr $EXPR))
                    ((OR $EXPR1 $EXPR2) (simplify-or-expr $EXPR))
                    ((NOT $EXPR1) (simplify-not-expr $EXPR))
                    ((XOR $EXPR1 $EXPR2) (simplify-xor-expr $EXPR))
                    ; (... add more operations)
                    ($else (Error "Invalid boolean expression"))
                )
            )

            $EXPR
        )
    ;; )
)

; #################################################################################################

(= (simplify-and-expr $EXPR)
    (let $cond (== (get-metatype $EXPR) Expression)
        (if $cond
            (case (sort $EXPR)
                (
                    ;; ( (AND $a False) False)                 ; (a and False)  -->  False
                    ( (AND False $a) False)
                    ;; ( (AND $a True) $a)                     ; (a and True)  -->  a
                    ( (AND True $a) $a)
                    ( (AND $a $a) $a)                       ; (a and a)  -->  a
                    ( (AND $a (NOT $a)) False)              ; (a and -a)  -->  False
                    ;; ( (AND (NOT $a) $a) False)
                    ( (AND $a (AND $a $b)) (AND $a $b))     ; (a and (a and b))  -->  (a and b)
                    ( (AND $a (AND $b $a)) (AND $a $b))
                    ;; ( (AND (AND $a $b) $a) (AND $b $a))
                    ;; ( (AND (AND $b $a) $a) (AND $b $a))
                    ( (AND $a (OR $a $b)) $a)               ; a and (a or b)  -->  a
                    ( (AND $a (OR $b $a)) $a)
                    ;; ( (AND (OR $a $b) $a) $a)
                    ;; ( (AND (OR $b $a) $a) $a)
                    ( (AND $a $b) (if (or (== (get-metatype $a) Expression) (== (get-metatype $b) Expression))
                                    (let $_EXPR (reduce-and $EXPR)
                                        (if (== (get-metatype $_EXPR) Expression)
                                            (simplify-operand $_EXPR)
                                            $_EXPR
                                        )
                                    )
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
    (case (sort $EXPR)
        (
            ;; ( (OR $a True) True)                ; (a OR True)  -->  True
            ( (OR True $a) True)
            ;; ( (OR $a False) $a)                 ; (a OR False)  -->  a
            ( (OR False $a) $a)
            ( (OR $a $a) $a)                    ; (a OR a)  -->  a
            ( (OR $a (NOT $a)) True)            ; (a OR -a)  -->  True
            ;; ( (OR (NOT $a) $a) True)
            ( (OR $a (OR $a $b)) (OR $a $b))    ; (a OR (a OR b))  -->  (a OR b)
            ( (OR $a (OR $b $a)) (OR $a $b))
            ;; ( (OR (OR $a $b) $a) (OR $a $b))
            ;; ( (OR (OR $b $a) $a) (OR $a $b))
            ( (OR $a (AND $a $b)) $a)           ; a OR (a AND b)  -->  a
            ( (OR $a (AND $b $a)) $a)
            ;; ( (OR (AND $a $b) $a) $a)
            ;; ( (OR (AND $b $a) $a) $a)
            ( (OR $a $b) (if (or (== (get-metatype $a) Expression) (== (get-metatype $b) Expression))
                            (let $_EXPR (reduce-or $EXPR)
                                (if (== (get-metatype $_EXPR) Expression)
                                    (simplify-operand $_EXPR)
                                    $_EXPR
                                )
                            )
                            $EXPR
                        ))
            ( $else (Error "Invalid OR expression"))   ;(simplify-operand $EXPR)
        )
    )
)

(= (simplify-not-expr $EXPR)
    (case $EXPR
        (
            ( (NOT True) False)                             ; (-(-a))  -->  a
            ( (NOT False) True)                             ; (-(-a))  -->  a
            ( (NOT (NOT $a)) $a)                            ; (-(-a))  -->  a
            ( (NOT (AND $a $b)) (OR (NOT $a) (NOT $b)) )    ; -(a AND b)  -->  (-a OR -b)
            ( (NOT (OR $a $b)) (AND (NOT $a) (NOT $b)) )    ; -(a OR b)  -->  (-a AND -b)
            ( (NOT $a) (if (== (get-metatype $a) Expression)
                            (simplify-operand $EXPR)
                            $EXPR
                        ))
            ( $else (Error "Invalid NOT expression"))    ;(simplify-operand $EXPR)
        )
    )
)

(= (simplify-xor-expr $EXPR)
    (case $EXPR
        (
            ( (XOR $a $a) False)             ; (a XOR a)  -->  False
            ;; ( (XOR $a $b) True)            ; (a XOR b)  -->  True
            ( (XOR $a $b) 
                (if (or (and (== (get-metatype $a) Symbol) (== (get-metatype $b) Symbol))
                        (and (== (get-metatype $a) Grounded) (== (get-metatype $b) Grounded)))
                    True
                    (simplify-operand $EXPR)
            ))
            ( $else (Error "Invalid XOR expression"))   ;(simplify-operand $EXPR)
        )
    )
)

; (... add more reduction functions)

; #################################################################################################

(= (simplify-operand $SUB_EXP)
    ;; (let $cond (== (get-metatype $SUB_EXP) Expression)
    ;; (if $cond
        (case $SUB_EXP
            (
                (
                    ($OP $EXP1 $EXP2) 
                    (if (== (get-metatype $EXP1) Expression)
                        ($OP (simplify $EXP1) (simplify $EXP2))
                        ($OP $EXP1 (simplify $EXP2))
                    )
                )
                (
                    ($OP $EXP1) 
                    (if (== (get-metatype $EXP1) Expression)
                        ($OP (simplify $EXP1))
                        $SUB_EXP
                    )
                )
                ( $else (Error "Invalid expression"))
            )
        )
    ;;     $SUB_EXP
    ;; )
    ;; )
)
