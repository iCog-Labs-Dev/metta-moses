!(register-module! ../../../metta-moses)
!(import! &self metta-moses:utilities:tree)
!(import! &self metta-moses:utilities:list-methods)
!(import! &self metta-moses:utilities:general-helpers)
!(import! &self metta-moses:representation:knob-representation)
!(import! &self metta-moses:representation:logical-probe)
!(import! &self metta-moses:representation:knob-representation)
!(import! &self metta-moses:representation:lsk)
!(import! &self metta-moses:utilities:nodeId)
!(import! &self metta-moses:representation:sample-logical-perms) 
! (import! &self metta-moses:utilities:python-treehelpers)

(= (APPEND_CHILD $tree $nodeId $child ) (py_appendChild $tree $nodeId $child))
(= (GetByID $tree $nodeId) (py_getById $tree $nodeId))

;; permsToTree tests
!(assertEqual (permsToTree (A B)) ((mkTree (mkNode B) Nil) (mkTree (mkNode A) Nil)))
!(assertEqual 
   (permsToTree ((OR A B) (AND C D))) 
   ((mkTree (mkNode AND) 
            (Cons (mkTree (mkNode C) Nil) (Cons (mkTree (mkNode D) Nil) Nil))) 
    (mkTree (mkNode OR) 
            (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil)))))


; logicalProbe tests
!(assertEqual 
    (=== (logicalProbe
      (mkTree (mkNode AND)     
        (Cons (mkTree (mkNode A) Nil)
          (Cons (mkTree (mkNode OR)
                  (Cons (mkTree (mkNode B) Nil)
                  (Cons (mkTree (mkNode C) Nil) Nil)))Nil)))
      (mkNodeId (2))           
      ((mkTree (mkNode B) Nil) (mkTree (mkNode A) Nil))    
      True
      ())
      
      (((mkLSK 
         (mkDiscKnob 
           (mkKnob (mkTree (mkNode AND) 
                           (Cons (mkTree (mkNode A) Nil) 
                           (Cons (mkTree (mkNode OR) 
                                 (Cons (mkTree (mkNode B) Nil) 
                                 (Cons (mkTree (mkNode C) Nil) Nil))) Nil))) 
                   (mkNodeId (2 1))) 
         (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) Nil) 
        (mkTree (mkNode B) Nil)) 

        (mkLSK 
         (mkDiscKnob 
          (mkKnob (mkTree (mkNode AND) 
                  (Cons (mkTree (mkNode A) Nil) 
                  (Cons (mkTree (mkNode OR) 
                        (Cons (mkTree (mkNode B) Nil) 
                        (Cons (mkTree (mkNode C) Nil) 
                        (Cons (mkNullVex 
                              (Cons (mkTree (mkNode A) Nil) Nil)) Nil)))) Nil))) 
                  (mkNodeId (2 3))) 
         (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) 
        (mkTree (mkNode A) Nil))) 
        
        (mkTree (mkNode AND) 
                (Cons (mkTree (mkNode A) Nil) 
                (Cons (mkTree (mkNode OR) 
                      (Cons (mkTree (mkNode B) Nil) 
                      (Cons (mkTree (mkNode C) Nil) 
                      (Cons (mkNullVex 
                             (Cons (mkTree (mkNode A) Nil) Nil)) Nil)))) Nil))))) True)

!(assertEqual 
    (=== (logicalProbe
      (mkTree (mkNode OR)
                  (Cons (mkTree (mkNode B) Nil)
                  (Cons (mkTree (mkNode C) Nil) Nil)))
      (mkNodeId (1))           
      ((mkTree (mkNode B) Nil))    
      True
      ())

     (((mkLSK 
        (mkDiscKnob 
          (mkKnob (mkTree (mkNode OR) 
                  (Cons (mkTree (mkNode B) 
                        (Cons (mkNullVex  
                              (Cons (mkTree (mkNode B) Nil) Nil)) Nil)) 
                  (Cons (mkTree (mkNode C) Nil) Nil))) 
                  (mkNodeId (1 1))) 
          (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) 
        (mkTree (mkNode B) Nil)))

      (mkTree (mkNode OR) 
              (Cons (mkTree (mkNode B) 
              (Cons (mkNullVex 
                    (Cons (mkTree (mkNode B) Nil) Nil)) Nil)) 
        (Cons (mkTree (mkNode C) Nil) Nil))))) True)