;; Binary def (what zipWith AND needs)
(= (AND $a $b) (and $a $b))
;; Rewriter-style destructure of the arity-1 surface form
(= (getChildren ($op $cs)) $cs)

!(println! (DESTRUCTURE_BARE (getChildren (AND (x y z)))))
!(getChildren (quote (AND (x y z))))
;; and the arity-2 row use working at the same time
!(println! (ROWUSE (AND True False)))
