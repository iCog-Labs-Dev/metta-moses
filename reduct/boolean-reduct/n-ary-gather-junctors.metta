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


; (: addAND (-> Expression Symbol Bool Expression))
(= (addAND $expr $prev $isFinal)
    (if (and $isFinal (or (== (car-atom $expr) OR) (== (car-atom $expr) NOT)))
        (AND $expr)
        $expr
    )
)

(= (addAND $expr)
  (if (== (get-metatype $expr) Expression)
      (addAND $expr (car-atom $expr))
      (addAND $expr ())
  )
  ; (addAND $expr (car-atom $expr))
  )

(= (addAND $expr $parent)
    (case (get-metatype $expr)
        (
            (Symbol (if (or (or (or (== AND $expr) (== OR $expr)) (== NOT $expr)) (== $parent AND)) $expr (AND $expr))) ;; track the parent instead of the previous one
            (Expression
                (let* (
                  ($h (car-atom $expr)) 
                  ($parentIsAND (== AND $parent))
                  )
                    (case ($h $parentIsAND)
                        (
                            ; (NOT (AND $expr))
                            ; (OR (AND (collapse (addAND (superpose $expr)))))
                            ; (AND (collapse (addAND (superpose $expr))))
                            ;; (AND (OR A B) A)
                            ;; (AND (NOT A))
                            ((NOT True) (map-atom $expr $x (addAND $x $h)))
                            ((NOT False) (AND $expr))
                            ((OR True) (map-atom $expr $x (addAND $x $h)))
                            ((OR False) (AND (map-atom $expr $x (addAND $x $h))))
                            ((AND $_) (map-atom $expr $x (addAND $x $parent)))
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
