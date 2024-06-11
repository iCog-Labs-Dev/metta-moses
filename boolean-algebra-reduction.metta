; put you code here
(= (reduce $exp)
    (if (== (get-metatype $exp) Expression)
        (case $exp
            (
                ( (OR $a True) True)            ; (a OR True)  -->  True
                ( (AND $a False) False)         ; (a AND False)  -->  False
                ( (OR $a False) $a)             ; (a OR False)  -->  a
                ( (AND $a True) $a)             ; (a AND True)  -->  a
                ( (OR $a $a) $a)                ; (a OR a)  -->  a
                ( (AND $a $a) $a)               ; (a AND a)  -->  a
                ( (OR $a (NOT $a)) True)        ; (a OR -a)  -->  True
                ( (AND $a (NOT $a)) False)      ; (a AND -a)  -->  False
                ( (OR $a (AND $a $b)) $a)       ; a OR (a AND b)  -->  a
                ( (AND $a (OR $a $b)) $a)       ; a AND (a OR b)  -->  a
                ( (NOT (NOT $a)) $a)            ; (-(-a))  -->  a
                ( (NOT (AND $a $b)) (OR (NOT $a) (NOT $b)) )    ; -(a AND b)  -->  (-a OR -b)
                ( (NOT (OR $a $b)) (AND (NOT $a) (NOT $b)) )    ; -(a OR b)  -->  (-a AND -b)
                ( $exp $exp )
        
            )
        )
        ($exp)
    )
   
)

;!(reduce $x)
;!(reduce (OR a True))

(= (reduce-expression $term)
    (let $cond (== (get-metatype $term) Expression)
        (if $cond
            (case $term
                (
                    ; If the expression has three elements (AND / OR)
                    ( ($op $exp1 $exp2) (
                        (let* (
                            ($exp1R (reduce $exp1))
                            ($exp2R (reduce $exp2))
                            ($e<>eR (OR (NOT (== $exp1 $exp1R)) (NOT (== $exp2 $exp2R))))
                            )
                            (if $e<>eR
                                (reduce ($op (reduce-expression $exp1) (reduce-expression $exp2)))
                                (reduce ($op $exp1 $exp2))
                            )
                        )
                      )
                    )
                    ; If the expression has two elements (NOT)
                    ;; ( ($op $exp1) (
                    ;;     (let* (
                    ;;         ($exp1R (reduce $exp1))
                    ;;         ($e1<>e1R ((NOT (== $exp1 $exp1R))))
                    ;;         )
                    ;;         (if $e1<>e1R
                    ;;             (reduce ($op (reduce-expression $exp1)))
                    ;;             (reduce ($op $exp1))
                    ;;         )
                    ;;     )
                    ;;   )
                    ;; )
                )
            )
            ($term)
        )
    )
)


!(reduce-expression (OR a (OR b (OR c (OR d True)))))
!(reduce-expression (OR a  True))
!(reduce-expression (OR a (OR b True)))
!(reduce-expression (OR a (AND b (AND c (AND d False)))))