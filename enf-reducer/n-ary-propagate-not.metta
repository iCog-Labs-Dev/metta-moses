(=(AND $x) (cons-atom AND $x))
(=(OR $x) (cons-atom OR $x))

;; Propagate to childrens for both (propagateNot NOT) and (propagateNot logic)
(=(propagateChildrens $tuple) (collapse (propagateNot (superpose $tuple))))
(=(propagateNotChildrens $tuple) (collapse (propagateNot NOT (superpose $tuple))))

;; Rules
(= (propagateNot AND $tuple) (let $res (propagateChildrens $tuple) (AND $res)))
(= (propagateNot OR $tuple) (let $res (propagateChildrens $tuple) (OR $res)))
(= (propagateNot NOT AND $tuple) (let $res (propagateNotChildrens $tuple) (OR $res)))
(= (propagateNot NOT OR $tuple) (let $res (propagateNotChildrens $tuple) (AND $res)))
(= (propagateNot NOT NOT $tuple) (propagateNot $tuple))

(=(propagateNot NOT $symbol ()) (NOT $symbol))
(=(propagateNot NOT $expr)
  (if(== (get-metatype $expr) Expression)
     (let $x (car-atom $expr) 
       (if(== (get-metatype $x) Expression)
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