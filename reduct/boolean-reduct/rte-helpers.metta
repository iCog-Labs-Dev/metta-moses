 ;; Partial function that is used with the getGuardSetExp
 ;; It checks if an element in an expression can be a guardset or not
 ;; returns empty if it isn't, returns the value itself if it's a guardset
 ;; example (NOT A) is guard set and will be returned
 ;; example A is guard set and will be returned
 ;; example (AND A B) is not guard set and will not be returned

(= (filterGuard $exp)
        (if (== (get-metatype $exp) Symbol)
            (if (or (== $exp AND) (== $exp OR))
                (empty)
                $exp)
            (if (== (car-atom $exp) NOT)
                $exp
                (empty))))

;; Partial function used to filter and keep only children of an expression.
;; A child of an expression is a subexpression that isn't a Symbol.
(= (filterChildren $exp)
        (if (== (get-metatype $exp) Symbol)
            (empty)
            (if (== (car-atom $exp) NOT)
                (empty)
                $exp)))

;; getGuardSetExp that takes an expression and returns it's guard sets
;; uses the partial function filterGuard to map over every element in the expression
;; example (AND (NOT A) (NOT B) A) -> ( (NOT A) (NOT B) A)
(= (getGuardSetExp $exp)
     (if (== $exp ())
       ()
       (if (== (get-metatype $exp) Expression)
           (if (== (car-atom $exp) OR)
               ()
               (collapse (filterGuard (superpose $exp))))
           (collapse (filterGuard (superpose ($exp)))))))

;; A function to return children of a given expression. A child of a given expression is any subExpression.
;; An atom of mettatype Symbol isn't considered to be a child of an expression.
(= (getChildren $exp)
     (if (== $exp ())
       ()
       (if (== (get-metatype $exp) Expression)
           (collapse (filterGuard (superpose $exp))))
           ()))

;; a helper function to the zeroConstraintSubsume function
;; a function which checks if an Expression (a representation of a node) has a child or not
(= (nodeHasChildExp $node)
    (let*
        (
          ($head (car-atom $node))
          ($tail (cdr-atom $node))
          ($nodeType (get-metatype $node)))

        (if (== $nodeType Symbol)
            False
            (if (== $tail ())
                False
                True))))

 ;a function that will return Gardset(literals for OR) and the children as a tuple ((Gset), (Children))
(= (GsetandChildren $expr $literals $nonLiterals)
    (if (== $expr ())
        ($literals $nonLiterals)
        (let*
            (
                ($head (car-atom $expr))
                ($tail (cdr-atom $expr))
                ($isLiteral (or (== (get-metatype $head) Symbol) (unify $head (NOT $_) True False))))
        (if (or (== $head AND) (== $head OR))
            (GsetandChildren $tail $literals $nonLiterals)

            (if $isLiteral
                (GsetandChildren $tail (concatTuple $literals ($head)) $nonLiterals)
                (GsetandChildren $tail $literals (concatTuple $nonLiterals ($head))))))))

(= (getGsetAndChildren $expr) (GsetandChildren $expr () ()))

 ; Function to find common literals between a tuple and a nested tuple
(= (findCommonLiterals $tuple $nestedTuple)
    (if (or (== $nestedTuple ()) (== $tuple ()))
        ()
        (let*
            (
                ($first (car-atom $nestedTuple))
                ($tail (cdr-atom $nestedTuple))
                ($common (collapse (intersection (superpose $tuple) (superpose $first)))))
        (if (== $tail ())
            $common
            (findCommonLiterals $common $tail)))))

;; Function to find common literals in a nested tuple
(= (findCommon $nestedTuple)
    (if (or (== $nestedTuple ()) (== (cdr-atom $nestedTuple) ()))
        ()
        (let*
          (
            ($first (car-atom $nestedTuple))
            ($tail (cdr-atom $nestedTuple)))
        (findCommonLiterals $first $tail))))

;; function to find returin the Gardset of an expression
(= (getGuardSet $expr $acc)
    (if (== $expr ())
        $acc
        (let*
            (
                ($head (car-atom $expr))
                ($tail (cdr-atom $expr))
                ($isLiteral (or (== (get-metatype $head) Symbol) (unify $head (NOT $_) True False))))
        (if (or (== $head AND) (== $head OR))
            (getGuardSet $tail $acc)
            (if $isLiteral
                (getGuardSet $tail (concatTuple $acc ($head)))
                (getGuardSet $tail $acc))))))
