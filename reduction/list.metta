; -----------------------------------------------------
;; (NOT a b) ~~ (AND b a)                                   || (Cons-and a (Cons-and b Nil)
;; (AND (OR a b) (OR c d)) ~~ (AND (OR d c) (OR b a))       || (Cons-and (Cons-or a (Cons-or b Nil)) (Cons-and (Cons-or c (Cons-or d Nil)) Nil))

(= (flatten-and $exp)
    (let (AND $a $b) $exp
        (Cons-and (flatten $a) (Cons-and (flatten $b) Nil))
    )
)
(= (flatten $exp)
    (case $exp
        (
            ((AND $a $b) (append (flatten-and $a) (Cons-and (flatten $b) Nil)))
            ((OR $a $b) (Cons-or (flatten $a) (Cons-or (flatten $b) Nil)))
            ($symbol $symbol)
        )
    )
)
;; ! (flatten (AND a b))
;; ! (flatten (AND a (AND b (AND c d))))
;; ! (flatten (AND a (OR b c)))
;; ! (flatten (AND a (OR b (AND c (NOT d)))))
;; ! (flatten (NOT a))
;; ! (flatten (AND (NOT a) (NOT b)))


;; (= (length $exp)
;;     (case $exp
;;         (
;;             (Nil 0)
;;             (($Cons $x $xs) (+ 1 (length $xs)))
;;         )
;;     )
;; )

;; (= (equal $list1 $list2)
;;     (if (== (length $list1) (length $list2))
;;         (case $list1
;;             (Nil False)
;;             ((Cons $x $xs)


;;             )
;;         )
;;         False
;;     )
;; )


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
;; (: Blah type)
;; (: a Blah)
;; !(== a a)
;; !((get-metatype a))
;; !((get-type a))
;; !(== (get-metatype a) Symbol)
;; !(== (get-type a) Blah)
;; !(== (get-metatype a) (get-metatype a)) ; ???
;; !(== (get-type a) (get-type a)) ; ???

;; !(equal-exp a a)
;; !(equal-exp (AND a b) (AND a b))
;; !(equal-exp (AND a b) (AND b a))
; The problem is that it doesn't reduce (OR (AND c a) (OR (AND a (AND c d)))) to (AND c a)
;; !(equal-exp (AND a b) (AND b c))
;; !(equal-exp (AND (OR a (NOT b)) (OR c d)) (AND (OR d c) (OR (NOT b) a)))


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
; (OR (AND a b) (AND a c))
; The problem is that it doesn't reduce (OR (AND c a) (OR (AND a (AND c d)))) to (AND c a)
; The problem is that it doesn't reduce (AND (OP c a) (OR (AND a (AND c d)))) to (AND c a)
;;  (OR (AND a (AND c d)) (OR (AND a (AND c e)) (AND c a)))
;; !(member OR (AND c a) (OR (AND a (AND c d))))

;; !(member AND c (AND a (AND c d)))
;; !(member AND (NOT d) (AND a (AND c (NOT d))))
;; !(member AND (OR b d) (AND a (AND c (OR b d))))

;; !(member OR c (OR (AND a (AND c d))))
;; !(member AND (OR b d) (AND a (AND c (OR b c))))
(= (subset $sub_exp $exp)
    (case $sub_exp
        (
            ((AND $a $b) (and (member AND $a $exp) (member AND $b $exp)))
            ((OR $a $b) (and (member OR $a $exp) (member OR $b $exp)))
            ((NOT $a) (member NOT $a $exp))
            ($symbol (member $_ $symbol $exp))
        )
    )
)


;; !(subset (AND c a) (AND a (AND c d)))
;; !(subset (AND c a) (AND a (AND d (AND c a))))
;; !(subset (AND c a) (AND a (AND d (OR c a))))



;; (= (greater $num1 $num2)
;;     (if (> $num1 $num2) $num1 $num2)
;; )
;; (: depth (-> Expression Number))
;; (= (depth $exp)
;;     (case $exp
;;         (($op $a $b) (if (greater (depth $a)) 
;;             (+ 1 (depth $a))
;;             (+ 1 (depth $b))
;;         ))
;;         (($op $a) (+ 1 (depth $a)))
;;         ($symbol 0)
;;     )
;; )

;; !(depth (AND a b))



((AND $a (NOT $a)) False)   ; (a and -a)  -->  False                (complement law)
((Or $a (NOT $a)) False)   ; (a or -a)  -->  True                (complement law)
((AND $a $a) $a)            ; (a and a)  -->  a                     (idempotent law)

(member AND $a $b)          ; (a AND (a AND b))  -->  (a AND b)     (idempotent law)

(member OR $a $b)           ; a AND (a OR b)  -->  a                (absorption law)
(member AND $a $b)          ; a OR (a AND b)  -->  a                (absorption law)

(member AND (NOT $a) $b)    ; (a AND ((not a) AND b))  -->  False     (annulment law)
(member OR (NOT $a) $b)     ; (a OR ((not a) OR b))  -->  True       (annulment law)

;; (= (complement $exp)
;;     (let ($op $a (NOT $b)) $exp
;;         (if (equal-exp $a $b)
;;             (== $op OR) ; True if OR, False if AND
;;             $exp
;;         )
;;     )
;; )
;; !(complement (AND (AND a b) (NOT (AND b a))))
;; !(complement (OR (AND a b) (NOT (AND b a))))
;; !(complement (OR (AND a b) (NOT (AND b b))))

;; (= (complement $exp)
;;     (let ($op $a $b) $exp
;;         (case $a
;;             (
;;                 (($op1 $a1 $a2)
;;                     (if )
;;                 )
;;                 ((AND $a1 $a2) (or (complement ($a1 $b)) (complement ($a2 $b))))
;;                 ((OR $a1 $a2) (and (complement ($a1 $b)) (complement ($a2 $b))))
;;                 ((NOT $a1) (member $op $a1 $b))
;;                 ($symbol (member $op (NOT $a) $b))
;;             )
;;         )
;;     )
;; )
;; !(complement (AND (AND a b) (AND (NOT a) b))) ; -a || -b --> 0

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
; TODO: add more edge cases for complement law
(= (complement-law $exp)
    (let ($op $a $b) $exp
        (if (subset (complement $a) $b)
            (== $op OR)
            $exp
        )
    )
)

;; (if (and (== (exp-type $a) AND) (== (exp-type $b) AND))
;;     (if (or (member AND $a $exp) (member AND $b $exp))
    
;;     )
;;     (if (and (== (exp-type $a) OR) (== (exp-type $b) OR))
;;         -
;;         -
;;     )
;;     ;; ((OR $a $b) (and (member OR $a $exp) (member OR $b $exp)))
;;     ;; ((NOT $a) (member NOT $a $exp))
;;     ;; ($symbol (member $_ $symbol $exp))            
;; )

;; !(member AND (AND a b) (AND (AND (NOT a) b) (AND a (OR a b))))
;; !(subset (AND a b) (AND (AND (NOT a) b) (AND a (OR a b))))
;; ;; !(subset (AND (AND a (AND b c)) (AND (AND d e) (AND f (AND g h)))) (AND (AND h (AND b (AND a g))) (AND (AND c (AND e d)) (AND f i))))
;; !(equal-exp (AND (AND a (AND b c)) (AND (AND d e) (AND f (AND g h)))) (AND (AND h (AND b (AND a g))) (AND (AND c (AND e d)) i)))


;; !(complement-law (AND (AND a b) (AND (AND (NOT a) b) (OR a b)))) ; -a || -b --> 0
;; !(complement-law (AND (OR a b) (AND (AND (NOT a) b) (OR a b))))  ; -a && -b --> 0

;; !(complement-law (OR (AND a b) (OR (AND (NOT a) b) (OR (NOT a) (NOT b)))))  ; -a && -b --> 1
;; !(complement-law (OR (OR a b) (OR (AND (NOT a) b) (OR (NOT a) b))))    ; -a || -b --> 1

;; !(complement-law (AND (NOT a) (AND (AND (NOT b) a) (OR a b))))
;; !(complement-law (AND b (AND (AND (NOT b) c) (OR a b))))

(= (idempotent $exp)
    (let ($op $a $b) $exp
        (if (subset $a $b)
            $b
            $exp
        )
    )
)
;; !(idempotent (AND a (AND a b)))
;; !(idempotent (AND (AND a b) (AND b a)))
;; !(idempotent (OR (AND a b) (AND b a)))
;; !(idempotent (OR (AND a b) (AND b b)))
; TODO: Update subset function
!(idempotent (OR (AND (OR a b) (AND (NOT c) d)) (AND (AND d (NOT c)) (OR b a))) )

;;((AND x1 x2) ()

(= (absorption $exp)
    (let ($op1 $a ($op2 $b $c)) $exp
        (if (== $op1 $op2)
            (idempotent $exp) ; ??
            (if (or (member $op2 $a $b) (member $op2 $b $c)) ;(subset $a ($op2 $b $c))
                $a
                $exp
            )
        )
    )
)
;; !(absorption (AND (AND a b) (OR (AND b a) c)))
;; !(idempotent (AND (AND a b) (AND (AND b a) c)))



;; (a OR ((not a) OR b))  -->  True       (annulment law)
;; (a AND ((not a) AND b))  -->  False     (annulment law)
(= (annulment $exp)
    (let ($op $a ($op $b $c)) $exp
        (pass)
    )
)