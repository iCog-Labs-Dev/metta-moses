;; Permutation sampling for logical knob building. Only ~arity random
;; pairs are ever needed, so rather than enumerating the whole list we
;; map each random index straight to its pair (pairAt),
;; mirroring classic build_knobs::sample_logical_perms.

(= (intDiv $a $b) (floor-math (/ $a $b)))

;; $i-th ordered pair ($a $b), $a != $b, over {0 .. $n-1} in lexicographic order
(= (pairAt $n $i)
    (let* (($d (- $n 1))
           ($a (intDiv $i $d))
           ($j (% $i $d))
           ($b (if (< $j $a) $j (+ $j 1))))
        ($a $b)))

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


;; Generate a logical candidate unless its operator is ignored.
(= (makeLogicalCandidate $op $a $b $ignoreOps)
      (if (operatorAllowed $op $ignoreOps)
          (cons-atom $op (cons-atom $a (cons-atom $b ())))
          ()))


(= (makeLogicalNotCandidate $op $a $b $ignoreOps)
      (if (and
             (operatorAllowed $op $ignoreOps)
             (operatorAllowed NOT $ignoreOps))
          (cons-atom $op (cons-atom (cons-atom NOT (cons-atom $a ())) (cons-atom $b ())))
          ()))

;; getArgs -> generate logical expressions for the picked permutation indices
;; Parameters:
;;          $swapedOp -> swaped operator
;;          $n -> number of argument labels (index space {0 .. $n-1})
;;          $picked -> list of picked idxs
;; (: getArgs (-> Atom Number Expression Expression Expression))
(= (getArgs $op $n $picked $argLabels $ignoreOps)
    (filter-atom
        (map-atom $picked $i
            (let*
                (
                    (($a $b) (pairAt $n $i))
                    ($1 (index-atom $argLabels $a))
                    ($2 (index-atom $argLabels $b))
                )
                (if (< $b $a)
                    (makeLogicalCandidate $op $2 $1 $ignoreOps)
                    (makeLogicalNotCandidate $op $1 $2 $ignoreOps))))
        $perm
        (!= $perm ())))

;; sampleLogicalPerms -> generate logical permutations for boolean expressions
;; Parameters:
;;          $op -> the operator passed from the iterator
;;          $arity -> the number of arguments in the logical expression
;; Returns:
;;          Union of $perms (the list of logical expressions generated) with args
;; (: sampleLogicalPerms (-> Atom Number Expression Expression))
(= (sampleLogicalPerms $op $arity $argLabels $ignoreOps)
    (let* (($swapedOp (swapAndOr $op))
           ($nPairs $arity)) ;; since perm_ratio is 0.0 the max number of n_pairs = arity
        (if (<= $nPairs 1)
            (let $arg (car-atom $argLabels)
                     (if (operatorAllowed NOT $ignoreOps)
                         (quote ($arg (NOT $arg)))
                         (cons-atom $arg ()))) ;; assuming at worst case, only one argument is returned -- representation building process makes sure that those with empty feature set do not make it to actual knob building stage;; Preserve the argument even when NOT is ignored.
            (let* (($upperbound (- (* $arity (- $arity 1)) 1))
                   ($picked (lazyRandomSelector 0 $upperbound $nPairs))
                   ($perms (getArgs $swapedOp $arity $picked $argLabels $ignoreOps)))
               (concatT $argLabels $perms)))))
