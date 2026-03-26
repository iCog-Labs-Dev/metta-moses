;;;; buildKnobs constructor that is directly called by the representaion constructor
;; Params: Tree (Exemplar)
;;         $mmp: multimap to store knobs
;;         $argLabels: list of argument labels (input variables) from the ITable
;; Returns: a tuple containing the updatedTree and a multimap of $kbSpec $kb pairs 
 ;; (: buildKnobs (-> (Tree Bool) (MultiMap ($k $v)) Expression ((Tree $a) (MultiMap ($k $v)))))
(= (buildKnobs $exemplar $mmp $argLabels)
    (let (mkTree (mkNode $rootOp) $children) $exemplar
        (if (== $rootOp PRIORITIZED-OR)
            (buildStrategy $exemplar (mkNodeId (0)) $mmp $argLabels)
            (let $canonized (logicalCanonize $exemplar) (buildLogical $canonized (mkNodeId (0)) $mmp $argLabels)))))
