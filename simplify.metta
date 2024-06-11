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
        ;;; Simplifies AND expression.
        ((and (equal (first EXPR) `and) (>= (length EXPR) 3)) (simplify-and-expr (rest
        EXPR)))
        ;;; Simplifies OR expression.
        ((and (equal (first EXPR) `or) (>= (length EXPR) 3)) (simplify-or-expr (rest
        EXPR)))
        ;;; Simplifies NOT expression.
        ((and (equal (first EXPR) `not) (= (length EXPR) 2)) (simplify-not-expr (rest
        EXPR)))
        ;;; More rules can be implemented here:
        ;;; (...)
        ;;; Anything else is considered to be ill-formed.
        (T (error "~S is not a valid boolean expression or has an unknown operator." EXPR))
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

;; (defun simplify-or-expr (EXPR)
;;     ;;; Removes all 0's constants and duplicates (RULE: equivalence and absorbing).
;;     (let ((SIMPLIFIED_EXPR (remove `NIL (remove-duplicates EXPR))))
;;     (cond ;;; Returns with 0's constant.
;;     ((null SIMPLIFIED_EXPR) `NIL)
;;     ;;; Returns with 1's constant (RULE: existential closure).
;;     ((member `T SIMPLIFIED_EXPR) `T)
;;     ;;; Returns with the only operand.
;;     ((null (second SIMPLIFIED_EXPR)) (first SIMPLIFIED_EXPR))
;;     ;;; More rules can be implemented here:
;;     ;;; (...)
;;     ;;; Simplifies every operand recursively.
;;     (T (cons `or (simplify-operand SIMPLIFIED_EXPR)))))
;; )

;; (defun simplify-not-expr (EXPR)
;;     (cond ;;; Simplifies constants.
;;     ((equal (first EXPR) `NIL) `T)
;;     ((equal (first EXPR) `T) `NIL)
;;     ;;; Simplifies double inveresions (RULE).
;;     ((and (listp (first EXPR)) (equal (first (first EXPR)) `not)) (first (rest (first
;;     EXPR))))
;;     ;;; More rules can be implemented here:
;;     ;;; (...)
;;     ;;; Does nothing, otherwise.
;;     (T (cons `not (simplify-operand EXPR))))
;; )

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
;;     (cond 
;;         ;;; Terminates with NIL.
;;         ((null SUB_EXP) NIL)
;;         ;;; Simpifies the rest of operads.
;;         ((atom (first SUB_EXP)) (cons (first SUB_EXP) (simplify-operand (rest
;;         SUB_EXP))))
;;         ;;; Simpifies a sub-expression and the rest of operands.
;;         (T (cons (simplify-expr NIL (first SUB_EXP)) (simplify-operand (rest
;;         SUB_EXP))))
;;     )
;; ) 

!(simplify (AND a True))