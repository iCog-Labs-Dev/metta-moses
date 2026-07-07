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


; (: addAND (-> Expression Bool Expression))
(= (addAND $expr $isFinal)
    (if (and $isFinal (or (== (car-atom $expr) OR) (== (car-atom $expr) NOT)))
        (AND $expr)
        $expr
    )
)

; (: addAND (-> Expression Expression))
(= (addAND $expr)
  (if (== (get-metatype $expr) Expression)
      (addAND $expr (car-atom $expr) ())
      (addAND $expr () ())
  ))

; (: addAND (-> Expression Symbol Symbol Expression))
(= (addAND $expr $parent $prev)
    (if (== (get-metatype $expr) Expression)
        (let* (
            (($h $t) (decons-atom $expr))
            ($parentIsAND (== AND $parent))

          )
            (if (== $h NOT)
                (if $parentIsAND $expr (AND $expr))
                (if (== $h OR)
                    (if $parentIsAND
                        (map-atom $expr $ex (addAND $ex $h $h))
                        (AND (map-atom $expr $ex (addAND $ex $h $h))))
                    (if (== $h AND)
                        (map-atom $expr $ex (addAND $ex AND $h))
                        (if (== $t ()) (addAND $h () ()) (AND)))))
        )
        ;; non-Expression = leaf (Symbol, Variable or Grounded):
        ;; junctor symbols and AND-parented leaves stay bare, others wrap
        (if (or (or (or (== AND $expr) (== OR $expr)) (== NOT $expr))
                (or (== $parent AND) (== $prev AND)))
              $expr
              (AND $expr)
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
                ($newTuple (fold concat-tuple () (map-atom $tuple $tp (nary-gather-junctors $tp $op))))
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
