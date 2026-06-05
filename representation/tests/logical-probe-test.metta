!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/nodeId)
!(import! &self ../../utilities/tree)
!(import! &self ../../representation/lsk)
!(import! &self ../../representation/knob-representation)
!(import! &self ../../representation/logical-probe)
!(import! &self ../../representation/sample-logical-perms) 


;; logicalProbe tests
!(assertEqual (logicalProbe
      (mkTree (mkNode AND)     
        (cons (mkTree (mkNode A) ())
          (cons (mkTree (mkNode OR)
                  (cons (mkTree (mkNode B) ())
                  (cons (mkTree (mkNode C) ()) ())))())))
      ((mkTree (mkNode B) ()) (mkTree (mkNode A) ()))    
      True)
      ( ((mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ())))
        (mkTree (mkNode AND) ((mkTree (mkNode OR) ((mkTree (mkNode B) ()) (mkTree (mkNode C) ()))) (mkKnob (mkNullVex ((mkTree (mkNode B) ()))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 0) (mkKnob (mkTree (mkNode A) ()) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ())) 1)))))

!(resetState &knobCount)

!(assertEqual 
    (logicalProbe
          (mkTree (mkNode OR)
                      (cons (mkTree (mkNode B) ())
                      (cons (mkTree (mkNode C) ()) ())))
          ((mkTree (mkNode B) ()))    
          True
    )
    (
      ((mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ())))
      (mkTree (mkNode OR) ((mkTree (mkNode C) ()) (mkKnob (mkTree (mkNode B) ()) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ())) 0)))))

;; Tests for strategyProbe function (game strategy version)
;; strategyProbe test 1: Multiple game move permutations
!(assertEqual 
    (=== (strategyProbe
      (mkTree (mkNode PRIORITIZED-OR)     
        (cons (mkTree (mkNode playcenter) ())
          (cons (mkTree (mkNode playcorner) ()) ())))
      (mkNodeId (0))           
      ((mkTree (mkNode playblock) ()) (mkTree (mkNode playcenter) ()))    
      True
      ())
      ( ((mkSSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ())) (mkSSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 1) (mkDiscSpec 1) ())))    
        (mkTree (mkNode PRIORITIZED-OR) 
                (cons (mkTree (mkNode playcenter) ()) 
                (cons (mkTree (mkNode playcorner) ()) 
                (cons (mkNullVex 
                       (cons (mkTree (mkNode playblock) ()) ())) ())))))) True)

;; strategyProbe test 2: Single game move permutation
!(assertEqual 
    (=== (strategyProbe
      (mkTree (mkNode PRIORITIZED-OR)
                  (cons (mkTree (mkNode playcenter) ())
                  (cons (mkTree (mkNode playcorner) ()) ())))
      (mkNodeId (0))           
      ((mkTree (mkNode playcorner) ()))    
      True
      ())

     (((mkSSK 
        (mkDiscKnob (mkKnob  (mkNodeId (2))) 
          (mkMultip 2) (mkDiscSpec 1) (mkDiscSpec 1) ())))

      (mkTree (mkNode PRIORITIZED-OR) 
            (cons (mkTree (mkNode playcenter) ()) 
            (cons (mkTree (mkNode playcorner) ()) ()))))) True)

;; Test empty permutation list for strategyProbe
!(assertEqual 
    (=== (strategyProbe
      (mkTree (mkNode PRIORITIZED-OR)
                  (cons (mkTree (mkNode playcenter) ()) ()))
      (mkNodeId (0))           
      ()    
      True
      ())
     (() (mkTree (mkNode PRIORITIZED-OR) 
                 (cons (mkTree (mkNode playcenter) ()) ())))) True)

;; Test strategyProbe with diverse game moves
!(assertEqual 
    (=== (strategyProbe
      (mkTree (mkNode PRIORITIZED-OR)     
        (cons (mkTree (mkNode playwin) ())
          (cons (mkTree (mkNode playfork) ()) ())))
      (mkNodeId (0))           
      ((mkTree (mkNode playblock) ()))    
      True
      ())
      ( ((mkSSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ())))    
        (mkTree (mkNode PRIORITIZED-OR) 
                (cons (mkTree (mkNode playwin) ()) 
                (cons (mkTree (mkNode playfork) ()) 
                (cons (mkNullVex 
                       (cons (mkTree (mkNode playblock) ()) ())) ())))))) True)

; ;; Test that strategyProbe creates SSK knobs (multiplicity 2) not LSK knobs (multiplicity 3)
!(assertEqual 
    (let* (
        (($knobs $tree) (strategyProbe
                           (mkTree (mkNode PRIORITIZED-OR)
                                   (cons (mkTree (mkNode playcenter) ()) ()))
                           (mkNodeId (0))
                           ((mkTree (mkNode playcorner) ()))
                           True
                           ()))
        ($firstKnob (car-atom $knobs))
        ($multi (getKnobMultip $firstKnob))
    )
    (== $multi (mkMultip 2))) True)
