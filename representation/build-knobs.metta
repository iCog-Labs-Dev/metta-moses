;;;; buildKnobs constructor that is directly called by the representaion constructor
;; Params: Tree (Exemplar)
;; Returns: a tuple containing the updatedTree and a multimap of $kbSpec $kb pairs 
(: buildKnobs (-> (Tree Bool) (MultiMap ($k $v)) ((Tree $a) (MultiMap ($k $v)))))
(= (buildKnobs $exemplar $mmp)
(buildLogical $exemplar (mkNodeId (0)) $mmp))