(= (AND $x) (cons-atom AND $x))
(= (OR $x) (cons-atom OR $x))

;; Propagate to childrens for both (propagateNot NOT) and (propagateNot logic)
(= (propagateNotChildrens () $tuple) (collapse (propagateNot (superpose $tuple))))
(= (propagateNotChildrens $tuple) (collapse (propagateNot NOT (superpose $tuple))))

;; Rules
(= (propagateNot AND $tuple) (AND (propagateNotChildrens () $tuple)))
(= (propagateNot OR $tuple) (OR  (propagateNotChildrens () $tuple)))
(= (propagateNot NOT AND $tuple) (OR (propagateNotChildrens $tuple)))
(= (propagateNot NOT OR $tuple) (AND (propagateNotChildrens $tuple)))
(= (propagateNot NOT NOT $tuple) (propagateNot $tuple))

(= (propagateNot NOT $symbol ()) (NOT $symbol))
(= (propagateNot NOT $expr)
   ( if (== (get-metatype $expr) Expression)
     ( let $x (car-atom $expr) 
       ( if(== (get-metatype $x) Expression)
          (propagateNot NOT (car-atom $x) (cdr-atom $x))
          (propagateNot NOT $x (cdr-atom $expr))
       )
      )
      (NOT $expr)
))

(=(propagateNot $expr ()) (propagateNot $expr))
(=(propagateNot $expr) 
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
