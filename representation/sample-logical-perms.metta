;; Permutation sampling for logical / strategy knob building. Only ~arity random
;; pairs/triplets are ever needed, so rather than enumerating the whole list we
;; map each random index straight to its pair/triplet (pairAt / tripletAt),
;; mirroring classic build_knobs::sample_logical_perms.

(= (intDiv $a $b) (floor-math (/ $a $b)))

;; $i-th ordered pair ($a $b), $a != $b, over {0 .. $n-1} in lexicographic order
(= (pairAt $n $i)
    (let* (($d (- $n 1))
           ($a (intDiv $i $d))
           ($j (% $i $d))
           ($b (if (< $j $a) $j (+ $j 1))))
        ($a $b)))

;; $i-th ordered triplet of distinct ($x $y $z) over {0 .. $n-1}; each $x owns a
;; block of (n-1)(n-2) triplets whose ($y $z) come from pairAt over the rest
(= (tripletAt $n $i)
    (let* (($m (- $n 1))
           ($per (* $m (- $m 1)))
           ($x (intDiv $i $per))
           ($k (% $i $per))
           (($p $q) (pairAt $m $k))
           ($y (if (< $p $x) $p (+ $p 1)))
           ($z (if (< $q $x) $q (+ $q 1))))
        ($x $y $z)))

;; genPairs / genTriplet: deterministic full enumerations, kept as utilities
;; (: genPairs (-> Expression Expression))
(= (genPairs $list) (genPairsLoop $list $list))

(= (genPairsLoop $xs $full)
    (if (== $xs ())
        ()
        (let* (($x (car-atom $xs))
               ($rest (cdr-atom $xs)))
            (pairWith $x $full (genPairsLoop $rest $full)))))

(= (pairWith $x $ys $tail)
    (if (== $ys ())
        $tail
        (let* (($y (car-atom $ys))
               ($rest (cdr-atom $ys)))
            (if (== $x $y)
                (pairWith $x $rest $tail)
                (cons-atom ($x $y) (pairWith $x $rest $tail))))))

;; (: genTriplet (-> Expression Expression))
(= (genTriplet $list) (genTripletLoop $list (genPairs $list)))

(= (genTripletLoop $xs $pairs)
    (if (== $xs ())
        ()
        (let* (($x (car-atom $xs))
               ($rest (cdr-atom $xs)))
            (tripletWith $x $pairs (genTripletLoop $rest $pairs)))))

(= (tripletWith $x $pairs $tail)
    (if (== $pairs ())
        $tail
        (let* (($p (car-atom $pairs))
               ($rest (cdr-atom $pairs))
               (($y $z) $p))
            (if (and (!= $x $y) (!= $x $z))
                (cons-atom ($x $y $z) (tripletWith $x $rest $tail))
                (tripletWith $x $rest $tail)))))

;; getArgs -> generate logical expressions for the picked permutation indices
;; Parameters:
;;          $swapedOp -> swaped operator
;;          $n -> number of argument labels (index space {0 .. $n-1})
;;          $picked -> list of picked idxs
;; (: getArgs (-> Atom Number Expression Expression Expression))
(= (getArgs $swapedOp $n $picked $argLabels)
    (if (== $picked ())
        ()
        (let* (($i (car-atom $picked))
               ($rest (cdr-atom $picked))
               (($a $b) (pairAt $n $i))
               ($1 (index-atom $argLabels $a))
               ($2 (index-atom $argLabels $b))
               ($expr (if (< $b $a)
                          ($swapedOp $2 $1)
                          ($swapedOp (NOT $1) $2))))
            (cons-atom $expr (getArgs $swapedOp $n $rest $argLabels)))))

;; sampleLogicalPerms -> generate logical permutations for boolean expressions
;; Parameters:
;;          $op -> the operator passed from the iterator
;;          $arity -> the number of arguments in the logical expression
;; Returns:
;;          Union of $perms (the list of logical expressions generated) with args
;; (: sampleLogicalPerms (-> Atom Number Expression Expression))
(= (sampleLogicalPerms $op $arity $argLabels)
    (let* (($swapedOp (swapAndOr $op))
           ($nPairs $arity)) ;; since perm_ratio is 0.0 the max number of n_pairs = arity
        (if (<= $nPairs 1)
            (let $arg (car-atom $argLabels) ($arg (NOT $arg)))  ;; assuming at worst case, only one argument is returned -- representation building process makes sure that those with empty feature set do not make it to actual knob building stage
            (let* (($upperbound (- (* $arity (- $arity 1)) 1))
                   ($picked (lazyRandomSelector 0 $upperbound $nPairs))
                   ($perms (getArgs $swapedOp $arity $picked $argLabels)))
               (concatT $argLabels $perms)))))

;; getMoveArgs -> generate move expressions for the picked triplet indices
;; Params:
;;          $op: move operator (PRIORITIZED-OR)
;;          $n: number of move labels (index space {0 .. $n-1})
;;          $picked: list of picked triplet idxs
;;          $moveLabels: list of move labels (playcenter, playcorner, etc.)
;; (: getMoveArgs (-> Atom Number Expression Expression Expression))
(= (getMoveArgs $op $n $picked $moveLabels)
    (if (== $picked ())
        ()
        (let* (($i (car-atom $picked))
               ($rest (cdr-atom $picked))
               (($a $b $c) (tripletAt $n $i))
               ($move1 (index-atom $moveLabels $a))
               ($move2 (index-atom $moveLabels $b))
               ($move3 (index-atom $moveLabels $c)))
            (cons-atom ($op $move1 $move2 $move3)
                       (getMoveArgs $op $n $rest $moveLabels)))))

;; sampleStrategyPerms -> generate strategy permutations for game strategy evolution
;; Params:
;;          $op: the strategy operator (PRIORITIZED-OR)
;;          $arity: the number of moves in the strategy sequence
;;          $moveLabels: list of move labels (playcenter, playblock, playcorner, etc.)
;; Returns:
;;          Union of original moves with alternative move strategy expressions
;; (: sampleStrategyPerms (-> Atom Number Expression Expression))
(= (sampleStrategyPerms $op $arity $moveLabels)
    (let* (($n (length $moveLabels))
           ($nPairs $arity))
        (if (<= $nPairs 1)
            ($op (car-atom $moveLabels))
            (let* (($upperbound (- (* $n (* (- $n 1) (- $n 2))) 1))
                   ($picked (lazyRandomSelector 0 $upperbound $nPairs))
                   ($perms (getMoveArgs $op $n $picked $moveLabels)))
               $perms))))
