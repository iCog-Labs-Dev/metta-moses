; Original lisp version: https://web.cecs.pdx.edu/~mperkows/class478-2005/tsewen-midterm.pdf
!(import! &self utils)
!(import! &self helper-functions)

; Main function to call for reducing boolean expressions
(= (simplify $EXPR)
    ; Print the unreduced expression (this is called recursively)
    (let* ((() (println! ("Sub-Exp: " $EXPR))))
    ; First argument is an empty expression at first
    (simplify-expr () $EXPR)
    )
)

; Simplify expression2 is reduced and compared to expression1 (which is the unreduced expression)
(= (simplify-expr $EXPR1 $EXPR2)
    ; Print both expressions
    (let* ((() (println! ("Compare:" $EXPR1 $EXPR2))))
    ; If expression2 is not a literal and if it's not the same as the unreduced expression
    (if (and (== (get-metatype $EXPR2) Expression) (not (== $EXPR1 $EXPR2)))
        ; Continue simplifying expression2
        (simplify-expr $EXPR2 (simplify-boolean-expr $EXPR2))
        ; Return expression2 because can't be further reduced
        $EXPR2
    )
    )
)

; Call reduction functions for each type of expression correspondingly
(= (simplify-boolean-expr $_EXPR)
    ; Sort the outer expression (grounded < symbol < expression)
    (let $EXPR (sort $_EXPR)
        (if (== (get-metatype $EXPR) Expression)
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
            ; In case we try to simplify a literal
            $EXPR
        )
    )
)

; #################################################################################################

; Reduction function for AND expressions
(= (simplify-and-expr $EXPR)
    (case $EXPR
        (
            ( (AND False $a) False)                 ; (a and False)  -->  False             (annulment/identity law)
            ( (AND True $a) $a)                     ; (a and True)  -->  a                  (identity law)
            ( (AND $a (NOT $a)) False)              ; (a and -a)  -->  False                (complement law)
            ( (AND $a $a) $a)                       ; (a and a)  -->  a                     (idempotent law)

            ; For all other cases of AND expressions
            ( (AND $a $b)
                ; If either a or b is an expression
                (if (or (== (get-metatype $a) Expression) (== (get-metatype $b) Expression))
                    (let $_EXPR (flatten $EXPR)
                        (if (== (get-metatype $_EXPR) Expression)
                            (simplify-recursive $_EXPR)
                            $_EXPR
                        )
                    )
                    ; If a and b are literals
                    $EXPR
                )
            )
            ( $else (Error "Invalid AND expression"))
        )
    )
)

; Reduction function for OR expressions
(= (simplify-or-expr $EXPR)
    (case $EXPR
        (
            ( (OR True $a) True)                ; (a OR True)  -->  True
            ( (OR False $a) $a)                 ; (a OR False)  -->  a
            ( (OR $a $a) $a)                    ; (a OR a)  -->  a
            ( (OR $a (NOT $a)) True)            ; (a OR -a)  -->  True

            ; For all other cases of OR expressions
            ( (OR $a $b)
                ; If either a or b is an expression
                (if (or (== (get-metatype $a) Expression) (== (get-metatype $b) Expression))
                    (let $_EXPR (flatten $EXPR)
                        (if (== (get-metatype $_EXPR) Expression)
                            (simplify-recursive $_EXPR)
                            $_EXPR
                        )
                    )
                    ; If a and b are literals
                    $EXPR
                )
            )
            ( $else (Error "Invalid OR expression"))
        )
    )
)

; Reduction function for NOT expressions
(= (simplify-not-expr $EXPR)
    (case $EXPR
        (
            ( (NOT True) False)                             ; (-(-a))  -->  a
            ( (NOT False) True)                             ; (-(-a))  -->  a
            ( (NOT (NOT $a)) $a)                            ; (-(-a))  -->  a
            ( (NOT (AND $a $b)) (OR (NOT $a) (NOT $b)) )    ; -(a AND b)  -->  (-a OR -b)
            ( (NOT (OR $a $b)) (AND (NOT $a) (NOT $b)) )    ; -(a OR b)  -->  (-a AND -b)
            ( (NOT $a) 
                (if (== (get-metatype $a) Expression)
                    (simplify-recursive $EXPR)
                    $EXPR
                )
            )
            ( $else (Error "Invalid NOT expression"))
        )
    )
)

; Reduction function for XOR expressions
(= (simplify-xor-expr $EXPR)
    (case $EXPR
        (
            ( (XOR $a $a) False)             ; (a XOR a)  -->  False
            ( (XOR $a $b) 
                (if (or (and (== (get-metatype $a) Symbol) (== (get-metatype $b) Symbol))
                        (and (== (get-metatype $a) Grounded) (== (get-metatype $b) Grounded)))
                    True
                    (simplify-recursive $EXPR)
                )
            )
            ( $else (Error "Invalid XOR expression"))
        )
    )
)

; (... add more reduction functions) (NAND | NOT | XNOR | IMP | BI-IMP)

; #################################################################################################

; Function to recursively apply reuction to sub-expressions
(= (simplify-recursive $EXPR)
    (let*
        (
            ; Sort the expression (grounded < symbol < expression)
            ($_EXPR (sort $EXPR))
            (() (println! ("Expression: " $_EXPR)))
        )
        (case $_EXPR
            (
                (
                    ($OP $exp1 $exp2) 
                    (if (== (get-metatype $exp1) Expression)
                        (simplify-expr $_EXPR ($OP (simplify $exp1) (simplify $exp2)))
                        (if (== (get-metatype $exp2) Expression) ;--
                            (simplify-expr $_EXPR ($OP $exp1 (simplify $exp2)))
                            $_EXPR ;--
                        ) ;--
                    )
                )
                (
                    ($OP $exp1) 
                    (if (== (get-metatype $exp1) Expression)
                        (simplify-expr $_EXPR ($OP (simplify $exp1)))
                        $_EXPR
                    )
                )
                ( $else (Error "Invalid expression"))
            )
        )
    )
)
