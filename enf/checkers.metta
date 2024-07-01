!(register-module! ../../metta-moses-reduction)
!(import! &self metta-moses-reduction:utilities:helper-functions)
!(import! &self metta-moses-reduction:reduction:utils)


(= (get-guard-set $exp $guard-set)(
    (case $exp (
        
            (($OP $exp1 $exp2)
                ((if (and (== (get-metatype $exp1) Expression) (== (get-metatype $exp2) Expression)) 
                    Nil
                    (if (and (== (get-metatype $exp1) Symbol) (== (get-metatype $exp2) Symbol))
                        (append (Cons $exp1 $exp2) $guard-set)
                        (if (and (== (get-metatype $exp1) Symbol) (== (get-metatype $exp2) Expression))
                            $exp1
                            (if (and (== (get-metatype $exp1) Expression) (== (get-metatype $exp2) Symbol))
                                $exp2
                            )
                        )
                    )
                ))
            )

        
    ))
))

(= (get-children $exp $guard-set)(
    (if (==(get-metatype $exp) Symbol)
        Nil
    (if (==(get-metatype $exp) Expression)
        (case $exp(
            (($op $exp1 $exp2)(
                (if (and (==(get-metatype $exp1) Symbol) (==(get-metatype $exp2) Symbol))
                    (append (Cons $exp1 $exp2) $guard-set)
        
                    (if (and (==(get-metatype $exp1) Symbol) (==(get-metatype $exp2) Expression))
                        
                        (append (Cons $exp1 (get-children $exp2 $guard-set)))
                    
                    (if (and (==(get-metatype $exp1) Expression) (==(get-metatype $exp2) Symbol))
                        
                        (append (Cons (get-children $exp1 $guard-set) $exp2))
                    )
                    )

                )
            ))

        ))
    )
    
    )
))

(= (get-branchset $exp1 ) $exp1
    ;; (if (== (get-metatype $exp1) Symbol)
    ;;     $exp1
    ;; )
)



!(get-branchset x1)
!(get-guard-set (AND (OR x1 x2) x3) Nil)
!(get-children (AND (OR x1 x2) x3) Nil)
