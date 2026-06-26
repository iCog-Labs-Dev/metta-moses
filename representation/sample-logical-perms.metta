;; pairInnerLoop -> selects second candidate for each anchor and 
;;                 builds (anchor partner) pairs.
;; Type: (-> Expression Number Number Number Expression)
(= (pairInnerLoop $list $i $j $size)
    (if (>= $j $size)
        ()
        (if (== $i $j)
            (pairInnerLoop $list $i (+ $j 1) $size)
            (cons-atom ((index-atom $list $i) (index-atom $list $j))
                      (pairInnerLoop $list $i (+ $j 1) $size)))))

;; pairOuterLoop -> fixes the first element of the pair (i) and 
;;                   Iterates over all possible anchors in the list.
;; Type: (-> Expression Number Number Expression)
(= (pairOuterLoop $list $i $size)
    (if (>= $i $size)
        ()
        (append (pairInnerLoop $list $i 0 $size)
                (pairOuterLoop $list (+ $i 1) $size))))

;; A function to generate all pairs of numbers from a list, where a != b
;; (: genPairs (-> Expression Expression))
(= (genPairs $list)
    (pairOuterLoop $list 0 (size-atom $list)))

;; TODO: Rewrite using iterative logic
(= (genTriplet $list)
    (let*
        (
            ($x (superpose $list))
            ($y (superpose $list))
            ($z (superpose $list))
        )
        (if (and (and (!= $x $y) (!= $y $z)) (!= $x $z)) 
            ($x $y $z)
            (empty) 
        )
    )
)

;; getArgs -> generate logical expressions from the list of pairs
;; Parameters:
;;          $swapedOp -> swaped operator
;;          $PermPairs -> list of pairs of idx permutations
;;          $picked -> list of picked idxs
;; (: getArgs (-> Atom Expression Expression Expression Expression))
;; TODO: Rewrite using iterative logic
(= (getArgs $swapedOp $PermPairs $picked $argLabels)
    (let*
        (
            (($a $b) (index-atom $PermPairs (superpose $picked)))
            (($1 $2) ((index-atom $argLabels $a) (index-atom $argLabels $b)))
        )
        (if (< $b $a)
            ($swapedOp $2 $1)
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
;; (: sampleLogicalPerms (-> Atom Number Expression Expression))
;; TODO: Rewrite using iterative logic
(= (sampleLogicalPerms $op $arity $argLabels)
    (let*
        ( 
            ($swapedOp (swapAndOr $op))
            ($list (genList (- $arity 1)))
            ($idxPairs (collapse (genPairs $list)))
            ($nPairs $arity)) ;; since perm_ratio is 0.0 the max number of n_pairs = arity
            ;; ($nPairs 0)) ;; since perm_ratio is 0.0 the max number of n_pairs = arity
            (if (<= $nPairs 1)
                (let $arg (car-atom $argLabels) ($arg (NOT $arg)))  ;; assuming at worst case, only one argument is returned -- representation building process makes sure that those with empty feature set do not make it to actual knob building stage
                (let* (($upperbound (- (* $arity (- $arity 1)) 1))
                        ($picked (lazyRandomSelector 0 $upperbound $nPairs))
                        ($perms (collapse (getArgs $swapedOp $idxPairs $picked $argLabels))))
                   (concatT $argLabels $perms)))))

;; getMoveArgs -> generate move expressions from pairs of move indices
;; Params:
;;          $op: move operator (PRIORITIZED-OR)
;;          $PermPairs: list of pairs of idx permutations
;;          $picked: list of picked move idxs
;;          $moveLabels: list of move labels (playcenter, playcorner, etc.)
;; Returns: move expressions with operator and move combinations
;; (: getMoveArgs (-> Atom Expression Expression Expression Expression))
;; TODO: Rewrite using iterative logic
(= (getMoveArgs $op $PermPairs $picked $moveLabels)
    (let*
        (
            ; ($triplet (index-atom $PermPairs (superpose $picked)))
            (($a $b $c)(index-atom $PermPairs (superpose $picked)))
            (($move1 $move2 $move3) ((index-atom $moveLabels $a) (index-atom $moveLabels $b) (index-atom $moveLabels $c)))
        )
        ($op $move1 $move2 $move3)
    ))

;; sampleStrategyPerms -> generate strategy permutations for game strategy evolution
;; Params:
;;          $op: the strategy operator (PRIORITIZED-OR)
;;          $arity: the number of moves in the strategy sequence
;;          $moveLabels: list of move labels (playcenter, playblock, playcorner, etc.)
;; Returns:
;;          Union of original moves with alternative move strategy expressions
;; (: sampleStrategyPerms (-> Atom Number Expression Expression))
;; TODO: Rewrite using iterative logic
(= (sampleStrategyPerms $op $arity $moveLabels)
    (let*
        (
            ($list (genList (- (length $moveLabels) 1)))
            ($idxPairs (collapse (genTriplet $list)))
            ($nPairs $arity)
        )
        (if (<= $nPairs 1)
            ($op (car-atom $moveLabels))
            (let*
                (
                    ($upperbound (- (length $idxPairs) 1))
                    ($picked (lazyRandomSelector 0 $upperbound $nPairs))
                    ($perms (collapse (getMoveArgs $op $idxPairs $picked $moveLabels)))
                )
                   $perms
            )
        )
))
