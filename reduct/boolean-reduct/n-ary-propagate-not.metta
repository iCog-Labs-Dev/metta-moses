;; Pushes every NOT down to the literals (negation normal form), with De Morgan's laws.
;; $negate is True when an odd number of NOTs is above $expr.
(= (propagateNot $expr) (propagateNot $expr False))
(= (propagateNot $expr $negate)
   (if (== (get-metatype $expr) Expression)
       (if (== $expr ()) 
           ()
           (let*
             (
               (($op $t) (decons-atom $expr))
               ($result (map-atom $t $ts (propagateNotHelper $ts $op $negate)))
             )
             (case $op
                   (
                     (AND (if $negate (cons-atom OR $result) (cons-atom AND $result)))
                     (OR (if $negate (cons-atom AND $result) (cons-atom OR $result)))
                     (NOT (car-atom $result))
                     ($_ (trace! (Returning Error for operator $op) ERROR))
                   ))))
       ;; The bare (NOT $expr) build is data only because this file loads before scoring/boolean-ops.
       (if (== (get-metatype $expr) Symbol)
           (if $negate (NOT $expr) $expr)
           $expr)))

(= (propagateNotHelper $childExpr $op $negate) (propagateNot $childExpr (xor (== $op NOT) $negate)))
