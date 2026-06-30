

;; A function to generate all pairs of numbers from a list, where a != b
;; Uses nested map-atom calls to construct the Cartesian product,
;; foldl-atom to flatten the nested results,
;; and filter-atom to remove self-pairs.
;; (: genPairs (-> Expression Expression))
(= (genPairs $list)
    (let*
        (($nested (map-atom $list $x (map-atom $list $y ($x $y))))
         ($pairs (foldl-atom $nested () $acc $sub  (union-atom $sub $acc)))
        )
        (filter-atom $pairs ($a $b) (!= $a $b))))           

;; genTriplet -> Generate all valid ordered triplets from a list.
;; Uses nested map-atom calls to construct the Cartesian product,
;; reverse to preserve the recursive traversal order, foldl-atom
;; to flatten nested results, and filter-atom to remove duplicates.
;; (: genTriplet (-> Expression Expression))
(= (genTriplet $list)
    (let*
        (
            ($nested 
                 (map-atom $list $x 
                               (reverse (map-atom $list $y (map-atom  $list $z ($x $y $z))))))

            ($level1 (foldl-atom $nested () $acc $sub (union-atom $sub $acc)))
            ($triplets (foldl-atom $level1 () $acc $sub (union-atom $sub $acc)))
        )

        (filter-atom $triplets ($a $b $c) (and (!= $a $b) (and (!= $a $c) (!= $b $c))))))

;; getArgs ->  Produces deterministic tuple of logical expressions.
;;             Maps each selected pair index to its corresponding logical expression
;; Parameters:
;;          $swapedOp -> swaped operator
;;          $PermPairs -> list of pairs of idx permutations
;;          $picked -> list of picked idxs
;; (: getArgs (-> Atom Expression Expression Expression Expression))
(= (getArgs $swapedOp $PermPairs $picked $argLabels)
    (map-atom
        $picked
        $pairIdx
        (let*
            (
                (($a $b) (index-atom $PermPairs $pairIdx))
                (($1 $2) ((index-atom $argLabels $a) (index-atom $argLabels $b)))
            )
            (if (< $b $a)
                ($swapedOp $2 $1)
                ($swapedOp (NOT $1) $2)))))

;; sampleLogicalPerms -> generate logical permutations for boolean expressions
;; Parameters:
;;          $op -> the operator passed from the iterator 
;;          $arity -> the number of arguments in the logical expression
;; Returns:
;;          Union of $perms (the list of logical expressions generated) with args

; (= (sampleLogicalPerms $op $arity) (sampleLogicalPerms $op $arity ()))
;; (: sampleLogicalPerms (-> Atom Number Expression Expression))
(= (sampleLogicalPerms $op $arity $argLabels)
    (let*
        ( 
            ($swapedOp (swapAndOr $op))
            ($list (genList (- $arity 1)))
            ($idxPairs (genPairs $list))
            ($nPairs $arity)) ;; since perm_ratio is 0.0 the max number of n_pairs = arity
            ;; ($nPairs 0) ;; since perm_ratio is 0.0 the max number of n_pairs = arity
            (if (<= $nPairs 1)
                (let $arg (car-atom $argLabels) ($arg (NOT $arg)))  ;; assuming at worst case, only one argument is returned -- representation building process makes sure that those with empty feature set do not make it to actual knob building stage
                (let* (($upperbound (- (* $arity (- $arity 1)) 1))
                        ($picked (lazyRandomSelector 0 $upperbound $nPairs))
                        ($perms (getArgs $swapedOp $idxPairs $picked $argLabels)))
                   (concatT $argLabels $perms)))))

;; getMoveArgs -> Generate move expressions from selected triplet indices.
;; Maps each selected triplet index to its corresponding move expression.
;; Params:
;;          $op: move operator (PRIORITIZED-OR)
;;          $PermPairs: list of pairs of idx permutations
;;          $picked: list of picked move idxs
;;          $moveLabels: list of move labels (playcenter, playcorner, etc.)
;; Returns: move expressions with operator and move combinations
;; (: getMoveArgs (-> Atom Expression Expression Expression Expression))
(= (getMoveArgs $op $PermPairs $picked $moveLabels)
    (map-atom 
          $picked 
          $permIdx
          (let*
            (
                (($a $b $c) (index-atom $PermPairs $permIdx))
                (($move1 $move2 $move3) (
                        (index-atom $moveLabels $a)
                        (index-atom $moveLabels $b)
                        (index-atom $moveLabels $c)))
            )
            ($op $move1 $move2 $move3))))

;; sampleStrategyPerms -> generate strategy permutations for game strategy evolution
;; Params:
;;          $op: the strategy operator (PRIORITIZED-OR)
;;          $arity: the number of moves in the strategy sequence
;;          $moveLabels: list of move labels (playcenter, playblock, playcorner, etc.)
;; Returns:
;;          Union of original moves with alternative move strategy expressions
;; (: sampleStrategyPerms (-> Atom Number Expression Expression))
(= (sampleStrategyPerms $op $arity $moveLabels)
    (let*
        (
            ($list (genList (- (length $moveLabels) 1)))
            ($idxPairs (genTriplet $list))
            ($nPairs $arity)
        )
        (if (<= $nPairs 1)
            ($op (car-atom $moveLabels))
            (let*
                (
                    ($upperbound (- (length $idxPairs) 1))
                    ($picked (lazyRandomSelector 0 $upperbound $nPairs))
                    ($perms (getMoveArgs $op $idxPairs $picked $moveLabels))
                )
                   $perms
            ))))


