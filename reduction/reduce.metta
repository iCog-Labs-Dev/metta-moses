!(import! &self rules)
!(import! &self utils)

; Main function to call for reducing boolean expressions
(= (reduce $EXPR)
    ; Print the unreduced expression (this is called recursively)
    (let* ((() (println! ("Reduce: " $EXPR))))
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
    (let $EXPR (sort $_EXPR)
        (if (== (get-metatype $EXPR) Expression)
                (case $EXPR
                    (
                        ((AND $EXPR1 $EXPR2) (reduce-and-expression $EXPR))
                        ((OR $EXPR1 $EXPR2) (reduce-or-expression $EXPR))
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
(= (reduce-and-expression $EXPR)
    (case $EXPR
        (
            ; Apply some AND reduction rules by pattern matching
            ( (AND False $a) False)                 ; (a and False)  -->  False             (annulment/identity law)
            ( (AND True $a) $a)                     ; (a and True)  -->  a                  (identity law)
            ( (AND $a (NOT $a)) False)              ; (a and -a)  -->  False                (complement law)
            ( (AND $a $a) $a)                       ; (a and a)  -->  a                     (idempotent law)

            ; For all other cases of AND expressions
            ( (AND $a $b)
                ; If either a or b is an expression
                (if (or (== (get-metatype $a) Expression) (== (get-metatype $b) Expression))
                    ;; (let* 
                    ;;     (
                    ;;         ($EXPR_1 (idempotent $EXPR))
                    ;;         ($EXPR_2 (identity $EXPR_1))
                    ;;         ($_EXPR (flatten $EXPR_2))
                    ;;     )
                    (let $_EXPR (apply-reduction-rules $EXPR)
                        (if (== (get-metatype $_EXPR) Expression)
                            (reduce-recursive $_EXPR)
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
(= (reduce-or-expression $EXPR)
    (case $EXPR
        (
            ; Apply some OR reduction rules by pattern matching
            ( (OR True $a) True)                ; (a OR True)  -->  True
            ( (OR False $a) $a)                 ; (a OR False)  -->  a
            ( (OR $a $a) $a)                    ; (a OR a)  -->  a
            ( (OR $a (NOT $a)) True)            ; (a OR -a)  -->  True

            ; For all other cases of OR expressions
            ( (OR $a $b)
                ; If either a or b is an expression
                (if (or (== (get-metatype $a) Expression) (== (get-metatype $b) Expression))
                    (let $_EXPR (apply-reduction-rules $EXPR)
                        (if (== (get-metatype $_EXPR) Expression)
                            (reduce-recursive $_EXPR)
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
            ($_EXPR (sort $EXPR))
            (() (println! ("Reduce Recursive: " $_EXPR)))
        )
        (case $_EXPR
            (
                (
                    ($OP $exp1 $exp2) 
                    (if (== (get-metatype $exp1) Expression)
                        (compare-and-reduce $_EXPR ($OP (reduce $exp1) (reduce $exp2)))
                        (if (== (get-metatype $exp2) Expression) ;--
                            (compare-and-reduce $_EXPR ($OP $exp1 (reduce $exp2)))
                            $_EXPR ;--
                        ) ;--
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
