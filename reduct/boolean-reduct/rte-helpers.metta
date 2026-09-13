;; Partial function used to filter and keep only literals of an expression.
;; An expression (NOT A) is also considered as a literal in the case of boolean expression.
;; 'AND' and 'OR' are not considered as a literal.
(= (filterLiterals $exp)
        (if (== (get-metatype $exp) Symbol)
            (if (or (or (== $exp AND) (== $exp OR)) (isConstant $exp)) (empty) $exp)
            (if (== (car-atom $exp) NOT)
                $exp
                (empty))))

(= (isLiterals $exp)
   (if (== (get-metatype $exp) Symbol)
       (not (or (or (== $exp AND) (== $exp OR)) (isConstant $exp)))
       (== (car-atom $exp) NOT)))

;; A function that takes an expression and returns it's guard sets
;; Definition: Guard set of a node is the set of literals in the node. 
;;                Only AND nodes have guard sets.
;; Example: (AND (NOT A) (NOT B) A) -> ( (NOT A) (NOT B) A)
;; Plain guarded ifs, NOT if-decons-expr-custom: that helper's (eval $then)
;; deep-normalizes the returned guard set, firing scoring/boolean-ops'
;; AND/OR/NOT clauses on the (NOT x) literals inside it.
(= (getGuardSet $exp)
   (if (isConstant $exp)
       ()
   (if (== (get-metatype $exp) Expression)
       (if (== $exp ())
           $exp
           (if (== (car-atom $exp) OR)
               ()
               (getLiterals $exp)))
       $exp))
)


;; A function similar to the getGuardSet function but returns a
;;    non deterministic list instead of a collapsed atom.
;; Example: (AND (NOT A) (NOT B) A) -> [(NOT A), (NOT B), A]
;; Plain guarded ifs for the same reason as getGuardSet. Baseline behavior
;; preserved: decons-atom on () still yields no solution, and OR nodes
;; yield (empty) — zero ND solutions.
(= (getGuardSetND $exp)
   (if (or (and (!= $exp ()) (!= (get-metatype $exp) Symbol)) (== (get-metatype $exp) Expression))
      (let ($h $t) (decons-atom $exp)
        (if (== $h OR)
            (empty)
            (getLiteralsND $exp)))
      $exp
    )
)  

(= (addLiterals $exp $elements)
   (let*
     (
        ($op (car-atom $exp))
        ($guardSet (getLiterals $exp))
        ($newGuardSet (union-atom $guardSet $elements))
        ($newGuardSet' (unique-atom $newGuardSet))
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
            (if (isConstant $exp) $exp (empty))
            (if (== (car-atom $exp) NOT)
                (empty)
                $exp)))

(= (isChildren $exp)
        (if (== (get-metatype $exp) Symbol)
            (isConstant $exp)
            (not (== (car-atom $exp) NOT))))

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
                          (filter-atom $exp isChildren)
                          ())))))

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
     (case $exp
       (
         (() $exp)
         ((NOT $x) $exp)
         ($else (if (isConstant $exp)
                    ()
                    (if (== (get-metatype $exp) Expression) (filter-atom $exp isLiterals) $exp))))))

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
         ($else (if (isConstant $exp)
                    (empty)
                    (if (== (get-metatype $exp) Expression) (filterLiterals (superpose $exp)) $exp))))))

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

;; Name:                        invertLiterals
;; Description:                 A helper function that negates all literals in a literal only expression.
;;                              Used when finding a negated literal of the POA in the guardset of the commanding AND node.
;; Example:                     invertLiterals (A B) -> ((NOT A) (NOT B))
;;                              invertLiterals (A (NOT B)) -> ((NOT A) B)

(= (invertLiterals $guardSet) (map-atom $guardSet $literal (invertLiteral $literal)))

;; Negates a single literal.
;; LIVE-HEAD HAZARD: a structural head check, NOT (unify $literal (NOT $x) $x (NOT $literal)).
;; Once scoring/boolean-ops is loaded NOT is a DEFINED head, so both the unify pattern
;; and a bare (NOT $literal) become live calls: they yield the wrong number of solutions
;; (two for a non-match, none for a match) and silently take the whole reduction with them.
;; quote substitutes the binding and strips once, yielding (NOT A) as plain data.
(= (invertLiteral $literal)
   (if (== (get-metatype $literal) Symbol)
       (quote (NOT $literal))
       (if (== (car-atom $literal) NOT)
           (car-atom (cdr-atom $literal))
           (quote (NOT $literal)))))

