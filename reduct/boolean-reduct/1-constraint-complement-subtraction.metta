;; Name:                oneCcSub
;; A function to remove an element from the point of application (POA) if its negated form is contained in the
;;                       guard set of a commanding AND node (COM).
;; Parameters:
;;                      1. $parent:- the parent expression, possibly containing the point of application and a commanding AND node.
;;                      2. $poa:- the point of application, a non-root AND node.
;;                      3. $com:- the guard set of the commanding terminal AND node (COM).
;;                      
;; Goal:                To remove a constraint that is not needed because it is commanded by its negated form.
;;                      
;; POA:                 Any non-root AND node.
;;
;; Preconditions:       The POA’s guard set contains constraint X and the POA is commanded 
;;                      by a terminal AND node COM whose guard set consists of the constraint 
;;                      which is the opposite of X.
;; Action:              Subtract the constraint X from the guard set of the POA.
;;
;; Example:             if $poa -->(AND B C), and $com -->((NOT B) A) - one literal in the $poa is found in its negated form 
;;                      in the $com, B. In 1-constraint-complement-subtraction transformation, this common element is removed  
;;                      from its immediate parent, $poa, so $poa is now just (AND C).
;;
;; Function call:       !(oneCcSub $parent $poa $com)
;;                      E.g. $parent->(OR (AND D) (AND B C)), $poa->(AND B C),  $com->((NOT B) C) 
;;                      !(oneCcSub (OR (AND D) (AND B C)) (AND B C) ((NOT B) C)) --> (OR (AND D) (AND C))
(= (oneCcSub $parent $poa $com)
    (let* 
        (
            ($poaGuardSet (getGuardSet $poa))
            ($invertedCom (invertLiterals $com))
            ($commonElements (collapse (intersection (superpose $poaGuardSet) (superpose $invertedCom))))
        )
         (collapse (let $el (superpose $parent)
            (if (expressionEquality $el $poa)
                (collapse (subtraction (superpose $poa) (superpose $commonElements)))
                $el)))))

;; Name:               invertLiterals
;; A function to return a negated form of all the literals in a tuple.
;; Example             input-(A B C) -output- ((NOT A) (NOT B) (NOT C))
;;                     input-(A (NOT B) C) -output- ((NOT A) B (NOT C))
(= (invertLiterals $guardSet)
    (collapse (let $literal (superpose $guardSet)
            (unify $literal (NOT $x)
                $x
                (NOT $literal)
                ))))

;; Name:              expressionEquality
;; A function to compare two expressions and returns True if equal.
;;                    Expressions are deemed equal irrespective of the ordering of literal 
;;                    children in the expression.
;;                    Example --> (AND B A) and (AND A B) are equal expressions.
;;                    normal equality comparison, i.e., ==, would return false in the above case.
(= (expressionEquality $a $b)
    (let $diff (collapse (subtraction (superpose $a) (superpose $b)))
        (if (== $diff ())
            True
            False
        )))
