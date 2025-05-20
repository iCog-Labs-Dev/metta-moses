;; Old implementation
; (= (fold $f $acc $tuple)
;     (if (== $tuple ()) $acc
;         (fold $f ($f $acc (car-atom $tuple)) (cdr-atom $tuple))
;     )
; )

(= (concat-tuple $xs $ys)
    (if (== $xs ()) $ys
        (let* (($head (car-atom $xs))  
               ($tail (cdr-atom $xs)) 
               ($tail-new (concat-tuple $tail $ys))  
              )
          (cons-atom $head $tail-new)  
        )
    )
)


(= (nary-gather-junctors $expr $prev)
    (
        if (== (get-metatype $expr) Expression)
                (
            let* (
                ($op (car-atom $expr)) 
                ($tuple (cdr-atom $expr))
                ($newChilderen (map-atom $tuple $t (nary-gather-junctors $t $op)))
                ($newTuple (foldl-atom $newChilderen () $acc $x (concat-tuple $acc $x)))
                ($tupleWithOp (cons-atom $op $newTuple))
            )
            (
                if (== $op $prev)
                    $newTuple
                    (
                        if (== $prev ())
                            $tupleWithOp
                            ($tupleWithOp)
                    )

            )
        )
        
        ($expr)
    )
)       


 
(= (gatherJunctors $expr) (nary-gather-junctors $expr ()))
