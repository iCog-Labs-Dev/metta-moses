!(import! &self ../../utilities/general-helpers) 
!(import! &self ../../utilities/list-methods) 
!(import! &self ../../utilities/map)
!(import! &self ../../utilities/ordered-multimap)
!(import! &self ../../utilities/ordered-set)
!(import! &self ../../utilities/lru-cache)
!(import! &self ../../utilities/lazy-random-selector)
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
!(import! &self ..//logical-canonize)
!(import! &self ../sample-logical-perms) 
!(import! &self ../add-logical-knobs)
!(import! &self ../build-logical)
!(import! &self ../build-knobs)
!(import! &self ../knob-mapper)
!(import! &self ../representation)
!(import! &self ../create-representation)





(= (ttable) 
    (mkITable 
        (cons (cons False (cons False (cons True (cons True (cons True ())))))
        (cons (cons True (cons False (cons False (cons True (cons True ())))))
        (cons (cons False (cons True (cons False (cons True (cons False ())))))
        (cons (cons False (cons False (cons False (cons True (cons False ()))))) ()))))
        (cons A (cons B (cons C (cons D (cons Output ())))))))


;; Test for the create representation
;; The test case is the same as the representation test case
;;      if create representation supports feature selection and ignore op it will be different
;; takes exemplar and generates Representation($kbMapKnobMap $updatedExemplar)
; !(assertEqual (createRepresentation (mkTree (mkNode OR) (cons (mkTree (mkNode C) ()) ())) (A B))
; (mkRep (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (1 2)) 3) (ConsMap ((mkNodeId (1 3)) 2) (ConsMap ((mkNodeId (1 4)) 1) (ConsMap ((mkNodeId (1 5)) 0) (ConsMap ((mkNodeId (2)) 7) (ConsMap ((mkNodeId (3)) 6) (ConsMap ((mkNodeId (4)) 5) (ConsMap ((mkNodeId (5)) 4) NilMap))))))))) (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 5))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (5))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) NilMMap)))))))))) 
; (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) ())))))) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) ()))))))))
;; New test based on improved representation building
;; INFO: The test cases pass individually but hangs even after the successfully passing the test.
;; !(assertEqual 
;;     (createRepresentation 
;;         2
;;         (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())) 
;;         (ttable) 
;;         sim 
;;         False
;;         ; ((E 0.4) (F 0.3) (G 0.73))
;;         ()
;;         mi ;; scorerType
;;         )
;; ((mkRep (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (1 1)) 4) (ConsMap ((mkNodeId (1 1 2)) 8) (ConsMap ((mkNodeId (1 1 3)) 9) (ConsMap ((mkNodeId (1 1 4)) 10) (ConsMap ((mkNodeId (1 2)) 5) (ConsMap ((mkNodeId (1 3)) 6) (ConsMap ((mkNodeId (1 4)) 7) (ConsMap ((mkNodeId (1 5 1)) 11) (ConsMap ((mkNodeId (1 5 2)) 12) (ConsMap ((mkNodeId (1 5 3)) 13) (ConsMap ((mkNodeId (1 5 4)) 14) (ConsMap ((mkNodeId (2)) 0) (ConsMap ((mkNodeId (3)) 1) (ConsMap ((mkNodeId (4)) 2) (ConsMap ((mkNodeId (5)) 3) (ConsMap ((mkNodeId (6 1)) 15) (ConsMap ((mkNodeId (6 2)) 16) (ConsMap ((mkNodeId (6 3)) 17) (ConsMap ((mkNodeId (6 4)) 18) NilMap)))))))))))))))))))) (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (5))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 1))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 1 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 1 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 1 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 5 1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 5 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 5 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 5 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (6 1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (6 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (6 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (6 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) NilMMap))))))))))))))))))))) (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) ()))))) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkTree (mkNode OR) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) ()))))) ())))))) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkTree (mkNode AND) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) ()))))) ())))))))))
;; )


(= (table1) (mkITable
                         (cons (cons False (cons False (cons False ()))) 
                         (cons (cons True (cons False (cons False ()))) 
                         (cons (cons False (cons True (cons False ())))
                         (cons (cons True (cons True (cons True ()))) ()))))
                         (cons A (cons B (cons O ())))))

;; INFO: The test cases pass individually but hangs even after the successfully passing the test.
;; !(assertEqual 
;;    (createRepresentation 1 (mkTree (mkNode OR) (cons (mkTree (mkNode B) ()) ())) (table1) sim False () mi)
;;
;; ((mkRep (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (1 1)) 5) (ConsMap ((mkNodeId (1 1 2)) 8) (ConsMap ((mkNodeId (1 1 3)) 9) (ConsMap ((mkNodeId (1 1 4)) 10) (ConsMap ((mkNodeId (1 2)) 4) (ConsMap ((mkNodeId (1 3)) 6) (ConsMap ((mkNodeId (1 4)) 7) (ConsMap ((mkNodeId (1 5 1)) 11) (ConsMap ((mkNodeId (1 5 2)) 12) (ConsMap ((mkNodeId (1 5 3)) 13) (ConsMap ((mkNodeId (1 5 4)) 14) (ConsMap ((mkNodeId (2)) 0) (ConsMap ((mkNodeId (3)) 1) (ConsMap ((mkNodeId (4)) 2) (ConsMap ((mkNodeId (5)) 3) (ConsMap ((mkNodeId (6 1)) 15) (ConsMap ((mkNodeId (6 2)) 16) (ConsMap ((mkNodeId (6 3)) 17) (ConsMap ((mkNodeId (6 4)) 18) NilMap)))))))))))))))))))) (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (5))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 1))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 1 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 1 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 1 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 5 1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 5 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 5 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 5 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (6 1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (6 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (6 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (6 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) NilMMap))))))))))))))))))))) (mkTree (mkNode AND) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) ()))))) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkTree (mkNode AND) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) ()))))) ())))))) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkTree (mkNode OR) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) ()))))) ())))))))))
;; )
