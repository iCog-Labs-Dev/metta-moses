;; functions to Constract expression i.e (AND (A B) ) => (AND A B)
(= (singleton-operator $op $x) (cons-atom $op $x))

;; function to propagate to all of nested tuples by  mapping a propagetNot function to them
(= (propagateNotChildrens () $tuple) (collapse (propagateNot (superpose $tuple))))
(= (propagateNotChildrens $tuple) (collapse (propagateNot NOT (superpose $tuple))))

;; Rules to propagete
(= (propagateNot AND $tuple) (singleton-operator AND (propagateNotChildrens () $tuple)))
(= (propagateNot OR $tuple) (singleton-operator OR (propagateNotChildrens () $tuple)))
(= (propagateNot NOT AND $tuple) (singleton-operator OR (propagateNotChildrens $tuple)))
(= (propagateNot NOT OR $tuple) (singleton-operator AND (propagateNotChildrens $tuple)))
(= (propagateNot NOT NOT $tuple) (propagateNot $tuple))

;;functions to Extract the operators form operands and make oprands tuple  from the expression
(= (propagateNot NOT $symbol ()) (NOT $symbol))
(= (propagateNot NOT $expr)
   ( if (== (get-metatype $expr) Expression) ;; check if the the variable is expression 
     (let $tuple (car-atom $expr) 
       ( if (== (get-metatype $tuple) Expression)
          (propagateNot NOT (car-atom $tuple) (cdr-atom $tuple))
          (propagateNot NOT $tuple (cdr-atom $expr))
       )
      )
      (NOT $expr)
  )
)

(= (propagateNot $expr ()) (if (== (get-metatype $expr) Expression) (propagateNot $expr) (empty))) ;; Returns in ND result when given => (AND)
(= (propagateNot $expr) 
  (
    if (== (get-metatype $expr) Expression)
       ( let* (
                ($op (car-atom $expr))
                ($tuple (cdr-atom $expr))
              )
              (propagateNot $op $tuple)
       )
       $expr
  )
)
