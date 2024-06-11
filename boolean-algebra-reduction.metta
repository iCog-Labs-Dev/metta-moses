; put you code here
(= (reduce $exp)
    (if (== (get-metatype $exp) Expression)
        (case $exp
            (
                ( (or $a True) True)            ; (a OR True)  -->  True
                ( (and $a False) False)         ; (a AND False)  -->  False
                ( (or $a False) $a)             ; (a OR False)  -->  a
                ( (and $a True) $a)             ; (a AND True)  -->  a
                ( (or $a $a) $a)                ; (a OR a)  -->  a
                ( (and $a $a) $a)               ; (a AND a)  -->  a
                ( (or $a (not $a)) True)        ; (a OR -a)  -->  True
                ( (and $a (not $a)) False)      ; (a AND -a)  -->  False
                ( (or $a (and $a $b)) $a)       ; a OR (a AND b)  -->  a
                ( (and $a (or $a $b)) $a)       ; a AND (a OR b)  -->  a
                ( (not (not $a)) $a)            ; (-(-a))  -->  a
                ( (not (and $a $b)) (or (not $a) (not $b)) )    ; -(a AND b)  -->  (-a OR -b)
                ( (not (or $a $b)) (and (not $a) (not $b)) )    ; -(a OR b)  -->  (-a AND -b)
                ( $exp $exp )
        
            )
        )
        ($exp)
    )
   
)

;; !(reduce $x)
;; !(reduce a)
;; !(reduce (or a True))

(= (reduce-expression $term)
    ;; (let $cond (== (get-metatype $term) Expression)
        (if (== (get-metatype $term) Expression)
            (case $term
                (
                    ; If the expression has three elements (AND / OR)
                    ( ($op $exp1 $exp2) (
                        (let* (
                            ($exp1R (reduce $exp1))
                            ($exp2R (reduce $exp2))
                            ($e<>eR (or (not (== $exp1 $exp1R)) (not (== $exp2 $exp2R))))
                            )
                            (if $e<>eR ;(or (not (== $exp1 (reduce $exp1))) (not (== $exp2 (reduce $exp2R))))
                                (reduce-expression ($op (reduce-expression $exp1) (reduce-expression $exp2)))
                                (reduce ($op $exp1 $exp2))
                            )
                        )
                      )
                    )

                    ; If the expression has two elements (not)
                    ;; ( ($op $exp1) (
                    ;;     (let* (
                    ;;         ($exp1R (reduce $exp1))
                    ;;         ($e1<>e1R ((not (== $exp1 $exp1R))))
                    ;;         )
                    ;;         (if $e1<>e1R
                    ;;             (reduce ($op (reduce-expression $exp1)))
                    ;;             (reduce ($op $exp1))
                    ;;         )
                    ;;     )
                    ;;   )
                    ;; )

                    ($else $term)
                )
            )
            ($term)
        )
    ;; )
)

;; !(reduce-expression True)
;; !(reduce-expression $x)
;; !(reduce-expression a)


!(reduce-expression (or a  True))
;; !(reduce-expression (or a (or b True)))
;; !(reduce-expression (or a (or b (or c (or d True)))))
;; !(reduce-expression (or a (and b (and c (and d False)))))
