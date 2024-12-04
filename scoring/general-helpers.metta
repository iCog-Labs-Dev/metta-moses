

(= (addToSpace $row $space) (add-atom $space $row))

(= (removeFromSpace $row $space) (remove-atom $space $row))

(: foldr (-> (-> $a $b $b) $b $c $d))
(= (foldr $f $i $xs)
   (if (== $xs ())
       $i
       (let* (($h (car-atom $xs))
              ($t (cdr-atom $xs))
              ($ft (foldr $f $i $t)))
         ($f $h $ft))))

; replace expersion with Truth value from the space
(= (replaceWithTruth $expr $space $spaceContent)
    (if (== (get-metatype $expr) Expression) 
        (let* (
            ($op (car-atom $expr))
            ($tuple (cdr-atom $expr)) 
            ($substitutedArgs (collapse (replaceWithTruth (superpose $tuple) $space $spaceContent)) )

            ($tupleWithOp (cons-atom $op $substitutedArgs))
        )
            $tupleWithOp
        )
         (unify $space ($expr $value) $value 'undefined') 
    )
)

;a function to evaluateuate the boolean expression
(= (evaluate $expr)
    (if (== (get-metatype $expr) Grounded) ; T/ F
        $expr
        (let* (
            ($op (car-atom $expr))
            ($tuple (cdr-atom $expr))
        )
            (if (== $op AND)
                (evaluateAnd $tuple)
                (if (== $op OR)
                    (evaluateOr $tuple)
                    (if (== $op NOT)
                        (not (evaluate $tuple))
                        ERROR
                    )
                )
            )
        )
    )
)

(= (evaluateOr $args)
    (if (== $args ())
        False
        (let* (
            ($first (car-atom $args))
            ($rest (cdr-atom $args))
        )
            (if (== (evaluate $first) True)
                True
                (evaluateOr $rest)
            )
        )
    )
)

(= (evaluateAnd $args)
    (if (== $args ())
        True
        (let* (
            ($first (car-atom $args))
            ($rest (cdr-atom $args))
        )
            (if (== (evaluate $first) False)
                False
                (evaluateAnd $rest)
            )
        )
    )
)

(= (length $tuple)
    (if (== $tuple ())
        0
        (+ 1 (length (cdr-atom $tuple)))
    )
)

(= (counter $expr)
    (if (== $expr ())
        0 
        (let* (
            ($head (car-atom $expr)) 
            ($tail (cdr-atom $expr)) 
        )
            (if (== (get-metatype $head) Expression) 
                (+ (counter $head) (counter $tail))
                (if (or (== $head AND) (== $head OR)) 
                    (+ 1 (counter $tail)) 
                    (counter $tail) 
                )
            )
        )
    )
)





