

(= (changeToList $data)
    (if (== (get-metatype $data) Expression)
        $data
        ($data)
    )
)

(= (unlist $accum $list)
    (if (== $list ())
        $accum
        (let $head (car-atom $list)
            (unlist (cons-atom $head $accum) (cdr-atom $list))
        )
    )
)

(= (gatherJunctor $tree $parentType)
    (case $tree (
        (($op $left $right)
                (let* (
                    ($left-gather (gatherJunctor $left $op))
                    ($right-gather (gatherJunctor $right $op))
                    ($accum ())
                )
                    (if (== $parentType $op)
                        (reverse-list (unlist (unlist $accum (changeToList $left-gather)) (changeToList $right-gather)) ())
                        ((reverse-list (unlist (unlist ($op) (changeToList $left-gather)) (changeToList $right-gather)) ()))                
                    )
                )
        )
        ($_ $tree)
        )
    )
)



(=(reverse-list $exp $accum)
    (if (== $exp ())
        $accum 
        (let $head (car-atom $exp)
            (reverse-list (cdr-atom $exp) (cons-atom $head $accum))
        )
    )
)

;; !(gatherJunctor (AND A B) NONE)
;; !(unlist (1 2 3 4) ((1 2 3 4 5) 6 7 8 9))
;; !(gatherJunctor (AND (AND x1 x2) x3) NONE)
;; !(gatherJunctor (AND (AND (AND x1 x2) (OR y1 y2)) c) NONE)
;; !(gatherJunctor (AND (AND (AND x1 x2) (OR y1 y2)) c) NONE)
;; !(gatherJunctor (AND (AND (AND x1 x2) (OR y1 y2)) c) NONE)
;;!(gatherJunctor (AND A (OR B (OR C (AND D (OR E F))))) NONE)
;;!(pop (1 2 3 4 5 6))
;; !(unlist () (AND (OR x1 x2) x3))
;; !(hasExpression (AND x1 xs))
;; !(hasExpression (AND (AND x1 xs) x3))
;; !(hasExpression (AND (NOT x2) x3))