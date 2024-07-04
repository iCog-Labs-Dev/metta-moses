!(register-module! ../../metta-moses-reduction)
!(import! &self metta-moses-reduction:utilities:helper-functions)
!(import! &self metta-moses-reduction:reduction:utils)

(:get-guard-set (-> Expression List List))
(= (get-guard-set $exp $guard-set)
        (case $exp (
            (($OP $exp1 $exp2)
                (if (and (== (get-metatype $exp1) Expression) (== (get-metatype $exp2) Expression)) 
                    Nil
                    (if (and (== (get-metatype $exp1) Symbol) (== (get-metatype $exp2) Symbol))
                        (append (Cons $exp1 (Cons $exp2)) $guard-set)
                        (if (and (== (get-metatype $exp1) Symbol) (== (get-metatype $exp2) Expression))
                            $exp1
                            (if (and (== (get-metatype $exp1) Expression) (== (get-metatype $exp2) Symbol))
                                $exp2
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
(:get-children (-> Expression List List))
(= (get-children $exp $guard-set)(
    (if (==(get-metatype $exp) Symbol)
        Nil
    (if (==(get-metatype $exp) Expression)
        (case $exp (
            (($op $exp1 $exp2)(
                (if (and (==(get-metatype $exp1) Symbol) (==(get-metatype $exp2) Symbol))
                    (append (Cons $exp1 (Cons $exp2)) $guard-set)
        
                    (if (and (==(get-metatype $exp1) Symbol) (==(get-metatype $exp2) Expression))
                        
                        (append (Cons $exp1 (get-children $exp2 $guard-set)))
                    
                        (if (and (==(get-metatype $exp1) Expression) (==(get-metatype $exp2) Symbol))
                            
                            (append (Cons (get-children $exp1 $guard-set) $exp2))
                            (if (and (==(get-metatype $exp1) Expression) (==(get-metatype $exp2) Expression))
                                (append (get-children $exp1 $guard-set) (get-children $exp2 $guard-set))
                            )
                        )
                    )

                )
            ))
            ($_ (Error This shouldn't be the correct format))
            

        ))
        (ERROR the format is invalid)
    )
    
    )
))
;; (: get-branchset (-> Expression List List))
;; (= (get-branchset $exp $branch-set)
;;     (case $exp (
;;         (($OP $exp1 $exp2)
;;             (if (== $OP AND)
;;                 (if (and (==(get-metatype $exp1) Expression) (not (==(get-metatype $exp2) Expression)))
;;                     (get-branchset $exp1 (append $exp2 $branch-set))
;;                     (if (and (not (== get-metatype $exp1) Expression) (==(get-metatype $exp2) Expression))
;;                         (get-branchset (append $exp1 $branch-set) $exp2)
;;                         (if (and (not (== get-metatype $exp1) Expression) (not (==(get-metatype $exp2) Expression)))
;;                             (get-branchset (append $exp1 $branch-set) $exp2)
;;                             (Error This shouldn't exist) 
;;                         )
;;                     )
;;                 )
;;                 ((get-branchset $exp1 guard-set) (get-branchset $exp1 guard-set))
;;             )
;;         )

;;     )
;; ))
(= (get-dominant-set $exp1 $dominant-set)(

    )
)
(=(fourth-rule-checker $exp1)(
    (if )
))

(= (not-checker $exp)
    (case $exp
        (
            (($OP $exp1 $exp2) False)
            (($OP $exp1) (if (== $OP NOT) True (Error "Invalid NOT expression.")) )
            ($else (Error "Invalid"))
        )
    )
)
(=(fourth-rule-checker $exp $branch-set)
    (if ==(get-metatype $exp) 

))




;; !(not-checker (NOT x))
;; !(not-checker (NOT x a b ))
;; !(get-branchset (AND (OR x1 x2) x3) Nil)
;; !(get-guard-set (AND a1 a2) Nil)
;; !(get-children (AND (OR x1 x2) x3) Nil)
(=(length ...) 0)
(=(length ...)(+ 1 (length $xs)))
!(length (Cons A (Cons B (Cons C Nil))))
