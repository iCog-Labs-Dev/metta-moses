;(: gatherJunctors (-> Expression Expression Expression))
;; Guarded if-chain dispatch: the 3-element shape is verified before
;; let-destructuring, so an unbound label var never unifies with ($op $a $b).
(= (gatherJunctors $expr $prev)
   (if (not (== (get-metatype $expr) Expression))
       ($expr)
       (if (== (size-atom $expr) 3)
           (let ($op $a $b) $expr
              ;; (cons-atom $op ()) instead of ($op): a var-headed 1-tuple
              ;; compiles as a runtime meta-call — partial-closure debris
              ;; once boolean-ops registers AND/OR
              (if (== $prev ())
                 (concatTuple (cons-atom $op ()) (concatTuple (gatherJunctors $a $op) (gatherJunctors $b $op)))
                 (if (== $op $prev)
                    (concatTuple (gatherJunctors $a $op) (gatherJunctors $b $op))
                    ((concatTuple (cons-atom $op ()) (concatTuple (gatherJunctors $a $op) (gatherJunctors $b $op))))
                 )
              )
           )
           ($expr)
       )
   )
)
