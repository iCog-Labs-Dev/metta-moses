
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
              (mkKnob  (mkNodeId (2 3)))
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
              (mkKnob  (mkNodeId (1)))
              (mkMultip 3)
              (mkDiscSpec 1)
              (mkDiscSpec 1)
              Nil)
            ))

(= (knobMapObj) (mkKbMap
                      (mkDscKbMp (ConsMap ((mkNodeId (2 3)) 0) (ConsMap ((mkNodeId (3)) 1) (ConsMap ((mkNodeId (1)) 2) NilMap))))
                      (mkDscMp (ConsMMap ((mkDiscSpec 1) (lsk1)) (ConsMMap ((mkDiscSpec 0) (lsk2)) (ConsMMap ((mkDiscSpec 1) (lsk3)) NilMMap))))))


; Test case for Instance (0 0 0): (AND A (OR B C)) => (AND (OR B C))
!("===================Test case for Instance (0 0 0)============================")

!(assertEqual
    (getCandidateRec (mkRep (knobMapObj) (tree1))
                     (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) 
                     (mkNodeId (0))
                     (mkNodeId (0))
                     (mkNullVex Nil))
    (mkTree (mkNode AND)
        (Cons (mkNullVex
                (Cons (mkTree (mkNode A) Nil) Nil))
        (Cons (mkTree (mkNode OR)
                (Cons (mkTree (mkNode B) Nil)
                (Cons (mkTree (mkNode C) Nil)
                (Cons (mkNullVex
                        (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) 
        (Cons (mkNullVex
                (Cons (mkTree (mkNode OR)
                         (Cons (mkTree (mkNode A) Nil) Nil)) Nil)) Nil)))))

;; Test case for Instance (1 1 1): (AND A (OR B C)) => (AND A (OR B C D) (OR A))
!("===================Test case for Instance (1 1 1)============================")
!(assertEqual
   (getCandidateRec (mkRep (knobMapObj) (tree1))
                    (mkInst (Cons 1 (Cons 1 (Cons 1 Nil)))) 
                    (mkNodeId (0))
                    (mkNodeId (0))
                    (mkNullVex Nil))
   (mkTree (mkNode AND)
      (Cons (mkTree (mkNode A) Nil)
      (Cons (mkTree (mkNode OR) 
              (Cons (mkTree (mkNode B) Nil)
              (Cons (mkTree (mkNode C) Nil)
              (Cons (mkTree (mkNode D) Nil) Nil))))
      (Cons (mkTree (mkNode OR)
                (Cons (mkTree (mkNode A) Nil) Nil)) Nil)))))

;; Test case for Instance (2 2 2): (AND A (OR B C)) => (AND (NOT A) (OR B C (NOT D)) (NOT (OR A)))
!("===================Test case for Instance (2 2 2)============================")
!(assertEqual
   (getCandidateRec (mkRep (knobMapObj) (tree1))
                    (mkInst (Cons 2 (Cons 2 (Cons 2 Nil))))
                    (mkNodeId (0))
                    (mkNodeId (0))
                    (mkNullVex Nil))
   (mkTree (mkNode AND)
      (Cons (mkTree (mkNode NOT)
              (Cons (mkTree (mkNode A) Nil) Nil))
      (Cons (mkTree (mkNode OR)
              (Cons (mkTree (mkNode B) Nil)
              (Cons (mkTree (mkNode C) Nil)
              (Cons (mkTree (mkNode NOT)
                      (Cons (mkTree (mkNode D) Nil) Nil)) Nil))))
      (Cons (mkTree (mkNode NOT)
              (Cons (mkTree (mkNode OR)
                      (Cons (mkTree (mkNode A) Nil) Nil)) Nil)) Nil)))))

;; Test case for Instance (2 1 0): (AND A (OR B C)) => (AND (OR B C (NOT D)) (OR A))
!("===================Test case for Instance (2 1 0)============================")
!(assertEqual
   (getCandidateRec (mkRep (knobMapObj) (tree1))
                    (mkInst (Cons 2 (Cons 1 (Cons 0 Nil))))
                    (mkNodeId (0))
                    (mkNodeId (0))
                    (mkNullVex Nil))
   (mkTree (mkNode AND)
      (Cons (mkNullVex
              (Cons (mkTree (mkNode A) Nil) Nil))
      (Cons (mkTree (mkNode OR)
              (Cons (mkTree (mkNode B) Nil)
              (Cons (mkTree (mkNode C) Nil)
              (Cons (mkTree (mkNode NOT)
                      (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) 
      (Cons (mkTree (mkNode OR)
              (Cons (mkTree (mkNode A) Nil) Nil)) Nil)))))

;; Test case for Instance (1 0 2): (AND A (OR B C)) => (AND (NOT A) (OR B C D))
!("===================Test case for Instance (1 0 2)============================")
!(assertEqual
   (getCandidateRec (mkRep (knobMapObj) (tree1))
                               (mkInst (Cons 1 (Cons 0 (Cons 2 Nil))))
                               (mkNodeId (0))
                               (mkNodeId (0))
                               (mkNullVex Nil))
   (mkTree (mkNode AND)
     (Cons (mkTree (mkNode NOT)
             (Cons (mkTree (mkNode A) Nil) Nil))
     (Cons (mkTree (mkNode OR)
             (Cons (mkTree (mkNode B) Nil)
             (Cons (mkTree (mkNode C) Nil)
             (Cons (mkTree (mkNode D) Nil) Nil))))
     (Cons (mkNullVex
             (Cons (mkTree (mkNode OR)
                      (Cons (mkTree (mkNode A) Nil) Nil)) Nil)) Nil)))))

;; Test case for Instance (2 0 1): (AND A (OR B C)) => (AND A (OR B C (NOT D)))
!("===================Test case for Instance (2 0 1)============================")
!(assertEqual
   (getCandidateRec (mkRep (knobMapObj) (tree1))
                    (mkInst (Cons 2 (Cons 0 (Cons 1 Nil))))
                    (mkNodeId (0))
                    (mkNodeId (0))
                    (mkNullVex Nil))
   (mkTree (mkNode AND)
      (Cons (mkTree (mkNode A) Nil)
      (Cons (mkTree (mkNode OR)
              (Cons (mkTree (mkNode B) Nil)
              (Cons (mkTree (mkNode C) Nil)
              (Cons (mkTree (mkNode NOT)
                      (Cons (mkTree (mkNode D) Nil) Nil)) Nil))))
      (Cons (mkNullVex
               (Cons (mkTree (mkNode OR)
                        (Cons (mkTree (mkNode A) Nil) Nil)) Nil)) Nil)))))

;; Test case for Instance (2 0 1): (AND A (OR B C)) => (AND A (OR B C (NOT D)))
!("===================Test case for Instance (2 0 1)============================")
!(assertEqual
   (getCandidate (mkRep (knobMapObj) (tree1))
                 (mkInst (Cons 2 (Cons 0 (Cons 1 Nil)))))

        (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) 
                (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) 
                                          (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) 
                                          (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)) Nil)))) Nil))))
; (
;    (mkTree (mkNode AND)
;       (Cons (mkTree (mkNode A) Nil)
;       (Cons (mkTree (mkNode OR)
;                 (Cons (mkTree (mkNode B) Nil)
;                 (Cons (mkTree (mkNode C) Nil)
;                 (Cons (mkTree (mkNode NOT)
;                         (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)))) (

;; TODO: Change the above expected by below when reduct issue is fixed.
                ; (Cons (mkTree (mkNode AND)
                ;         (Cons (mkTree (mkNode B) Nil) Nil))
                ; (Cons (mkTree (mkNode AND)
                ;         (Cons (mkTree (mkNode C) Nil) Nil))
                ; (Cons (mkTree (mkNode AND)
                ;         (Cons (mkTree (mkNode NOT)
                ;                  (Cons (mkTree (mkNode D) Nil) Nil)) Nil)) Nil))))

; Test for crtDiscKnobMap
; converts dscMp($kbSpec $kb) to dscKbMp($kbLoc $index)
!(assertEqual (crtDiscKnobMap (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob  (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) 
     (ConsMMap ((mkDiscSpec 2) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) 
     (ConsMMap ((mkDiscSpec 1) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2 1 1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) NilMMap)))) (mkDscKbMp NilMap) 0)
     (mkDscKbMp (ConsMap ((mkNodeId (2)) 0) (ConsMap ((mkNodeId (2 1 1)) 2) (ConsMap ((mkNodeId (2 3)) 1) NilMap)))))

!(assertEqual (crtDiscKnobMap (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) 
     (ConsMMap ((mkDiscSpec 2) (mkLSK (mkDiscKnob (mkKnob  (mkNodeId (2 3 1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) )) 
     (ConsMMap ((mkDiscSpec 1) (mkLSK (mkDiscKnob (mkKnob  (mkNodeId (2 1 1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) )) NilMMap)))) (mkDscKbMp NilMap) 0)
     (mkDscKbMp (ConsMap ((mkNodeId (2 1 1)) 2) (ConsMap ((mkNodeId (2 2)) 0) (ConsMap ((mkNodeId (2 3 1)) 1) NilMap)))))


; NOTE: This test is temporarily commented out because set-seed is 
; not functioning correctly in the current mettalog version. 
; The tests will be re-enabled after fixing Python binding in the workflow.

; ; Test for the representation -- according to previous repersentation building
; ; takes exemplar and generates Representation($kbMapKnobMap $updatedExemplar)
; !(assertEqual (representation  (mkTree (mkNode OR) (Cons (mkTree (mkNode C) Nil) Nil)))
; (mkRep 
;   (mkKbMap 
;      (mkDscKbMp (ConsMap ((mkNodeId (1 2)) 0) (ConsMap ((mkNodeId (1 3)) 1) (ConsMap ((mkNodeId (1 4)) 2) (ConsMap ((mkNodeId (1 5)) 3) (ConsMap ((mkNodeId (2)) 4) (ConsMap ((mkNodeId (3)) 5) (ConsMap ((mkNodeId (4)) 6) (ConsMap ((mkNodeId (5)) 7) NilMap))))))))) 
;      (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil))) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) Nil)))))) (mkNodeId (1 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil)))) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) Nil)))))) (mkNodeId (1 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) Nil))))) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) Nil)))))) (mkNodeId (1 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode B) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) Nil)))))) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) Nil)))))) (mkNodeId (1 5))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode A) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode OR) (Cons (mkTree (mkNode C) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil))) (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode OR) (Cons (mkTree (mkNode C) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil)))) (mkNodeId (3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode OR) (Cons (mkTree (mkNode C) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) Nil))))) (mkNodeId (4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode B) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode OR) (Cons (mkTree (mkNode C) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) Nil)))))) (mkNodeId (5))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode A) Nil))) NilMMap)))))))))) 
;      (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) Nil)))))) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) Nil))))))))

