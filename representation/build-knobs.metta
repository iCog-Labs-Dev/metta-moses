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
        (if (isActionOperator $rootOp)
            (Error "buildKnobs 4-arity cannot be called with action operator root")
        (if (== $rootOp PRIORITIZED-OR)
            (buildStrategy $exemplar (mkNodeId (0)) $mmp $argLabels)
            (let $canonized (logicalCanonize $exemplar)
                 (let (mkTree (mkNode $canonRootOp) $canonChildren) $canonized
                      (buildLogical $canonized $canonRootOp $mmp $argLabels $disable-discprobe $canonized (mkNodeId (0)))))))))

(= (buildKnobs (mkTree (mkNode $rootOp) $children) $mmp $argLabels $actions $perceptions)
    (if (== $rootOp PRIORITIZED-OR)
        (buildStrategy (mkTree (mkNode PRIORITIZED-OR) $children) (mkNodeId (0)) $mmp $argLabels)
        (if (or (isActionOperator $rootOp) (is-member $rootOp $actions))
            (let*
              (
                ($canonized (actionCanonize (mkTree (mkNode $rootOp) $children)))
                (($updatedTree $updatedMMap) (buildAction $canonized (mkNodeId (0)) $mmp $actions $perceptions))
                ($cleanedTree (actionCleanup $updatedTree))
                ($finalTree (if (isNullVertex $cleanedTree) (mkTree (mkNode and_seq) ()) $cleanedTree))
              )
              ($finalTree $updatedMMap))
            (let $canonized (logicalCanonize (mkTree (mkNode $rootOp) $children))
                 (let (mkTree (mkNode $canonRootOp) $canonChildren) $canonized
                      (buildLogical $canonized $canonRootOp $mmp $argLabels True $canonized (mkNodeId (0))))))))
