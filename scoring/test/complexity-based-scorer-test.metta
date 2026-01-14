!(import! &self ../complexity-based-scorer)
!(import! &self ../fitness)
!(import! &self ../../representation/instance)

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

!(import! &self ../../representation/lsk)
!(import! &self ../../representation/knob-mapper)
!(import! &self ../../representation/representation)
!(import! &self ../../representation/knob-representation)
!(import! &self ../../representation/logical-probe) 
!(import! &self ../../representation/build-logical)
!(import! &self ../../representation/build-knobs)
!(import! &self ../../representation/sample-logical-perms) 
!(import! &self ../../representation/add-logical-knobs)

!(import! &self ../../utilities/map)
!(import! &self ../../utilities/lazy-random-selector)
!(import! &self ../../utilities/tree) 
!(import! &self ../../utilities/nodeId)
!(import! &self ../../utilities/list-methods) 
!(import! &self ../../utilities/general-helpers) 
!(import! &self ../../utilities/ordered-multimap)
!(import! &self ../../utilities/ordered-set)
!(import! &self ../../utilities/lru-cache)

!(import! &self ../../scoring/bscore)
!(import! &self ../../scoring/cscore)

!(import! &self ../../feature-selection/feature-selection-helpers)
!(import! &self ../../feature-selection/feature-selection-main)
!(import! &self ../../feature-selection/select-top-features)
!(import! &self ../../feature-selection/similarity-scorers)
!(import! &self ../../feature-selection/simple)
!(import! &self ../../feature-selection/smd)
!(import! &self ../../feature-selection/random-feature-selection)
!(import! &self ../../feature-selection/incremental)


;;!(import! &self ../../utilities/python-treehelpers)

;; TODO: Add REDUCE Function here when it's edge case if fixed.
(= (APPEND_CHILD $tree $nodeId $child ) (py_appendChild $tree $nodeId $child))

(= (tree1)
        (mkTree (mkNode AND)
          (Cons (mkTree (mkNode A) Nil)
          (Cons (mkTree (mkNode OR)
                  (Cons (mkTree (mkNode B) Nil)
                  (Cons (mkTree (mkNode C) Nil)
                  (Cons (mkNullVex
                          (Cons (mkTree (mkNode D) Nil) Nil)) Nil))))
          (Cons (mkNullVex
                  (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) Nil)) Nil)) Nil)))))

(= (lsk1)
        (mkLSK
            (mkDiscKnob
              (mkKnob (mkNodeId (2 3)))
              (mkMultip 3)
              (mkDiscSpec 0)
              (mkDiscSpec 0)
              Nil)
            ))

(= (lsk2)
        (mkLSK
            (mkDiscKnob
              (mkKnob (mkNodeId (3)))
              (mkMultip 3)
              (mkDiscSpec 0)
              (mkDiscSpec 0)
              Nil)
            ))

(= (lsk3)
        (mkLSK
            (mkDiscKnob
              (mkKnob (mkNodeId (1)))
              (mkMultip 3)
              (mkDiscSpec 1)
              (mkDiscSpec 1)
              Nil)
            ))

(= (knobMapObj) (mkKbMap
                      (mkDscKbMp (ConsMap ((mkNodeId (2 3)) 0) (ConsMap ((mkNodeId (3)) 1) (ConsMap ((mkNodeId (1)) 2) NilMap))))
               
                      (mkDscMp (ConsMMap ((mkDiscSpec 1) (lsk1)) (ConsMMap ((mkDiscSpec 0) (lsk2)) (ConsMMap ((mkDiscSpec 1) (lsk3)) NilMMap))))))
(= (ttable1) (mkITable (Cons (Cons True (Cons False (Cons False (Cons True (Cons True Nil)))))
                        (Cons (Cons True (Cons True (Cons True (Cons False (Cons True Nil))))) Nil))
                        (Cons A (Cons B (Cons C (Cons D (Cons O Nil)) )))))
(= (ttable2) (mkITable
                    (Cons (Cons True (Cons True (Cons False (Cons True (Cons True Nil)))))
                    (Cons (Cons True (Cons False (Cons False (Cons True (Cons True Nil)))))
                    (Cons (Cons False (Cons True (Cons False (Cons True (Cons False Nil)))))
                    (Cons (Cons False (Cons False (Cons False (Cons True (Cons False Nil))))) Nil))))
                    (Cons A (Cons B (Cons C (Cons D (Cons Output Nil)))))))

;; Testcases for the complexityBasedScorer
!(assertEqual 
 (complexityBasedScorer 
         (mkRep (knobMapObj) (tree1))
         (mkInst (Cons 2 (Cons 0 (Cons 1 Nil))))
         (ttable1)
         2.0)
 (mkCscore -1 4 2.0 0.0 -3.0))

!(assertEqual
 (complexityBasedScorer 
         (mkRep (knobMapObj) (tree1))
         (mkInst (Cons 1 (Cons 0 (Cons 1 Nil))))
         (ttable2)
         2.0)
 (mkCscore 0 4 2.0 0.0 -2.0))
 