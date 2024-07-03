; Original lisp version: https://web.cecs.pdx.edu/~mperkows/class478-2005/tsewen-midterm.pdf
;; !(import! &self type-defs)
!(import! &self utils)

(= (simplify $EXPR)
    (let* ((() (println! ("Sub-Exp: " $EXPR))))
    (simplify-expr () $EXPR)
    )
)

(= (simplify-expr $EXPR1 $EXPR2)
    (let* ((() (println! ("Compare:" $EXPR1 $EXPR2))))
    (if (and (== (get-metatype $EXPR2) Expression) (not (== $EXPR1 $EXPR2)))
        ;;; Continues simplifying, otherwise.
        (simplify-expr $EXPR2 (simplify-boolean-expr $EXPR2))
        ;;; Terminates if (EXPR1 == EXPR2 || CONSTANT).
        $EXPR2
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
    (let $_EXPR (sort $EXPR) ;$cond (== (get-metatype $EXPR) Expression)
        ;; (if $cond
        (case $_EXPR
            (
                ( (AND False $a) False)                 ; (a and False)  -->  False             (annulment/identity law)
                ( (AND True $a) $a)                     ; (a and True)  -->  a                  (identity law)
                ( (AND $a (NOT $a)) False)              ; (a and -a)  -->  False                (complement law)
                ( (AND $a $a) $a)                       ; (a and a)  -->  a                     (idempotent law)
                ;; ( (AND $a (AND $a $b)) (AND $a $b))     ; (a and (a and b))  -->  (a and b)     (idempotent law)
                ;; ( (AND $a (AND $b $a)) (AND $a $b))
                ;; ( (AND $a (OR $a $b)) $a)               ; a and (a or b)  -->  a                (absorption law)
                ;; ( (AND $a (OR $b $a)) $a)
                ;; ( (AND $a (OR $b $c)) (OR (AND $a $b) (OR $a $c)))

                ( (AND $a $b) (if (or (== (get-metatype $a) Expression) (== (get-metatype $b) Expression))
                                (let $_EXPR_ (flatten-and $_EXPR)
                                    (if (== (get-metatype $_EXPR_) Expression)
                                        (simplify-operand $_EXPR_)
                                        $_EXPR_
                                    )
                                )
                                $_EXPR
                            ))
                ( $else (Error "Invalid AND expression")) ;(simplify-operand $EXPR)
            )
        )
            ;; $_EXPR
        ;; )
    )
)

(= (simplify-or-expr $EXPR)
    (let $_EXPR (sort $EXPR)
        (case $_EXPR
            (
                ( (OR True $a) True)                ; (a OR True)  -->  True
                ( (OR False $a) $a)                 ; (a OR False)  -->  a
                ( (OR $a $a) $a)                    ; (a OR a)  -->  a
                ( (OR $a (NOT $a)) True)            ; (a OR -a)  -->  True
                ;; ( (OR $a (OR $a $b)) (OR $a $b))    ; (a OR (a OR b))  -->  (a OR b)
                ;; ( (OR $a (OR $b $a)) (OR $a $b))
                ;; ( (OR $a (AND $a $b)) $a)           ; a OR (a AND b)  -->  a
                ;; ( (OR $a (AND $b $a)) $a)
                ;; ( (OR $a (AND $b $c)) (AND (OR $a $b) (OR $a $c)))

                ( (OR $a $b) (if (or (== (get-metatype $a) Expression) (== (get-metatype $b) Expression))
                                (let $_EXPR_ (flatten-or $_EXPR)
                                    (if (== (get-metatype $_EXPR_) Expression)
                                        (simplify-operand $_EXPR_)
                                        $_EXPR_
                                    )
                                )
                                $_EXPR
                            ))
                ( $else (Error "Invalid OR expression"))   ;(simplify-operand $EXPR)
            )
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

; (... add more reduction functions) (NAND | NOT | XNOR | IMP | BI-IMP)

; #################################################################################################

(= (simplify-operand $SUB_EXP)
    ;; (let $cond (== (get-metatype $SUB_EXP) Expression)
    ;; (if $cond
    (let*
        ((() (println! ("Expression: " $SUB_EXP))))
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
    )
    ;;     $SUB_EXP
    ;; )
    ;; )
)
