!(register-module! ../../../metta-moses)
!(import! &self metta-moses:utilities:tree)
!(import! &self metta-moses:utilities:list-methods)
! (import! &self metta-moses:utilities:general-helpers)
!(import! &self metta-moses:representation:knob-representation)
!(import! &self metta-moses:representation:logical-probe)
!(import! &self metta-moses:representation:knob-representation)
!(import! &self metta-moses:representation:lsk)
!(import! &self metta-moses:utilities:nodeId)
!(import! &self metta-moses:representation:sample-logical-perms)

;; logicalProbe Tests
!(assertEqual
   (logicalProbe
      (mkTree (mkNode AND)     
        (Cons (mkTree (mkNode A) Nil)
          (Cons (mkTree (mkNode OR)
                  (Cons (mkTree (mkNode B) Nil)
                    (Cons (mkTree (mkNode C) Nil) Nil)))Nil)))
      (mkNodeId (2))           
      ((OR C D) (AND B C))     
      True                     
      ())                      
   ((mkLSK
      (mkDiscKnob
        (mkKnob
          (mkTree (mkNode AND)
            (Cons (mkTree (mkNode A) Nil)
              (Cons (mkTree (mkNode OR)
                      (Cons (mkTree (mkNode B) Nil)
                        (Cons (mkTree (mkNode C) Nil)
                          (Cons (mkNullVex
                                  (Cons (mkTree (mkNode OR)
                                          (Cons (mkTree (mkNode C) Nil)
                                            (Cons (mkTree (mkNode D) Nil) Nil)))Nil))Nil))))Nil)))
          (mkNodeId (2 3)))
        (mkMultip 3)
        (mkDiscSpec 0)
        (mkDiscSpec 0)  Nil)
      (mkTree (mkNode OR)
        (Cons (mkTree (mkNode C) Nil)
          (Cons (mkTree (mkNode D) Nil) Nil))))
    (mkLSK
      (mkDiscKnob
        (mkKnob
          (mkTree (mkNode AND)
            (Cons (mkTree (mkNode A) Nil)
              (Cons (mkTree (mkNode OR)
                      (Cons (mkTree (mkNode B) Nil)
                        (Cons (mkTree (mkNode C) Nil)
                          (Cons (mkNullVex
                                  (Cons (mkTree (mkNode AND)
                                          (Cons (mkTree (mkNode B) Nil)
                                            (Cons (mkTree (mkNode C) Nil) Nil))) Nil)) Nil)))) Nil)))
          (mkNodeId (2 3)))
        (mkMultip 3)
        (mkDiscSpec 0)
        (mkDiscSpec 0)  
        Nil)
      (mkTree (mkNode AND)
        (Cons (mkTree (mkNode B) Nil)
          (Cons (mkTree (mkNode C) Nil) Nil))))))


!(assertEqual 
   (logicalProbe
      (mkTree (mkNode AND)     
        (Cons (mkTree (mkNode A) Nil)
          (Cons (mkTree (mkNode B) Nil) Nil)))
      (mkNodeId (1))           
      (C D)     
      True                    
      ())   
      
   ((mkLSK 
      (mkDiscKnob 
        (mkKnob 
        (mkTree (mkNode AND) 
                (Cons (mkTree (mkNode A) 
                (Cons (mkNullVex 
                      (Cons (mkTree (mkNode C) Nil) Nil)) Nil)) 
                (Cons (mkTree (mkNode B) Nil) Nil)))  
        (mkNodeId (1 1))) 
        (mkMultip 3) 
        (mkDiscSpec 0) 
        (mkDiscSpec 0) Nil) 
      (mkTree (mkNode C) Nil)) 
      
    (mkLSK 
      (mkDiscKnob 
      (mkKnob 
      (mkTree (mkNode AND) 
              (Cons (mkTree (mkNode A) 
                    (Cons (mkNullVex 
                           (Cons (mkTree (mkNode D) Nil) Nil)) Nil)) 
              (Cons (mkTree (mkNode B) Nil) Nil))) 
      (mkNodeId (1 1))) 
      (mkMultip 3) 
      (mkDiscSpec 0) 
      (mkDiscSpec 0) Nil) 
    (mkTree (mkNode D) Nil))))  