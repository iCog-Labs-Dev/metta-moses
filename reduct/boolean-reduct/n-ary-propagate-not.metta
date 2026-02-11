(= (propagateNot $expr) (propagateNot $expr False))
(= (propagateNot $expr $negate)
   (if (== (get-metatype $expr) Expression)
       (if (== $expr ()) 
           ()
           (let*
             (
               (($op $t) (decons-atom $expr))
               ($result (map-atom $t (|-> ($childExpr) (propagateNot $childExpr (xor (== $op NOT) $negate)))))
             )
             (case $op
                   (
                     (AND (if $negate (cons-atom OR $result) (cons-atom AND $result)))
                     (OR (if $negate (cons-atom AND $result) (cons-atom OR $result)))
                     (NOT (car-atom $result))
                     ($_ ERROR)
                   ))))
       (if (== (get-metatype $expr) Symbol)
           (if $negate (NOT $expr) $expr)
           $expr)))
