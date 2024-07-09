!(register-module! ../../metta-moses-reduction)
!(import! &self metta-moses-reduction:utilities:helper-functions)
!(import! &self metta-moses-reduction:reduction:utils)
;;(get-guard-set (AND a1 a2) Nil)
(=(ret-append $set1 $set2)(append $set1 $set2))

(:get-guard-set (-> Expression List List))
(= (get-guard-set $exp $guard-set)
        (case $exp (
            (($OP $exp1 $exp2)
                (if (and (== (get-metatype $exp1) Expression) (== (get-metatype $exp2) Expression)) 
                    (Cons Nil)
                    (if (and (== (get-metatype $exp1) Symbol) (== (get-metatype $exp2) Symbol))
                        (append  $guard-set (Cons $exp1 (Cons $exp2)))
                        (if (and (== (get-metatype $exp1) Symbol) (== (get-metatype $exp2) Expression))
                            (Cons $exp1 (Cons Nil))
                            (if (and (== (get-metatype $exp1) Expression) (== (get-metatype $exp2) Symbol))
                                (Cons $exp2 (Cons Nil))
                                (ERROR the format is wrong)
                            )
                        )
                    )
                )
            )
            (($OP $exp)(
                (if (== NOT $exp) (NOT $exp) ERROR)
            ))
            ($exp $exp)

        
    ))
)


;; (= (get-branchset $exp $branch-set)
;;     (case $exp (
;;         (($OP $exp1 $exp2)
;;             (if (== $OP AND)

;;                 (if (and (==(get-metatype $exp1) Expression) (not (==(get-metatype $exp2) Expression)))
;;                     (get-branchset $exp1 (append $exp2 $branch-set))
;;                     (if (and (not (== (get-metatype $exp1) Expression) (==(get-metatype $exp2) Expression))
;;                         (get-branchset (append $exp1 $branch-set) $exp2)
;;                         (if (and (not (== (get-metatype $exp1) Expression))) (not (==(get-metatype $exp2) Expression)))
;;                             (get-branchset (append $exp1 $branch-set) $exp2)
;;                             (Error This shouldn't exist) 
;;                         )
;;                     )
;;                 )
;;                 ((get-branchset $exp1 (get-branchset $exp2 guard-set)) )
                
;;             )
;;         )

;;     )
;; ))
(: get-branchset (-> Expression List List))
(=(get-branchset $exp $branch-set)
    (case $exp(
        (($op $exp1 $exp2)
            (if (== $OP AND)(let* (($type1 (get-metatype $exp1))
                                    ($type2 (get-metatype $exp2)))
                                    (if (and (== $type1 Expression)(== $type2 Expression))
                                       (append (get-guard-set $exp1 $branch-set) (get-guard-set $exp2 $branch-set))
                                       (if (and (== $type1 Expression)(== $type2 Symbol))
                                        (append (get-guard-set $exp1 $branch-set) (Cons $exp2 (Cons Nil)))
                                        (if (and (== $type1 Symbol)(== $type2 Expression)) 
                                            (append (get-guard-set $exp2 branch-set) $exp1)
                                            (ERROR IT is in the wrong format)

                                        )
                                       )
                                    )


        )
        (Cons (get-branchset $exp1 $branch-set) (Cons (get-branchset $exp2 $branch-set)))
            
        )
    )
    (($op $exp1) 
            (if (== $exp1 NOT) (get-branchset $exp1 $branch-set) (ERROR The format is wrong)))
    )

))
;; (= (get-dominant-set $exp1 $dominant-set)(

;;     )
;; )


(= (not-checker $exp)
    (if (== (get-metatype $exp) Symbol)
        True
        (case $exp
            (
                (($OP $exp1) (if (== $OP NOT) True (Error "Invalid NOT expression.")) )
                ($_ (case $exp (
                        (($OP $exp1 $exp2) ((not-checker $exp1) (not-checker $exp2)))
                        ($_ False)
                
                    ))
                
                )
            )
        )
    )
)

;; (= (not-gate $exp)
;;     (case $exp (
;;         (($op $exp1 $exp2)
;;             (if (== $op NOT) True False))
;;     )))
;; (=(fourth-rule-checker $exp $branch-set)
;;     (if ==(get-metatype $exp) 

;; ))




;;  !(not-checker (NOT x))
;;  !(not-gate (NOT A B))
;;  !(not-checker (NOT x a b ))
!(get-branchset (AND (OR x1 x2) x3) Nil)
!(get-guard-set (AND a1 a2) Nil)
!(ret-append (Cons x1 (Cons x2 (Cons x3 (Cons Nil)))) (Cons x4 (Cons x5 (Cons x6 ))))
;; !(get-children (AND (OR x1 x2) x3) Nil)
(=(length ...) 0)
(=(length ...)(+ 1 (length $xs)))
!(length (Cons A (Cons B (Cons C Nil))))
