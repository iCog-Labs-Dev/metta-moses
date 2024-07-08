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
;;     (XOR (OR C (NOT A)) (OR (AND B (NOT A)) (NOT C)))
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

;; ; ******************* Associativity example *******************

;; !(assertEqual
;;     (simplify (OR (OR (NOT A) (AND A (AND B C))) (AND B (AND C (NOT B)))))
;;     (OR (NOT A) (AND A (AND B C)))
;; )
;; !(assertEqual
;;     (simplify (OR (OR (NOT A) (AND A (AND B C))) (AND C (AND B (NOT B)))))
;;     (OR (NOT A) (AND A (AND B C)))
;; )


;; ; ******************* ENF examples *******************
;; ; Rule 4
;; !(assertEqual
;;     (simplify (AND a (OR b (AND c (OR d (AND e (NOT a)))))))
;;     (OR (AND a b) (AND a (AND c d)))
;; )
 
;; !(assertEqual
;;     (simplify (OR (OR (AND a b) (AND a (AND c d))) (AND a (AND c (AND e (NOT a))))))
;;     (OR (AND a b) (AND a (AND c d)))
;; )

;; !(assertEqual
;;     (simplify (OR (AND a b) (AND a (AND c (OR d (AND e (NOT a)))))))
;;     (OR (AND a b) (AND a (AND c d)))
;; )

;; !(assertEqual
;;     (simplify (OR (AND a b) (AND a (AND c (OR d (AND e a))))))
;;     (OR (AND a b) (OR (AND a (AND c d)) (AND c (AND e a))))
;; )

;; !(assertEqual
    ; (simplify (AND a (OR b (AND c (OR d (OR e a))))))
    ; (OR (AND a b) (OR (AND a (AND c d)) (OR (AND a (AND c e)) (AND c a))))  
    ; This is correct but it can be further reduced:
    ; (OR (AND a b) (AND a c))
    ; The problem is that it doesn't reduce (OR (AND c a) (OR (AND a (AND c d)))) to (AND c a)
;; )

;; !(assertEqual
;;     (simplify (OR (AND a b) (OR (AND a (AND c d)) (OR (AND a (AND c e)) (AND c a)))))
;;     (OR (AND a b) (OR (AND a (AND c d)) (OR (AND a (AND c e)) (AND c a))))
        ; This can be further reduced:
;;     (OR (AND a b) (AND c a))
;; )

;; !(assertEqual    ; time: 40m20s
;;      (simplify (OR (AND a b) (AND a (AND c (OR d (OR e a)))))) 
;;      (OR (AND a b) (OR (AND a (AND c d)) (OR (AND a (AND c e)) (AND c a))))
        ;This can be further reduced
;;      (OR (AND a b) (AND a c))
;; )

;; !(assertEqual    ; time: 41m53s
;;     (simplify (OR (AND a b) (AND a (AND c (OR d (OR e (NOT a)))))))
;;     (OR (AND a b) (OR (AND a (AND c d)) (AND a (AND c e))))
        ;This can be further reduced
    ;; (OR (AND a b) (OR (AND a (AND c d)) (OR (AND a (AND c e)))))
;; )

; ******************* Examples from Holman's PhD thesis *******************
; Example from Holman paper (page 19)
;; !(assertEqual
;;     (simplify (AND (NOT (OR (OR a (AND (NOT b) a)) c)) b))
;;     (AND b (AND (NOT a) (NOT c)))
;; )
;; !(assertEqual
;;     (simplify (AND (AND (AND (NOT a) (OR (NOT b) (NOT a))) (NOT c)) b))
;;     (AND b (AND (NOT a) (NOT c)))
;; )

; Example from Holman paper (page 19)
;; !(assertEqual
;;     (simplify (AND (AND (AND (NOT a) (OR (NOT b) (NOT a))) (NOT c)) b))
;;     (AND b (AND (NOT a) (NOT c)))
;; )


;** TODO **
;; !(assertEqual
;;     (simplify (OR (AND (AND c a) d) (OR (AND c a) (AND (AND c a) e))))
;;     (AND c a)
;; )
; Write subest, equal and list functions