;; Name:                        dedupSiblings
;; Description:                 Erases repeated conjuncts/disjuncts everywhere in a tree.
;;                              Classic MOSES does this at the top of reduce() with an
;;                              equal_subtree erase loop (logical_rules.cc:600). Duplicates are
;;                              logically idempotent, but they inflate treeComplexity and they
;;                              hide terminal AND nodes from filterTerminalAndNode, which
;;                              suppresses the absorptions 1-Subsume would otherwise perform.
;; Example:                     dedupSiblings (AND B A B (NOT C)) -> (AND B A (NOT C))
;;                              dedupSiblings (OR (AND C C) A)    -> (OR (AND C) A)
(= (dedupSiblings $expr)
   (if (== (get-metatype $expr) Expression)
       (if (== $expr ())
           $expr
           (let ($head $rest) (decons-atom $expr)
             ;; (NOT x) is a literal, not a junctor -- leave its single child alone.
             (if (== $head NOT)
                 $expr
                 (let $deduped (map-atom $rest $child (dedupSiblings $child))
                      (cons-atom $head (unique-atom $deduped))))))
       $expr))

;; Name:                        emptiedToConstant
;; Description:                 Reads a junctor that a rule just EMPTIED as the constant it
;;                              is: an empty conjunction is TRUE, an empty disjunction is
;;                              FALSE.
;;                              $before is what the node was on the way in. A junctor that
;;                              was ALREADY childless is a dangling placeholder from knob
;;                              building, not a truth value, and is returned untouched --
;;                              that guard is what makes this a DETECTION rather than a
;;                              reading, and it is the whole reason the constants are their
;;                              own symbols.
;;                              It takes WHOLE NODES, never a head and a tail: some callers
;;                              pass flat literal lists, where the first element is an
;;                              ordinary literal and rebuilding around it would both keep a
;;                              literal that should have been stripped and read its polarity
;;                              off a non-junctor head.
;; Example:                     emptiedToConstant (AND A B) (AND)  -> TRUE
;;                              emptiedToConstant (OR X)    (OR)   -> FALSE
;;                              emptiedToConstant (AND)     (AND)  -> (AND)  ;; placeholder
;;                              emptiedToConstant (A B D)   (D)    -> (D)
(= (emptiedToConstant $before $after)
   (if (== $after (AND))
       (if (== $before (AND)) $after TRUE)
       (if (== $after (OR))
           (if (== $before (OR)) $after FALSE)
           $after)))

;; Name:                        applyConstantLaws
;; Description:                 The identity and annihilator laws for TRUE / FALSE, stated once
;;                              instead of scattered over the transformations -- which is where
;;                              three of the four rows were missing, and a dropped constant was
;;                              lost for good.
;;
;;                                (AND ... FALSE ...) -> FALSE    false annihilates a conjunction
;;                                (OR  ... TRUE  ...) -> TRUE     true  annihilates a disjunction
;;                                (AND ... TRUE  ...) -> drop it  true  is the identity of AND
;;                                (OR  ... FALSE ...) -> drop it  false is the identity of OR
;;
;;                              This is classic's Delete/Disconnect propagation
;;                              (logical_rules.cc:715 and :817) with Delete == FALSE and
;;                              Disconnect == TRUE. Applied bottom-up, one pass, no fixpoint.
;; Example:                     applyConstantLaws (AND X FALSE)  -> FALSE
;;                              applyConstantLaws (OR X TRUE)    -> TRUE
;;                              applyConstantLaws (AND X TRUE Y) -> (AND X Y)
;;                              applyConstantLaws (AND TRUE)     -> TRUE
(= (applyConstantLaws $expr)
   (if (== (get-metatype $expr) Expression)
       (if (== $expr ())
           $expr
           (let ($head $rest) (decons-atom $expr)
             ;; (NOT x) is a literal -- do not descend into it. A childless (AND)/(OR) is a
             ;; dangling placeholder and is NOT a constant, so it is returned untouched.
             (if (or (== $head NOT) (== $rest ()))
                 $expr
                 (let* (($kids (map-atom $rest $child (applyConstantLaws $child)))
                        ($identity    (if (== $head AND) TRUE FALSE))
                        ($annihilator (if (== $head AND) FALSE TRUE))
                        ($kept (filter-atom $kids $k (not (== $k $identity)))))
                   (if (== (filter-atom $kids $k (== $k $annihilator)) ())
                       ;; Every child was the identity => the junctor IS the identity. With
                       ;; distinct constants this has to be said; under the old encoding
                       ;; (cons-atom AND ()) happened to already be the right answer.
                       (if (== $kept ()) $identity (cons-atom $head $kept))
                       $annihilator)))))
       $expr))
