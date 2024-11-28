;; Name:                oneCcSub
;; A function to remove an element from the point of application (POA) if it's negated form is 
;;                      contained in the guard set of a commanding AND node (COM).
;; Goal:                To remove a constraint that is not needed because it is commanded by 
;;                      its negated form.
;; POA:                 Any non-root AND node.
;; Preconditions:       The POA’s guard set contains constraint X and the POA is commanded 
;;                      by a terminal AND node COM whose guard set consists of the constraint 
;;                      which is the opposite of X.
;; Action:              Subtract the constraint X from the guard set of the POA.
;;
;; Example:             POA --> (AND B C), COM guard set ((NOT B) A) -- a negated literal of the POA is                        found in the COM guard set so the POA is commanded by this set and the common
;;                      element is subtracted from the POA that member, B in this case. After the 
;;                      transformation, the POA is now (AND C).
(= (oneCcSub $comSet $poa $subExpr)
    (let* 
        (
            ($poaGuardSet (getGuardSet $poa))
            ($invertedCom (invertLiterals $comSet))
            ($commonElements (collapse (intersection (superpose $poaGuardSet) (superpose $invertedCom))))
        )
         (collapse (let $el (superpose $subExpr)
            (if (expressionEquality $el $poa)
                (collapse (subtraction (superpose $poa) (superpose $commonElements)))
                $el)))))

;; Name:               invertLiterals
;; A function to return a negated form of all the literals in a tuple.
;; Example             input-(A B C) -output- ((NOT A) (NOT B) (NOT C))
;;                     input-(A (NOT B) C) -output- ((NOT A) B (NOT C))
(= (invertLiterals $guardSet)
    (collapse (let $a (superpose $guardSet)
            (unify $a (NOT $x)
                $x
                (NOT $a)
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

;; test cases

! (oneCcSub ((NOT B) C) (AND B C) (OR (AND D) (AND B C))) ;(OR (AND D) (AND C))
! (oneCcSub ((NOT B) C) (AND B C) (AND (AND D C) (NOT B) A (AND B C))) ;; (AND (AND D C) (NOT B) A (AND C))
! (oneCcSub ((NOT B) C) (AND A C) (AND (AND D C) (NOT B) A (AND B C))) ;; (AND (AND D C) (NOT B) A (AND B C)) ;; no reduction because the POA is not in the expression
! (oneCcSub (A B C) (AND (NOT A) C) (OR (AND (NOT A) C) (OR A B (AND B C)))) ;; (OR (AND C) (OR A B (AND B C)))
! (oneCcSub ((NOT A) B C) (AND (NOT A) C) (OR (AND (NOT A) C) (OR A B (AND B C)))) ;; (OR (AND (NOT A) C) (OR A B (AND B C))) ;; no reduction - COM set doesn't contain negated terminals
