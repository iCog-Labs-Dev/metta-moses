;; ---------------------------------------------------------------------------
;; Result-based truncation for sequential logical operators
;; ---------------------------------------------------------------------------

;; Truncate and_seq after first element that always fails
(= (reduceSeqAndAlwaysFails $expr)
   (if (and (== (get-metatype $expr) Expression) (!= $expr ()))
       (let ($op $args) (decons $expr)
         (if (== $op and_seq)
             (let $truncated (truncateAtAlwaysFails $args)
               (cons-atom and_seq $truncated))
             $expr))
       $expr))

;; Truncate or_seq after first element that always succeeds
(= (reduceSeqOrAlwaysSucceeds $expr)
   (if (and (== (get-metatype $expr) Expression) (!= $expr ()))
       (let ($op $args) (decons $expr)
         (if (== $op or_seq)
             (let $truncated (truncateAtAlwaysSucceeds $args)
               (cons-atom or_seq $truncated))
             $expr))
       $expr))
