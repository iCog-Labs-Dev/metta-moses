(= (compressTree $tree $parentTreeType $accum)
    (if (not (== $tree ()))
    (if (== NONE $parentTreeType)
        (case $tree (
                (($op $exp1 $exp2)
                    (let* (
                        ($newAccum (changeToList (compressTree $exp1 $op (cons-atom $op $accum))))
                        ($secondAccum (compressTree $exp2 $op $newAccum))

                    )
                        $secondAccum
                    )
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
                (let () (println! (head ==> $head tail ==> $tail accum ==> $accum))
                (if $headIsJunctor
                    (if (eq $head $parentTreeType)
                    ;;     (let () (println! (head ==> $head tail ==> $tail))
                    ;;     ;; (let* (
                    ;;     ;;         ($intermediateTree (compressTreeIterator $tail ()))
                    ;;     ;;         ;; ($intermediateHead (car-atom $intermediateTree))
                    ;;     ;;         ;; ($intermediateTail (cdr-atom $intermediateTree))
                    ;;     ;;         ;; ($nextIteration (changeToList (compressTree $intermediateTail $intermediateHead $accum)))
                                
                    ;;     ;;     )
                    ;;     ;;     (let () (println! (intermediateTree ==> $intermediateTree nextIteration ==> $nextIteration))
                    ;;     ;;         (cons-atom $intermediateTree $accum)
                    ;;     ;;         ;;(unlist $accum $nextIteration)
                    ;;     ;;         ;;$accum
                    ;;     ;;     )
                    ;;     ;;     ;;$nextIteration

                    ;;     ;; )
                    ;; )
                        ;;(compressTree $tail $head $accum)
                        (let $intermediateTree (compressTreeIterator $tail $parentTreeType ())
                            (let () (println! (intermediateTree ==> $intermediateTree))
                                (reverse-list (cons-atom $intermediateTree $accum))
                            )

                        )
                        
                        (let $intermediateTree (compressTreeIterator $tail $parentTreeType ($head))
                            (reverse-list (cons-atom $intermediateTree $accum))
                        )                        
                    )
                    ;; (let* (
                    ;;     ($tailEval (compressTree $tail $parentTreeType $accum))
                    
                    ;; )  
                    ;;     (cons-atom (cons-atom $head $accum) $tailEval)
                    ;; ;;     (cons-atom $modifiedAccum $tailEval)
                    ;; )
                    (compressTreeIterator $tail $parentTreeType $accum)
                )
            )
            )
            $accum
    )
        
    )
        $accum
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
(= (compressTreeIterator $tree $accum $parentType)
    (if (== $tree ())
        $accum
        ;; (reverse-list $accum)
        (let* (
            ($head (car-atom $tree))
            
        )
            (if (== (get-metatype $head) Expression)
                (let $nextIterVal (compressTree $head $parentType ())
                    (compressTreeIterator $tail (cons-atom $nextIterVal $accum))
                )
                (compressTreeIterator $tail (cons-atom $head $accum))
            )
        )
    )
)