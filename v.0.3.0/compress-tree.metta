
;; (= (compressTree $tree $parentTreeType $accum)
;;     (if (== NONE $parentTreeType)
;;         (case $tree (
;;                 (($op $exp1 $exp2)
;;                     ($op (compressTree $exp1 $op $accum) (compressTree $exp2 $op $accum))
;;                 )
;;                 ($_ $tree)

;;             )
;;         )
;;         (if (and (and (== (get-metatype $tree) Expression) (not (== $tree ()))) (not (== (car-atom $tree) NOT)))
;;             (let* (
;;                     ($head (car-atom $tree))
;;                     ($tail (cdr-atom $tree))
;;                     ($headIsJunctor (or (eq $head AND) (eq $head OR)))
;;                 )
;;                 (let () (println! (head ==> $head tail ==> $tail))
;;                 (if $headIsJunctor
;;                     (if (eq $head $parentTreeType)
;;                         ;;(let () (println! (head ==> $head tail ==> $tail)))
;;                         (let* (
;;                                 ($intermediateTree (iterate-and-expand $tree $tail ()))
;;                                 ($intermediateHead (car-atom $intermediateTree))
;;                                 ($intermediateTail (cdr-atom $intermediateTree))
;;                                 ($nextIteration (changeToList (compressTree $intermediateTail $intermediateHead $accum)))
                                
;;                             )
;;                             (let () (println! (intermediateTree ==> $intermediateTree nextIteration ==> $nextIteration))
;;                                 ;;(cons-atom $intermediateHead $nextIteration)
;;                                 $nextIteration
;;                             )
;;                             ;;$nextIteration

;;                         )
;;                         (compressTree $tail $head $accum)
                        
;;                     )
;;                     ;; (let* (
;;                     ;;     ($tailEval (compressTree $tail $parentTreeType $accum))
                    
;;                     ;; )  
;;                     ;;     (cons-atom (cons-atom $head $accum) $tailEval)
;;                     ;; ;;     (cons-atom $modifiedAccum $tailEval)
;;                     ;; )
;;                     (iterate-and-apply $tail $parentTreeType $accum)
;;                 )
;;             )
;;             )
;;             $tree
;;     )
        
;;     )

;; )
;; (= (iterate-and-apply $list $parentTreeType $accum)
;;     (if (not (== $list ()))
;;         (let* (
;;             ($computedValue (compressTree (car-atom $list) $parentTreeType $accum))
;;             ($nextIter (iterate-and-apply (cdr-atom $list) $parentTreeType $accum))

;;         )
;;             (let () (println! (Inside iterate-and-apply computedValue ==> $computedValue nextIter ==> $nextIter))
;;                 (cons-atom $computedValue $nextIter)
;;             )
;;             ;;($nextIter ())
;;         )
;;         $list
;;     )

;; )
;; (= (iterate-and-expand $tree $subTree $accum)
;;     (if (== $tree ())
;;         $accum
;;         (let $firstVal (car-atom $tree)
;;             (if (== $firstVal $subTree)
;;                 (unlist $accum $subTree)
;;                 (iterate-and-expand (cdr-atom $tree) $subTree (cons-atom $accum $firstVal))
                
;;             )
;;         )
;;     )
    
;; )
(= (unlist $accum $list)
    (if (== $list ())
        $accum
        (let $head (car-atom $list)
            (unlist (cons-atom $head $accum) (cdr-atom $list))
        )
    )
)
(= (compressTree $tree $parentType $accum)
    (if (not (== $tree ()))
        (if (== NONE $parentType)
            (case $tree (
            (($op $left $right)
                    (let* (
                        ($leftRecursion (compressTree $left $accum $op))
                        ($rightRecursion (compressTree $right $accum $op))
                        ($opAccumulator (cons-atom $op $accum))
                        ($leftAccumulated (cons-atom $accum $left))
                        ($rightAccumulated (cons-atom $leftAccumulated $right))
                        
                    )
                        $rightAccumulated    
                    )
            )

            ))
            (let* (
                ($head (car-atom $tree))
                ($tail (cdr-atom $tree))
                ($isHeadJunctor (or (== OR $head) (== AND $head)))
            )
                (if $isHeadJunctor
                    (if (eq $head $parentType)
                        (let* (
                                ($newAccum (unlist $accum $tail))
                            )
                            (compressTree $tail $parentType $newAccum)

                        )
                        (compressTree $tail $head $accum)
                    )
                    (let $updatedAccum (cons-atom $head $accum)
                        (compressTree $tail $parentType $updatedAccum)
                    )

                )
            )
            
        )
    $accum
)
)
!(compressTree (AND (AND (AND x1 x2) (OR y1 y2)) c) NONE ())
(cons-atom (() AND (AND x1 x2) (OR y1 y2)) c)