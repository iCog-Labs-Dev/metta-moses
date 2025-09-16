(= (fold $f $acc $tuple)
    (if (== $tuple ()) $acc
        (fold $f ($f $acc (car-atom $tuple)) (cdr-atom $tuple))
    )
)


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


(: addAND (-> Expression Bool Expression))
(= (addAND $expr $isFinal)
    (if (and $isFinal (or (== (car-atom $expr) OR) (== (car-atom $expr) NOT)))
        (AND $expr)
        $expr
    )
)

(: addAND (-> Expression Expression))
(= (addAND $expr)
  (if (== (get-metatype $expr) Expression)
      (addAND $expr (car-atom $expr) ())
      (addAND $expr () ())
  ))

(: addAND (-> Expression Symbol Symbol Expression))
(= (addAND $expr $parent $prev)
    (case (get-metatype $expr)
        (
            (Symbol (if (or (or (or (== AND $expr) (== OR $expr)) (== NOT $expr))
                            (or (== $parent AND) (== $prev AND)))
                          $expr
                          (AND $expr)
                    )
            ) ;; track the parent instead of the previous one
            (Expression
                (let* (
                    (($h $t) (decons-atom $expr))
                    ($parentIsAND (== AND $parent))

                  )
                    (case ($h $parentIsAND)
                        (
                            ((NOT True) $expr)
                            ((NOT False) (AND $expr))
                            ((OR True) (map-atom $expr $x (addAND $x $h $h)))
                            ((OR False) (AND (map-atom $expr $x (addAND $x $h $h))))
                            ((AND $_) (map-atom $expr $x (addAND $x AND $h)))
                        )
                    )
                )
            )
            ($else $expr)
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
                ($newTuple (fold concat-tuple () (collapse (nary-gather-junctors (superpose $tuple) $op))))
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
