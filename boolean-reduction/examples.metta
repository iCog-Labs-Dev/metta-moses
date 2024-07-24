!(import! &self reduce)

; ################################################## AND

;; !(assertEqual
;;     (reduce (AND a True))
;;     a
;; )
;; !(assertEqual
;;     (reduce (AND True a))
;;     a
;; )
;; !(assertEqual
;;     (reduce (AND a b))
;;     (AND a b)
;; )
;; !(assertEqual
;;     (reduce (AND a (AND a c)))
;;     (AND a c)
;; )
;; !(assertEqual
;;     (reduce (AND a (AND b False)))
;;     False
;; )
;; !(assertEqual
;;     (reduce (AND a (AND b (AND a (AND a (AND a True))))))
;;     (AND b a)
;; )
;; !(assertEqual
;;     (reduce (AND a (AND b (AND a (AND a (AND a False))))))
;;     False
;; )
;; !(assertEqual
;;     (reduce (AND A (AND B (AND C (AND (OR A (OR B (OR C A))) (AND B (AND (AND A A) (NOT A))))))))
;;     False
;; )

; ################################################## OR
;; !(assertEqual
;;     (reduce (OR a b))
;;     (OR a b)
;; )
;; !(assertEqual
;;     (reduce (OR (AND a b) (AND a b)))
;;     (AND a b)
;; )
;; !(assertEqual
;;     (reduce (OR a (OR b (OR c (OR d True)))))
;;     True
;; )
;; !(assertEqual
;;     (reduce (OR a (AND b (AND c (AND d False)))))
;;     a
;; )
;; !(assertEqual
;;     (reduce (OR (AND a b) (OR a True)))
;;     True
;; )

; ################################################## NOT
;; !(assertEqual
;;     (reduce (NOT a))
;;     (NOT a)
;; )
;; !(assertEqual
;;     (reduce (NOT (NOT a)))
;;     a
;; )
;; !(assertEqual
;;     (reduce (NOT (AND a b)))
;;     (OR (NOT a) (NOT b))
;; )
;; !(assertEqual
;;     (reduce (NOT (OR a b)))
;;     (AND (NOT a) (NOT b))
;; )
;; !(assertEqual
;;     (reduce (NOT (NOT (AND A B))))
;;     (AND A B)
;; )

; ################################################## XOR
;; !(assertEqual
;;     (reduce (XOR (OR (NOT A) C) (OR (AND (NOT A) B) (NOT C))))
;;     (XOR (OR C (NOT A)) (OR (AND B (NOT A)) (NOT C)))
;; )
;; !(assertEqual
;;     (reduce (XOR (OR (NOT A) A) (OR (AND (NOT A) B) True)))
;;     False
;; )
;; !(assertEqual
;;     (reduce (XOR a (AND a a)))
;;     False
;; )
;; !(assertEqual
;;     (reduce (XOR True False))
;;     True
;; )
;; !(assertEqual
;;     (reduce (XOR True True))
;;     False
;; )

;; ; ******************* Associativity example *******************

;; !(assertEqual
;;     (reduce (OR (OR (NOT A) (AND A (AND B C))) (AND B (AND C (NOT B)))))
;;     (OR (NOT A) (AND A (AND B C)))
;; )
;; !(assertEqual
;;     (reduce (OR (OR (NOT A) (AND A (AND B C))) (AND C (AND B (NOT B)))))
;;     (OR (NOT A) (AND A (AND B C)))
;; )


;; ; ******************* ENF examples *******************
;; ; Rule 4
;; !(assertEqual
;;     (reduce (AND a (OR b (AND c (OR d (AND e (NOT a)))))))
;;     (OR (AND a b) (AND a (AND c d)))
;; )
 
;; !(assertEqual
;;     (reduce (OR (OR (AND a b) (AND a (AND c d))) (AND a (AND c (AND e (NOT a))))))
;;     (OR (AND a b) (AND a (AND c d)))
;; )

;; !(assertEqual
;;     (reduce (OR (AND a b) (AND a (AND c (OR d (AND e (NOT a)))))))
;;     (OR (AND a b) (AND a (AND c d)))
;; )

;; !(assertEqual
;;     (reduce (OR (AND a b) (AND a (AND c (OR d (AND e a))))))
;;     (OR (AND a b) (OR (AND a (AND c d)) (AND c (AND e a))))
;; )

;; !(assertEqual
    ; (reduce (AND a (OR b (AND c (OR d (OR e a))))))
    ; (OR (AND a b) (OR (AND a (AND c d)) (OR (AND a (AND c e)) (AND c a))))  
    ; This is correct but it can be further reduced:
    ; (OR (AND a b) (AND a c))
    ; The problem is that it doesn't reduce (OR (AND c a) (OR (AND a (AND c d)))) to (AND c a)
;; )

;; !(assertEqual
;;     (reduce (OR (AND a b) (OR (AND a (AND c d)) (OR (AND a (AND c e)) (AND c a)))))
;;     (OR (AND a b) (OR (AND a (AND c d)) (OR (AND a (AND c e)) (AND c a))))
        ; This can be further reduced:
;;     (OR (AND a b) (AND c a))
;; )

;; !(assertEqual    ; time: 40m20s
;;      (reduce (OR (AND a b) (AND a (AND c (OR d (OR e a)))))) 
;;      (OR (AND a b) (OR (AND a (AND c d)) (OR (AND a (AND c e)) (AND c a))))
        ;This can be further reduced
;;      (OR (AND a b) (AND a c))
;; )

;; !(assertEqual    ; time: 41m53s
;;     (reduce (OR (AND a b) (AND a (AND c (OR d (OR e (NOT a)))))))
;;     (OR (AND a b) (OR (AND a (AND c d)) (AND a (AND c e))))
        ;This can be further reduced
    ;; (OR (AND a b) (OR (AND a (AND c d)) (OR (AND a (AND c e)))))
;; )

; ******************* Examples from Holman's PhD thesis *******************
; Example from Holman paper (page 19)
;; !(assertEqual
;;     (reduce (AND (NOT (OR (OR a (AND (NOT b) a)) c)) b))
;;     (AND b (AND (NOT a) (NOT c)))
;; )
;; !(assertEqual
;;     (reduce (AND (AND (AND (NOT a) (OR (NOT b) (NOT a))) (NOT c)) b))
;;     (AND b (AND (NOT a) (NOT c)))
;; )

; Example from Holman paper (page 19)
;; !(assertEqual
;;     (reduce (AND (AND (AND (NOT a) (OR (NOT b) (NOT a))) (NOT c)) b))
;;     (AND b (AND (NOT a) (NOT c)))
;; )


;** TODO: Implement more flexible reduction logic **
;; !(assertEqual
;;     (reduce (OR (AND (AND c a) d) (OR (AND c a) (AND (AND c a) e))))
;;     (AND c a)
;; )