(= (ttable)
    (mkITable 
        (Cons (Cons False (Cons False (Cons True (Cons True (Cons True Nil)))))
        (Cons (Cons True (Cons False (Cons False (Cons True (Cons True Nil)))))
        (Cons (Cons False (Cons True (Cons False (Cons True (Cons False Nil)))))
        (Cons (Cons False (Cons False (Cons False (Cons True (Cons False Nil))))) Nil))))
        (Cons A (Cons B (Cons C (Cons D (Cons Output Nil)))))))


!(assertEqual (representation 
        2
        (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) Nil)) 
        (ttable) 
        smd 
        False
        ; ((E 0.4) (F 0.3) (G 0.73))
        ()
        mi
        )
        ((mkRep (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (1)) 7) (ConsMap ((mkNodeId (1 1)) 3) (ConsMap ((mkNodeId (1 2)) 2) (ConsMap ((mkNodeId (1 3)) 1) (ConsMap ((mkNodeId (1 4)) 0) (ConsMap ((mkNodeId (2)) 6) (ConsMap ((mkNodeId (3)) 5) (ConsMap ((mkNodeId (4)) 4) NilMap))))))))) (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 1))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) Nil))) NilMMap)))))))))) (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode C) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode C) Nil) Nil))) Nil)) Nil))))) (Cons (mkNullVex (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode C) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode C) Nil) Nil))) Nil)) Nil)))))) (mkRep (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (1)) 7) (ConsMap ((mkNodeId (1 1)) 3) (ConsMap ((mkNodeId (1 2)) 2) (ConsMap ((mkNodeId (1 3)) 1) (ConsMap ((mkNodeId (1 4)) 0) (ConsMap ((mkNodeId (2)) 6) (ConsMap ((mkNodeId (3)) 5) (ConsMap ((mkNodeId (4)) 4) NilMap))))))))) (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 1))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) Nil))) NilMMap)))))))))) (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil))))) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil)))))))
)
;; The these test cases are commented out because they behave non deterministically when running all the 3 representation together 
;; but runs correctly when running them separately !!
; !(assertEqual (representation 
;         2
;         (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) Nil)) 
;         (ttable) 
;         inc 
;         False
;         ; ((E 0.4) (F 0.3) (G 0.73))
;         ()
;         mi
;         )
;         ((mkRep (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (1)) 11) (ConsMap ((mkNodeId (1 1)) 5) (ConsMap ((mkNodeId (1 2)) 4) (ConsMap ((mkNodeId (1 3)) 3) (ConsMap ((mkNodeId (1 4)) 2) (ConsMap ((mkNodeId (1 5)) 1) (ConsMap ((mkNodeId (1 6)) 0) (ConsMap ((mkNodeId (2)) 10) (ConsMap ((mkNodeId (3)) 9) (ConsMap ((mkNodeId (4)) 8) (ConsMap ((mkNodeId (5)) 7) (ConsMap ((mkNodeId (6)) 6) NilMap))))))))))))) (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 6))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 5))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 1))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (6))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (5))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) Nil))) NilMMap)))))))))))))) (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode C) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode C) Nil) Nil))) Nil)) Nil))))))) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode C) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode C) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil)))))))))
; )

; !(assertEqual (representation 
;         2
;         (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) Nil)) 
;         (ttable) 
;         rd 
;         False
;         ; ((E 0.4) (F 0.3) (G 0.73))
;         ()
;         mi
;         )
;         ((mkRep (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (1)) 7) (ConsMap ((mkNodeId (1 1)) 3) (ConsMap ((mkNodeId (1 2)) 2) (ConsMap ((mkNodeId (1 3)) 1) (ConsMap ((mkNodeId (1 4)) 0) (ConsMap ((mkNodeId (2)) 6) (ConsMap ((mkNodeId (3)) 5) (ConsMap ((mkNodeId (4)) 4) NilMap))))))))) (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 1))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) Nil))) NilMMap)))))))))) (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode D) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode D) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode D) Nil) Nil))) Nil)) Nil))))) (Cons (mkNullVex (Cons (mkTree (mkNode D) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode D) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode D) Nil) Nil))) Nil)) Nil)))))))
; )