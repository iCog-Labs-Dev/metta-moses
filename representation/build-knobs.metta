;;;; buildKnobs constructor that is directly called by the representaion constructor
;; Params: Tree (Exemplar)
;;         $mmp: multimap to store knobs
;;         $argLabels: list of argument labels (input variables) from the ITable
;; Returns: a tuple containing the updatedTree and a multimap of $kbSpec $kb pairs
 ;; (: buildKnobs (-> (Tree Bool) (MultiMap ($k $v)) Expression ((Tree $a) (MultiMap ($k $v)))))
;; Excludes operators from candidate generation.
(= (buildKnobs $exemplar $mmp $argLabels)
    (buildKnobs $exemplar $mmp $argLabels True (param ignoreOps)))

(= (buildKnobs $exemplar $mmp $argLabels $disable-discprobe $ignoreOps)
    (let (mkTree (mkNode $rootOp) $children) $exemplar
        (if (isActionOperator $rootOp)
            (Error "buildKnobs 5-arity cannot be called with action operator root")
            (let $canonized (logicalCanonize $exemplar)
                (let (mkTree (mkNode $canonRootOp) $canonChildren) $canonized
                    (buildLogical $canonized $canonRootOp $mmp $argLabels $disable-discprobe $canonized (mkNodeId (0)) $ignoreOps))))))


(= (buildKnobs (mkTree (mkNode $rootOp) $children) $mmp $argLabels $actions $perceptions $ignoreOps)
        (if (or (isActionOperator $rootOp) (once (is-member $rootOp $actions))) ;; is-member A (A A B B) true, true
            (let*
              (
                ($canonized (actionCanonize (mkTree (mkNode $rootOp) $children)))
                (($updatedTree $updatedMMap) (buildAction $canonized $mmp $actions $perceptions $ignoreOps))
                ($cleanedTree (actionCleanup $updatedTree))
                ($finalTree (if (isNullVertex $cleanedTree) (mkTree (mkNode and_seq) ()) $cleanedTree))
              )
              ($finalTree $updatedMMap))
            (let $canonized (logicalCanonize (mkTree (mkNode $rootOp) $children))
                 (let (mkTree (mkNode $canonRootOp) $canonChildren) $canonized
                      (buildLogical $canonized $canonRootOp $mmp $argLabels True $canonized (mkNodeId (0)))))))
