; Function to find the length of a list
(:length (-> (List $t) Number))
(= (length Nil) 0)
(= (length (Cons $x $xs))
    (+ 1 (length $xs))
)

; Function to find a list element given an index
(:index (-> Number (List $t) $t))
(= (index $a Nil) Nil)
 ;(= (index 0 (Cons $x $xs)) $x)
(= (index $a (Cons $x $xs))
    (if (== $a 0)
        $x
        (index (- $a 1) $xs)
    )
)

; Function to apply a partial function to every element in a list
(:map (-> Atom (List $t) (List $tt)))
(= (map $func Nil) Nil)
(= (map $func (Cons $x $xs))
    (Cons ($func $x) (map $func $xs))
)

; Function to check the existance of an element in a list given the comparing function
(:memberWith (-> (-> $t $t Bool) $t (List $t) Bool))
(= (memberWith $f $a Nil) False)
(= (memberWith $f $a (Cons $x $xs))
    (if ($f $a $x)
        True
        (memberWith $f $a $xs)
    )
)

; Function to check whether an Atom exists in a list
(:member (-> $t (List $t) Bool))
(= (member $a $list)
    (memberWith == $a $list)
)

; Function to remove duplicates from a list
(:removeuplicates (-> (List $t) (List $t)))
(= (removeuplicates Nil) Nil)
(= (removeuplicates (Cons $x $xs))
    (if (member $x $xs)
        (removeuplicates $xs)
        (Cons $x (removeuplicates $xs))
    )
)

; Function to merge two lists
(:extend (-> (List $t) (List $t) (List $t)))
(= (extend Nil $ys) $ys)
(= (extend (Cons $x $xs) $ys) (Cons $x (extend $xs $ys)))

; Function to partition the list
(:partition (-> Atom (List $t) ( (List $t) (List $t) )))
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
(:any (-> (List Bool) Bool))
(= (any Nil) False) ;; return False if the list is empty

(= (any (Cons True $xs)) ;; return True if the item is True
    True
)
(= (any (Cons False $xs)) ;;go to the next list item if False
    (any $xs)
)

; A function that check if all of the elements are true from a Bool List.
(:all (-> (List Bool) Bool))

(= (all Nil) True) ;; return True if the list is empty

(= (all (Cons False $xs)) ;; return False if the item is False
    False
)
(= (all (Cons True $xs)) ;;go to the next list item if True
    (all $xs)
)

; A function to find and remove element from a list
(:findAndRemove (-> $t (List $t) (List $t)))
(= (findAndRemove $elem Nil) Nil)
(= (findAndRemove $elem (Cons $x $xs))
    (if (== $x $elem) (findAndRemove $elem $xs)
        (Cons $x (findAndRemove $elem $xs)))
)

; A function to compare 2 lists
(:compare (-> (List $t) (List $t) (Bool)))
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
(:quickSort (-> List List))
(= (quickSort Nil) Nil)
(= (quickSort (Cons $x $xs))
    (let ($left $right) (partition $x $xs)
        (extend (quickSort $left) (Cons $x (quickSort $right)))
    )
)

(:checkNotDuplicated (-> (List $t) Bool))
(= (checkNotDuplicated $list)
    (case $list
        (
            (Nil True)
            ((Cons $x $xs)
                (if (member $x $xs)
                    False
                    (checkNotDuplicated $xs)
                )
            )
        )
    )
)

(:checkNotInverseDuplicated (-> (List $t) Bool))
(= (checkNotInverseDuplicated $list)
    (case $list
        (
            (Nil True)
            ((Cons $x $xs)
                (if (member-not $x $xs)
                    False
                    (checkNotInverseDuplicated $xs)
                )
            )
        )
    )
)

(:intersect (-> (List $t) (List $t) (List $t) (List $t)))
(=(intersect $list1 $list2 $accumulator)
    (if (and (isEmpty $list1) (isEmpty $list2))
        $accumulator
        (case $list1 (
                ((Cons $x $xs)
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

(:unionSet (-> (List $t) (List $t) (List $t) (List $t)))
(=(unionSet $list1 $list2)
    (removeDuplicates (extend $list1 $list2))
)

(:isSubset (-> (List $t) (List $t) Bool))
(=(isSubset $list1 $list2)
    (let* (
            ($min-list (if (> (length $list1) (length $list2)) $list2 $list1
                        ))
            ($max-list (if (> (length $list1) (length $list2)) $list1 $list2
                        ) )
        )(isSubsetOrdered $min-list $max-list)
    )
   
)

(:isSubsetOrdered (-> (List $t) (List $t) Bool))
(=(isSubsetOrdered $min-list $max-list)
    (if (== $min-list Nil)
        True
        (case $min-list (
            ((Cons $x $xs)
                (if (member $x $max-list)
                    (isSubsetOrdered $xs $max-list)
                    False
                )
            )
            )
        )
    )
)

(:hasTerminalNode (-> Tree Bool))
(= (hasTerminalNode NilNode) False)
(= (hasTerminalNode $node) (
    case $node (
        ( (TreeNode (Value $value $truthValue AND) NilNode NilNode $guardSet NilList) (
            unify $guardSet (ConsTree $singleNode NilList) True False
        ) )
        ( (TreeNode $nodeValue $left $right $guardSet $children) ( or (hasTerminalNode $left) (hasTerminalNode $right)) )
    )
))

(:containsTerminalNode (-> TreeList Bool ))
(= (containsTerminalNode NilList) False)
(= (containsTerminalNode $treeList) (
    case $treeList (
        ( (ConsTree $t $ts) (or (hasTerminalNode $t) (trace! (evaluating $ts ) (containsTerminalNode $ts))) )
        ; ($else (Invalid Expression--- $else))
    )
))