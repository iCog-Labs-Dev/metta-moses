(= (reduce $exp)
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
            ( (NOT (NOT $a)) $a)            ; (-(-a))  -->  a
            ;( (OR $a $b) (OR $b $a))        ; (a OR b)  -->  (b OR a)
            ;( (AND $a $b) (AND $b $a))      ; (a AND b)  -->  (b AND a)
            ;( (OR (OR $a $b) $c) (OR $a (OR $b $c)))                ; ((a OR b) OR c)  -->  (a OR (b OR c))
            ;( (AND (AND $a $b) $c) (AND $a (AND $b $c)))            ; ((a AND b) AND c)  -->  (a AND (b AND c))
            ;( (OR $a (AND $b $c)) (AND (OR $a $b) (OR $a $c)))      ; (a OR (b AND c))  -->  ((a OR b) AND (a OR c))
            ;( (AND $a (OR $b $c)) (OR (AND $a $b) (AND $a $c)))     ; (a AND (b OR c))  -->  ((a AND b) OR (a AND c))
            ( (OR $a (AND $a $b)) $a)       ; a OR (a AND b)  -->  a
            ( (AND $a (OR $a $b)) $a)       ; a AND (a OR b)  -->  a
            ( (NOT (AND $a $b)) (OR (NOT $a) (NOT $b)) )    ; -(a AND b)  -->  (-a OR -b)
            ( (NOT (OR $a $b)) (AND (NOT $a) (NOT $b)) )    ; -(a OR b)  -->  (-a AND -b)
            ( $exp $exp )
    
        )
    )
)



(= (reduce-expression $term)
    (if (== (get-metatype $term) Expression)
        (case $term
            (
                ( ($op $exp1 $exp2) (
                    (let* (
                        ($exp1R (reduce $exp1))
                        ($exp2R (reduce $exp2))
                        )
                        (if (OR (NOT (== $exp1 $exp1R)) (NOT (== $exp2 $exp2R)))
                            (reduce-expression ($op $exp1R $exp2R))
                            (reduce ($op $exp1 $exp2))
                        )
                    )
                ) )





                ;; ( ($op $exp1 $exp2) (reduce ( $term) ) )
            )
        )

        ($term)
    )
)


;; (= (reduce-expression ($op $exp))
;;     (reduce ($op) (reduce-expression $exp))
;; )
;; (= (reduce-expression ($op $exp1 $exp2)) 
;;     (reduce ($op (reduce-expression $exp1) (reduce-expression $exp2))
;; ))

!(reduce-expression (OR a (OR b (OR c (OR d True)))))
!(reduce-expression (OR a  True))
!(reduce-expression (OR a (OR b True)))
!(reduce-expression (OR a (AND b (AND c (AND d False)))))