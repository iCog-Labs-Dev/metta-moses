(list x 1)
(list x 2)
(list x 3)

(list y 2)
(list y 3)
(list y 4)
 ;a function to append an element to a list
(= (append $list-name $x) (
        add-atom &self (list $list-name $x)
    ))
 ;testcase
 ;! (append x 9)

 ;a function to return thenon-deterministic tree
(= (return-list $list-name) (
        match &self (list $list-name $y) $y
    ))
 ;testcase
 ;! (return-list x)

 ;a function to search and return an element
(= (search $list-name $x) (
        match &self (list $list-name $x) $x
    ))
 ;testcase
 ;! (search x 3)

 ;a function to return the intersection of lists
(= (intersect $list-name1 $list-name2 $intersectionList) (
        match &self (list $list-name1 $x) (
            match &self (list $list-name2 $y) (
                if (== $x $y) (add-atom &self (list w $x)) ()
            )
    )
))
 ;testcase
 ;! (intersect x y w)
 ;! (return-list w)

 ;a function to find and remove an element
(= (find-and-remove $list-name $val) (
        remove-atom &self (list $list-name $val)
    ))
 ;testcase
 ;! (find-and-remove x 2)
 ;! (return-list x)

 ;a function to find and replace an element
(= (find-and-replace $list-name $val $newVal) (
        (find-and-remove $list-name $val)
        (append $list-name $newVal)
    ))
 ;testcase
 ;! (find-and-replace x 9 8)
 ;! (return-list x)

 ;a function to return the union of two lists
(= (listUnion $list-name1 $list-name2 $merged-list) (
        (listUnion-helper $list-name1 $merged-list)
        (listUnion-helper $list-name2 $merged-list)
    ))
(= (listUnion-helper $list-name $merged-list) (
        match &self (list $list-name $x) (
            add-atom &self (list $merged-list $x)
        )
))
 ;testcase
 ;! (listUnion x y z)
 ;! (return-list z)

 ;a function to map over a list
(= (double $x) (+ $x $x))
(= (map $func $list-name) (
        match &self (list $list-name $x) ($func $x)
    ))
 ;testcase
 ;! (map double x)

 ;a function to check if an element is found in a list
(= (exists-in-list $x $list-name) (
        match &self (list $list-name $y) (
            if (== $x $y) True _
        )
))
 ;testcase
 ;! (exists-in-list 3 x)

 ;a function to check if an element is member of a tuple
(= (is-member $x $collapse)
    (if (== $collapse ()) False
        (let*
            (
                ($head (car-atom $collapse))
                ($tail (cdr-atom $collapse))
            )
        (
            if (== $x $head) True (is-member $x $tail)
        )
)
)
)
 ;testcase
 ;! (is-member 8 (1 5 3))

 ;a function to remove duplicates from a tuple
(= (remove-duplicates $tuple)
    (if (== $tuple ()) ()
        (let*
            (
                ($head (car-atom $tuple))
                ($tail (cdr-atom $tuple))
            )
        (if (is-member $head $tail)
            (remove-duplicates $tail)
            ( let*
                (
                    ($add-atom (add-atom &self (list NoDuplicatesList $head)))
                    ($remove-duplicate (remove-duplicates $tail))
                )
            ()
        )
)
)
)
)
 ;testcase
 ;! (remove-duplicates (1 2 3 4 4 5) )
 ;! (return-list NoDuplicatesList)
