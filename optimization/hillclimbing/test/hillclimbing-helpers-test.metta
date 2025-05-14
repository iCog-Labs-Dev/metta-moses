!(register-module! ../../../../metta-moses)

!(import! &self metta-moses:representation:knob-representation)
!(import! &self metta-moses:representation:representation)
!(import! &self metta-moses:representation:instance)
!(import! &self metta-moses:utilities:list-methods)
!(import! &self metta-moses:utilities:ordered-multimap)
!(import! &self metta-moses:utilities:general-helpers)
!(import! &self metta-moses:utilities:nodeId)
!(import! &self metta-moses:optimization:hillclimbing:hill-climbing-helpers)
!(import! &self metta-moses:moses:neighborhood-sampling)
!(import! &self metta-moses:utilities:python-helpers)

(= (pyExprToList $expr) (py_exprToList $expr))


!(bind! knobmap1
        (ConsMMap (
                    (mkNodeId (0))
                    (
                      (mkDiscSpec 1)
                      (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode A) Nil))))
        (ConsMMap (
                    (mkNodeId (0))
                    (
                      (mkDiscSpec 1)
                      (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode B) Nil) (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode B) Nil))))
        NilMMap)))

!(bind! knobmap2
        (ConsMMap (
                    (mkNodeId (0))
                    (
                      (mkDiscSpec 1)
                      (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode A) Nil))))
        (ConsMMap (
                    (mkNodeId (0))
                    (
                      (mkDiscSpec 1)
                      (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode B) Nil) (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode B) Nil))))
        NilMMap)))

!(bind! knobmap3   
  (mkKbMap 
    (mkDscKbMp 
      (ConsMap ((mkNodeId (1 2)) 0)
        (ConsMap ((mkNodeId (2)) 1)
          (ConsMap ((mkNodeId (3)) 2) NilMap))))
    (mkDscMp 
      (ConsMMap 
        ((mkDiscSpec 3)
         (mkLSK 
           (mkDiscKnob 
             (mkKnob 
               (mkTree 
                 (mkNode OR) 
                 (Cons 
                   (mkTree 
                     (mkNode AND) 
                     (Cons 
                       (mkTree (mkNode C) Nil)
                       (Cons 
                         (mkNullVex 
                           (Cons 
                             (mkTree 
                               (mkNode OR) 
                               (Cons 
                                 (mkTree (mkNode A) Nil)
                                 (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil)))
                   (Cons 
                     (mkNullVex 
                       (Cons 
                         (mkTree 
                           (mkNode AND) 
                           (Cons 
                             (mkTree (mkNode A) Nil)
                             (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil)))
               (mkNodeId (1 2)))
             (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil)
           (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil)))))
        (ConsMMap 
          ((mkDiscSpec 3)
           (mkLSK 
             (mkDiscKnob 
               (mkKnob 
                 (mkTree 
                   (mkNode OR) 
                   (Cons 
                     (mkTree (mkNode C) Nil)
                     (Cons 
                       (mkNullVex 
                         (Cons 
                           (mkTree 
                             (mkNode AND) 
                             (Cons 
                               (mkTree (mkNode A) Nil)
                               (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil)))
                 (mkNodeId (2)))
               (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil)
             (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil)))))
          (ConsMMap 
            ((mkDiscSpec 3)
             (mkLSK 
               (mkDiscKnob 
                 (mkKnob 
                   (mkTree 
                     (mkNode OR) 
                     (Cons 
                       (mkTree (mkNode C) Nil)
                       (Cons 
                         (mkNullVex 
                           (Cons 
                             (mkTree 
                               (mkNode AND) 
                               (Cons 
                                 (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil))
                                 (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil)))
                   (mkNodeId (3)))
                 (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil)
               (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil)))))
            NilMMap))))))
;; Test informationTheoreticBits with a knob 
;; map containing two knobs with same multiplicity of 3
!(assertEqual (informationTheoreticBits knobmap1) 6)

;; Test informationTheoreticBits with a knob
;; map containing two knobs with different multiplicity of 2 and 3
!(assertEqual (informationTheoreticBits knobmap2) 5)

;; Testing estimateNeighborhood on the above knob maps
!(assertEqual (estimateNeighborhood 0 knobmap1) 1)
!(assertEqual (estimateNeighborhood 1 knobmap2) 10)
!(assertEqual (estimateNeighborhood 2 knobmap1) 12)
!(assertEqual (estimateNeighborhood 2 knobmap2) 10)

;Testcase 1 for countNeighborhood
!(assertEqual 
 (countNeighborhood
  knobmap3  ;knobmap
  (mkInst (Cons 1 (Cons 0 (Cons 2 Nil)))) ;instance
  2 ; distance
  20) ; maximum count
  12)

;Testcase 2 for countNeighborhood
!(assertEqual 
 (countNeighborhood
  knobmap3 ;knobmap
  (mkInst (Cons 1 (Cons 0 (Cons 2 Nil)))) ;instance
  3 ;distance
  20) ;maxCount
  8) 

;Testcase 3 for countNeighborhood
!(assertEqual 
 (let*
    (
       ($totalSize (countNeighborhood knobmap3 (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) 3 20))
       ($generatedSize (List.length (generateAllInNeighborhood (mkMultip 3) (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) 3)))
    )
    (<= (* 3 $totalSize) (* 4 $generatedSize))) True)

;Testcase 4 for countNeighborhood
!(assertEqual 
 (let*
    (
       ($totalSize (countNeighborhood knobmap3 (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) 2 20))
       ($generatedSize (List.length (generateAllInNeighborhood (mkMultip 3) (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) 2)))
    )
    (<= (* 3 $totalSize) (* 4 $generatedSize))) True)

;Testcase 5 for countNeighborhood
!(assertEqual
 (let*
    (
       ($totalSize (countNeighborhood knobmap3 (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) 1 20))
       ($generatedSize (List.length (generateAllInNeighborhood (mkMultip 3) (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) 1)))
    )
    (<= (* 3 $totalSize) (* 4 $generatedSize))) True)