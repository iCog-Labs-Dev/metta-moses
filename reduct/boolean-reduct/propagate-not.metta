; (: propagateNot (-> $expr $expr))

;; Guarded if-chain dispatch: shape is verified structurally (metatype,
;; size-atom, == on heads) before let-destructuring, so unbound label vars
;; are never unified with a pattern (a case/unify dispatch binds them).
(= (propagateNot $expr)
    (if (not (== (get-metatype $expr) Expression))
        $expr                                             ;; leaf: Symbol / Variable / Grounded
        (if (== $expr ())
            $expr
            (if (== (size-atom $expr) 3)                  ;; ($logic $a $b)
                (let ($logic $a $b) $expr
                  ;; cons-atom, not ($logic ...): a var-headed construction
                  ;; compiles as a runtime meta-call, which turns into a
                  ;; partial-closure once boolean-ops registers AND/OR
                  (cons-atom $logic ((propagateNot $a) (propagateNot $b))))
                (if (== (size-atom $expr) 2)
                    (if (== (car-atom $expr) NOT)         ;; (NOT $arg)
                        (let (NOT $arg) $expr
                          (if (not (== (get-metatype $arg) Expression))
                              (NOT $arg)                  ;; (NOT $symbol)
                              (if (== $arg ())
                                  (NOT $arg)
                                  (if (and (== (car-atom $arg) AND) (== (size-atom $arg) 3))
                                      (let (AND $b $c) $arg
                                        (OR (propagateNot (NOT $b)) (propagateNot (NOT $c))))
                                      (if (and (== (car-atom $arg) OR) (== (size-atom $arg) 3))
                                          (let (OR $b $c) $arg
                                            (AND (propagateNot (NOT $b)) (propagateNot (NOT $c))))
                                          (if (and (== (car-atom $arg) NOT) (== (size-atom $arg) 2))
                                              (let (NOT $x) $arg (propagateNot $x))
                                              (NOT $arg)))))))
                        $expr)                            ;; other 2-element expression
                    $expr)))))                            ;; any other shape

