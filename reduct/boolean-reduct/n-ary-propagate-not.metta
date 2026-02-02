(= (propagateNot $expr) (propagateNot $expr False))
(= (propagateNot $expr $negate)
   (if (== (get-metatype $expr) Expression)
       (if (== $expr ()) 
           ()
           (let*
             (
               ($_ (println! (Inside propNot)))
               (($op $t) (decons-atom $expr))
               ($_ (println! (OP: $op T: $t )))
               ($result (map-atom $t (|-> ($childExpr) (propagateNot $childExpr (xor (== $op NOT) $negate)))))
               ($_ (println! (Result: $result)))
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
