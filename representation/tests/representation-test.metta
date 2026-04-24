!(import! &self ../../utilities/general-helpers) 
!(import! &self ../../utilities/list-methods) 
!(import! &self ../../utilities/map)
!(import! &self ../../utilities/ordered-multimap)
!(import! &self ../../utilities/ordered-set)
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

!(import! &self ../../representation/lsk)
!(import! &self ../../representation/knob-representation)
!(import! &self ../../representation/logical-probe) 
!(import! &self ../../representation/logical-canonize)
!(import! &self ../../representation/sample-logical-perms) 
!(import! &self ../../representation/add-logical-knobs)
!(import! &self ../../representation/build-logical)
!(import! &self ../../representation/build-knobs)
!(import! &self ../../representation/knob-mapper)

!(import! &self ../../scoring/bscore)
!(import! &self ../../scoring/cscore)

!(import! &self ../../feature-selection/feature-selection-helpers)

!(import! &self ../../feature-selection/simple)
!(import! &self ../../feature-selection/smd)
!(import! &self ../../feature-selection/random-feature-selection)
!(import! &self ../../feature-selection/incremental)

!(import! &self ../../feature-selection/similarity-scorers)
!(import! &self ../../feature-selection/select-top-features)

!(import! &self ../../feature-selection/feature-selection-main)

!(import! &self ../../representation/representation)


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
              (mkKnob  (mkNodeId (2 3)))
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
              (mkKnob  (mkNodeId (1)))
              (mkMultip 3)
              (mkDiscSpec 1)
              (mkDiscSpec 1)
              ())
            ))

(= (knobMapObj) (mkKbMap
                      (mkDscKbMp (cons ((mkNodeId (2 3)) 0) (cons ((mkNodeId (3)) 1) (cons ((mkNodeId (1)) 2) ()))))
                      (mkDscMp (cons ((mkDiscSpec 1) (lsk1)) (cons ((mkDiscSpec 0) (lsk2)) (cons ((mkDiscSpec 1) (lsk3)) ()))))))


;; Test case for Instance (0 0 0): (AND A (OR B C)) => (AND (OR B C))
!("===================Test case for Instance (0 0 0)============================")

!(assertEqual
    (getCandidateRec (mkRep (knobMapObj) (tree1))
                     (mkInst (cons 0 (cons 0 (cons 0 ())))) 
                     (mkNodeId (0))
                     (mkNodeId (0))
                     (mkNodeId (0))
                     (mkNullVex ()))
    (mkTree (mkNode AND) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode B) ()) (cons (mkTree (mkNode C) ()) ()))) ())))

;; Test case for Instance (1 1 1): (AND A (OR B C)) => (AND A (OR B C D) (OR A))
!("===================Test case for Instance (1 1 1)============================")
!(assertEqual
   (getCandidateRec (mkRep (knobMapObj) (tree1))
                    (mkInst (cons 1 (cons 1 (cons 1 ())))) 
                    (mkNodeId (0))
                    (mkNodeId (0))
                    (mkNodeId (0))
                    (mkNullVex ()))
   (mkTree (mkNode AND)
      (cons (mkTree (mkNode A) ())
      (cons (mkTree (mkNode OR) 
              (cons (mkTree (mkNode B) ())
              (cons (mkTree (mkNode C) ())
              (cons (mkTree (mkNode D) ()) ()))))
      (cons (mkTree (mkNode OR)
                (cons (mkTree (mkNode A) ()) ())) ())))))

