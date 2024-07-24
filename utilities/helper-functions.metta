!(import! &self list)

(= (check-not-duplicated $list)
    (case $list
        (
            (Nil True)
            ((Cons $x $xs)
                (if (member $x $xs)
                    False
                    (check-not-duplicated $xs)
                )
            )
        )
    )
)
(= (check-not-inverse-duplicated $list)
    (case $list
        (
            (Nil True)
            ((Cons $x $xs)
                (if (member-not $x $xs)
                    False
                    (check-not-inverse-duplicated $xs)
                )
            )
        )
    )
)
(=(isEmpty $exp)
    (if (== Nil $exp) True False)
)

(:intersect (-> List List List List))
;;This function takes two lists and finds the intersection of two lists
;;after it accumulates it in to an accumulator
(= (intersect $list1 $list2 $accumulator)
    (case $list1(
        ((Cons $x $xs)
            (if (member $x $list2)
                (intersect $xs $list2 (append $accumulator (Cons $x Nil)))
                (intersect $xs $list2 $accumulator)
            )
        )
        ($_ $accumulator)

    )

    )
)

(:union-set (->List List List List))
(=(union-set $list1 $list2)
    (remove-duplicates (append $list1 $list2))
)


(:cdr (-> List Atom))
(=(cdr ()) Nil)
(=(cdr (Cons $x $xs)) $xs)
(:car (-> List Atom))
(=(car ()) Nil)
(=(car (Cons $x $xs)) $x)


(=(check_tree_depth $data)
    (case $data (
            (($op $exp1 $exp2)
                
                 (+ 1 (max (check_tree_depth $exp1) (check_tree_depth $exp2)))
            )
            (($op $exp1) 1)
            ($_ 0)

        )
    )
)
(=(max $first-val $second-val)
    (if (> $first-val $second-val) $first-val $second-val
    )
)



(:get-children (-> Expression List List))
(= (get-children $exp $guard-set)
    (if (==(get-metatype $exp) Symbol)
        Nil
    (if (==(get-metatype $exp) Expression)
        (case $exp (
            (($op $exp1 $exp2)
                (let* (
                    ($type1 (get-metatype $exp1))
                    ($type2 (get-metatype $exp2))
                )
                (if (and (== $type1 Symbol) (== $type2 Symbol))
                    (append (Cons $exp1 (Cons $exp2 Nil)) $guard-set)
        
                    (if (and (== $type1 Symbol) (== $type2 Expression))
                        
                        (append (Cons $exp1 Nil) (get-children $exp2 $guard-set))
                    
                        (if (and (== $type1 Expression) (== $type2 Symbol))
                            (append (Cons $exp2 Nil) (get-children $exp1 $guard-set))
                            (append (get-children $exp1 $guard-set) (get-children $exp2 $guard-set))
                            
                        )
                    )

                )
            )
            )
    
            

        ))
        (ERROR the format is invalid)
    )
    
    )
)
(:get-guard-set (-> Expression List List))
(= (get-guard-set $exp)
        (case $exp (
            (($OP $exp1 $exp2)
            (let* (
                    ($type1 (get-metatype $exp1))
                    ($type2 (get-metatype $exp2)) 
                )
                (if (and (== $type1 Expression) (== $type2 Expression)) 
                    Nil
                    (if (== $OP AND)
                        (if (and (== $type1 Symbol) (== $type2 Symbol))
                            (Cons $exp1 (Cons $exp2 Nil))
                            (if (and (== $type1 Symbol) (== $type2 Expression))
                                (Cons $exp1 Nil)
                                (Cons $exp2 Nil)
                                
                            )
                        )
                        Nil
                    )
                )
            )
            )
            (($OP $exp)(
                (if (== NOT $exp) ($OP $exp) ERROR)
            ))
            ($exp (Cons $exp Nil))

        
    )
)
)
;; (=(get-dominant-set $exp)
;;     (case $exp (
;;             (($op $exp1 $exp2)
;;                 (if (== AND $op)
                   
                    
;;                 )
;;             )


;;         )
;;     )
;; )
(=(n-ary-and $exp)
    (case $exp (
            (Nil True)
            ((Cons $x $xs)
                (if (== $x True)
                    (n-ary-and $xs)
                    False
                )
            )

        )
    )
)

(=(n-ary-or $exp)
    (case $exp (
            (Nil False)
            ((Cons $x $xs)
                (if (== $x True)
                    True
                    (n-ary-or $xs)
                    
                )
            )

        )
    )
)
(=(is-subset $list1 $list2)
    (let* (
            ($min-list (if (> (length $list1) (length $list2)) $list2 $list1
                        ))

            ($max-list (if (> (length $list1) (length $list2)) $list1 $list2
                        ) )

        )(is-subset-ordered $min-list $max-list)
    )
   
)
(=(is-subset-ordered $min-list $max-list)
    (if (== $min-list Nil)
        True
        (case $min-list (
            ((Cons $x $xs)
                (if (member $x $max-list)
                    (is-subset-ordered $xs $max-list)
                    False
                )
            )


            )
        )
    )

)

(= (set-difference $set-a $set-b $accumulator)
    (case $set-a (
            ((Cons $x $xs)
                (if (member $x $set-b)
                    (set-difference $xs $set-b $accumulator)
                    (set-difference $xs $set-b (append $accumulator (Cons $x Nil)))
                )
            )
            ($_ $accumulator)

        )
    )
)
(= (is-consistent $set)
        (case $set (
                ((Cons $x $xs)
                    (if (member-not $x $xs)
                        False
                        (is-consistent $xs)
                    )
                )
                ($_ True)
            )

        )
)

;;!(is-subset (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))) (Cons 1 (Cons 2 (Cons 3  Nil))))
;;!(union-set (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))) (Cons 5 (Cons 6 (Cons 7 (Cons 1 Nil)))) )
!(set-difference (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))) (Cons 5 (Cons 6 (Cons 7 (Cons 1 Nil)))) Nil)
;; !(n-ary-or (Cons False (Cons True (Cons False (Cons True Nil)))))
;; !(n-ary-and (Cons True (Cons True (Cons False (Cons True Nil)))))

;; main = print $ mergeSort [3, 6, 2, 7, 1, 5, 4]
;; !(quickSort (Cons 2 (Cons 1 (Cons 3 Nil))))
;; !(quickSort (Cons 3 (Cons 6 (Cons 2 (Cons 7 (Cons 1 (Cons 5 (Cons 4 Nil))))))))
;;!(intersection (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))) (Cons 1 (Cons 4 (Cons 5 (Cons 6 Nil)))) Nil)
;;!(get-type True)
;; !(cdr (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))))
;; !(get-children (AND (OR x1 x2) (AND x3 x4)) Nil)
;;!(get-guard-set (AND (OR x1 x2) (AND x3 x4)))
;;!(intersect (Cons a (Cons b (Cons c Nil))) (Cons c (Cons d (Cons e (Cons f Nil)))) Nil)
;;!(check_tree_depth (AND (OR x1 x2) (AND x3 x4)))
;;!(member 1 Nil)
;;!(add-three 1 2 3)
;;!(append (Cons a (Cons b (Cons c Nil))) (Cons c Nil))