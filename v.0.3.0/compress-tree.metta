
(= (compressTree $tree $parentTreeType $accum)
    (if (not (== $tree ()))
    (if (== NONE $parentTreeType)
        (case $tree (
                (($op $exp1 $exp2)
                    ($op (compressTree $exp1 $op $accum) (compressTree $exp2 $op $accum))
                )
                ($_ $tree)

            )
        )
        (if (and (and (== (get-metatype $tree) Expression) (not (== $tree ()))) (not (== (car-atom $tree) NOT)))
            (let* (
                    ($head (car-atom $tree))
                    ($tail (cdr-atom $tree))
                    ($headIsJunctor (or (eq $head AND) (eq $head OR)))
                )
                (let () (println! (head ==> $head tail ==> $tail))
                (if $headIsJunctor
                    (if (eq $head $parentTreeType)
                        (let () (println! (head ==> $head tail ==> $tail))
                        (let* (
                                ($intermediateTree (iterate-and-expand $tree $tail ()))
                                ($intermediateHead (car-atom $intermediateTree))
                                ($intermediateTail (cdr-atom $intermediateTree))
                                ($nextIteration (changeToList (compressTree $intermediateTail $intermediateHead $accum)))
                                
                            )
                            (let () (println! (intermediateTree ==> $intermediateTree nextIteration ==> $nextIteration))
                                (cons-atom $intermediateHead $nextIteration)
                                ;;(unlist $accum $nextIteration)
                                ;;$accum
                            )
                            ;;$nextIteration

                        )
                    )
                        (compressTree $tail $head $accum)
                        
                    )
                    ;; (let* (
                    ;;     ($tailEval (compressTree $tail $parentTreeType $accum))
                    
                    ;; )  
                    ;;     (cons-atom (cons-atom $head $accum) $tailEval)
                    ;; ;;     (cons-atom $modifiedAccum $tailEval)
                    ;; )
                    (iterate-and-apply $tail $parentTreeType $accum)
                )
            )
            )
            $tree
    )
        
    )
        $tree
    )
)
(= (iterate-and-apply $list $parentTreeType $accum)
    (if (not (== $list ()))
        (let* (
            ($computedValue (compressTree (car-atom $list) $parentTreeType $accum))
            ($nextIter (iterate-and-apply (cdr-atom $list) $parentTreeType $accum))

        )
            (let () (println! (Inside iterate-and-apply computedValue ==> $computedValue nextIter ==> $nextIter))
                (cons-atom $computedValue $nextIter)
            )
            ;;($nextIter ())
        )
        $list
    )

)
(= (iterate-and-insert $accum $data)
    (let* (
            ($head (car-atom $accum))
            ($tail (cdr-atom $accum))
        )
        (if (== $data ())
            $accum
            (let $midValue (iterate-and-insert (cons-atom (car-atom $data) $tail) (cdr-atom $data))
                (cons-atom $head $midValue)
            )
        )
    )
)
(=(eq $a $b)
    (let* (
            ($typeA (get-metatype $a))
            ($typeB (get-metatype $b))
        )
        (if (== $typeA $typeB)
            (== $a $b)
            False
        )
    )
    
)
(= (changeToList $data)
    (if (== (get-metatype $data) Expression)
        $data
        ($data)
    )
)
(= (iterate-and-expand $tree $subTree $accum)
    (if (== $tree ())
        $accum
        (let $firstVal (car-atom $tree)
            (if (== $firstVal $subTree)
                (unlist $accum $subTree)
                (iterate-and-expand (cdr-atom $tree) $subTree (cons-atom $accum $firstVal))
                
            )
        )
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
;; (= (compressTree $tree $parentType $accum)
;;     (let () (println! (accum ==> $accum))
;;     (if (not (== $tree ()))
;;         (if (== NONE $parentType)
;;             (case $tree (
;;                 (($op $left $right)
;;                         (let* (
;;                                 ($leftRecursion (compressTree $left $accum $op))
;;                                 ($rightRecursion (compressTree $right $accum $op))
;;                                 ;;($opAccumulator (cons-atom $op $accum))
;;                                 ($rightAccumulated (cons-atom $rightRecursion $accum))
;;                                 ($leftAccumulated (cons-atom $leftRecursion $rightAccumulated))
;;                                 ($opAccumulator (cons-atom $op $leftAccumulated))
                            
;;                             )
;;                             $opAccumulator   
;;                         )
;;                 )

;;                 )
;;             )
;;             (let* (
;;                 ($head (car-atom $tree))
;;                 ($tail (cdr-atom $tree))
;;                 ($isHeadJunctor (or (== OR $head) (== AND $head)))
;;             )
;;             (let () (println! (head ==> $head tail ==> $tail))
;;                 (if $isHeadJunctor
;;                     (if (== $head $parentType)
;;                         (let* (
;;                                 ($newAccum (unlist $accum $tail))
;;                             )
;;                             (let () (println! (newAccum ==> $newAccum))
;;                                 (compressTree $tree $parentType $newAccum)
;;                             )
;;                         )
;;                         (compressTree $tail $head $accum)
;;                     )
;;                     (let $updatedAccum (cons-atom $head $accum)
;;                         (compressTree $tail $parentType $updatedAccum)
;;                     )

;;                 )
;;             )
;;             )
            
;;         )
;;     $accum
;; )
;; )
;; )
(= (gatherJunctor $tree $parentType $accum)
    (if (not (== $tree ()))
    (if (== $parentType NONE)
        (case $tree (
                (($op $left $right)
                        (let* (
                                ($leftRecursion (compressTree $left $accum $op))
                                ($rightRecursion (compressTree $right $accum $op))
                                ($rightAccumulated (cons-atom $rightRecursion $accum))
                                ($leftAccumulated (cons-atom $leftRecursion $rightAccumulated))
                                ($opAccumulator (cons-atom $op $leftAccumulated))
                            
                            )
                            $opAccumulator   
                        )
                )

            )
        )
        (let* (
                ($head (car-atom $tree))
                ($tail (cdr-atom $tree))
            )
            (if (== $head $parentType)
                (if (not (hasExpression $tail))
                    (unlist $accum $tail)
                    (iterate-and-apply $tail )
                )


            )
        )

    )
)
)
(= (hasExpression $exp)
    (if (== $exp ())
        False
        (let* (
                ($head (car-atom $exp))
                ($tail (cdr-atom $exp))
                ($isHeadExpression (== (get-metatype $head) Expression))

            )(if $isHeadExpression
                (let $secondHead (car-atom $head)
                    (if (== $secondHead NOT)
                        (hasExpression $tail)
                        True
                    )
                )
                (hasExpression $tail)
            )
        )
    )
)
(= (pop-helper $exp $accum)
    (if (== (cdr-atom $exp) ())
        $accum
        (let $head (car-atom $exp)
            (pop-helper (cdr-atom $exp) (cons-atom $head $accum))
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
(= (pop $exp)
    (reverse-list (pop-helper $exp ()) ())
)

;; !(compressTree (AND (AND x1 x2) x3) NONE ())
;; !(compressTree (AND (AND (AND x1 x2) (OR y1 y2)) c) NONE ())
;;!(compressTree (AND (AND (AND x1 x2) (OR y1 y2)) c) NONE ())
!(pop (1 2 3 4 5 6))
;; !(unlist () (AND (OR x1 x2) x3))
;; !(hasExpression (AND x1 xs))
;; !(hasExpression (AND (AND x1 xs) x3))
;; !(hasExpression (AND (NOT x2) x3))