;; Test case for Instance (2 2 2): (AND A (OR B C)) => (AND (NOT A) (OR B C (NOT D)) (NOT (OR A)))
!("===================Test case for Instance (2 2 2)============================")
!(assertEqual
   (getCandidateRec (mkRep (knobMapObj) (tree1))
                    (mkInst (cons 2 (cons 2 (cons 2 ()))))
                    (mkNodeId (0))
                    (mkNodeId (0))
                    (mkNodeId (0))
                    (mkNullVex ()))
   (mkTree (mkNode AND)
      (cons (mkTree (mkNode NOT)
              (cons (mkTree (mkNode A) ()) ()))
      (cons (mkTree (mkNode OR)
              (cons (mkTree (mkNode B) ())
              (cons (mkTree (mkNode C) ())
              (cons (mkTree (mkNode NOT)
                      (cons (mkTree (mkNode D) ()) ())) ()))))
      (cons (mkTree (mkNode NOT)
              (cons (mkTree (mkNode OR)
                      (cons (mkTree (mkNode A) ()) ())) ())) ())))))

;; Test case for Instance (2 1 0): (AND A (OR B C)) => (AND (OR B C (NOT D)) (OR A))
!("===================Test case for Instance (2 1 0)============================")
!(assertEqual
   (getCandidateRec (mkRep (knobMapObj) (tree1))
                    (mkInst (cons 2 (cons 1 (cons 0 ()))))
                    (mkNodeId (0))
                    (mkNodeId (0))
                    (mkNodeId (0))
                    (mkNullVex ()))
   (mkTree (mkNode AND) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode B) ()) (cons (mkTree (mkNode C) ()) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode D) ()) ())) ())))) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) ())) ()))))

;; Test case for Instance (1 0 2): (AND A (OR B C)) => (AND (NOT A) (OR B C D))
!("===================Test case for Instance (1 0 2)============================")

!(assertEqual
   (getCandidateRec (mkRep (knobMapObj) (tree1))
                               (mkInst (cons 1 (cons 0 (cons 2 ()))))
                               (mkNodeId (0))
                               (mkNodeId (0))
                               (mkNodeId (0))
                               (mkNullVex ()))
   (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode B) ()) (cons (mkTree (mkNode C) ()) (cons (mkTree (mkNode D) ()) ())))) ())))
)

;; Test case for Instance (2 0 1): (AND A (OR B C)) => (AND A (OR B C (NOT D)))
!("===================Test case for Instance (2 0 1)============================")


!(assertEqual
   (getCandidateRec (mkRep (knobMapObj) (tree1))
                    (mkInst (cons 2 (cons 0 (cons 1 ()))))
                    (mkNodeId (0))
                    (mkNodeId (0))
                    (mkNodeId (0))
                    (mkNullVex ()))
   (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode B) ()) (cons (mkTree (mkNode C) ()) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode D) ()) ())) ())))) ()))))

;; Test case for Instance (2 0 1): (AND A (OR B C)) => (AND A (OR B C (NOT D)))
!("===================Test case for Instance (2 0 1)============================")
!(assertEqual
   (getCandidate (mkRep (knobMapObj) (tree1))
                 (mkInst (cons 2 (cons 0 (cons 1 ())))))

        (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode B) ()) (cons (mkTree (mkNode C) ()) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode D) ()) ())) ())))) ())))
)
; (
;    (mkTree (mkNode AND)
;       (cons (mkTree (mkNode A) ())
;       (cons (mkTree (mkNode OR)
;                 (cons (mkTree (mkNode B) ())
;                 (cons (mkTree (mkNode C) ())
;                 (cons (mkTree (mkNode NOT)
;                         (cons (mkTree (mkNode D) ()) ())) ())))) ())))) (

;; TODO: Change the above expected by below when reduct issue is fixed.
                ; (cons (mkTree (mkNode AND)
                ;         (cons (mkTree (mkNode B) ()) ()))
                ; (cons (mkTree (mkNode AND)
                ;         (cons (mkTree (mkNode C) ()) ()))
                ; (cons (mkTree (mkNode AND)
                ;         (cons (mkTree (mkNode NOT)
                ;                  (cons (mkTree (mkNode D) ()) ())) ())) ()))))

