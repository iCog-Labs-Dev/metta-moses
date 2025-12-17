;; A function to remove an unnecessary OR and its child.
;; Preconditions: The point of application (POA) has only one child.
;; Action: If the preconditions are met, the function adds the POA's
;;            grandChildren to the POA's parent and removes the POA
;;            from parent. It then returns the updated parent, an
;;            empty atom and a boolean value of true. If conditions 
;;            are not met, it returns the state unchanged.
;; Example: input: POA ==> (OR (AND (NOT D))), parent => (AND B (OR (AND (NOT D))))
;;          output: ((AND B (NOT D)) () True)
; (: orCut (-> Expression Expression (Expression Expression Bool)))


(= (orCut $expr $poa)
    (if (== $expr $poa)
        (let* (
            ($head (car-atom $poa))
            ($children (cdr-atom $poa))
            ($numChildren (size-atom $children))
            )
            (if (and (== $head OR) (== $numChildren 1))
                (let $result (car-atom $children)
                    ($result () True))
                ($expr $poa False)
            )
        )
        (if (is-expr $expr)
            (let* (
                ($head (car-atom $expr))
                ($children (cdr-atom $expr))
                ($results (collapse (let $child (superpose $children)
                    (orCut $child $poa))))
                ($anyChanged (collapse (let $r (superpose $results)
                    (let ($res $p $changed) $r
                        (if (== $changed True) True (empty))))))
                ($processedChildren (collapse (let $r (superpose $results)
                    (let ($res $p $changed) $r
                        (if (is-expr $res)
                            (let $childHead (car-atom $res)
                                (if (== $childHead $head)
                                    (let $grandChildren (cdr-atom $res)
                                        (superpose $grandChildren))
                                    $res
                                ))
                            $res
                        )))))
                ($finalResult (cons-atom $head $processedChildren))
                )
                (if (== $anyChanged ())
                    ($finalResult $poa False)
                    ($finalResult () True)
                )
            )
            ($expr $poa False)
        )))