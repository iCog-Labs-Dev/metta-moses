!(register-module! ../../../metta-moses)
!(import! &self metta-moses:utilities:tree)
!(import! &self metta-moses:utilities:list-methods)
!(import! &self metta-moses:utilities:general-helpers)
!(import! &self metta-moses:representation:knob-representation)
!(import! &self metta-moses:utilities:ordered-multimap) 

! (assertEqual (let $return (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) $return)  
               (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1)))
               )
! (assertEqual (let $return (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil) $return)
               (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil)
               )
! (assertEqual (let $return (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2)) $return)
               (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2))
               ) 
! (assertEqual (let $return (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode A) Nil)) $return)
               (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2)) (mkTree (mkNode A) Nil))
               )             
! (assertEqual (let $return (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode A) Nil)) $return)
               (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2)) (mkTree (mkNode A) Nil))
               )

! (assertEqual (let $type (get-type (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1)))) $type) Knob)
! (assertEqual (let $type (get-type (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil)) $type) DiscreteKnob)
! (assertEqual (let $type (get-type (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2))) $type) DiscreteKnob)
! (assertEqual (let $type (get-type (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode A) Nil))) $type) LogicalSubtreeKnob)
! (assertEqual (let $type (get-type (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2)) (mkTree (mkNode A) Nil))) $type) LogicalSubtreeKnob)

;; inExemplar tests
!(assertEqual (inExemplar (mkDiscKnob $knob $multiplicity (mkDiscSpec 0) (mkDiscSpec 1) Nil)) True)
!(assertEqual (inExemplar (mkDiscKnob $knob $multiplicity)) False)

;; getDiscKnob Tests
!(assertEqual (getDiscKnob (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode A) Nil)))
  (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil))
!(assertEqual (getDiscKnob (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2)) (mkTree (mkNode A) Nil)))
  (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil))

;; getTree Tests
!(assertEqual (getTree (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode A) Nil)))
  (mkTree (mkNode A) Nil))
!(assertEqual (getTree (mkLSK 
       (mkDiscKnob 
       (mkKnob (mkTree (mkNode AND) 
                       (Cons (mkTree (mkNode A) 
                             (Cons (mkNullVex (Cons (mkTree (mkNode D) Nil) Nil)) Nil)) 
                                              (Cons (mkTree (mkNode B) Nil) Nil))) 
               (mkNodeId (1 1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) 
       (mkTree (mkNode D) Nil)) )
  (mkTree (mkNode AND) 
                       (Cons (mkTree (mkNode A) 
                             (Cons (mkNullVex (Cons (mkTree (mkNode D) Nil) Nil)) Nil)) 
                                              (Cons (mkTree (mkNode B) Nil) Nil))))

;; getKnobSpec Tests
!(assertEqual (getKnobSpec (mkLSK 
       (mkDiscKnob 
       (mkKnob (mkTree (mkNode AND) 
                       (Cons (mkTree (mkNode A) 
                             (Cons (mkNullVex (Cons (mkTree (mkNode D) Nil) Nil)) Nil)) 
                                              (Cons (mkTree (mkNode B) Nil) Nil))) 
               (mkNodeId (1 1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) (Cons (mkDiscSpec 1) Nil)) 
       (mkTree (mkNode D) Nil))) (mkDiscSpec 2))

;; Testing getmultiplicity function
!(assertEqual (getKnobMultip (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2))) (mkMultip 2))
!(assertEqual (getKnobMultip (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode A) Nil))) (mkMultip 2))
!(assertEqual (getKnobSpec (mkLSK 
       (mkDiscKnob 
       (mkKnob (mkTree (mkNode AND) 
                       (Cons (mkTree (mkNode A) 
                             (Cons (mkNullVex (Cons (mkTree (mkNode D) Nil) Nil)) Nil)) 
                                              (Cons (mkTree (mkNode B) Nil) Nil))) 
               (mkNodeId (1 1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) 
       (mkTree (mkNode D) Nil)) ) (mkDiscSpec 3))

;; Test for getKnobLoc
!(assertEqual (getKnobLoc (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode A) Nil))) (mkNodeId (1)))
!(assertEqual (getKnobLoc (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode A) Nil))) (mkNodeId (1)))

;; Test for discSpec<=
!(assertEqual (discSpec<= (mkDiscSpec 2) (mkDiscSpec 3)) True)
!(assertEqual (discSpec<= (mkDiscSpec 3) (mkDiscSpec 2)) False)

;; Test for nodeId<
!(assertEqual (nodeId< (mkNodeId (2 1)) (mkNodeId (2 1 1))) True)
!(assertEqual (nodeId< (mkNodeId (2 1)) (mkNodeId (2 2))) True)
!(assertEqual (nodeId< (mkNodeId (2 2 3)) (mkNodeId (2 3))) True)
!(assertEqual (nodeId< (mkNodeId (2 3)) (mkNodeId (1 2))) False)
!(assertEqual (nodeId< (mkNodeId (2 3)) (mkNodeId (2 3))) False)

