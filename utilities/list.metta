(: List type)
(: Nil (List $t))
(: Cons (-> $t (List $t)  (List $t)))

 ; Function to find the length of a list
(: length (-> (List $t) Number))
(= (length Nil) 0)
(= (length (Cons $x $xs))
    (+ 1 (length $xs))
)
 ;; ! (length (Cons A (Cons B (Cons C Nil))))

 ;Function to find a list element given an index
(: index (-> Number (List $t) $t))
(= (index $a Nil) Nil)
 ;(= (index 0 (Cons $x $xs)) $x)
(= (index $a (Cons $x $xs))
    (if (== $a 0)
        $x
        (index (- $a 1) $xs)
    )
)
 ;; ! (index 2 (Cons A (Cons B (Cons C Nil))))

 ; Function to apply a partial function to every element in a list
(: map (-> Atom (List $t) (List $tt)))
(= (map $func Nil) Nil)
(= (map $func (Cons $x $xs))
    (Cons ($func $x) (map $func $xs))
)
 ;; (= (add1 $num) (+ $num 1))
 ;; ! (map add1 (Cons 1 (Cons 2 (Cons 3 Nil))))

 ; Function to check the existance of an element in a list given the comparing function
(: memberWith (-> (-> $t $t Bool) $t (List $t) Bool))
(= (memberWith $f $a Nil) False)
(= (memberWith $f $a (Cons $x $xs))
    (if ($f $a $x)
        True
        (memberWith $f $a $xs)
    )
)

 ; !(memberWith == 4 (Cons 1 (Cons 2 (Cons 3 Nil))))

 ; Function to check whether an Atom exists in a list
(: member (-> $t (List $t) Bool))
(= (member $a $list)
    (memberWith == $a $list)
)

! (member B (Cons A (Cons B (Cons C Nil))))

 ; Function to remove duplicates from a list
(: remove-duplicates (-> (List $t) (List $t)))
(= (remove-duplicates Nil) Nil)
(= (remove-duplicates (Cons $x $xs))
    (if (member $x $xs)
        (remove-duplicates $xs)
        (Cons $x (remove-duplicates $xs))
    )
)
 ;; ! (remove-duplicates (Cons A (Cons B (Cons B Nil))))

 ; Function to merge two lists
(: extend (-> (List $t) (List $t) (List $t)))
(= (extend Nil $ys) $ys)
(= (extend (Cons $x $xs) $ys) (Cons $x (join $xs $ys)))

 ; Function to partition the list
(: partition (-> Atom (List $t) ( (List $t) (List $t) )))
(= (partition $_ Nil) ( Nil Nil ))
(= (partition $pivot (Cons $x $xs))
    (let ($left $right) (partition $pivot $xs)
        (let* ( ($cond  (<= $x $pivot))
                 ;; (let* ( ($cond (lte $x $pivot))
                ( () (println! ($x "<= " $pivot "= " $cond)))
                ( () (println! ($left "---" $right)))
            )
        (if $cond
            ( (Cons $x $left) $right)
            ($left (Cons $x $right))
        )
)
)
)

 ;A function that checks if at least one True exists from a Boolean list
(: any (-> (List Bool) Bool))
(= (any Nil) False) ;; return False if the list is empty

(= (any (Cons True $xs)) ;; return True if the item is True
    True
)
(= (any (Cons False $xs)) ;;go to the next list item if False
    (any $xs)
)
 ;;test cases
 ; ! (any (Cons False Nil)) ;; False
 ; ! (any (Cons True Nil)) ;; True
 ; ! (any (Cons True(Cons False (Cons True Nil)))) ;; True

 ;A function that check if all of the elements are true from a Bool List.
(: all (-> (List Bool) Bool))

(= (all Nil) True) ;; return True if the list is empty

(= (all (Cons False $xs)) ;; return False if the item is False
    False
)
(= (all (Cons True $xs)) ;;go to the next list item if True
    (all $xs)
)
 ;; test cases
 ; ! (all (Cons False Nil)) ;; False
 ; ! (all (Cons True Nil)) ;; True
 ; ! (all (Cons False(Cons True (Cons False Nil)))) ;; False
 ; ! (all (Cons True(Cons True (Cons True Nil)))) ;; True

 ; A function to find and remove element from a list
(: findAndRemove (-> $t (List $t) (List $t)))
(= (findAndRemove $elem Nil) Nil)
(= (findAndRemove $elem (Cons $x $xs))
    (if (== $x $elem) (findAndRemove $elem $xs)
        (Cons $x (findAndRemove $elem $xs)))
)

 ;; Test cases
 ; !(findAndRemove 1 (Cons 1 (Cons 2 (Cons 3 Nil))))  ;; Output: [(Cons 2 (Cons 3 Nil))]
 ; !(findAndRemove 3 (Cons 1 (Cons 2 (Cons 3 Nil))))  ;; Output: [(Cons 1 (Cons 2 Nil))]
 ; !(findAndRemove 4 (Cons 1 (Cons 2 (Cons 3 Nil))))  ;; Output: [(Cons 1 (Cons 2 (Cons 3 Nil)))]

 ;A function to compare 2 lists
(: compare (-> (List $t) (List $t) (Bool)))
 ;; if both the lists are empty, They are the same.
(= (compare Nil Nil) True)
(= (compare (Cons $x $xs) (Cons $y $ys))
    (if (and (not (== $xs $ys)) (or (== $xs Nil) (== $ys Nil)))
        False
        (if (== $x $y)
            (compare $xs $ys)
            False
        )
)
)
 ;; Test cases
 ; !(compare (Cons 1 Nil) (Cons 1 Nil)) ;; Output: True
 ; !(compare (Cons "A" Nil) (Cons "a" Nil)) ;; Output: False
 ; !(compare (Cons 1 (Cons 2 (Cons 3 Nil))) (Cons 1 (Cons 2 (Cons 3 Nil)))) ;; Output: True
 ; !(compare (Cons 1 (Cons 2 (Cons 3 Nil))) (Cons 1  (Cons 2 Nil)) ) ;; Output: False

 ; QuickSort implementation
(: quickSort (-> List List))
(= (quickSort Nil) Nil)
(= (quickSort (Cons $x $xs))
    (let ($left $right) (partition $x $xs)
        (append (quickSort $left) (Cons $x (quickSort $right)))
    )
)
