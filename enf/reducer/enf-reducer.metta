;; !(import! &self ../../utilities/helper-functions.metta)
;; !(import! &self ../enf)
;; !(load-ascii &self ../enf.metta)
;; !(load-ascii &self ../../utilities/helper-functions.metta)
;; !(load-ascii &self ../../utilities/type-defs.metta)

;; (: get-guard-set (-> Expression List List))
;; (= (get-guard-set $exp $guard-set)
;;     (case $exp
;;         (
;;             (($OP $a $b) 
;;                 ; If both children are literals
;;                 (if (not (or (== (get-metatype $a) Expression) (== (get-metatype $b) Expression)))
;;                     (append $guard-set (Cons $a (Cons $b Nil)))
;;                     ; If both are expressions
;;                     (if (and (== (get-metatype $a) Expression) (== (get-metatype $b) Expression))
;;                         (append (get-guard-set $a $guard-set) (get-guard-set $b $guard-set))
;;                         ; If only $a is a literal
;;                         (if (== (get-metatype $b) Expression)
;;                             (get-guard-set $b (append $guard-set (Cons $a Nil)))
;;                             ; If only $b is a literal
;;                             (if (== (get-metatype $a) Expression)
;;                                 (get-guard-set $a (append $guard-set (Cons $b Nil)))
;;                             )
;;                         )
;;                     )
;;                 )
;;             )
;;             (($OP $a)
;;                 (if (== (get-metatype $a) Expression)
;;                     (get-guard-set $a $guard-set)
;;                     (append $guard-set $a)
;;                 )
;;             )
;;             ($a (append $guard-set $a))
;;         )
;;     )
;; )


;; !(get-guard-set (OR
;;     (AND 
;;         (OR 
;;             x3
;;             x4
;;         )
;;         x2
;;     )
;;     x7
;; ) Nil)
;; !(get-guard-set (OR
;;     (AND 
;;         (OR 
;;             (NOT x3)
;;             (NOT x4)
;;         )
;;         (OR
;;             x3
;;             (AND x3 x6)
;;         )
;;     )
;;     x7
;; ) Nil)

;; !(append Nil (Cons 1 Nil))
;; !(append (Cons 1 Nil) Nil)
;; !(append (Cons 1 (Cons 2 Nil)) (Cons 3 Nil))

;; !(get-guard-set (AND (OR x3 x4) (NOT x2)) Nil)
;; !(remove-duplicates (get-guard-set (AND (OR x3 x4) (NOT x2)) Nil))

; 4. No branch set contains a literal and its negation.
(: distrubute-branch-set (-> Expression Expression))
(= (distrubute-branch-set $exp) 
    (case $exp
        (
            (($OP ))
        )
    )
)

(= (distrubutive $exp)
    (case $exp
        (
            ( (OR $a (AND $b $c)) (AND (OR $a $b) (OR $a $c)))      ; (a OR (b AND c))  -->  ((a OR b) AND (a OR c))
            ( (AND $a (OR $b $c)) (OR (AND $a $b) (AND $a $c)))     ; (a AND (b OR c))  -->  ((a AND b) OR (a AND c))
        )
    )
)