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
        $exp
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
                            ($e1<>e1R (not (== $exp1 $exp1R)))
                            ($e2<>e2R (not (== $exp2 $exp2R)))
                            )
                            (if $e1<>e1R ;(or (not (== $exp1 (reduce $exp1))) (not (== $exp2 (reduce $exp2R))))
                                (reduce-expression ($op (reduce-expression $exp1) $exp2))
                                (if $e2<>e2R
                                    (reduce-expression ($op $exp1 (reduce-expression $exp2)))
                                    (reduce ($op $exp1 $exp2))
                                )
                            )
                        )
                      )
                    )
                    ($else $term)
                )
            )
            $term
        )
    ;; )
)

;; !(reduce-expression True)
;; !(reduce-expression $x)
;; !(reduce-expression a)


;; !(reduce-expression (or a  True))
!(reduce-expression (or a (or b True)))
;; !(reduce-expression (or a (or b (or c (or d True)))))
;; !(reduce-expression (or a (and b (and c (and d False)))))

;; [((((let* (($exp1R#10536 (reduce ((or (b) (True))))) ($exp2R#10537 (reduce NoValidAlternatives)) ($e1<>e1R#10538 (not (== ((or (b) (True))) $exp1R#10536))) ($e2<>e2R#10539 (not (== NoValidAlternatives $exp2R#10537)))) (if $e1<>e1R#10538 (reduce-expression (Error (reduce-expression ((or (b) (True)))) NoValidAlternatives)) (if $e2<>e2R#10539 (reduce-expression (Error ((or (b) (True))) (reduce-expression NoValidAlternatives))) (reduce (Error ((or (b) (True))) NoValidAlternatives))))))))]


