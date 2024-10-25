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
                     ((NOT $b) (if (== (get-metatype $b) Symbol) $expOriginal ())) ;If the head of the expression is NOT, $b should only be a literal for it to have a guardSet of (NOT $b). If $b is an expression, the guardSet is ()
                 )
             )
             (if (== $head OR) ()  ;an OR expression doesn't have a guardSet
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
(let $guardSetTuple (getGuardSetExp $exp $exp ()) 
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
; Function to get the guardSet and children from an expression.
(: getGsetAndChildren (-> Expression (Tuple Expression Expression)))  ; Expecting a tuple as the return type
(= (getGsetAndChildren $expr)
     (getGsetAndChildrenHelper $expr () ()))  ; Initial call with empty tuples for guardSets and children.

; Helper function to recursively find guardSets and children.
(: getGsetAndChildrenHelper (-> Expression (Tuple Expression Expression) Expression Expression))
(= (getGsetAndChildrenHelper $expr $literals $nonLiterals)
    (if (== $expr ())
        (tuple $literals $nonLiterals)  ; Return guardSets and children as a single tuple when the expression is empty.
        (let* (
            ($head (car-atom $expr))  ; Get the head of the expression.
            ($tail (cdr-atom $expr))   ; Get the tail of the expression.
            ($isLiteral (or (== (get-metatype $head) Symbol) (unify $head (NOT $_) True False)))  ; Check if head is a literal.
        )
        (if (or (== $head AND) (== $head OR))
            (getGsetAndChildrenHelper $tail $literals $nonLiterals)  ; Skip adding AND/OR to either tuple and continue with tail.
            (if $isLiteral
                (getGsetAndChildrenHelper $tail (concatTuple $literals ($head)) $nonLiterals)  ; Add literals to guardSets.
                (getGsetAndChildrenHelper $tail $literals (concatTuple $nonLiterals ($head)))  ; Add other expressions to children.
            )
        ))
    )
)

; Test cases for getGsetAndChildren function.

; Test case 1: Simple AND expression
; Input: (AND A B (OR A B) C)
; Expected Output: ((A B C) ((OR A B)))
(= (testGetGsetAndChildrenCase1)
    (let* 
        (
            ($expr (AND A B (OR A B) C))
            ($expectedGuardSets (A B C))
            ($expectedChildren ((OR A B)))
            ($result (getGsetAndChildren $expr))
        )
        (if (== $result (tuple $expectedGuardSets $expectedChildren))  ; Use tuple for comparison
            "Test Case 1 Passed"
            (str "Test Case 1 Failed: Expected " (tuple $expectedGuardSets $expectedChildren) " but got " $result)
        )
    )
)

; Test case 2: Simple OR expression
; Input: (OR A B (AND A B) C)
; Expected Output: ((A B C) ((AND A B)))
(= (testGetGsetAndChildrenCase2)
    (let* 
        (
            ($expr (OR A B (AND A B) C))
            ($expectedGuardSets (A B C))
            ($expectedChildren ((AND A B)))
            ($result (getGsetAndChildren $expr))
        )
        (if (== $result (tuple $expectedGuardSets $expectedChildren))  ; Use tuple for comparison
            "Test Case 2 Passed"
            (str "Test Case 2 Failed: Expected " (tuple $expectedGuardSets $expectedChildren) " but got " $result)
        )
    )
)

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