; Test for crtDiscKnobMap
; converts dscMp($kbSpec $kb) to dscKbMp($kbLoc $index)
!(assertEqual (crtDiscKnobMap (mkDscMp (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob  (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) 
     (cons ((mkDiscSpec 2) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) 
     (cons ((mkDiscSpec 1) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2 1 1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ())))) (mkDscKbMp ()) 0)
     (mkDscKbMp (cons ((mkNodeId (2)) 0) (cons ((mkNodeId (2 1 1)) 2) (cons ((mkNodeId (2 3)) 1) ())))))

!(assertEqual (crtDiscKnobMap (mkDscMp (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) 
     (cons ((mkDiscSpec 2) (mkLSK (mkDiscKnob (mkKnob  (mkNodeId (2 3 1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) )) 
     (cons ((mkDiscSpec 1) (mkLSK (mkDiscKnob (mkKnob  (mkNodeId (2 1 1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) )) ())))) (mkDscKbMp ()) 0)
     (mkDscKbMp (cons ((mkNodeId (2 1 1)) 2) (cons ((mkNodeId (2 2)) 0) (cons ((mkNodeId (2 3 1)) 1) ())))))


; NOTE: This test is temporarily commented out because set-seed is 
; not functioning correctly in the current mettalog version. 
; The tests will be re-enabled after fixing Python binding in the workflow.

; ; Test for the representation -- according to previous repersentation building
; ; takes exemplar and generates Representation($kbMapKnobMap $updatedExemplar)
; !(assertEqual (representation  (mkTree (mkNode OR) (cons (mkTree (mkNode C) ()) ())))
; (mkRep 
;   (mkKbMap 
;      (mkDscKbMp (cons ((mkNodeId (1 2)) 0) (cons ((mkNodeId (1 3)) 1) (cons ((mkNodeId (1 4)) 2) (cons ((mkNodeId (1 5)) 3) (cons ((mkNodeId (2)) 4) (cons ((mkNodeId (3)) 5) (cons ((mkNodeId (4)) 6) (cons ((mkNodeId (5)) 7) ()))))))))) 
;      (mkDscMp (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) ()))) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) ())))))) (mkNodeId (1 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) ())))) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) ())))))) (mkNodeId (1 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) ()))))) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) ())))))) (mkNodeId (1 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) (mkTree (mkNode B) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) ())))))) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) ())))))) (mkNodeId (1 5))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) (mkTree (mkNode A) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode OR) (cons (mkTree (mkNode C) ()) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) ()))) (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode OR) (cons (mkTree (mkNode C) ()) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) ())))) (mkNodeId (3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode OR) (cons (mkTree (mkNode C) ()) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) ()))))) (mkNodeId (4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) (mkTree (mkNode B) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode OR) (cons (mkTree (mkNode C) ()) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) ())))))) (mkNodeId (5))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) (mkTree (mkNode A) ()))) ())))))))))) 
;; ;      (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) ())))))) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) ()))))))))
;;
(= (ttable)
    (mkITable 
        (cons (cons False (cons False (cons True (cons True (cons True ())))))
        (cons (cons True (cons False (cons False (cons True (cons True ())))))
        (cons (cons False (cons True (cons False (cons True (cons False ())))))
        (cons (cons False (cons False (cons False (cons True (cons False ()))))) ()))))
        (cons A (cons B (cons C (cons D (cons Output ())))))))


