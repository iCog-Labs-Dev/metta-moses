 ; functions to remove unnecessary OR's from an expression
 ;Example (OR A) --> A
 ;Example (OR (OR B (OR C))) --> (OR B C)
(= (cutUnnecessaryOr $expresion)
    (if (== $expresion ()) ()
        (let* (
                ($head (car-atom $expresion))
                ($tail (cdr-atom $expresion))
                ($type (get-metatype $head))
                ($newtail (cutUnnecessaryOr $tail))
            )
         ; check if head is an expression and apply orCut to head as well
        (if (== $type Expression)
            (cons-atom (cutUnnecessaryOr $head) $newtail)
            ( if (== OR $head) (let* (
                        ($subhead (car-atom $newtail))
                        ($subtail (cdr-atom $newtail))
                    ) (if (== $subtail ())
                    $subhead
                    (cons-atom $head $newtail)
                )
        )
    (cons-atom $head $newtail))
)
)
)
)

 ;; Test 1:
! (assertEqual (cutUnnecessaryOr (OR (AND A B) (AND C D)))
    (OR (AND A B) (AND C D)))

 ;; Test 2:
! (assertEqual (cutUnnecessaryOr (OR (AND (OR X Z) (OR A B))))
    (AND (OR X Z) (OR A B)))

 ;; Test 3:
! (assertEqual (cutUnnecessaryOr (OR A))
    A)

 ;; Test 4:
! (assertEqual (cutUnnecessaryOr (OR (OR A)))
    A)

 ; Test 5:
! (assertEqual (cutUnnecessaryOr (OR (OR A (OR B))))
    (OR A B))