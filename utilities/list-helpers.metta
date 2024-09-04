; Function to find the length of a list
(: length (-> (List $t) Number))
(= (length Nil) 0)
(= (length (Cons $x $xs))
    (+ 1 (length $xs))
)

 ; Function to retirive the head of given list
(: (-> (List $t) $t))
(= (head Nil) Nil)
(= (head (Cons $x $xs)) $x)

 ; Function to retrive the tail of given list
(: (-> (List $t) (List $t)))
(= (tail Nil) Nil)
(= (tail (Cons $x $xs)) $xs)

; Function to find a list element given an index
(: index (-> Number (List $t) $t))
(= (index $a Nil) Nil)
 ;(= (index 0 (Cons $x $xs)) $x)
(= (index $a (Cons $x $xs))
    (if (== $a 0)
        $x
        (index (- $a 1) $xs)
    )
)

; Function to apply a partial function to every element in a list
(: map (-> Atom (List $t) (List $tt)))
(= (map $func Nil) Nil)
(= (map $func (Cons $x $xs))
    (Cons ($func $x) (map $func $xs))
)

; Function to apply a function to each element in a list, and accumulate the results in a list, merge them with cons-atom
(: consMap (-> Atom $ac (List $t) (List $tt)))
(= (consMap $func $ac Nil) $ac)
(= (consMap $func $ac (Cons $x $xs))
		(let $result ($func $x)
			(consMap $func (cons-atom $result $ac) $xs)
		)
)

; Function to check the existance of an element in a list given the comparing function
(: memberWith (-> (-> $t $t Bool) $t (List $t) Bool))
(= (memberWith $f $a Nil) False)
(= (memberWith $f $a (Cons $x $xs))
    (if ($f $a $x)
        True
        (memberWith $f $a $xs)
    )
)

; Function to check whether an Atom exists in a list
(: member (-> $t (List $t) Bool))
(= (member $a $list)
    (memberWith == $a $list)
)

; Function to remove duplicates given a list and a compare compareFunc.
(= (removeDuplicates $compareFunc Nil) Nil)
(= (removeDuplicates $compareFunc (Cons $x $xs))
    (if ($compareFunc $x $xs)
        (removeDuplicates $compareFunc $xs)
        (Cons $x (removeDuplicates $compareFunc $xs))
    )
)

; Function to merge two lists
(: extend (-> (List $t) (List $t) (List $t)))
(= (extend Nil $ys) $ys)
(= (extend (Cons $x $xs) $ys) (Cons $x (extend $xs $ys)))

(: ++ (-> (List $t) (List $t) (List $t)))
(= ($list1 ++ $list2) (extend $list1 $list2))

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

; A function that checks if at least one True exists from a Boolean list
(: any (-> (List Bool) Bool))
(= (any Nil) False) ;; return False if the list is empty

(= (any (Cons True $xs)) ;; return True if the item is True
    True
)
(= (any (Cons False $xs)) ;;go to the next list item if False
    (any $xs)
)

; A function that check if all of the elements are true from a Bool List.
(: all (-> (List Bool) Bool))

(= (all Nil) True) ;; return True if the list is empty

(= (all (Cons False $xs)) ;; return False if the item is False
    False
)
(= (all (Cons True $xs)) ;;go to the next list item if True
    (all $xs)
)

; A function to find and remove element from a list
(: findAndRemove (-> $t (List $t) (List $t)))
(= (findAndRemove $elem Nil) Nil)
(= (findAndRemove $elem (Cons $x $xs))
    (if (== $x $elem) (findAndRemove $elem $xs)
        (Cons $x (findAndRemove $elem $xs)))
)

 ;;function to find a given node from a list of nodes and remove it. Similar to findAndRemove implementation of for the lists.
(: findAndRemoveTree (-> Tree (List Tree) (List Tree)))
(= (findAndRemoveTree $elem Nil) Nil)
(= (findAndRemoveTree $elem (Cons $x $xs))
    (if (isNodeEqual $x $elem)
        (findAndRemoveTree $elem $xs)
        (Cons $x (findAndRemoveTree $elem $xs))
    )
)

; A function to compare 2 lists
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

 ; QuickSort implementation
(: quickSort (-> List List))
(= (quickSort Nil) Nil)
(= (quickSort (Cons $x $xs))
    (let ($left $right) (partition $x $xs)
        (extend (quickSort $left) (Cons $x (quickSort $right)))
    )
)

(: checkNotDuplicated (-> (List $t) Bool))
(= (checkNotDuplicated $list)
    (case $list
        (
            (Nil True)
            ( (Cons $x $xs)
                (if (member $x $xs)
                    False
                    (checkNotDuplicated $xs)
                )
        )
)
)
)

