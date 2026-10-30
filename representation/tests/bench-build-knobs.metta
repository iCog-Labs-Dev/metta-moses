;; Micro-benchmark for the representation-building hot path.
;; Seeds the RNG so permutation sampling is identical across runs, then builds
;; knobs repeatedly with disc-probing enabled (the expensive configuration).
;; Run:  sh $(command -v run.sh) representation/tests/bench-build-knobs.metta -s

!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/ordered-multimap)
!(import! &self ../../utilities/lazy-random-selector)
!(import! &self ../../utilities/nodeId)

!(import! &self ../../reduct/boolean-reduct/rte-helpers)
!(import! &self ../../reduct/boolean-reduct/cut-unnecessary-or)
!(import! &self ../../reduct/boolean-reduct/cut-unnecessary-and)
!(import! &self ../../reduct/boolean-reduct/n-ary-propagate-not)
!(import! &self ../../reduct/boolean-reduct/n-ary-gather-junctors)
!(import! &self ../../reduct/boolean-reduct/delete-inconsistent-handle)
!(import! &self ../../reduct/boolean-reduct/zero-constraint-subsumption)
!(import! &self ../../reduct/boolean-reduct/one-constraint-subsumption)
!(import! &self ../../reduct/boolean-reduct/promote-common-constraints)
!(import! &self ../../reduct/boolean-reduct/reduce-to-elegance)

!(import! &self ../../utilities/tree)

!(import! &self ../../representation/knob-representation)
!(import! &self ../../representation/lsk)
!(import! &self ../../representation/disc-probe)
!(import! &self ../../representation/logical-probe)
!(import! &self ../../representation/logical-canonize)
!(import! &self ../../representation/sample-logical-perms)
!(import! &self ../../representation/add-logical-knobs)
!(import! &self ../../representation/build-logical)
!(import! &self ../../representation/build-knobs)

!(py-call (random.seed 20240902))

(= (benchLabels) (A B C D))

(= (benchExemplar)
   (buildTree (AND (OR A (AND B C)) (OR (AND D A) (NOT B)))))

;; One iteration = a full knob build with disc-probe enabled (4th arg False).
(= (benchOnce)
   (let ($tree $mmap) (buildKnobs (benchExemplar) () (benchLabels) False)
      (treeComplexity $tree)))

(= (benchLoop $n $acc)
   (if (<= $n 0)
       $acc
       (benchLoop (- $n 1) (+ $acc (benchOnce)))))

!(benchLoop 10 0)
