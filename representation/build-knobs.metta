;;;; buildKnobs constructor that is directly called by the representation constructor
;; Dispatches to the appropriate builder based on the root operator of the exemplar:
;;   PRIORITIZED-OR            → buildStrategy  (game strategy domain)
;;   SEQUENTIAL-AND / ACTION-BOOLEAN-IF → buildAction     (action domain)
;;   anything else             → buildLogical   (boolean logic domain)
;; Params: Tree (Exemplar)
;;         $mmp: multimap to store knobs
;;         $argLabels: list of argument labels (input variables) from the ITable
;;         $disable-discprobe: when False, buildLogical runs disc probing to prune redundant settings
;; Returns: a tuple containing the updatedTree and a multimap of $kbSpec $kb pairs
;; (: buildKnobs (-> (Tree Bool) (MultiMap ($k $v)) Expression ((Tree $a) (MultiMap ($k $v)))))
;; 3-arg form keeps disc probing disabled by default; representation.metta uses the 4-arg form.
(= (buildKnobs $exemplar $mmp $argLabels)
    (buildKnobs $exemplar $mmp $argLabels True))

(= (buildKnobs $exemplar $mmp $argLabels $disable-discprobe)
    (let (mkTree (mkNode $rootOp) $children) $exemplar
        (if (== $rootOp PRIORITIZED-OR)
            (buildStrategy $exemplar (mkNodeId (0)) $mmp $argLabels)
            (if (or (== $rootOp SEQUENTIAL-AND) (== $rootOp ACTION-BOOLEAN-IF))
                (buildAction $exemplar (mkNodeId (0)) $mmp)
                (let $domain (getDiscreteDomain)
                     (if (not (== $domain ()))
                         (buildDiscrete $exemplar (mkNodeId (0)) $mmp $domain)
                         (let $canonized (logicalCanonize $exemplar)
                              (buildLogical $canonized (mkNodeId (0)) $mmp $argLabels $disable-discprobe))))))))
