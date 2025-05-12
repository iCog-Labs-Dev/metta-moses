!(register-module! ../../../metta-moses)
! (import! &self metta-moses:representation:lsk)
! (import! &self metta-moses:representation:knob-mapper)
! (import! &self metta-moses:representation:representation)
! (import! &self metta-moses:representation:knob-representation)
! (import! &self metta-moses:representation:logical-probe) 
! (import! &self metta-moses:representation:build-logical)
! (import! &self metta-moses:representation:sample-logical-perms) 
! (import! &self metta-moses:representation:add-logical-knobs)
! (import! &self metta-moses:representation:instance)
! (import! &self metta-moses:representation:count-neighborhood)

! (import! &self metta-moses:utilities:map)
! (import! &self metta-moses:utilities:tree) 
! (import! &self metta-moses:utilities:nodeId)
! (import! &self metta-moses:utilities:list-methods) 
! (import! &self metta-moses:utilities:general-helpers) 
! (import! &self metta-moses:utilities:ordered-multimap)

;Testcase for countNeighborhood
!(assertEqual 
 (countNeighborhood
 ; knobMap
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
                                 (Cons (mkTree (mkNode B) Nil) Nil)))
                             Nil))
                         Nil)))
                   (Cons 
                     (mkNullVex 
                       (Cons 
                         (mkTree 
                           (mkNode AND) 
                           (Cons 
                             (mkTree (mkNode A) Nil)
                             (Cons (mkTree (mkNode B) Nil) Nil)))
                         Nil))
                     Nil)))
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
                               (Cons (mkTree (mkNode B) Nil) Nil)))
                           Nil))
                       Nil)))
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
                                 (Cons (mkTree (mkNode B) Nil) Nil)))
                             Nil))
                         Nil)))
                   (mkNodeId (3)))
                 (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil)
               (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil)))))
            NilMMap)))))
  (mkInst (Cons 1 (Cons 0 (Cons 2 Nil)))) ;instance
  2 ; distance
  20) ; maximum count
  12)

;Testcase for countNeighborhood
!(assertEqual 
 (countNeighborhood
 ;knobmap
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
                                 (Cons (mkTree (mkNode B) Nil) Nil)))
                             Nil))
                         Nil)))
                   (Cons 
                     (mkNullVex 
                       (Cons 
                         (mkTree 
                           (mkNode AND) 
                           (Cons 
                             (mkTree (mkNode A) Nil)
                             (Cons (mkTree (mkNode B) Nil) Nil)))
                         Nil))
                     Nil)))
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
                               (Cons (mkTree (mkNode B) Nil) Nil)))
                           Nil))
                       Nil)))
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
                                 (Cons (mkTree (mkNode B) Nil) Nil)))
                             Nil))
                         Nil)))
                   (mkNodeId (3)))
                 (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil)
               (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil)))))
            NilMMap)))))
  ;instance
  (mkInst (Cons 1 (Cons 0 (Cons 2 Nil))))
  3 ;distance
  20) ;maxCount
  8) 