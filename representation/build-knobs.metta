;;;; buildKnobs constructor that is directly called by the representation constructor
;; Dispatches to the appropriate builder based on the root operator of the exemplar:
;;   PRIORITIZED-OR            → buildStrategy  (game strategy domain)
;;   SEQUENTIAL-AND / ACTION-BOOLEAN-IF → buildAction     (action domain)
;;   anything else             → buildLogical   (boolean logic domain)
;; Params: Tree (Exemplar)
;;         $mmp: multimap to store knobs
;;         $argLabels: list of argument labels (input variables) from the ITable
;; Returns: a tuple containing the updatedTree and a multimap of $kbSpec $kb pairs
;; (: buildKnobs (-> (Tree Bool) (MultiMap ($k $v)) Expression ((Tree $a) (MultiMap ($k $v)))))
(= (buildKnobs $exemplar $mmp $argLabels)
    (let (mkTree (mkNode $rootOp) $children) $exemplar
        (if (== $rootOp PRIORITIZED-OR)
            (buildStrategy $exemplar (mkNodeId (0)) $mmp $argLabels)
            (if (or (== $rootOp SEQUENTIAL-AND) (== $rootOp ACTION-BOOLEAN-IF))
                (buildAction $exemplar (mkNodeId (0)) $mmp)
                (let $canonized (logicalCanonize $exemplar)
                     (buildLogical $canonized (mkNodeId (0)) $mmp $argLabels))))))
