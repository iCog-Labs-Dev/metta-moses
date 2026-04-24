!(import! &self ../../utilities/general-helpers) 
!(import! &self ../../utilities/list-methods) 
!(import! &self ../../utilities/map)
!(import! &self ../../utilities/ordered-set)
!(import! &self ../../utilities/ordered-multimap)
!(import! &self ../../utilities/lazy-random-selector)
!(import! &self ../../utilities/lru-cache)
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
!(import! &self ../../representation/logical-probe) 
!(import! &self ../../representation/logical-canonize)
!(import! &self ../../representation/sample-logical-perms) 
!(import! &self ../../representation/add-logical-knobs)
!(import! &self ../../representation/build-logical)
!(import! &self ../../representation/build-knobs)
!(import! &self ../../representation/knob-mapper)
!(import! &self ../../representation/representation)
!(import! &self ../../representation/instance)

!(import! &self ../fitness)
!(import! &self ../../scoring/bscore)
!(import! &self ../../scoring/cscore)

!(import! &self ../complexity-based-scorer)

!(import! &self ../../feature-selection/feature-selection-helpers)
!(import! &self ../../feature-selection/similarity-scorers)
!(import! &self ../../feature-selection/simple)
!(import! &self ../../feature-selection/smd)
!(import! &self ../../feature-selection/random-feature-selection)
!(import! &self ../../feature-selection/incremental)
!(import! &self ../../feature-selection/select-top-features)
!(import! &self ../../feature-selection/feature-selection-main)


(= (tree1)
        (mkTree (mkNode AND)
          (cons (mkTree (mkNode A) ())
          (cons (mkTree (mkNode OR)
                  (cons (mkTree (mkNode B) ())
                  (cons (mkTree (mkNode C) ())
                  (cons (mkNullVex
                          (cons (mkTree (mkNode D) ()) ())) ()))))
          (cons (mkNullVex
                  (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) ())) ())) ())))))

(= (lsk1)
        (mkLSK
            (mkDiscKnob
              (mkKnob (mkNodeId (2 3)))
              (mkMultip 3)
              (mkDiscSpec 0)
              (mkDiscSpec 0)
              ())
            ))

(= (lsk2)
        (mkLSK
            (mkDiscKnob
              (mkKnob (mkNodeId (3)))
              (mkMultip 3)
              (mkDiscSpec 0)
              (mkDiscSpec 0)
              ())
            ))

(= (lsk3)
        (mkLSK
            (mkDiscKnob
              (mkKnob (mkNodeId (1)))
              (mkMultip 3)
              (mkDiscSpec 1)
              (mkDiscSpec 1)
              ())
            ))

(= (knobMapObj) (mkKbMap
                      (mkDscKbMp (cons ((mkNodeId (2 3)) 0) (cons ((mkNodeId (3)) 1) (cons ((mkNodeId (1)) 2) ()))))
               
                      (mkDscMp (cons ((mkDiscSpec 1) (lsk1)) (cons ((mkDiscSpec 0) (lsk2)) (cons ((mkDiscSpec 1) (lsk3)) ()))))))
(= (ttable1) (mkITable (cons (cons True (cons False (cons False (cons True (cons True ())))))
                        (cons (cons True (cons True (cons True (cons False (cons True ()))))) ()))
                        (cons A (cons B (cons C (cons D (cons O ())) )))))
(= (ttable2) (mkITable
                    (cons (cons True (cons True (cons False (cons True (cons True ())))))
                    (cons (cons True (cons False (cons False (cons True (cons True ())))))
                    (cons (cons False (cons True (cons False (cons True (cons False ())))))
                    (cons (cons False (cons False (cons False (cons True (cons False ()))))) ()))))
                    (cons A (cons B (cons C (cons D (cons Output ())))))))

;; Testcases for the complexityBasedScorer
!(assertEqual 
 (complexityBasedScorer 
         (mkRep (knobMapObj) (tree1))
         (mkInst (cons 2 (cons 0 (cons 1 ()))))
         (ttable1)
         2.0)
 (mkCscore -1 4 2.0 0.0 -3.0))

!(assertEqual
 (complexityBasedScorer 
         (mkRep (knobMapObj) (tree1))
         (mkInst (cons 1 (cons 0 (cons 1 ()))))
         (ttable2)
         2.0)
 (mkCscore 0 4 2.0 0.0 -2.0))
 
