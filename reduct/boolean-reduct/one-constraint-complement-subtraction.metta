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
            ($commonElements (intersection-atom $poaGuardSet $invertedCom))
        )
         (map-atom $parent $el
            (if (trace! (El: $el POA: $poa) (=== $el $poa))
                (subtraction-atom $poa $commonElements)
                $el))))

;; invertLiterals now lives in rte-helpers.metta: reduce-to-elegance needs it too,
;; and a reduct module must not carry an import! header.
