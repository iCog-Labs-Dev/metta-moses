!(register-module! ../metta-moses-reduction)
!(import! &self  metta-moses-reduction:examples:boolean-algebra-rules)
(= (reduce $exp)
    (case $exp
        (
            ;(annulment $exp)
            ( (OR $a True) True)            ; (a OR True)  -->  True
            ( (AND $a False) False)         ; (a AND False)  -->  False
            ;(identity $exp)
            ( (OR $a False) $a)             ; (a OR False)  -->  a
            ( (AND $a True) $a)             ; (a AND True)  -->  a
            ( (OR $a $a) $a)                ; (a OR a)  -->  a
            ( (AND $a $a) $a)               ; (a AND a)  -->  a
            ( (OR $a (NOT $a)) True)        ; (a OR -a)  -->  True
            ( (AND $a (NOT $a)) False)      ; (a AND -a)  -->  False
            ( (NOT (NOT $a)) $a)            ; (-(-a))  -->  a
            ( (OR $a (AND $a $b)) $a)       ; a OR (a AND b)  -->  a
            ( (AND $a (OR $a $b)) $a)       ; a AND (a OR b)  -->  a
            ( (NOT (AND $a $b)) (OR (NOT $a) (NOT $b)) )    ; -(a AND b)  -->  (-a OR -b)
            ( (NOT (OR $a $b)) (AND (NOT $a) (NOT $b)) )    ; -(a OR b)  -->  (-a AND -b)
    

        )
        $exp
    )
   
)

;; !(reduce $x)
;; !(reduce a)
;; !(reduce (or a True))

(= (reduce-expression $exp)
    $exp
)
(= (reduce-expression ($op $exp))
    (reduce ($op (reduce-expression $exp)))
)
(= (reduce-expression ($op $exp1 $exp2)) 
    (reduce ($op (reduce-expression $exp1) (reduce-expression $exp2))
))

