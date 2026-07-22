;; Define AND at BINARY arity (what (zipWith AND ...) would require)
(= (AND $a $b) (and $a $b))

;; Candidate data uses AND at arity-1 (wrapped n-ary shape (AND (children)))
;; Q: does quote keep the arity-1 data inert, or does partial still leak?
!(println! (BARE (AND (True False True))))
!(println! (QUOTED (quote (AND (True False True)))))
!(println! (REDUCED (reduce (quote (AND (True False True))))))
