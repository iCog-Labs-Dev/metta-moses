!(import! &self ../utilities/helper-functions.metta)
!(import! &self ../reduction/utils.metta)

;;The get-guard-set is a function that is going to 
;;get the guard set of functions.
;; (=(get-guard-set $exp $fill)(
    
;;         (case $exp(
;;             (($op $x $xs)(Cons (get-guard-set $x $xs)))
;;             ($else (Cons $fill))
;;             )
;;         )
;;     )
;; )

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
(: get-guard-set (-> Expression List List))
(=(get-guard-set $exp $guard-set)(
    (case $exp(
        (
            ($OP $exp1 $exp2)(
            (if (and (== (get-metatype $exp1) Expression) 
                (== (get-metatype $exp2) Expression))(Nil)
            (if (and (== (get-metatype $exp1) Symbol) 
                    (== (get-metatype $exp2)) Symbol)
                (append $guard-set $exp1)
                (append $guard-set $exp2)

            )
            )

        ))
    ))
))
(: get-children (-> Expression List List))
(=(get-children $exp $guard-set)(
    (if (==(get-metatype $exp) Symbol)(
        Nil
    )(
        (case $exp(
            (($op $exp1 $exp2)(
                (if (and (==(get-metatype $exp1) Symbol) (==(get-metatype $exp2) Symbol))(
                    (append $guard-set $exp1)
                    (append $guard-set $exp2)

                )
                (if (and (==(get-metatype $exp1) Symbol) (==(get-metatype $exp2) Expression))(
                    (append $guard-set $exp1)
                    (append $guard-set (get-children $exp2))
                )
                (if (and (==(get-metatype $exp1) Expression) (==(get-metatype $exp2) Symbol))(
                    (append $guard-set (get-children $exp1))
                    (append $guard-set $exp2)
                ))
                )

                )
            ))
        ))
    )
    )
))


!(get-guard-set (AND (OR x1 x2)) Nil)
!(get-children (AND (OR x1 x2)) Nil )
