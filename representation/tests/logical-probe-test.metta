!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/nodeId)
!(import! &self ../../utilities/tree)
!(import! &self ../../representation/lsk)
!(import! &self ../../representation/knob-representation)
!(import! &self ../../representation/logical-probe)
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

;; Tests for strategyProbe function (game strategy version)
;; strategyProbe test 1: Multiple game move permutations
!(assertEqual 
    (=== (strategyProbe
      (mkTree (mkNode PRIORITIZED-OR)     
        (Cons (mkTree (mkNode playcenter) Nil)
          (Cons (mkTree (mkNode playcorner) Nil) Nil)))
      (mkNodeId (0))           
      ((mkTree (mkNode playblock) Nil) (mkTree (mkNode playcenter) Nil))    
      True
      ())
      ( ((mkSSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil)) (mkSSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 1) (mkDiscSpec 1) Nil)))    
        (mkTree (mkNode PRIORITIZED-OR) 
                (Cons (mkTree (mkNode playcenter) Nil) 
                (Cons (mkTree (mkNode playcorner) Nil) 
                (Cons (mkNullVex 
                       (Cons (mkTree (mkNode playblock) Nil) Nil)) Nil)))))) True)

;; strategyProbe test 2: Single game move permutation
!(assertEqual 
    (=== (strategyProbe
      (mkTree (mkNode PRIORITIZED-OR)
                  (Cons (mkTree (mkNode playcenter) Nil)
                  (Cons (mkTree (mkNode playcorner) Nil) Nil)))
      (mkNodeId (0))           
      ((mkTree (mkNode playcorner) Nil))    
      True
      ())

     (((mkSSK 
        (mkDiscKnob (mkKnob  (mkNodeId (2))) 
          (mkMultip 2) (mkDiscSpec 1) (mkDiscSpec 1) Nil)))

      (mkTree (mkNode PRIORITIZED-OR) 
            (Cons (mkTree (mkNode playcenter) Nil) 
            (Cons (mkTree (mkNode playcorner) Nil) Nil))))) True)

;; Test empty permutation list for strategyProbe
!(assertEqual 
    (=== (strategyProbe
      (mkTree (mkNode PRIORITIZED-OR)
                  (Cons (mkTree (mkNode playcenter) Nil) Nil))
      (mkNodeId (0))           
      ()    
      True
      ())
     (() (mkTree (mkNode PRIORITIZED-OR) 
                 (Cons (mkTree (mkNode playcenter) Nil) Nil)))) True)

;; Test strategyProbe with diverse game moves
!(assertEqual 
    (=== (strategyProbe
      (mkTree (mkNode PRIORITIZED-OR)     
        (Cons (mkTree (mkNode playwin) Nil)
          (Cons (mkTree (mkNode playfork) Nil) Nil)))
      (mkNodeId (0))           
      ((mkTree (mkNode playblock) Nil))    
      True
      ())
      ( ((mkSSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil)))    
        (mkTree (mkNode PRIORITIZED-OR) 
                (Cons (mkTree (mkNode playwin) Nil) 
                (Cons (mkTree (mkNode playfork) Nil) 
                (Cons (mkNullVex 
                       (Cons (mkTree (mkNode playblock) Nil) Nil)) Nil)))))) True)

; ;; Test that strategyProbe creates SSK knobs (multiplicity 2) not LSK knobs (multiplicity 3)
!(assertEqual 
    (let* (
        (($knobs $tree) (strategyProbe
                           (mkTree (mkNode PRIORITIZED-OR)
                                   (Cons (mkTree (mkNode playcenter) Nil) Nil))
                           (mkNodeId (0))
                           ((mkTree (mkNode playcorner) Nil))
                           True
                           ()))
        ($firstKnob (car-atom $knobs))
        ($multi (getKnobMultip $firstKnob))
    )
    (== $multi (mkMultip 2))) True)