;; !(assertEqual (representation 
;;         2
;;         (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())) 
;;         (ttable) 
;;         smd 
;;         False
;;         ; ((E 0.4) (F 0.3) (G 0.73))
;;         ()
;;         mi
;;         )
;;         ((mkRep (mkKbMap (mkDscKbMp (cons ((mkNodeId (1 1)) 4) (cons ((mkNodeId (1 1 2)) 8) (cons ((mkNodeId (1 1 3)) 9) (cons ((mkNodeId (1 1 4)) 10) (cons ((mkNodeId (1 2)) 5) (cons ((mkNodeId (1 3)) 6) (cons ((mkNodeId (1 4)) 7) (cons ((mkNodeId (1 5 1)) 11) (cons ((mkNodeId (1 5 2)) 12) (cons ((mkNodeId (1 5 3)) 13) (cons ((mkNodeId (1 5 4)) 14) (cons ((mkNodeId (2)) 0) (cons ((mkNodeId (3)) 1) (cons ((mkNodeId (4)) 2) (cons ((mkNodeId (5)) 3) (cons ((mkNodeId (6 1)) 15) (cons ((mkNodeId (6 2)) 16) (cons ((mkNodeId (6 3)) 17) (cons ((mkNodeId (6 4)) 18) ())))))))))))))))))))) (mkDscMp (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (5))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 1))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 1 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 1 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 1 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 5 1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 5 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 5 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 5 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (6 1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (6 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (6 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (6 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ()))))))))))))))))))))) (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkNullVex (cons (mkTree (mkNode C) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode C) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode C) ()) ()))) ())) ()))))) (cons (mkNullVex (cons (mkTree (mkNode C) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode C) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode C) ()) ()))) ())) (cons (mkTree (mkNode OR) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode C) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode C) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode C) ()) ()))) ())) ()))))) ())))))) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode C) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode C) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode C) ()) ()))) ())) (cons (mkTree (mkNode AND) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode C) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode C) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode C) ()) ()))) ())) ()))))) ())))))))) (mkRep (mkKbMap (mkDscKbMp (cons ((mkNodeId (1 1)) 4) (cons ((mkNodeId (1 1 2)) 8) (cons ((mkNodeId (1 1 3)) 9) (cons ((mkNodeId (1 1 4)) 10) (cons ((mkNodeId (1 2)) 5) (cons ((mkNodeId (1 3)) 6) (cons ((mkNodeId (1 4)) 7) (cons ((mkNodeId (1 5 1)) 11) (cons ((mkNodeId (1 5 2)) 12) (cons ((mkNodeId (1 5 3)) 13) (cons ((mkNodeId (1 5 4)) 14) (cons ((mkNodeId (2)) 0) (cons ((mkNodeId (3)) 1) (cons ((mkNodeId (4)) 2) (cons ((mkNodeId (5)) 3) (cons ((mkNodeId (6 1)) 15) (cons ((mkNodeId (6 2)) 16) (cons ((mkNodeId (6 3)) 17) (cons ((mkNodeId (6 4)) 18) ())))))))))))))))))))) (mkDscMp (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (5))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 1))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 1 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 1 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 1 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 5 1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 5 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 5 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 5 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (6 1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (6 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (6 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (6 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ()))))))))))))))))))))) (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) ()))))) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkTree (mkNode OR) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) ()))))) ())))))) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkTree (mkNode AND) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) ()))))) ())))))))))
;; ) ;; FIX: After passing the test this hangs for no apparent reason.
;; The these test cases are commented out because they behave non deterministically when running all the 3 representation together 
;; but runs correctly when running them separately !!
; !(assertEqual (representation 
;         2
;         (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())) 
;         (ttable) 
;         inc 
;         False
;         ; ((E 0.4) (F 0.3) (G 0.73))
;         ()
;         mi
;         )
;         ((mkRep (mkKbMap (mkDscKbMp (cons ((mkNodeId (1)) 11) (cons ((mkNodeId (1 1)) 5) (cons ((mkNodeId (1 2)) 4) (cons ((mkNodeId (1 3)) 3) (cons ((mkNodeId (1 4)) 2) (cons ((mkNodeId (1 5)) 1) (cons ((mkNodeId (1 6)) 0) (cons ((mkNodeId (2)) 10) (cons ((mkNodeId (3)) 9) (cons ((mkNodeId (4)) 8) (cons ((mkNodeId (5)) 7) (cons ((mkNodeId (6)) 6) ()))))))))))))) (mkDscMp (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 6))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 5))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 1))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (6))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (5))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ()))) ())))))))))))))) (mkTree (mkNode AND) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode C) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode C) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode C) ()) ()))) ())) ()))))))) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode C) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode C) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode B) ()) (cons (mkTree (mkNode C) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) ())))))))))
; )

