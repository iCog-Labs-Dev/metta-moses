 ; a function to get the guardset of an n-ary expression as a tuple.
(= (getGuardSetExp $expOriginal $expRecursive $acc)
    (if (== (get-metatype $expOriginal) Symbol) ($expOriginal) ;if $exp is LITERAL, the guardSet is the set containing the literal itself
        (if (== $expRecursive ()) $acc
            (let*
                (
                    ($head (car-atom $expRecursive))
                    ($headIsExpression (== (get-metatype $head) Expression))
                    ($tail (cdr-atom $expRecursive))
                    ($tailIsExpression (== (get-metatype $tail) Expression))
                )
            (if (== $head NOT)
                (case $expOriginal
                    (
                        ( (NOT $b) (if (== (get-metatype $b) Symbol) $expOriginal ())) ;If the head of the expression is NOT, $b should only be a literal for it to have a guardSet of (NOT $b). If $b is an expression, the guardSet is ()
                    )
            )
        (if (== $head OR) () ;an OR expression doesn't have a guardSet
            (if (== $head AND) ; an AND expression has a guardSet which contains its literal and (NOT $literal) children
                (getGuardSetExp $expOriginal $tail $acc)
                (if $headIsExpression
                    (case $head
                        (
                            ( (NOT $a) (getGuardSetExp $expOriginal $tail (cons-atom $head $acc)))
                            ($else (getGuardSetExp $expOriginal $tail $acc))
                        )
                )
            (getGuardSetExp $expOriginal $tail (cons-atom $head $acc))
        )
)
)
)
)
)
)
)

 ;a function to check whether an n-ary expression is consistent or not.
(= (isConsistentExp $exp)
    (let $guardSetTuple (getGuardSetExpression $exp)
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

 ;; Partial function that is used with the getGuardSetExpression
 ;; It checks if an element in an expression can be a guardset or not
 ;; example (NOT A) is guard set and will be returned
 ;; example A is guard set and will be returned
 ;; example (AND A B) is not guard set and will not be returned
( = (isGuard $exp) (let*
        (
            ($type (get-metatype $exp))
        ) (if (== $type Symbol)
        (if (or (== AND $exp) (== OR $exp))
            (empty)
            $exp
        ) (if (== (car-atom $exp) NOT)
        $exp
        (empty)
    )
)
)
)

 ; getGuardSetExpression that takes an expression and returns it's guard sets
 ; uses the partial function isGuard to map over every element in the expression
 ;; example (AND (NOT A) (NOT B) A) -> ( (NOT A) (NOT B) A)
( = (getGuardSetExpression $exp) (if (== $exp ()) ()
        (if (== (get-metatype $exp) Expression) (let*
                (
                    ($head (car-atom $exp))
                ) (if (== $head OR)
                ()
                (collapse ( isGuard (superpose $exp))))
        )
    (collapse ( isGuard (superpose ($exp))))
))
)