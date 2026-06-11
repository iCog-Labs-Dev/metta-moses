;;;; buildKnobs constructor that is directly called by the representaion constructor
;; Params: Tree (Exemplar)
;;         $mmp: multimap to store knobs
;;         $argLabels: list of argument labels (input variables) from the ITable
;; Returns: a tuple containing the updatedTree and a multimap of $kbSpec $kb pairs 
 ;; (: buildKnobs (-> (Tree Bool) (MultiMap ($k $v)) Expression ((Tree $a) (MultiMap ($k $v)))))
(= (buildKnobs $exemplar $mmp $argLabels)
    (buildKnobs $exemplar $mmp $argLabels True))

(= (buildKnobs $exemplar $mmp $argLabels $disable-discprobe)
    (let (mkTree (mkNode $rootOp) $children) $exemplar
        (if (== $rootOp PRIORITIZED-OR)
            (buildStrategy $exemplar (mkNodeId (0)) $mmp $argLabels)
            (let $canonized (logicalCanonize $exemplar)
                 (let (mkTree (mkNode $canonRootOp) $canonChildren) $canonized
                      (buildLogical $canonized $canonRootOp $mmp $argLabels $disable-discprobe $canonized (mkNodeId (0))))))))
