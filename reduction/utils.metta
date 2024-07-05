!(import! &self helper-functions)

; Function to apply distributive property
(= (distrubutive $exp)
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
            ( $else $exp)
        )
    )
)


(= (flatten-and (AND $a $b))
    (if (member AND $a $b)       ; (a AND (a AND b))  -->  (a AND b)     (idempotent law)
        $b
        (if (member OR $a $b)           ; a AND (a OR b)  -->  a                (absorption law)
            $a
            (if (member AND (NOT $a) $b)            ; (a AND ((not a) AND b))  -->  False     (annulment law)
                False
                (if (== (get-metatype $a) Expression)
                    (AND $a $b)
                    (distrubutive (AND $a $b))          ; (distributive property)
                )
            )
        )
    )
)

; The problem is that it doesn't reduce (OR (AND c a) (OR (AND a (AND c d)))) to (AND c a)
(= (flatten-or (OR $a $b))
    (if (member OR $a $b)       ; (a OR (a OR b))  -->  (a OR b)        (idempotent law)
        $b
        (if (member AND $a $b)          ; a OR (a AND b)  -->  a                (absorption law)
            $a
            (if (member OR (NOT $a) $b)         ; (a OR ((not a) OR b))  -->  True       (annulment law)
                True
                (if (== (get-metatype $a) Expression)
                    (OR $a $b)
                    (distrubutive (OR $a $b))          ; (distributive property)
                )
            )
        )
    )
)

(= (flatten $expr)
    (case $expr
        (
            ((AND $a $b) (flatten-and $expr))
            ((OR $a $b) (flatten-or $expr))
            ($else $expr)
        )
    )
)

;; !(flatten (AND B (AND C B)))
;; !(flatten (AND B (AND C (AND E B))))
;; !(flatten (AND B (AND C (NOT B))))
;; !(flatten (AND B (OR C (OR E (NOT B)))))
 
;; !(flatten (AND B (OR E (NOT B))))
;; !(flatten (AND B (NOT B)))
;; !(flatten (AND (AND A B) (OR B (AND C (NOT A)))))
;; !(flatten (AND (AND A B) (AND B (AND C (NOT (AND A B))))))