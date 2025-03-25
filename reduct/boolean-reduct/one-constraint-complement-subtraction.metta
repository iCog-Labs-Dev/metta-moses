;; Name:                        oneCcSub
;; Parameters:              
;;                              1:- $parent, a boolean expression possibly containing a non-root AND node, 
;;                              the POA and a commanding terminal AND node, COM.
;;                              2:- $poa, the point of application from whose literal is to be subtracted.
;;                              3:- $com, the guard set of the commanding AND node possibly containing
;;                              a negated form of a member of the guard set of the POA.
;; Goal:                        To remove a constraint which is not needed because it is commanded by its negated form.
;; Point of application(POA):   Any non-root AND node.
;; Preconditions:               The POA’s guard set contains constraint X and the POA is commanded
;;                              by a terminal AND node COM whose guard set consists of the constraint 
;;                              which is the opposite of X.
;;
;; Action:                      Subtract the constraint X from the guard set of the POA.
;; Example Function call        $parent <- (OR (AND D) (AND B C)), $poa <- (AND B C), $com <- ((NOT B) C)                    
;;                              oneCcSub ((OR (AND D) (AND B C)) (AND B C) ((NOT B) C)) -> (OR (AND D) (AND C))

(= (oneCcSub $parent $poa $com)
    (let* 
        (
            ($poaGuardSet (getGuardSet $poa))
            ($invertedCom (invertLiterals $com))
            ($commonElements (collapse (intersection (superpose $poaGuardSet) (superpose $invertedCom))))
        )
         (collapse (let $el (superpose $parent)
            (if (=== $el $poa)
                (collapse (subtraction (superpose $poa) (superpose $commonElements)))
                $el)))))

;; Name:                        invertLiterals
;; Description:                 A helper function that negates all literals in a literal only expression.
;;                              Used when finding a negated literal of the POA in the guardset of the commanding AND node.
;; Example:                     invertLiterals (A B) -> ((NOT A) (NOT B))
;;                              invertLiterals (A (NOT B)) -> ((NOT A) B)

(= (invertLiterals $guardSet)
    (collapse (let $literal (superpose $guardSet)
            (unify $literal (NOT $x)
                $x
                (NOT $literal)))))
