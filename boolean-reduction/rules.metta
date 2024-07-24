!(import! &self utils)

; Function to apply distributive property to an expression
(= (distrubutive-law $exp)
    (case $exp
        (
            ( (AND $a (OR $b $c))           ; (a AND (b OR c))  -->  ((a AND b) OR (a AND c))
                (if (== (get-metatype $a) Expression)
                    $exp
                    (OR (AND $a $b) (AND $a $c))
                )
            )
            ( (OR $a (AND $b $c))           ; (a OR (b AND c))  -->  ((a OR b) AND (a OR c))
                (if (== (get-metatype $a) Expression)
                    $exp
                    (AND (OR $a $b) (OR $a $c))
                )
            )
            ( $else $exp )
        )
    )
)

;** TODO **
; Write other recursive boolean reduction rules: identity | complement | annulment | absorption

(= (apply-and-reduction-rules (AND $a $b))
    (if (member AND $a $b)       ; (a AND (a AND b))  -->  (a AND b)     (idempotent law)
        $b
        (if (member OR $a $b)           ; a AND (a OR b)  -->  a                (absorption law)
            $a
            (if (member AND (NOT $a) $b)            ; (a AND ((not a) AND b))  -->  False     (annulment law)
                False
                (if (== (get-metatype $a) Expression)
                    (AND $a $b)
                    (distrubutive-law (AND $a $b))          ; (distributive property)
                )
            )
        )
    )
)

; The problem is that it doesn't reduce (OR (AND c a) (OR (AND a (AND c d)))) to (AND c a)
(= (apply-or-reduction-rules (OR $a $b))
    (if (member OR $a $b)       ; (a OR (a OR b))  -->  (a OR b)        (idempotent law)
        $b
        (if (member AND $a $b)          ; a OR (a AND b)  -->  a                (absorption law)
            $a
            (if (member OR (NOT $a) $b)         ; (a OR ((not a) OR b))  -->  True       (annulment law)
                True
                (if (== (get-metatype $a) Expression)
                    (OR $a $b)
                    (distrubutive-law (OR $a $b))          ; (distributive property)
                )
            )
        )
    )
)

(= (apply-reduction-rules $expr)
    (case $expr
        (
            ((AND $a $b) (apply-and-reduction-rules $expr))
            ((OR $a $b) (apply-or-reduction-rules $expr))
            ($else $expr)
        )
    )
)

; #################################################################################################

(= (complement-law $exp)
    (case $exp
        (
            ( (AND $a $b) (if (member AND (complement $a) $b) False $exp) )
            ( (OR $a $b) (if (member OR (complement $a) $b) True $exp) )
            ( $else $exp )
        )
    )
)

; #################################################################################################

(= (idempotent-law $exp)
    (case $exp
        (
            (($op $a $b)
                (if (subset $a $b)
                    $b
                    $exp
                )
            )
            ( $else $exp )
        )
    )
)

(= (absorption-idempotent-law $exp)
    (case $exp
        (
            (($op1 $a ($op2 $b $c))
                (if (== $op1 $op2)
                    (idempotent-law $exp)
                    (if (or (member $op2 $a $b) (member $op2 $a $c)) ;(subset $a ($op2 $b $c))
                        $a
                        $exp
                    )
                )
            )
            ( $else $exp )
        )
    )
)

; #################################################################################################

(= (annulment-identity-law $exp)
    (case (sort-metatype $exp)
        (
            (($op True $a)
                (if (== $op OR) True $a)
            )
            (($op False $a)
                (if (== $op AND) False $a)
            )
            ( $else $exp )
        )
    )
)