; !(assertEqual (representation 
;         2
;         (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())) 
;         (ttable) 
;         rd 
;         False
;         ; ((E 0.4) (F 0.3) (G 0.73))
;         ()
;         mi
;         )
;         ((mkRep (mkKbMap (mkDscKbMp (cons ((mkNodeId (1)) 7) (cons ((mkNodeId (1 1)) 3) (cons ((mkNodeId (1 2)) 2) (cons ((mkNodeId (1 3)) 1) (cons ((mkNodeId (1 4)) 0) (cons ((mkNodeId (2)) 6) (cons ((mkNodeId (3)) 5) (cons ((mkNodeId (4)) 4) ()))))))))) (mkDscMp (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 1))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ()))) ())))))))))) (mkTree (mkNode AND) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkNullVex (cons (mkTree (mkNode D) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode D) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode D) ()) ()))) ())) ()))))) (cons (mkNullVex (cons (mkTree (mkNode D) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode D) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode D) ()) ()))) ())) ())))))))
; )
(= (gameTree) (mkTree (mkNode PRIORITIZED-OR) 
            (cons (mkTree (mkNode playcenter) ()) 
                  (cons (mkTree (mkNode playcorner) ()) ()))))

;; Game strategy representation with nDeme=1
!(assertEqual (representation (gameTree) 1) ((mkRep (mkKbMap (mkDscKbMp (cons ((mkNodeId (3)) 0) (cons ((mkNodeId (4)) 1) (cons ((mkNodeId (5)) 2) (cons ((mkNodeId (6)) 3) (cons ((mkNodeId (7)) 4) ())))))) (mkDscMp (cons ((mkDiscSpec 2) (mkSSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 2) (mkSSK (mkDiscKnob (mkKnob (mkNodeId (4))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 2) (mkSSK (mkDiscKnob (mkKnob (mkNodeId (5))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 2) (mkSSK (mkDiscKnob (mkKnob (mkNodeId (6))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 2) (mkSSK (mkDiscKnob (mkKnob (mkNodeId (7))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ()))))))) (mkTree (mkNode PRIORITIZED-OR) (cons (mkTree (mkNode playcenter) ()) (cons (mkTree (mkNode playcorner) ()) (cons (mkNullVex (cons (mkTree (mkNode PRIORITIZED-OR) (cons (mkTree (mkNode playside) ()) (cons (mkTree (mkNode playwin) ()) (cons (mkTree (mkNode playcenter) ()) ())))) ())) (cons (mkNullVex (cons (mkTree (mkNode PRIORITIZED-OR) (cons (mkTree (mkNode playwin) ()) (cons (mkTree (mkNode playcenter) ()) (cons (mkTree (mkNode playblock) ()) ())))) ())) (cons (mkNullVex (cons (mkTree (mkNode PRIORITIZED-OR) (cons (mkTree (mkNode playside) ()) (cons (mkTree (mkNode playcenter) ()) (cons (mkTree (mkNode playblock) ()) ())))) ())) (cons (mkNullVex (cons (mkTree (mkNode PRIORITIZED-OR) (cons (mkTree (mkNode playside) ()) (cons (mkTree (mkNode playwin) ()) (cons (mkTree (mkNode playcorner) ()) ())))) ())) (cons (mkNullVex (cons (mkTree (mkNode PRIORITIZED-OR) (cons (mkTree (mkNode playwin) ()) (cons (mkTree (mkNode playcenter) ()) (cons (mkTree (mkNode playside) ()) ())))) ())) ())))))))))))
;; Game strategy representation with nDeme=2 
!(assertEqual (representation (gameTree) 2)
              ((mkRep (mkKbMap (mkDscKbMp (cons ((mkNodeId (3)) 0) (cons ((mkNodeId (4)) 1) (cons ((mkNodeId (5)) 2) (cons ((mkNodeId (6)) 3) (cons ((mkNodeId (7)) 4) ())))))) (mkDscMp (cons ((mkDiscSpec 2) (mkSSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 2) (mkSSK (mkDiscKnob (mkKnob (mkNodeId (4))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 2) (mkSSK (mkDiscKnob (mkKnob (mkNodeId (5))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 2) (mkSSK (mkDiscKnob (mkKnob (mkNodeId (6))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 2) (mkSSK (mkDiscKnob (mkKnob (mkNodeId (7))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ()))))))) (mkTree (mkNode PRIORITIZED-OR) (cons (mkTree (mkNode playcenter) ()) (cons (mkTree (mkNode playcorner) ()) (cons (mkNullVex (cons (mkTree (mkNode PRIORITIZED-OR) (cons (mkTree (mkNode playcenter) ()) (cons (mkTree (mkNode playblock) ()) (cons (mkTree (mkNode playside) ()) ())))) ())) (cons (mkNullVex (cons (mkTree (mkNode PRIORITIZED-OR) (cons (mkTree (mkNode playblock) ()) (cons (mkTree (mkNode playwin) ()) (cons (mkTree (mkNode playcorner) ()) ())))) ())) (cons (mkNullVex (cons (mkTree (mkNode PRIORITIZED-OR) (cons (mkTree (mkNode playwin) ()) (cons (mkTree (mkNode playcorner) ()) (cons (mkTree (mkNode playside) ()) ())))) ())) (cons (mkNullVex (cons (mkTree (mkNode PRIORITIZED-OR) (cons (mkTree (mkNode playwin) ()) (cons (mkTree (mkNode playcorner) ()) (cons (mkTree (mkNode playblock) ()) ())))) ())) (cons (mkNullVex (cons (mkTree (mkNode PRIORITIZED-OR) (cons (mkTree (mkNode playwin) ()) (cons (mkTree (mkNode playcenter) ()) (cons (mkTree (mkNode playcorner) ()) ())))) ())) ()))))))))) (mkRep (mkKbMap (mkDscKbMp (cons ((mkNodeId (3)) 0) (cons ((mkNodeId (4)) 1) (cons ((mkNodeId (5)) 2) (cons ((mkNodeId (6)) 3) (cons ((mkNodeId (7)) 4) ())))))) (mkDscMp (cons ((mkDiscSpec 2) (mkSSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 2) (mkSSK (mkDiscKnob (mkKnob (mkNodeId (4))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 2) (mkSSK (mkDiscKnob (mkKnob (mkNodeId (5))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 2) (mkSSK (mkDiscKnob (mkKnob (mkNodeId (6))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 2) (mkSSK (mkDiscKnob (mkKnob (mkNodeId (7))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ()))))))) (mkTree (mkNode PRIORITIZED-OR) (cons (mkTree (mkNode playcenter) ()) (cons (mkTree (mkNode playcorner) ()) (cons (mkNullVex (cons (mkTree (mkNode PRIORITIZED-OR) (cons (mkTree (mkNode playside) ()) (cons (mkTree (mkNode playcorner) ()) (cons (mkTree (mkNode playblock) ()) ())))) ())) (cons (mkNullVex (cons (mkTree (mkNode PRIORITIZED-OR) (cons (mkTree (mkNode playside) ()) (cons (mkTree (mkNode playcenter) ()) (cons (mkTree (mkNode playcorner) ()) ())))) ())) (cons (mkNullVex (cons (mkTree (mkNode PRIORITIZED-OR) (cons (mkTree (mkNode playside) ()) (cons (mkTree (mkNode playblock) ()) (cons (mkTree (mkNode playcorner) ()) ())))) ())) (cons (mkNullVex (cons (mkTree (mkNode PRIORITIZED-OR) (cons (mkTree (mkNode playblock) ()) (cons (mkTree (mkNode playcorner) ()) (cons (mkTree (mkNode playwin) ()) ())))) ())) (cons (mkNullVex (cons (mkTree (mkNode PRIORITIZED-OR) (cons (mkTree (mkNode playwin) ()) (cons (mkTree (mkNode playcorner) ()) (cons (mkTree (mkNode playcenter) ()) ())))) ())) ())))))))))))
