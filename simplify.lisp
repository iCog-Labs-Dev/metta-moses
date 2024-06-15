;/*
; * A Boolean Simplifier by Tzewen Wang.
; * See the paper for detail description and discussion.
; * https://web.cecs.pdx.edu/~mperkows/class478-2005/tsewen-midterm.pdf
;*/
(defun simplify (EXPR)
    (simplify-expr NIL EXPR)
)

(defun simplify-expr (EXPR1 EXPR2)
    (cond 
        ;;; Terminates if (EXPR1 == EXPR2 || CONSTANT).
        ((or (atom EXPR2) (equal EXPR1 EXPR2)) EXPR2)
        ;;; Continues simplifying, otherwise.
        (T (simplify-expr EXPR2 (simplify-boolean-expr EXPR2)))
    )
)

(defun simplify-boolean-expr (EXPR)
    (cond 
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

(defun simplify-and-expr (EXPR)
    ;;; Removes all 1's constants and duplicates (RULE: equivalence and absorbing).
    (let ((SIMPLIFIED_EXPR (remove `T (remove-duplicates EXPR))))
        (cond 
            ;;; Returns with 1's constant.
            ((null SIMPLIFIED_EXPR) `T)
            ;;; Returns with 0's constant (RULE: universal closure).
            ((member `NIL SIMPLIFIED_EXPR) `NIL)
            ;;; Returns with the only operand.
            ((null (second SIMPLIFIED_EXPR)) (first SIMPLIFIED_EXPR))
            ;;; More rules can be implemented here:
            ;;; (...)
            ;;; Simplifies every operand recursively.
            (T (cons `and (simplify-operand SIMPLIFIED_EXPR)))
        )
    )
)

(defun simplify-or-expr (EXPR)
    ;;; Removes all 0's constants and duplicates (RULE: equivalence and absorbing).
    (let ((SIMPLIFIED_EXPR (remove `NIL (remove-duplicates EXPR))))
    (cond ;;; Returns with 0's constant.
    ((null SIMPLIFIED_EXPR) `NIL)
    ;;; Returns with 1's constant (RULE: existential closure).
    ((member `T SIMPLIFIED_EXPR) `T)
    ;;; Returns with the only operand.
    ((null (second SIMPLIFIED_EXPR)) (first SIMPLIFIED_EXPR))
    ;;; More rules can be implemented here:
    ;;; (...)
    ;;; Simplifies every operand recursively.
    (T (cons `or (simplify-operand SIMPLIFIED_EXPR)))))
)

(defun simplify-not-expr (EXPR)
    (cond ;;; Simplifies constants.
    ((equal (first EXPR) `NIL) `T)
    ((equal (first EXPR) `T) `NIL)
    ;;; Simplifies double inveresions (RULE).
    ((and (listp (first EXPR)) (equal (first (first EXPR)) `not)) (first (rest (first
    EXPR))))
    ;;; More rules can be implemented here:
    ;;; (...)
    ;;; Does nothing, otherwise.
    (T (cons `not (simplify-operand EXPR))))
)

(defun simplify-operand (OPERAND_LIST)
    (cond 
        ;;; Terminates with NIL.
        ((null OPERAND_LIST) NIL)
        ;;; Simpifies the rest of operads.
        ((atom (first OPERAND_LIST)) (cons (first OPERAND_LIST) (simplify-operand (rest
        OPERAND_LIST))))
        ;;; Simpifies a sub-expression and the rest of operands.
        (T (cons (simplify-expr NIL (first OPERAND_LIST)) (simplify-operand (rest
        OPERAND_LIST))))
    )
) 
