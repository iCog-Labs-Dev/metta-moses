
(= (removeRedundent $symbol $expr) 
    (if (== $expr ()) () 
        (let* (
            ($head (car-atom $expr))
            ($tail (cdr-atom $expr))
            ($newtail (removeRedundent $symbol $tail)) ; Process the tail recursively
        )
            ; If the head matches the symbol, skip it
            (if (== $symbol $head) 
                $newtail 
                ; Check if $head is an expression and handle special case for (NOT ...)
                (let $newhead 
                    (if (and (== (get-metatype $head) Expression) 
                             (not (== (car-atom $head) NOT))) 
                        ; Recursively remove redundancy if not a (NOT ...) expression
                        (removeRedundent $symbol $head) 
                        $head)
                    (cons-atom $newhead $newtail)
                )
            )
        )
    )
)

; Function to remove redundancy of a specific symbol from subexpressions (excluding NOT expressions)
(= (removeRedundency $symbol $expr)
    (if (== $expr ()) ()  ; Base case: empty expression
        (let* (
            ($head (car-atom $expr))  ; Get the head of the current expression
            ($tail (cdr-atom $expr))  ; Get the tail of the current expression
            ($newtail (removeRedundency $symbol $tail))  ; Process the tail recursively
        )
            ; Check if the head is an expression, and process only subexpressions like AND/OR (skip NOT)
            (if (and (== (get-metatype $head) Expression)
                     (not (== (car-atom $head) NOT)))  ; Skip (NOT ...) expressions
                (let $newhead (removeRedundent $symbol $head)  ; Recursively process subexpressions
                    (cons-atom $newhead $newtail)  ; Rebuild the expression with processed head and tail
                )
                ; Now we are at the top level: keep $symbol if it appears here, remove it from subexpressions
                (if (== $head $symbol) 
                    (cons-atom $head $newtail)  ; Keep the symbol at the top level
                    (cons-atom $head $newtail)  ; Rebuild the expression without the symbol in subexpressions
                )
            )
        )
    )
)


; ; Test Case 1: Remove 'b' from subexpressions
; ! (removeRedundency b (AND b (AND b c) (NOT a) (OR a (OR b (NOT a)))))
; ; Expected output: (AND b (AND c) (NOT a) (OR a (OR (NOT a))))

; ; Test Case 2: Remove 'a' from subexpressions
; ! (removeRedundency a (AND a b (NOT a) (OR c (NOT b) (AND b a))))
; ; Expected output: (AND a b (NOT a) (OR c (NOT b) (AND b)))

;; Main function for removing redundancies from subexpressions
(= (removeRedundencyFromSubExpressions $expr)
    (if (== $expr ()) ()  ; Base case: empty expression
        (let* (
            ($head (car-atom $expr))  ; Get the head of the current expression
            ($tail (cdr-atom $expr))  ; Get the tail of the current expression
            ($new-tail (removeRedundencyFromSubExpressions $tail))  ; Process the tail recursively
        )
            ; Check if the head is a symbol (except AND/OR) or an expression starting with NOT
            (if (or (and (== (get-metatype $head) Symbol) (not (or (== $head AND) (== $head OR)))) 
                    (and (== (get-metatype $head) Expression) (== (car-atom $head) NOT)))
                ; If the head is a symbol or starts with NOT, apply removeRedundency
                (let* (
                    ($updatedexpr (removeRedundency $head $new-tail))  ; Remove redundancy for current symbol/NOT
                )
                    (cons-atom $head $updatedexpr)
                )
                ; Otherwise, keep processing the tail without further recursion
                (cons-atom $head $new-tail)
            )
        )
    )
)

; Test Case 1: Removing redundancies from subexpressions
! (removeRedundencyFromSubExpressions (AND b (OR b c) (NOT a) (OR a (OR b (NOT a)))))
; Expected output: (AND b (OR c) (NOT a) (OR a (OR)))

; Test Case 2: Removing redundancies from subexpressions
! (removeRedundencyFromSubExpressions (AND a b (NOT a) (OR c (NOT a) (AND b a))))
; Expected output: (AND a b (NOT a) (OR c (AND)))