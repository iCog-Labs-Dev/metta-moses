!(import! &self ../../utilities/general-helpers) 
!(import! &self ../../utilities/list-methods) 
!(import! &self ../../utilities/map)
!(import! &self ../../utilities/ordered-multimap)
!(import! &self ../../utilities/ordered-set)
!(import! &self ../../utilities/lru-cache)
!(import! &self ../../utilities/lazy-random-selector)
!(import! &self ../../utilities/nodeId)

!(import! &self ../../reduct/boolean-reduct/cut-unnecessary-or)
!(import! &self ../../reduct/boolean-reduct/cut-unnecessary-and)
!(import! &self ../../reduct/boolean-reduct/n-ary-propagate-not)
!(import! &self ../../reduct/boolean-reduct/n-ary-gather-junctors)
!(import! &self ../../reduct/boolean-reduct/delete-inconsistent-handle)
!(import! &self ../../reduct/boolean-reduct/zero-constraint-subsumption)
!(import! &self ../../reduct/boolean-reduct/one-constraint-subsumption)
!(import! &self ../../reduct/boolean-reduct/promote-common-constraints)

!(import! &self ../../reduct/boolean-reduct/rte-helpers)
!(import! &self ../../reduct/boolean-reduct/reduce-to-elegance)

!(import! &self ../../utilities/tree) 

!(import! &self ../../scoring/bscore)
!(import! &self ../../scoring/cscore)

!(import! &self ../../feature-selection/feature-selection-helpers)
!(import! &self ../../feature-selection/select-top-features)
!(import! &self ../../feature-selection/similarity-scorers)
!(import! &self ../../feature-selection/simple)
!(import! &self ../../feature-selection/smd)
!(import! &self ../../feature-selection/random-feature-selection)
!(import! &self ../../feature-selection/incremental)

!(import! &self ../../feature-selection/feature-selection-main)

!(import! &self ../knob-representation)
!(import! &self ../lsk)
!(import! &self ../logical-probe) 
!(import! &self ../sample-logical-perms) 
!(import! &self ../add-logical-knobs)
!(import! &self ../build-logical)
!(import! &self ../build-knobs)
!(import! &self ../knob-mapper)
!(import! &self ../representation)
!(import! &self ../create-representation)





(= (ttable) 
    (mkITable 
        (Cons (Cons False (Cons False (Cons True (Cons True (Cons True Nil)))))
        (Cons (Cons True (Cons False (Cons False (Cons True (Cons True Nil)))))
        (Cons (Cons False (Cons True (Cons False (Cons True (Cons False Nil)))))
        (Cons (Cons False (Cons False (Cons False (Cons True (Cons False Nil))))) Nil))))
        (Cons A (Cons B (Cons C (Cons D (Cons Output Nil)))))))


;; Test for the create representation
;; The test case is the same as the representation test case
;;      if create representation supports feature selection and ignore op it will be different
;; takes exemplar and generates Representation($kbMapKnobMap $updatedExemplar)
; !(assertEqual (createRepresentation (mkTree (mkNode OR) (Cons (mkTree (mkNode C) Nil) Nil)) (A B))
; (mkRep (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (1 2)) 3) (ConsMap ((mkNodeId (1 3)) 2) (ConsMap ((mkNodeId (1 4)) 1) (ConsMap ((mkNodeId (1 5)) 0) (ConsMap ((mkNodeId (2)) 7) (ConsMap ((mkNodeId (3)) 6) (ConsMap ((mkNodeId (4)) 5) (ConsMap ((mkNodeId (5)) 4) NilMap))))))))) (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 5))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (5))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) NilMMap)))))))))) 
; (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil)))))) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil))))))))
;; New test based on improved representation building
!(assertEqual 
    (createRepresentation 
        2
        (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) Nil)) 
        (ttable) 
        sim 
        False
        ; ((E 0.4) (F 0.3) (G 0.73))
        ()
        mi ;; scorerType
        )
       ((mkRep (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (1)) 7) (ConsMap ((mkNodeId (1 1)) 3) (ConsMap ((mkNodeId (1 2)) 2) (ConsMap ((mkNodeId (1 3)) 1) (ConsMap ((mkNodeId (1 4)) 0) (ConsMap ((mkNodeId (2)) 6) (ConsMap ((mkNodeId (3)) 5) (ConsMap ((mkNodeId (4)) 4) NilMap))))))))) (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 1))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) Nil))) NilMMap)))))))))) (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil))))) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil)))))))
    )


(= (table1) (mkITable
                         (Cons (Cons False (Cons False (Cons False Nil))) 
                         (Cons (Cons True (Cons False (Cons False Nil))) 
                         (Cons (Cons False (Cons True (Cons False Nil)))
                         (Cons (Cons True (Cons True (Cons True Nil))) Nil))))
                         (Cons A (Cons B (Cons O Nil)))))

!(assertEqual 
   (createRepresentation 1 (mkTree (mkNode OR) (Cons (mkTree (mkNode B) Nil) Nil)) (table1) sim False () mi)
   ((mkRep (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (1)) 6) (ConsMap ((mkNodeId (1 1)) 2) (ConsMap ((mkNodeId (1 2)) 3) (ConsMap ((mkNodeId (1 3)) 1) (ConsMap ((mkNodeId (1 4)) 0) (ConsMap ((mkNodeId (2)) 7) (ConsMap ((mkNodeId (3)) 5) (ConsMap ((mkNodeId (4)) 4) NilMap))))))))) (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 1))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) NilMMap)))))))))) (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil))))) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil))))))))
