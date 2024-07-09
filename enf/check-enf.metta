!(register-module! ../../metta-moses-reduction)
!(import! &self metta-moses-reduction:utilities:helper-functions)
(: List type)
(: Nil List)
(: Cons (-> $a List List))

; 1. Negation appears only in literals.
(: check-negation (-> Expression Bool))
(= (check-negation $exp) 
    (case $exp
        (
            ( (NOT $a) (not (== (get-metatype $a) Expression)) )
            ( ($OP $a $b) (and (check-negation $a) (check-negation $b)) )
            ( $else True )
        )
    )
)



; 2. Levels of conjunction and disjunction alternate.
(: check-alternate (-> Expression Bool))
(= (check-alternate $exp) 
    (case $exp
        (
            ( ($OP $a $b) (and  ; check for both children
                (if (== (get-metatype $a) Expression)
                    (case $a
                        (
                            (($OP $_a $_b) False)   ; if it has the same Operator as its parent
                            ( $else (check-alternate $a))
                        )
                    )
                    True    ; True if it's not an expression
                )

                (if (== (get-metatype $b) Expression)
                    (case $b
                        (
                            (($OP $_a $_b) False)
                            ( $else (check-alternate $b))
                        )
                    )
                    True
                )
            ))

            ( ($OP $a) (check-alternate $a) )

            ( $else True)
        )
    )
)

;; !(check-alternate (AND (OR a b) c))
;; !(check-alternate (AND (OR a b) (NOT c)))
;; !(check-alternate (AND (OR a b) (OR c d)))
;; !(check-alternate (AND (OR a (AND b c)) (OR c (AND d e))))
;; !(check-alternate (AND (OR a b) (NOT (NOT (AND a b)))))

;; !(check-alternate (AND (AND a b) (OR c d)))
;; !(check-alternate (AND (OR a (OR c b)) (OR c d)))
;; !(check-alternate (AND (OR a b) (NOT (NOT (AND a (AND e d))))))


; 3. No conjunction or disjunction has both a literal and its negation, 
    ; or multiple copies of the same literal, as children.
(: check-redundant (-> Expression Bool))
(= (check-redundant $exp)
    (case $exp
        (
            (($OP $a $b) 
                ; If both children are expressions
                (if (and (== (get-metatype $a) Expression) (== (get-metatype $b) Expression))
                    (and (check-redundant $a) (check-redundant $b))
                    
                    ; If either child is an expression
                    (if (or (== (get-metatype $a) Expression) (== (get-metatype $b) Expression))
                        (if (or (== $a (NOT $b)) (== $b (NOT $a)))  ; If one is a negation of the other
                            False
                            (and (check-redundant $a) (check-redundant $b))
                        )
                        (not (== $a $b))    ; If both literals are the same
                    )
                )
            )
            ;; (($OP $a $a) False)
            ;; (($OP $a (NOT $a)) False)

            (($OP $a) (check-redundant $a))
            ( $else True)
        )
    )
)

;; !(check-redundant (AND a b))
;; !(check-redundant (AND (AND a b) b))
;; !(check-redundant (AND (AND a b) (OR a (NOT b))))

;; !(check-redundant (AND a a))
;; !(check-redundant (AND a (NOT a)))
;; !(check-redundant (AND (OR a (AND b (NOT b))) (NOT a)))

(: get-guard-set (-> Expression List List))
(= (get-guard-set $exp $guard-set)
    (case $exp
        (
            (($OP $a $b) 
                ; If both children are literals
                (if (not (or (== (get-metatype $a) Expression) (== (get-metatype $b) Expression)))
                    (append $guard-set (Cons $a (Cons $b Nil)))
                    ; If both are expressions
                    (if (and (== (get-metatype $a) Expression) (== (get-metatype $b) Expression))
                        (append (get-guard-set $a $guard-set) (get-guard-set $b $guard-set))
                        ; If only $a is a literal
                        (if (== (get-metatype $b) Expression)
                            (get-guard-set $b (append $guard-set (Cons $a Nil)))
                            ; If only $b is a literal
                            (if (== (get-metatype $a) Expression)
                                (get-guard-set $a (append $guard-set (Cons $b Nil)))
                            )
                        )
                    )
                )
            )
            (($OP $a)
                (if (== (get-metatype $a) Expression)
                    (get-guard-set $a $guard-set)
                    (append $guard-set $a)
                )
            )
            ($a (append $guard-set $a))
        )
    )
)


;; !(get-guard-set (OR
;;     (AND 
;;         (OR 
;;             x3
;;             x4
;;         )
;;         x2
;;     )
;;     x7
;; ) Nil)
!(get-guard-set (OR
    (AND 
        (OR 
            (NOT x3)
            (NOT x4)
        )
        (OR
            x3
            (AND x3 x6)
        )
    )
    x7
) Nil)

;; !(append Nil (Cons 1 Nil))
;; !(append (Cons 1 Nil) Nil)
;; !(append (Cons 1 (Cons 2 Nil)) (Cons 3 Nil))

;; !(get-guard-set (AND (OR x3 x4) (NOT x2)) Nil)
;; !(remove-duplicates (get-guard-set (AND (OR x3 x4) (NOT x2)) Nil))

