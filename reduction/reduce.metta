!(import! &self rules)
!(import! &self utils)

; Main function to call for reducing boolean expressions
(= (reduce $EXPR)
    ; Print the unreduced expression (this is called recursively)
    (let* ((() (println! ("Reduce:" $EXPR))))
    ; First argument is an empty expression at first
    (compare-and-reduce () $EXPR)
    )
)

; expression2 is reduced and compared to expression1 (which is the unreduced expression)
(= (compare-and-reduce $EXPR1 $EXPR2)
    ; Print both expressions
    (let* ((() (println! ("Compare:" $EXPR1 $EXPR2))))
    ; If expression2 is not a literal and if it's not the same as the unreduced expression
    (if (and (== (get-metatype $EXPR2) Expression) (not (== $EXPR1 $EXPR2)))
        ; Continue reducing expression2
        (compare-and-reduce $EXPR2 (reduce-expression $EXPR2))
        ; Return expression2 because can't be further reduced
        $EXPR2
    )
    )
)

; Call reduction functions for each type of expression correspondingly
(= (reduce-expression $_EXPR)
    ; Sort the outer expression (grounded < symbol < expression)
    (let* (
            ($EXPR' (sort-metatype $_EXPR))
            ($EXPR (sort-depth $EXPR'))
        )
        (if (== (get-metatype $EXPR) Expression)
                (case $EXPR
                    (
                        ((AND $EXPR1 $EXPR2) (reduce-andor-expression $EXPR))
                        ((OR $EXPR1 $EXPR2) (reduce-andor-expression $EXPR))
                        ((NOT $EXPR1) (reduce-not-expression $EXPR))
                        ((XOR $EXPR1 $EXPR2) (reduce-xor-expression $EXPR))
                        ; (... add more operations)
                        ($else (Error "Invalid boolean expression"))
                    )
                )
            ; In case we try to reduce a literal
            $EXPR
        )
    )
)

; #################################################################################################

; Reduction function for AND expressions
(= (reduce-andor-expression $EXPR)
    (case $EXPR
        (
            ; For any AND/OR expression
            ( ($op $a $b)
                    (let* 
                        (
                            ($reduced_1 (complement-law $EXPR))
                            ($reduced_2 (absorption-idempotent-law $reduced_1))
                            ($reduced_3 (idempotent-law $reduced_2))
                            ($reduced_4 (annulment-identity-law $reduced_3))
                            ($reduced (distrubutive-law $reduced_4))
                            ; (... add more reduction rules)
                        )
                        (if (== (get-metatype $reduced) Expression)
                            (reduce-recursive $reduced)
                            $reduced
                        )
                    )
            )
            ( $else (Error "Invalid AND/OR expression"))
        )
    )
)

; Reduction function for NOT expressions
(= (reduce-not-expression $EXPR)
    (case $EXPR
        (
            ; Apply NOT reduction rules by pattern matching
            ( (NOT True) False)                             ; (-(-a))  -->  a
            ( (NOT False) True)                             ; (-(-a))  -->  a
            ( (NOT (NOT $a)) $a)                            ; (-(-a))  -->  a
            ( (NOT (AND $a $b)) (OR (NOT $a) (NOT $b)) )    ; -(a AND b)  -->  (-a OR -b)
            ( (NOT (OR $a $b)) (AND (NOT $a) (NOT $b)) )    ; -(a OR b)  -->  (-a AND -b)
            ( (NOT $a) 
                (if (== (get-metatype $a) Expression)
                    (reduce-recursive $EXPR)
                    $EXPR
                )
            )
            ( $else (Error "Invalid NOT expression"))
        )
    )
)

; Reduction function for XOR expressions
(= (reduce-xor-expression $EXPR)
    (case $EXPR
        (
            ( (XOR $a $a) False)             ; (a XOR a)  -->  False
            ( (XOR $a $b)
                ; Check if the sub-expressions can't be further reduced
                (if (or (and (== (get-metatype $a) Symbol) (== (get-metatype $b) Symbol))
                        (and (== (get-metatype $a) Grounded) (== (get-metatype $b) Grounded)))
                    True
                    ; Further reduce the sub-expressions
                    (reduce-recursive $EXPR)
                )
            )
            ( $else (Error "Invalid XOR expression"))
        )
    )
)

; (... add more reduction functions) (NAND | NOT | XNOR | IMP | BI-IMP)

; #################################################################################################

; Function to recursively apply reuction to sub-expressions
(= (reduce-recursive $EXPR)
    (let*
        (
            ; Sort the expression (grounded < symbol < expression)
            ($_EXPR' (sort-metatype $EXPR))
            ($_EXPR (sort-depth $_EXPR'))
            (() (println! ("Reduce Recursive:" $_EXPR)))
        )
        (case $_EXPR
            (
                (
                    ($OP $exp1 $exp2) 
                    (if (== (get-metatype $exp1) Expression)
                        (compare-and-reduce $_EXPR ($OP (reduce $exp1) (reduce $exp2)))
                        (if (== (get-metatype $exp2) Expression)
                            (compare-and-reduce $_EXPR ($OP $exp1 (reduce $exp2)))
                            $_EXPR
                        )
                    )
                )
                (
                    ($OP $exp1) 
                    (if (== (get-metatype $exp1) Expression)
                        (compare-and-reduce $_EXPR ($OP (reduce $exp1)))
                        $_EXPR
                    )
                )
                ( $else (Error "Invalid expression"))
            )
        )
    )
)
