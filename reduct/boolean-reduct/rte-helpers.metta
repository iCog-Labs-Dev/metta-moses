; a function to get the guardset of an n-ary expression as a tuple.
(= (getGuardSetExp $expr)
    (if (== $expr ())
        ()
        (if (== (car-atom $expr) OR)
            ()
            (collapse (let* (($tail (cdr-atom $expr))
                            ($x (superpose $tail)))
                            (if (== (get-metatype $x) Symbol)
                                $x 
                                (if (== (car-atom $x) NOT)
                                    $x
                                    (empty)
                                )
                            )
                    ) 
            )  
        )
    )
)

;a function to check whether an n-ary expression is consistent or not.
(= (isConsistentExp $exp)
(let $guardSetTuple (getGuardSetExp $exp) 
(if (== $guardSetTuple ()) True
        (let*
            (
                ($head (car-atom $guardSetTuple))
                ($tail (cdr-atom $guardSetTuple))
            )
        (if (isMember (Not $head) $tail) False
            (isConsistentExp $tail)
        ))
)
)   
)

;a helper function to the zeroConstraintSubsume function
;a function which checks if an Expression (a representation of a node) has a child or not
(= (nodeHasChildExp $node)
(let*
(
    ($head (car-atom $node))
    ($tail (cdr-atom $node))
    ($nodeType (get-metatype $node))
)
(if (== $nodeType Symbol) 
 False 
 (if (== $tail ()) 
     False 
     True
 )
)
)
)

;a function that will return Gardset(literals for OR) and the children as a tuple ((Gset), (Children))
(= (GsetandChildren $expr $literals $nonLiterals)
    (if (== $expr ())
        ($literals $nonLiterals)
        (let* 
            (   
                ($head (car-atom $expr))
                ($tail (cdr-atom $expr))
                ($isLiteral (or (== (get-metatype $head) Symbol) (unify $head (NOT $_) True False)))
            )
            (if (or (== $head AND) (== $head OR)) 
                (GsetandChildren $tail $literals $nonLiterals)

                (if $isLiteral 
                    (GsetandChildren $tail (concatTuple $literals ($head)) $nonLiterals)
                    (GsetandChildren $tail $literals (concatTuple $nonLiterals ($head)))        
                )
            )
        )
    )
)

(= (getGsetAndChildren $expr) (GsetandChildren $expr () ()))

; Function to find common literals between a tuple and a nested tuple
(= (findCommonLiterals $tuple $nestedTuple)
    (if (or (== $nestedTuple ()) (== $tuple ()))
        ()
        (let* 
            (
                ($first (car-atom $nestedTuple))
                ($tail (cdr-atom $nestedTuple))
                ($common (collapse (intersection (superpose $tuple) (superpose $first))))
            )
            (if (== $tail ())
                $common
                (findCommonLiterals $common $tail)
            )
        )
    )
)

; Function to find common literals in a nested tuple
(= (findCommon $nestedTuple)
    (if (or (== $nestedTuple ()) (== (cdr-atom $nestedTuple) ()))
        ()
        (let* (
            ($first (car-atom $nestedTuple))
            ($tail (cdr-atom $nestedTuple))
        )
        (findCommonLiterals $first $tail)
        )
    )
)
;function to find returin the Gardset of an expression
(= (getGuardSet $expr $acc)
    (if (== $expr ())
        $acc
        (let* 
            (
                ($head (car-atom $expr))
                ($tail (cdr-atom $expr))
                ($isLiteral (or (== (get-metatype $head) Symbol) (unify $head (NOT $_) True False)))
            )
            (if (or (== $head AND) (== $head OR)) 
                (getGuardSet $tail $acc)
                (if $isLiteral 
                    (getGuardSet $tail (concatTuple $acc ($head)))
                    (getGuardSet $tail $acc)
                )
            )
        )
    )
)

