;; !(register-module! ../utilities)
;; !(import! &self utilities:list)
;; !(import! &self utilities:helper-functions)

(= (distrubutive $exp)
    (case $exp
        (
            ( (OR $a (AND $b $c))           ; (a OR (b AND c))  -->  ((a OR b) AND (a OR c))
                (if (== (get-metatype $a) Expression)
                    $exp
                    (AND (OR $a $b) (OR $a $c))
                )
            )
            ( (AND $a (OR $b $c))           ; (a AND (b OR c))  -->  ((a AND b) OR (a AND c))
                (if (== (get-metatype $a) Expression)
                    $exp
                    (OR (AND $a $b) (AND $a $c))
                )
            )
            ( $else $exp)
        )
    )
)

; (= (flatten $exp) case ... )

(= (flatten-and (AND $a $b))
    (if (member AND $a $b)
        $b
        (if (member OR $a $b)
            $a
            (if (member AND (NOT $a) $b)
                False
                ;; (if (== (get-metatype $a) Expression)
                    ;; (AND $a $b)
                    (distrubutive (AND $a $b))
                ;; )
            )
        )
    )
)

(= (flatten-or (OR $a $b))
    (if (member OR $a $b)
        $b
        (if (member AND $a $b)
            $a
            (if (member OR (NOT $a) $b)
                True
                ;; (if (== (get-metatype $a) Expression)
                    ;; (OR $a $b)
                    (distrubutive (OR $a $b))
                ;; )
            )
        )
    )
)

;; !(flatten-and (AND B (AND C B)))
;; !(flatten-and (AND B (AND C (AND E B))))
;; !(flatten-and (AND B (AND C (NOT B))))
;; !(flatten-and (AND B (AND C (AND E (NOT B)))))

;; !(member AND A A)
;; !(member AND A (AND A B))

;; !(member AND (NOT A) (AND A B))
;; !(member AND A (AND C B))

;; !(member AND (NOT A) (AND (NOT A) B))
;; !(member AND (NOT A) (NOT A))

;; !(member OR A A)
;; !(member OR A (AND A B))

;; !(member OR (NOT A) (OR A B))
;; !(member OR A (AND C B))

;; !(member OR (NOT A) (AND (NOT A) B))
;; !(member OR (NOT A) (NOT A))