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
             (if (== $op AND)
                 (if $negate (cons-atom OR $result) (cons-atom AND $result))
                 (if (== $op OR)
                     (if $negate (cons-atom AND $result) (cons-atom OR $result))
                     (if (== $op NOT)
                         (car-atom $result)
                         ;; non-boolean head (var-headed / (NOT $x)-headed candidate
                         ;; shapes): soft-fail unchanged — a trace!-ERROR here poisons
                         ;; the whole reduction (lost-refactor commit 3717053)
                         $expr)))))
       ;; non-Expression = leaf (Symbol, Variable or Grounded) — all negate uniformly
       (if $negate (NOT $expr) $expr)))

(= (propagateNotHelper $childExpr $op $negate) (propagateNot $childExpr (xor (== $op NOT) $negate)))
