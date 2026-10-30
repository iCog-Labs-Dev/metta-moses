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

;; getArgs -> generate logical expressions for the picked permutation indices
;; Parameters:
;;          $op -> the operator (callers pass the swapped operator)
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
                    (if (operatorAllowed $op $ignoreOps)
                        (quote ($op $2 $1))
                        ())
                    (if (and (operatorAllowed $op $ignoreOps)
                             (operatorAllowed NOT $ignoreOps))
                        (quote ($op (NOT $1) $2))
                        ())
                    )))
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
                         (quote ($arg)))) ;; assuming at worst case, only one argument is returned -- representation building process makes sure that those with empty feature set do not make it to actual knob building stage;; Preserve the argument even when NOT is ignored.
            (let* (($upperbound (- (* $arity (- $arity 1)) 1))
                   ($picked (lazyRandomSelector 0 $upperbound $nPairs))
                   ($perms (getArgs $swapedOp $arity $picked $argLabels $ignoreOps)))
               (concatT $argLabels $perms)))))
