;; Partial function used to filter and keep only literals of an expression.
;; An expression (NOT A) is also considered as a literal in the case of boolean expression.
;; 'AND' and 'OR' are not considered as a literal.
(= (filterLiterals $exp)
        (if (== (get-metatype $exp) Symbol)
            (if (or (== $exp AND) (== $exp OR)) (empty) $exp)
            (if (== (car-atom $exp) NOT)
                $exp
                (empty))))


;; A function that takes an expression and returns it's guard sets
;; Definition: Guard set of a node is the set of literals in the node. 
;;                Only AND nodes have guard sets.
;; Example: (AND (NOT A) (NOT B) A) -> ( (NOT A) (NOT B) A)
(= (getGuardSet $exp)
    (if (== (car-atom $exp) OR)
        ()
        (getLiterals $exp)))

;; A function similar to the getGuardSet function but returns a
;;    non deterministic list instead of a collapsed atom.
;; Example: (AND (NOT A) (NOT B) A) -> [(NOT A), (NOT B), A]
(= (getGuardSetND $exp)
    (if (== (car-atom $exp) OR)
        (empty)
        (getLiteralsND $exp)))

;; A function to add a list of literals to a given expression
;;    and keep the uniqueness of the literals.
;; Example: input: $exp -> (AND A B (OR C D) E F), $elements -> (A B G)
;;          output: (AND A B E F G (OR C D))
(= (addLiterals $exp $elements)
   (let*
     (
        ($op (car-atom $exp))
        ($guardSet (getLiterals $exp))
        ($newGuardSet (concatTuple $guardSet $elements))
        ($newGuardSet' (collapse (unique (superpose $newGuardSet))))
        ($updatedSubExpression (concatTuple $newGuardSet' (getChildren $exp)))

        ($newExp (cons-atom $op $updatedSubExpression))
     )
     $newExp
   )
)

;; Partial function used to filter and keep only children of an expression.
;; A child of an expression is a subexpression that isn't a Symbol.
;; An expression (NOT A) is considered as a symbol in the case of boolean expression.
(= (filterChildren $exp)
        (if (== (get-metatype $exp) Symbol)
            (empty)
            (if (== (car-atom $exp) NOT)
                (empty)
                $exp)))

;; A function to return children of a given expression.
;; A child of a given expression is any subExpression.
;; An expression (NOT A) is also considered as a literal 
;;    in the case of boolean expression. Hence not included as a child.
(= (getChildren $exp)
     (case $exp
       (
         (() $exp)
         ((NOT $x) ())
         ($else (if (== (get-metatype $exp) Expression) (collapse (filterChildren (superpose $exp))) ())))))

;; A function to add a list of children to a given expression.
;; Example: input: $exp -> (AND A B (OR C D)), $children -> ((OR A B) (OR E F) (OR D))
;;          output: (AND A B (OR C D) (OR A B) (OR E F) (OR D))
(= (addChildren $exp $children)
   (let*
     (
        ($op (car-atom $exp))
        ($oldChildren (getChildren $exp))
        ($newChildren (concatTuple $oldChildren $children))
        ($updatedSubExpression (concatTuple (getLiterals $exp) $newChildren))

        ($newExp (cons-atom $op $updatedSubExpression))
     )
     $newExp
   )
)

;; A function to find return the literals of an expression
;;  the function performs returns the literals if the
;;  expression is either an AND or an OR.
;; Example: (AND (NOT A) (NOT B) A) -> ( (NOT A) (NOT B) A)
;;          (OR (NOT A) (NOT B) A) -> ( (NOT A) (NOT B) A)
;;          (NOT A) -> (NOT A)
(= (getLiterals $exp)
     (case $exp
       (
         (() $exp)
         ((NOT $x) $exp)
         ($else (if (== (get-metatype $exp) Expression) (collapse (filterLiterals (superpose $exp))) $exp)))))

;; A function similar to getLiterals function but returns a
;;    non deterministic list instead of a collapsed atom.
;; Example: (AND (NOT A) (NOT B) A) -> [(NOT A),(NOT B),A]
;;          (OR (NOT A) (NOT B) A) -> [(NOT A),(NOT B),A]
;;          (NOT A) -> [(NOT A)]
(= (getLiteralsND $exp)
     (case $exp
       (
         (() $exp)
         ((NOT $x) $exp)
         ($else (if (== (get-metatype $exp) Expression) (filterLiterals (superpose $exp)) $exp)))))

;;A function that will return both literals (Also called guard sets for AND nodes)
;;  and the children as a tuple ((...literals...), (...children...))
(= (getLiteralChildren $expr) ((getLiterals $expr) (getChildren $expr)))

;; Function to find common literals between a tuple and a nested tuple 
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
   (case $nestedTuple 
     ((() $nestedTuple)
      ($else
        (if (== (cdr-atom $nestedTuple) ())
            (car-atom $nestedTuple)
            (let*
              (
                ($first (car-atom $nestedTuple))
                ($tail (cdr-atom $nestedTuple)))
              (findCommonLiterals $first $tail)))))))
