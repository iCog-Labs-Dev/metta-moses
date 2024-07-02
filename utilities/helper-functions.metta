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
;; ! (index 2 (Cons A (Cons B (Cons C Nil))))

;; (: map (-> Atom List List))
;; (= (map $func Nil) Nil)
;; (= (map $func (Cons $x $xs))
;;     (Cons ($func $x) (map $func $xs))
;; )
;; ! (map (+ 1) (Cons 1 (Cons 2 (Cons 3 Nil))))

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
(:intersection (->List List List))
(=(intersection $set1 $set2)(

))
(:union (->List List ))
(=(union $set1 $set2)(

))


;; main = print $ mergeSort [3, 6, 2, 7, 1, 5, 4]
;; !(quickSort (Cons 2 (Cons 1 (Cons 3 Nil))))
;; !(quickSort (Cons 3 (Cons 6 (Cons 2 (Cons 7 (Cons 1 (Cons 5 (Cons 4 Nil))))))))
;;!(get-type True)