; Function to compare two Atoms based on their metatypes (less than or equal to)
    ; (grounded < symbol < expression < variable)
(= (lte $a $b)
    (let* ( ($type-a (get-metatype $a))
            ($type-b (get-metatype $b)))
        (if (== $type-a $type-b)
            True
            (if (== $type-a Grounded)
                True
                (if (and (== $type-a Symbol) (or (== $type-b Expression) (== $type-b Variable)))
                    True
                    (if (and (== $type-a Expression) (== $type-b Variable))
                        True
                        False ;; add other conditions
                    )
                ))
        )
    )
)

; Fnuction to sort an outer expression based on their metatypes
(= (sort-metatype $expr)
    (case $expr
        (
            (($OP $a $b) 
                (if (lte $a $b)
                    ($OP $a $b)
                    ($OP $b $a)
                )
            )
            ($else $expr)
        )
    )
)

; #################################################################################################

(= (depth $exp $init)
    (case $exp
        (
            (($op $a $b)
                (if (or (== (get-metatype $a) Expression) (== (get-metatype $b) Expression))
                    (let* (
                            ($depth-a (depth $a (+ $init 1)))
                            ($depth-b (depth $b (+ $init 1)))
                        )
                        (if (> $depth-a $depth-b)
                            $depth-a
                            $depth-b
                        )
                    )
                    (+ $init 1)
                )
            )
            ( $else $init )
        )
    )
)

(= (sort-depth $exp)
    (case $exp
        (
            (($OP $a $b) 
                (if (> (depth $a 0) (depth $b 0))
                    ($OP $b $a)
                    ($OP $a $b)
                )
            )
            ( $else $exp )
        )
    )
)

; #################################################################################################

; Function to check whether a certain sub-expression is part of another expression
(= (member $op $sub_exp $EXP)
    (if (== (get-metatype $EXP) Expression)
        (case $EXP
            (
                ( ($op $a $b) (or (member $op $sub_exp $a) (member $op $sub_exp $b)) )
                ( $else (equal-exp $sub_exp $EXP) )
            )
        )
        (equal-exp $sub_exp $EXP)
    )
)

; #################################################################################################


(= (subset $sub_exp $exp)
    (case $sub_exp
        (
            (($op $a $b) (and (subset2 $a $exp) (subset2 $b $exp)))
            ;; ((OR $a $b) (and (member OR $a $exp) (member OR $b $exp)))
            ((NOT $a) (member NOT $a $exp))
            ($symbol (member $_ $symbol $exp))
        )
    )
)


; #################################################################################################

(= (exp-type $exp)
    (case $exp
        (
            ((AND $a $b) AND)
            ((OR $a $b) OR)
            ((NOT $a) NOT)
            ($else Literal)
        )
    )
)

(= (equal-exp $exp1 $exp2)
    (if (and (== (get-metatype $exp1) Expression) (== (get-metatype $exp2) Expression))
        (if (== (exp-type $exp1) (exp-type $exp2))
            (if (== (exp-type $exp1) NOT)
                (== $exp1 $exp2)
                (let*
                    (
                        (($op1 $a1 $b1) $exp1)
                        (($op2 $a2 $b2) $exp2)
                    )
                    (and
                        (or (equal-exp $a1 $a2) (equal-exp $a1 $b2))
                        (or (equal-exp $b1 $a2) (equal-exp $b1 $b2))
                    )
                )
            )
            False
        )
        (if (and (== (get-metatype $exp1) Symbol) (== (get-metatype $exp2) Symbol))
            (== $exp1 $exp2)
            False
        )
    )
)

; #################################################################################################

(= (complement $exp)
    (case $exp
        (
            ((AND $a $b) (OR (complement $a) (complement $b)))
            ((OR $a $b) (AND (complement $a) (complement $b)))
            ((NOT $a) $a)
            ($a (NOT $a))
        )
    )
)