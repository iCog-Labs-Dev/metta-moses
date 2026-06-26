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
;; Uses deterministic iterative helpers to construct the pair list.
;; (: genPairs (-> Expression Expression))
(= (genPairs $list)
    (pairOuterLoop $list 0 (size-atom $list)))

;; tripletInnerLoop -> selects third element (k) and  complete valid triplets.  
;; Type: (-> Expression Number Number Number Number Expression)
(= (tripletInnerLoop $list $i $j $k $size)
    (if (>= $k $size)
        ()
        (if (or (== $k $i) (== $k $j))
            (tripletInnerLoop $list $i $j (+ $k 1) $size)
            (cons-atom ((index-atom $list $i) (index-atom $list $j) (index-atom $list $k))
                        (tripletInnerLoop $list $i $j (+ $k 1) $size)))))

;; tripletMidLoop -> selects second element (j) for each anchor and 
;;                    prepares context for candidate selection.
;; Type: (-> Expression  Number Number Number Expression)
(= (tripletMidLoop $list $i $j $size)
    (if (>= $j $size)
        ()
        (if (== $i $j)
            (tripletMidLoop $list $i (+ $j 1) $size)
            (append (tripletInnerLoop $list $i $j 0 $size)
                    (tripletMidLoop $list $i (+ $j 1) $size)))))

;; tripletOutLoop -> fixes first element of the triplet and 
;;                    Drives the outermost iteration over all list elements.
;; Type: (-> Expression  Number Number Expression)
(= (tripletOutLoop $list $i $size)
    (if (>= $i $size)
        ()
        (append
            (tripletMidLoop $list $i 0 $size)
            (tripletOutLoop $list (+ $i 1) $size))))


;; genTriplet -> Generate all valid ordered triplets from a list.
;;               Uses the iterative anchor–pivot–candidate traversal to avoid nondeterministic evaluation.
;; (: genTriplet (-> Expression Expression))
(= (genTriplet $list)
    (tripletOutLoop $list 0 (size-atom $list)))

;; getArgsIter -> Iterative evaluator for logical argument generation.
;;              Walks through selected pair indices (picked list) deterministically.
;;              Builds expressions using anchor–partner index pairs from PermPairs.
;;Replaces nondeterministic superpose-based evaluation.
(= (getArgsIter $swapedOp $PermPairs $picked $argLabels $i $size)
    (if (>= $i $size)
        ()
        (let*
            (
                ($pairIdx (index-atom $picked $i))
                (($a $b) (index-atom $PermPairs $pairIdx))
                (($1 $2) ((index-atom $argLabels $a) (index-atom $argLabels $b)))

                ($expr (if (< $b $a) ($swapedOp $2 $1) ($swapedOp (NOT $1) $2))))
            (cons-atom $expr (getArgsIter $swapedOp $PermPairs $picked $argLabels (+ $i 1) $size)))))

;; getArgs ->  Produces deterministic tuple of logical expressions.
;; Parameters:
;;          $swapedOp -> swaped operator
;;          $PermPairs -> list of pairs of idx permutations
;;          $picked -> list of picked idxs
;; (: getArgs (-> Atom Expression Expression Expression Expression))
(= (getArgs $swapedOp $PermPairs $picked $argLabels)
    (getArgsIter $swapedOp $PermPairs $picked $argLabels 0 (size-atom $picked)))

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


;; Iterative evaluator for move expression generation.
;; Traverses selected triplet indices deterministically.
;; Builds move expressions using anchor–pivot–candidate structure.
;; Replaces superpose-based nondeterministic selection.
(= (getMoveArgsIter $op $PermPairs $picked $moveLabels $i $size)
    (if (>= $i $size)
        ()
        (let*
            (
                ($permIdx (index-atom $picked $i))
                (($a $b $c) (index-atom $PermPairs $permIdx))
                (($move1 $move2 $move3)
                    ((index-atom $moveLabels $a)
                     (index-atom $moveLabels $b) 
                     (index-atom $moveLabels $c)))
            )
            (cons-atom ($op $move1 $move2 $move3) 
                       (getMoveArgsIter $op $PermPairs $picked $moveLabels (+ $i 1) $size)))))
                       
;; getMoveArgs -> generate move expressions from pairs of move indices
;; Params:
;;          $op: move operator (PRIORITIZED-OR)
;;          $PermPairs: list of pairs of idx permutations
;;          $picked: list of picked move idxs
;;          $moveLabels: list of move labels (playcenter, playcorner, etc.)
;; Returns: move expressions with operator and move combinations
;; (: getMoveArgs (-> Atom Expression Expression Expression Expression))
(= (getMoveArgs $op $PermPairs $picked $moveLabels)
    (getMoveArgsIter $op $PermPairs $picked $moveLabels 0 (size-atom $picked)))

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
