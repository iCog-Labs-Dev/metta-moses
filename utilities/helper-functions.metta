(: List type)
(: Nil List)
(: Cons (-> $a List List))

(: length (-> List Number))
(= (length Nil) 0)
(= (length (Cons $x $xs))
    (+ 1 (length $xs))
)
;; ! (length (Cons A (Cons B (Cons C Nil))))

(: index (-> Number List $a))
(= (index $a Nil) Nil)
;(= (index 0 (Cons $x $xs)) $x)
(= (index $a (Cons $x $xs))
    (if (== $a 0) 
        $x
        (index (- $a 1) $xs)
    )
)

(: member (-> $a List Bool))
(= (member $a Nil) False)
(= (member $a (Cons $x $xs))
    (if (== $a $x)
        True
        (member $a $xs)
    )
)
;; ! (member B (Cons A (Cons B (Cons C Nil))))

(: remove-duplicates (-> List List))
(= (remove-duplicates Nil) Nil)
(= (remove-duplicates (Cons $x $xs))
  (if (member $x $xs)
    (remove-duplicates $xs)
    (Cons $x (remove-duplicates $xs))
  )
)
;; ! (remove-duplicates (Cons A (Cons B (Cons B Nil))))

; Function to compare two Atoms (less than or equal to)
;; (: lte (-> Atom Atom Bool))
(= (lte $a $b)
    (let* ( ($type-a (get-metatype $a))
            ($type-b (get-metatype $b)))
        (if (== $type-a $type-b)
            True
            (if (== $type-a Grounded)
                True
                (if (and (== $type-a Symbol) (or (== $type-b Expression) (== $type-b Variable)))
                    True
                    (if (and (== $type-a Expression) (== $type-b Variable))
                        True
                        False ;; add other conditions
                    )
                ))
        )
    )
)


; Function to append two lists
(: append (-> List List List))
(= (append Nil $ys) $ys)
(= (append (Cons $x $xs) $ys) (Cons $x (append $xs $ys)))

; Function to partition the list
(: partition (-> Atom List ( List List )))
(= (partition $_ Nil) ( Nil Nil ))
(= (partition $pivot (Cons $x $xs))
    (let ($left $right) (partition $pivot $xs)
        ;; (if (<= $x $pivot)
        ;; (let* ( ($cond  (<= $x $pivot))
        (let* ( ($cond (lte $x $pivot))
                (() (println! ($x "<=" $pivot "=" $cond)))
                (() (println! ($left "---" $right)))
            )
        (if $cond ;(lte $x $pivot)
            ((Cons $x $left) $right)
            ($left (Cons $x $right))
        )
        )
    )
)
; QuickSort implementation
(: quickSort (-> List List))
(= (quickSort Nil) Nil)
(= (quickSort (Cons $x $xs))
    (let ($left $right) (partition $x $xs)
        (append (quickSort $left) (Cons $x (quickSort $right)))
    )
)
;; !(quickSort (Cons 2 (Cons 1 (Cons 3 Nil))))
;; !(quickSort (Cons "False" (Cons "A" (Cons "True" (Cons "B" Nil)))))
;; !(quickSort (Cons A (Cons True Nil)))
;; !(quickSort (Cons A (Cons B Nil)))
;; !(lte (a) $b)

; get-guard-set / dominant-set / branch-set


; #####################################################################################################################

;; (= (compare $a $b) (lte $a $b))
;; !(compare (True) A)

; Function to split a list into two halves
;; split :: [a] -> ([a], [a])
(: split (-> List (List List)))
;; split [] = ([], [])
(= (split Nil) (Nil Nil))
;; split [x] = ([x], [])
(= (split (Cons $x Nil)) ((Cons $x Nil) Nil))

(= (split (Cons $x (Cons $y $xs)))
    (let ($left $right) (split $xs)
        ((Cons $x $left) (Cons $y $right))
    )
)

; Function to merge two sorted lists into one sorted list
;; merge :: (Ord a) => [a] -> [a] -> [a]
(: merge (-> List List List))
;; merge [] ys = ys
(= (merge Nil $ys) $ys)
;; merge xs [] = xs
(= (merge $xs Nil) $xs)
;; merge (x:xs) (y:ys)
;;     | x <= y    = x : merge xs (y:ys)
;;     | otherwise = y : merge (x:xs) ys
(= (merge (Cons $x $xs) (Cons $y $ys))
    (if (<= $x $y)
        (Cons $x (merge $xs (Cons $y $ys)))
        (Cons $y (merge (Cons $x $xs) $ys))
    )
)

; MergeSort implementation
;; mergeSort :: (Ord a) => [a] -> [a]
(: mergeSort (-> List List))
;; mergeSort [] = []
(= (mergeSort Nil) Nil)
;; mergeSort [x] = [x]
(= (mergeSort (Cons $x Nil)) (Cons $x Nil))
;; mergeSort xs = 
;;     let (left, right) = split xs
;;     in merge (mergeSort left) (mergeSort right)
(= (mergeSort $xs)
    (let ($left $right) (split $xs)
        (merge (mergeSort $left) (mergeSort $right))
    )
)
(= (member-not $elem $list) ;;checks if the member not member is working or not
    (case $list(
        (Nil False) ;;Checks if $x is repeated in $y
        ((Cons $x $xs)
            (if (or (== (NOT $x) $elem) (== $x (NOT $elem)))
                True
                (member-not $elem $xs)
            )
        )
    ))
)

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
(=(intersect $list1 $list2 $accumulator)
    (if (or (== $list1 Nil) (== $list2 Nil))
        $accumulator
        (case ($list1 $list2)
            (
                (((Cons $x $xs) (Cons $y $ys))
                        (let* (
                            ($is-x-member (member $x $ys))
                            ($is-y-member (member $y $xs))
                            )(if (and (== $is-x-member True) (== $is-y-member True))
                                (if (== $x $y)
                                    (intersect $xs $ys (append $accumulator (Cons $x Nil)))
                                    (intersect $xs $ys (append $accumulator (Cons $x (Cons $y Nil))))
                                )
                                (if (and (== $is-x-member True) (== $is-y-member False))
                                    (intersect $xs $ys (append $accumulator (Cons $x Nil)))
                                    (if (and (== $is-x-member False) (== $is-y-member True))
                                        (intersect $xs $ys (append $accumulator (Cons $y Nil)))
                                        (intersect $xs $ys $accumulator)
                                    )
                                )

                            )
                        )

      
                )
            )
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
            ($exp $exp)

        
    )
)
)
(=(get-dominant-set $exp)
    (case $exp (
            (($op $exp1 $exp2)
                (if (== AND $op)
                   
                    
                )
            )


        )
    )
)
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

!(is-subset (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))) (Cons 1 (Cons 2 (Cons 3  Nil))))
;;!(union-set (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))) (Cons 5 (Cons 6 (Cons 7 (Cons 1 Nil)))) )
;;!(intersect (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))) (Cons 5 (Cons 6 (Cons 7 (Cons 1 Nil)))) Nil)
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