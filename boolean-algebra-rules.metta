(= (annulment $exp)
    (case $exp
        (
            ( (OR $a True) True)        ; (a OR True)  -->  True
            ( (AND $a False) False)     ; (a AND False)  -->  False
        )
    )
)
; !(annulment (OR a True))  ; True

(= (identity $exp)
    (case $exp
        (
            ( (OR $a False) $a)     ; (a OR False)  -->  a
            ( (AND $a True) $a)     ; (a AND True)  -->  a
        )
    )
)
; !(identity (OR a False))  ; a

(= (idempotent $exp)
    (case $exp
        (
            ( (OR $a $a) $a)        ; (a OR a)  -->  a
            ( (AND $a $a) $a)       ; (a AND a)  -->  a
        )
    )
)
; !(idempotent (OR a a))  ; a

(= (complement $exp)
    (case $exp
        (
            ( (OR $a (NOT $a)) True)    ; (a OR -a)  -->  True
            ( (AND $a (NOT $a)) False)  ; (a AND -a)  -->  False
        )
    )
)
; !(complement (OR a (NOT a)))  ; True

(= (double-negation (NOT (NOT $a))) $a)     ; (-(-a))  -->  a
; !(double-negation (NOT (NOT a)))   ; a

;###############################################################################

(= (commutative $exp)
    (case $exp
        (
            ( (OR $a $b) (OR $b $a))        ; (a OR b)  -->  (b OR a)
            ( (AND $a $b) (AND $b $a))      ; (a AND b)  -->  (b AND a)
        )
    )
)
; !(commutative (OR a b))  ; (OR b a)

(= (associative $exp)
    (case $exp
        (
            ( (OR (OR $a $b) $c) (OR $a (OR $b $c)))        ; ((a OR b) OR c)  -->  (a OR (b OR c))
            ( (AND (AND $a $b) $c) (AND $a (AND $b $c)))    ; ((a AND b) AND c)  -->  (a AND (b AND c))
        )
    )
)
; !(associative (OR (OR a b) c))    ; (OR a (OR b c))

(= (distrubutive $exp)
    (case $exp
        (
            ( (OR $a (AND $b $c)) (AND (OR $a $b) (OR $a $c)))      ; (a OR (b AND c))  -->  ((a OR b) AND (a OR c))
            ( (AND $a (OR $b $c)) (OR (AND $a $b) (AND $a $c)))     ; (a AND (b OR c))  -->  ((a AND b) OR (a AND c))
        )
    )
)
; !(distrubutive (OR a (AND b c)))  ; (AND (OR a b) (OR a c))

(= (absorptive $exp)
    (case $exp
        (
            ( (OR $a (AND $a $b)) $a)   ; a OR (a AND b)  -->  a
            ( (AND $a (OR $a $b)) $a)   ; a AND (a OR b)  -->  a
        )
    )
)
; !(absorptive (OR a (AND a b)))    ; a

;###############################################################################

(= (demorgans $exp)
    (case $exp
        (
            ( (NOT (AND $a $b)) (OR (NOT $a) (NOT $b)) )    ; -(a AND b)  -->  (-a OR -b)
            ( (NOT (OR $a $b)) (AND (NOT $a) (NOT $b)) )    ; -(a OR b)  -->  (-a AND -b)
        )
    )
)
; !(demorgans (NOT (AND a b)))   ; (OR (NOT a) (NOT b))