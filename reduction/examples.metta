!(import! &self simplify)

; ################################################## AND

;; !(assertEqual
;;     (simplify (AND a True))
;;     a
;; )
;; !(assertEqual
;;     (simplify (AND True a))
;;     a
;; )
;; !(assertEqual
;;     (simplify (AND a b))
;;     (AND a b)
;; )
;; !(assertEqual
;;     (simplify (AND a (AND a c)))
;;     (AND a c)
;; )
;; !(assertEqual
;;     (simplify (AND a (AND b False)))
;;     False
;; )
;; !(assertEqual
;;     (simplify (AND a (AND b (AND a (AND a (AND a True))))))
;;     (AND b a)
;; )
;; !(assertEqual
;;     (simplify (AND a (AND b (AND a (AND a (AND a False))))))
;;     False
;; )
;; !(assertEqual
;;     (simplify (AND A (AND B (AND C (AND (OR A (OR B (OR C A))) (AND B (AND (AND A A) (NOT A))))))))
;;     False
;; )

; ################################################## OR
;; !(assertEqual
;;     (simplify (OR a b))
;;     (OR a b)
;; )
;; !(assertEqual
;;     (simplify (OR (AND a b) (AND a b)))
;;     (AND a b)
;; )
;; !(assertEqual
;;     (simplify (OR a (OR b (OR c (OR d True)))))
;;     True
;; )
;; !(assertEqual
;;     (simplify (OR a (AND b (AND c (AND d False)))))
;;     a
;; )
;; !(assertEqual
;;     (simplify (OR (AND a b) (OR a True)))
;;     True
;; )

; ################################################## NOT
;; !(assertEqual
;;     (simplify (NOT a))
;;     (NOT a)
;; )
;; !(assertEqual
;;     (simplify (NOT (NOT a)))
;;     a
;; )
;; !(assertEqual
;;     (simplify (NOT (AND a b)))
;;     (OR (NOT a) (NOT b))
;; )
;; !(assertEqual
;;     (simplify (NOT (OR a b)))
;;     (AND (NOT a) (NOT b))
;; )
;; !(assertEqual
;;     (simplify (NOT (NOT (AND A B))))
;;     (AND A B)
;; )

; ################################################## XOR
;; !(assertEqual
;;     (simplify (XOR (OR (NOT A) C) (OR (AND (NOT A) B) (NOT C))))
;;     (XOR (OR (NOT A) C) (OR (AND (NOT A) B) (NOT C)))
;; )
;; !(assertEqual
;;     (simplify (XOR (OR (NOT A) A) (OR (AND (NOT A) B) True)))
;;     False
;; )
;; !(assertEqual
;;     (simplify (XOR a (AND a a)))
;;     False
;; )
;; !(assertEqual
;;     (simplify (XOR True False))
;;     True
;; )
;; !(assertEqual
;;     (simplify (XOR True True))
;;     False
;; )

;; ; Associativity example

;; !(assertEqual
;;     (simplify (OR (OR (NOT A) (AND A (AND B C))) (AND B (AND C (NOT B)))))
;;     (OR (NOT A) (AND A (AND B C)))
;; )
;; !(assertEqual
;;     (simplify (OR (OR (NOT A) (AND A (AND B C))) (AND C (AND B (NOT B)))))
;;     (OR (NOT A) (AND A (AND B C)))
;; )


(= (distrubutive $exp)
    (case $exp`````
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

(= (distrubute-simplify $num $prev $exp)
    (if (or (== $prev $exp) (< $num 0))
        $exp
        (distrubute-simplify (- $num 1) $exp (simplify (distrubutive $exp)))
    )
)

;; !(simplify (AND a (OR b (AND c (OR d (AND e (NOT a)))))))

;; !(distrubute-simplify 5 empty (AND a (OR b (AND c (OR d (AND e (NOT a)))))))
 
;; !(distrubutive (AND a (OR b (AND c (OR d (AND e (NOT a)))))))
;; !(distrubutive (AND a (OR b c)))

;; !(distrubutive (AND a (OR b (AND c (OR d (AND e (NOT a)))))))
;; !(simplify (OR (AND a b) (AND a (AND c (OR d (AND e (NOT a)))))))
!(simplify (distrubutive (AND a (OR b (AND c (OR d (AND e (NOT a))))))))

!(simplify (OR (OR (AND a b) (AND a (AND c d))) (AND a (AND c (AND e (NOT a))))))
