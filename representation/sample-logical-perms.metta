
;; sampled arguments (inputs)
!(bind! args (A B))

;; A function to generate all pairs of numbers from a list, where a != b
(: genPairs (-> Expression Expression))
(= (genPairs $list)
    ( let*
        (
            ($x (superpose $list))
            ($y (superpose $list))
        )
        (if (not (== $x $y)) 
            ($x $y)
            (empty) 
        )
    )
)

;; getArgs -> generate logical expressions from the list of pairs
;; Parameters:
;;          $swapedOp -> swaped operator
;;          $PermPairs -> list of pairs of idx permutations
;;          $picked -> list of picked idxs
(: getArgs (-> Atom Expression Expression Expression))
(= (getArgs $swapedOp $PermPairs $picked)
    (let*
        (
            (($a $b) (index-atom $PermPairs (superpose $picked)))
            (($1 $2) ((index-atom args $a) (index-atom args $b)))
        )
        (if (< $b $a)
            ($swapedOp  $2 $1)
            ($swapedOp (NOT $1) $2)
        )
    )
)
;; sampleLogicalPerms -> generate logical permutations for boolean expressions
;; Parameters:
;;          $op -> the operator passed from the iterator 
;;          $arity -> the number of arguments in the logical expression
;; Returns:
;;          Union of $perms (the list of logical expressions generated) with args

; (= (sampleLogicalPerms $op $arity) (sampleLogicalPerms $op $arity ()))
(: sampleLogicalPerms (-> Atom Number Expression))
(= (sampleLogicalPerms $op $arity)
    (let*
        ( 
            ($swapedOp (swapAndOr $op))
            ($list (genList (- $arity 1)))
            ($idxPairs (collapse (genPairs $list)))
            ($nPairs $arity)                                          ;; since perm_ratio is 0.0 the max number of n_pairs = arity
            ($upperbound (- (* $arity (- $arity 1)) 1))               ;; we will have n * (n-1) pairs, since index substract 1
            ($picked (lazyRandomSelector 0 $upperbound $nPairs))
            ($perms (collapse (getArgs $swapedOp $idxPairs $picked)))
        )
        (collapse (union (superpose args) (superpose $perms)))
    )
)