(: checkNotInverseDuplicated (-> (List $t) Bool))
(= (checkNotInverseDuplicated $list)
    (case $list
        (
            (Nil True)
            ( (Cons $x $xs)
                (if (member-not $x $xs)
                    False
                    (checkNotInverseDuplicated $xs)
                )
        )
)
)
)

(: intersect (-> (List $t) (List $t) (List $t) (List $t)))
(=(intersect $list1 $list2 $accumulator)
    (if (and (isEmpty $list1) (isEmpty $list2))
        $accumulator
        (case $list1 (
                ( (Cons $x $xs)
                    (if (== (member $x $list2) True)
                        (intersect $xs $list2 (extend $accumulator (Cons $x Nil)))
                        (intersect $xs $list2 $accumulator)
                    )
            )
        (Nil $accumulator)
    )
)
)
)

; Function that takes two lists and an accumulator then returns the accumulator containing elements from the first list that are not found in the second list
(: setDifference (-> (-> $t (List $t) Bool) (List $t) (List $t) (List $t) (List $t)))
(= (setDifference $compareFunc Nil Nil $accumulator) Nil)
(= (setDifference $compareFunc (Cons $x $xs) Nil $accumulator) (Cons $x $xs))
(= (setDifference $compareFunc Nil (Cons $y $ys) $accumulator) $accumulator)
(= (setDifference $compareFunc (Cons $x $xs) (Cons $y $ys) $accumulator)
    (if ($compareFunc $x (Cons $y $ys))
        (setDifference $compareFunc $xs (Cons $y $ys) $accumulator)
        (setDifference $compareFunc $xs (Cons $y $ys) (extend $accumulator (Cons $x Nil)))
    )
)

(: setUnion (-> (-> $t (List $t) Bool) (List $t) (List $t) (List $t)))
(= (setUnion $compareFunc $list1 $list2)
    (removeDuplicates $compareFunc (extend $list1 $list2))
)

(: isSubset (-> (List $t) (List $t) Bool))
(= (isSubset $list1 $list2)
    (let* (
            ($min-list (if (> (length $list1) (length $list2)) $list2 $list1
                ))
        ($max-list (if (> (length $list1) (length $list2)) $list1 $list2
            ) )
) (isSubsetOrdered $min-list $max-list)
)

)

(: isSubsetOrdered (-> (List $t) (List $t) Bool))
(= (isSubsetOrdered $min-list $max-list)
    (if (== $min-list Nil)
        True
        (case $min-list (
                ( (Cons $x $xs)
                    (if (member $x $max-list)
                        (isSubsetOrdered $xs $max-list)
                        False
                    )
            )
    )
)
)
)

(: containsTerminalAndNode (-> (List Tree) Bool))
(= (containsTerminalAndNode Nil) False)
(= (containsTerminalAndNode (Cons $x $xs))
    (case $x
        (
            ( (TreeNode (Value $value $truthValue AND) (Cons $y Nil) Nil) True)
            ( (TreeNode $nodeValue $guardSet $children) (containsTerminalAndNode $xs))
        )
)
)

 ; A function to foldLeft function
(: foldLeft (-> (-> $t $t $t) $t (List $t) $t))
(= (foldLeft $func $acc Nil) $acc)
(= (foldLeft $func $acc (Cons $x $xs)) (foldLeft $func ($func $acc $x) $xs))

 ; an Abstract function to call foldLeft function and pass the first element as the initial accumulator (does not require an accumulator)
(: foldl (-> $t $t $t) (List $t) $t)
(= (foldl $func Nil)Nil)
(= (foldl $func (Cons $x $xs))
    (foldLeft $func $x $xs)
)

 ;Function to remove an element at a given index in a List.
(: removeAtIndex (-> Number (List $t) (List $t)))
(= (removeAtIndex $a Nil) Nil)

(= (removeAtIndex $a (Cons $x $xs))
    (if (== $a 0)
         $xs
        (Cons $x (removeAtIndex (- $a 1) $xs))
    )
)

 ;A Function to replace an element at a given index in a List.
(: replaceAtIndex (-> Number $t (List $t) (List $t)))
(= (replaceAtIndex $a $t Nil) Nil)

(= (replaceAtIndex $a $t (Cons $x $xs))
    (if (== $a 0)
        (Cons $t  $xs)
    (Cons $x (replaceAtIndex (- $a 1) $t $xs))
    )
)
(: setInsert (-> Atom (List $t) $t (List $t)))
(= (setInsert $compareFunc Nil $data) (Cons $data Nil))
(= (setInsert $compareFunc (Cons $x $xs) $data)
    (if ($compareFunc $x $data)
        (Cons $x $xs)
        (if (memberWith $compareFunc $data $xs)
            (Cons $x $xs)
            (Cons $data (Cons $x $xs))
        )
    )
)
