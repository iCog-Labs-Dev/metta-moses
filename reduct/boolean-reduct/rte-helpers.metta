;; True for terminal nodes of a boolean tree: bare labels (Symbol),
;;    label variables (Variable) and grounded atoms like true/false (Grounded).
;; Guards every leaf predicate so car-atom/decons-atom are never
;;    called on an unbound variable (a silently failing/var-binding goal).
(= (isLeaf $x)
   (let $mt (get-metatype $x)
     (or (== $mt Symbol) (or (== $mt Variable) (== $mt Grounded)))))

;; True for a (NOT ...) expression. Safe on leaves and () — car-atom is only
;; reached for genuine non-empty expressions (nested ifs short-circuit; a
;; single `and` would evaluate car-atom on a leaf and fail silently).
(= (isNotHeaded $x)
   (if (isLeaf $x)
       False
       (if (== $x ())
           False
           (== (car-atom $x) NOT))))

;; Structural (==-based) membership. Unlike is-member, never unifies,
;;    so unbound label variables only match themselves.
(= (memberOf $el $tuple)
   (if (== $tuple ())
       False
       (let ($h $t) (decons-atom $tuple)
         (if (== $el $h) True (memberOf $el $t)))))

;; Structural subtraction: elements of $tuple that are not (==) members of $del.
;; Replacement for subtraction-atom/removeElement, which remove by unification.
(= (subAll $tuple $del)
   (if (== $tuple ())
       ()
       (let ($h $t) (decons-atom $tuple)
         (let $rest (subAll $t $del)
           (if (memberOf $h $del) $rest (cons-atom $h $rest))))))

;; Structural dedup: keeps the leftmost occurrence, removes later (==) duplicates.
;; Replacement for unique-atom.
(= (uniqueStruct $tuple)
   (if (== $tuple ())
       ()
       (let ($h $t) (decons-atom $tuple)
         (cons-atom $h (uniqueStruct (subAll $t ($h)))))))

;; Structural intersection: elements of $x that are (==) members of $y.
;; Replacement for intersection-atom, which matches by unification.
(= (intersect $x $y)
   (if (== $x ())
       ()
       (let ($h $t) (decons-atom $x)
         (let $rest (intersect $t $y)
           (if (memberOf $h $y) (cons-atom $h $rest) $rest)))))

;; Flatten one level: concatenate a tuple of tuples into a single tuple.
(= (concatAll $tuples)
   (if (== $tuples ())
       ()
       (let ($h $t) (decons-atom $tuples)
         (concatTuple $h (concatAll $t)))))

;; Eval-free replacement for general-helpers' `until`: `until` wraps its
;; predicate call and recursion in `eval`, which deep-normalizes the whole
;; loop state — re-evaluating (NOT $var) data via the `not` builtin binds
;; the label var to true and corrupts the tree (finding #2).
;;
;; Application goes through clause-dispatched `applyStep`, NOT a var-headed
;; ($function $x) meta-call: under PeTTaV1 the generic dispatch of a
;; var-headed call re-translates its result, firing scoring's AND/OR/NOT
;; eval clauses on tree data and binding label vars to true/false.
;; This dummy clause only registers applyStep as a function so the call
;; below compiles as a call; the real clauses live at the bottom of
;; reduce-to-elegance.metta where all the loop bodies are already defined.
(= (applyStep __loopUntilRegistration $x) $x)

(= (loopUntil $predicate $function $x)
   (if (applyStep $predicate $x)
       $x
       (loopUntil $predicate $function (applyStep $function $x))))

;; Partial function used to filter and keep only literals of an expression.
;; An expression (NOT A) is also considered as a literal in the case of boolean expression.
;; 'AND' and 'OR' are not considered as a literal.
(= (filterLiterals $exp)
        (if (isLeaf $exp)
            (if (or (== $exp AND) (== $exp OR)) (empty) $exp)
            (if (== (car-atom $exp) NOT)
                $exp
                (empty))))

(= (isLiterals $exp)
   (if (isLeaf $exp)
       (not (or (== $exp AND) (== $exp OR)))
       (== (car-atom $exp) NOT)))

;; A function that takes an expression and returns it's guard sets
;; Definition: Guard set of a node is the set of literals in the node. 
;;                Only AND nodes have guard sets.
;; Example: (AND (NOT A) (NOT B) A) -> ( (NOT A) (NOT B) A)
(= (getGuardSet $exp)
   (if (== (get-metatype $exp) Expression)
    (if (== $exp ())
        $exp
        (let ($h $t) (decons-atom $exp)
          (if (== $h OR)
              ()
              (getLiterals $exp))))
    $exp)
)


;; A function similar to the getGuardSet function but returns a
;;    non deterministic list instead of a collapsed atom.
;; Example: (AND (NOT A) (NOT B) A) -> [(NOT A), (NOT B), A]
(= (getGuardSetND $exp)
   (if (== (get-metatype $exp) Expression)
      (if (== $exp ())
          (empty)
          (let ($h $t) (decons-atom $exp)
            (if (== $h OR) (empty) (getLiteralsND $exp)))
      )
      $exp ;; leaves (Symbol, Variable, Grounded) are their own guard set; never decons a var
    )
)

(= (addLiterals $exp $elements)
   (let*
     (
        ($op (car-atom $exp))
        ($guardSet (getLiterals $exp))
        ($newGuardSet (union-atom $guardSet $elements))
        ($newGuardSet' (uniqueStruct $newGuardSet))
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
        (if (isLeaf $exp)
            (empty)
            (if (== (car-atom $exp) NOT)
                (empty)
                $exp)))

(= (isChildren $exp)
        (if (isLeaf $exp)
            False
            (not (== (car-atom $exp) NOT))))

;; A function to return children of a given expression.
;; A child of a given expression is any subExpression.
;; An expression (NOT A) is also considered as a literal 
;;    in the case of boolean expression. Hence not included as a child.
(= (getChildrenExp $exp)
     (if (isLeaf $exp)
         ()
         (if (== $exp ())
             $exp
             (if (isNotHeaded $exp)
                 ()
                 (filter-atom $exp isChildren)))))

;; A function to add a list of children to a given expression.
;; Example: input: $exp -> (AND A B (OR C D)), $children -> ((OR A B) (OR E F) (OR D))
;;          output: (AND A B (OR C D) (OR A B) (OR E F) (OR D))
(= (addChildren $exp $children)
   (let*
     (
        ($op (car-atom $exp))
        ($oldChildren (getChildrenExp $exp))
        ($newChildren (concatTuple $oldChildren $children))
        ($updatedSubExpression (concatTuple (getLiterals $exp) $newChildren))
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
     (if (isLeaf $exp)
         $exp
         (if (== $exp ())
             $exp
             (if (isNotHeaded $exp)
                 $exp
                 (filter-atom $exp isLiterals)))))

;; A function similar to getLiterals function but returns a
;;    non deterministic list instead of a collapsed atom.
;; Example: (AND (NOT A) (NOT B) A) -> [(NOT A),(NOT B),A]
;;          (OR (NOT A) (NOT B) A) -> [(NOT A),(NOT B),A]
;;          (NOT A) -> [(NOT A)]
(= (getLiteralsND $exp)
     (if (isLeaf $exp)
         $exp
         (if (== $exp ())
             $exp
             (if (isNotHeaded $exp)
                 $exp
                 (filterLiterals (superpose $exp))))))

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
                ($common (intersect $tuple $first)))

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
