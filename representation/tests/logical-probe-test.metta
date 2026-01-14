
!(import! &self ../../utilities/tree)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/general-helpers)
!(import! &self ../../representation/knob-representation)
!(import! &self ../../representation/logical-probe)
!(import! &self ../../representation/lsk)
!(import! &self ../../utilities/nodeId)
!(import! &self ../../representation/sample-logical-perms) 


;; logicalProbe tests
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
      ( ((mkLSK (mkDiscKnob (mkKnob (mkNodeId (2 1))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) Nil)) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil)))    
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
        (mkDiscKnob (mkKnob  (mkNodeId (1 1))) 
          (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil)))

      (mkTree (mkNode OR) 
            (Cons (mkTree (mkNode B) 
            (Cons (mkNullVex 
                  (Cons (mkTree (mkNode B) Nil) Nil)) Nil)) 
            (Cons (mkTree (mkNode C) Nil) Nil))))) True)


