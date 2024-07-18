!(register-module! ../../metta-moses-reduction)
!(import! &self metta-moses-reduction:utilities:helper-functions)
!(import! &self metta-moses-reduction:reduction:utils)


(: check-branchset (-> Expression List Bool))
(= (check-branchset $exp $branch-set)
    (case $exp
        (
            (($op $exp1 $exp2)
                    (let* 
                        (
                            ($type1 (case $exp1
                                (
                                    (($op1 $b $c) subtree)
                                    
                                    ($_ not-subtree)
                                )
                            ))
                            ($type2 (case $exp2
                                (
                                    (($op1 $b $c) subtree)
                                    ($_ not-subtree)
                                )
                            ))
                        )
                        (if (and (== $type1 subtree) (== $type2 subtree))
                            (and (check-branchset $exp1 $branch-set) (check-branchset $exp2 $branch-set))

                            (if (and (== $type1 subtree) (== $type2 not-subtree))
                                (if (== $op AND)
                                    (check-branchset $exp1 (append (Cons $exp2 Nil) $branch-set))
                                    (check-branchset $exp1 $branch-set)
                                ) 
                                
                                (if (and (== $type1 not-subtree) (== $type2 subtree))
                                    (if (== $op AND)
                                        (check-branchset $exp2 (append (Cons $exp1 Nil) $branch-set))
                                        (check-branchset $exp2 $branch-set)
                                    )
                                    
                                    (let $all_branchset (append (Cons $exp1 (Cons $exp2 Nil)) $branch-set)
                                        (and (check-not-duplicated $all_branchset) (check-not-inverse-duplicated $all_branchset))
                                       
                                    )
                                )
                            )                                           
                        )
                    )
            )
            
            ($_ False)
        )
    )
)
(= (check-guard-set-disjunction $exp)
    (if (== $exp Nil)
        True
        (case $exp(
                (($op $exp1 $exp2)
                    (if (== $op AND)
                        (isEmpty (intersect (get-guard-set $exp1) (get-guard-set $exp2)))
                        False
                    )
                )

            )
        )

    )

)
(=(check-subset-constraint $exp)
    (case $exp(
            (($op $exp1 $exp2) 
                (if (is-subset (get-guard-set $exp1) (get-guard-set $exp2)) 
                    False 
                    True
                )
            )
            ($_ True)
 
        )
    )
)

(=(check-guard-set-conjunction $exp)
    (if (== $exp Nil)
        True
        (case $exp(
                (($op $exp1 $exp2)
                    (if (== $op OR)
                        (isEmpty (intersect (get-guard-set $exp1) (get-guard-set $exp2)))
                        False
                    )
                )

            )
        )

    )

)



;; !(check-duplicate (Cons 1 (Cons 2 (Cons 3 (Cons 3 Nil)))))
;; !(check-branchset (AND a (AND b (AND d c))) Nil)
;; !(check-branchset (AND a (OR a (AND b c))) Nil)

;; !(check-branchset (AND a (OR b (AND a c))) Nil)
;; !(check-branchset (AND (AND a (OR b (AND c a))) (OR e (AND f (OR g h)))) Nil)

 ;;!(check-branchset (AND (AND a (OR b (AND c (NOT a)))) (OR e (AND f (OR g h)))) Nil)
;; !(append (Cons 1 (Cons 2 (Cons 3 Nil))) (Cons a (Cons b (Cons c (Cons (NOT a) Nil)))))
;; !(check-not-duplicated (Cons 1 (Cons 2 (Cons 3 (Cons a (Cons b (Cons c (Cons (NOT a) Nil))))))))
;; !(check-not-inverse-duplicated (Cons 1 (Cons 2 (Cons 3 (Cons a (Cons b (Cons c (Cons (NOT a) Nil))))))))
;; !(member-not (NOT a) (Cons 1 (Cons 2 (Cons 3 (Cons a (Cons b (Cons c (Cons (NOT a) Nil))))))))
;; !(member-not a (Cons 1 (Cons 2 (Cons 3 (Cons a (Cons b (Cons c (Cons (NOT a) Nil))))))))
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






;;  !(not-checker (NOT x))
;;  !(not-gate (NOT A B))
;;  !(not-checker (NOT x a b ))
;;!(get-branchset (AND (OR x1 x2) x3) Nil)
;;!(get-metatype (1 2 3 4))
;; !(get-guard-set (AND a1 a2) Nil)
;; !(get-guard-set a1 Nil)
;;!(ret-append (Cons x1 (Cons x2 (Cons x3 (Cons Nil)))) (Cons x4 (Cons x5 (Cons x6 ))))
;; !(get-children (AND (OR x1 x2) x3) Nil)
;; (=(length ...) 0)
;; (=(length ...)(+ 1 (length $xs)))
;; !(length (Cons A (Cons B (Cons C Nil))))
