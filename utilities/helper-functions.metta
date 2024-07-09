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
;; split (x:y:xs) = 
;;     let (left, right) = split xs
;;     in (x:left, y:right)
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
(:intersection (->List List List List))
(= (intersection $x $y $accumulator)
    (append $accumulator (Cons $x (Cons $y)))
)
(= (intersection (Cons $x $xs) (Cons $y $ys) $accumulator)
    (if (and (not (member $x $ys)) (not (member $y $xs)))
        (if (not (== $x $y))
            (intersection $xs $ys (append $accumulator (Cons $x (Cons $y))))
            (intersection $xs $ys $accumulator)
        )
        (intersection $xs $ys $accumulator)
    )
)
(:cdr (-> List Atom))
(=(cdr ()) Nil)
(=(cdr (Cons $x $xs)) $xs)
(:car (-> List Atom))
(=(car ()) Nil)
(=(car (Cons $x $xs)) $x)
(:zip (->List List Atom))
(=(zip $exp1 $exp2)
        (let* (($type-exp1 (get-metatype $exp1))
                ($type-exp2 (get-metatype $exp2))
                        )(if (and (== $type-exp1 Expression) (== $type-exp2 Expression))
                                (case $exp1 $exp2(
                                    ((()())())
                                    (((Cons $x $xs)(Cons $y $ys))(Cons $x (Cons $y (zip $exp1 $exp2))))
                                ))
                        )))
;; (:union (-> List List List))
;; ;; (=(union $set1 $set2)(

;; ;; ))
(=(check_tree_depth $data)
    (if (== (get-metatype $data) Expression)
        (case $data (
            (($OP $EXP1 $EXP2) (+ 1  (check_tree_depth $EXP1)))
            (($OP $EXP1) 1)
        ))
        0
))

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


;; main = print $ mergeSort [3, 6, 2, 7, 1, 5, 4]
;; !(quickSort (Cons 2 (Cons 1 (Cons 3 Nil))))
;; !(quickSort (Cons 3 (Cons 6 (Cons 2 (Cons 7 (Cons 1 (Cons 5 (Cons 4 Nil))))))))
;;!(intersection (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))) (Cons 1 (Cons 4 (Cons 5 (Cons 6 Nil)))) Nil)
;;!(get-type True)
;; !(cdr (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))))
!(check_tree_depth (AND (OR x1 x2) (AND x3 x4)))
!(zip (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))) (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))))