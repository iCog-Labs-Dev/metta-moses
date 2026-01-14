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
   (if (== (get-metatype $exp) Expression)
    (let ($h $t) (if (not (== $exp ())) (decons-atom $exp) (() ()))
      (eval (if-decons-expr-custom $exp $h $t
          (if (== $h OR)
              ()               
              (getLiterals $exp))
          $exp))
    )
    $exp)
)


;; A function similar to the getGuardSet function but returns a
;;    non deterministic list instead of a collapsed atom.
;; Example: (AND (NOT A) (NOT B) A) -> [(NOT A), (NOT B), A]
(= (getGuardSetND $exp)
   (if (or (not (== $exp ())) (== (get-metatype $exp) Expression))
      (let*
        (
         (($h $t) (decons-atom $exp))
         ($then (if (== $h OR) (empty) (getLiteralsND $exp)))
         ($result (if-decons-expr-custom $exp $h $t $then $exp))
        )
        $result
      )
      $exp
    )
)  

(= (addLiterals $exp $elements)
   (let*
     (
        ($op (car-atom $exp))
        ($guardSet (getLiterals $exp))
        ($newGuardSet (union-atom $guardSet $elements))
        ($newGuardSet' (collapse (unique (superpose $newGuardSet))))
        ($updatedSubExpression (union-atom $newGuardSet' (getChildrenExp $exp)))
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
(= (getChildrenExp $exp)
     (case $exp
       (
         (() $exp)
         ((NOT $x) ())
         ($else (if (== (get-metatype $exp) Expression)
                          (collapse (eval (filterChildren (superpose $exp))))
                          ())))))

;; A function to add a list of children to a given expression.
;; Example: input: $exp -> (AND A B (OR C D)), $children -> ((OR A B) (OR E F) (OR D))
;;          output: (AND A B (OR C D) (OR A B) (OR E F) (OR D))
(= (addChildren $exp $children)
   (let*
     (
        ($op (car-atom $exp))
        ($oldChildren (getChildrenExp $exp))
        ($newChildren (eval (concatTuple $oldChildren $children)))
        ($updatedSubExpression (eval (concatTuple (getLiterals $exp) $newChildren)))
        ($newExp (cons-atom $op $updatedSubExpression))
        
        ; (() (println! (OldChildren: $oldChildren)))
        ; (() (println! (ChildrenToAdd: $children)))
        ; (() (println! (NewChildren: $newChildren)))
        ; (() (println! (SubExprs: $updatedSubExpression)))
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
         ($else (if (== (get-metatype $exp) Expression) (collapse (eval (filterLiterals (superpose $exp)))) $exp)))))

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
(= (getLiteralChildren $expr) ((getLiterals $expr) (getChildrenExp $expr)))

;; Function to find common literals between a tuple and a nested tuple 
(= (findCommonLiterals $tuple $nestedTuple)
    (if (or (== $nestedTuple ()) (== $tuple ()))
        ()
        (let*
            (
                ($first (car-atom $nestedTuple))
                ($tail (cdr-atom $nestedTuple))
                ($common (intersection-atom $tuple $first)))

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
