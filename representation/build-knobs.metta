;;;; buildKnobs constructor that is directly called by the representation constructor
;; Params: Tree (Exemplar)
;;         $mmp: multimap to store knobs
;;         $argLabels: list of argument labels (input variables) from the ITable
;;         $ignoreOps: operators that knob building must not add
;; Returns: a tuple containing the updatedTree and a multimap of $kbSpec $kb pairs
;; (: buildKnobs (-> (Tree Bool) (MultiMap ($k $v)) Expression ((Tree $a) (MultiMap ($k $v)))))
(= (buildKnobs $exemplar $mmp $argLabels)
    (buildKnobs $exemplar $mmp $argLabels True (param ignoreOps)))

(= (buildKnobs $exemplar $mmp $argLabels $discProbeDisabled $ignoreOps)
    (let (mkTree (mkNode $rootOp) $children) $exemplar
        (if (isActionOperator $rootOp)
            (Error "buildKnobs 5-arity cannot be called with action operator root")
            (let* (($canonized (logicalCanonize $exemplar))
                   ((mkTree (mkNode $canonRootOp) $canonChildren) $canonized))
                (buildLogical $canonized $canonRootOp $mmp $argLabels $discProbeDisabled $canonized (mkNodeId (0)) $ignoreOps)))))

(= (buildKnobs (mkTree (mkNode $rootOp) $children) $mmp $argLabels $actions $perceptions $ignoreOps)
    ;; Inline membership test: isDomainAction is in build-action, which some
    ;; contexts load after this file.
    (if (or (isActionOperator $rootOp) (once (is-member $rootOp $actions)))
        (let*
          (
            ($canonized (actionCanonize (mkTree (mkNode $rootOp) $children)))
            (($updatedTree $updatedMMap) (buildAction $canonized $mmp $actions $perceptions $ignoreOps))
            ($cleanedTree (actionCleanup $updatedTree))
            ($finalTree (if (isNullVertex $cleanedTree) (mkTree (mkNode and_seq) ()) $cleanedTree))
          )
          ($finalTree $updatedMMap))
        ;; Not an action root, so the 5-arity action guard does not fire.
        (buildKnobs (mkTree (mkNode $rootOp) $children) $mmp $argLabels True $ignoreOps)))