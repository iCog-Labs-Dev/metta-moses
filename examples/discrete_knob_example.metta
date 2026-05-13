!(import! &self ../utilities/general-helpers)
!(import! &self ../utilities/list-methods)
!(import! &self ../utilities/nodeId)
!(import! &self ../utilities/tree)
!(import! &self ../representation/lsk)
!(import! &self ../representation/knob-representation)

;; MOSES DISCRETE DOMAIN DEMONSTRATION
;; This script demonstrates how MOSES can now handle non-boolean discrete 
;; domains, such as swapping operators or selecting from a set of constants.

;; 1. Define our discrete domain (Arithmetic Operators)
(= (operator-domain) (PLUS MINUS MULT DIV))

;; 2. Create a General Discrete Knob (GDK)
;; This knob is located at the root (NodeId (0)), has 4 options, and defaults to state 0 (PLUS).
(= (my-discrete-knob) 
   (mkGDK (mkDiscKnob (mkKnob (mkNodeId (0))) (mkMultip 4) (mkDiscSpec 0) (mkDiscSpec 0) ()) 
          (operator-domain)))

;; 3. Define our "Reference Tree" (The Exemplar with the knob)
;; For simplicity, we'll just use a tree where the root is the knob itself.
;; In a real MOSES run, this would be a larger tree containing multiple knobs.
(= (reference-tree) (mkTree (mkNode PLACEHOLDER) ()))

;; 4. Define a helper to build a candidate tree from an index
(= (build-candidate $d)
   (let* (
          ($empty-candidate (mkNullVex ()))
          ($result (appendTo (reference-tree) (my-discrete-knob) $empty-candidate (mkNodeId (0)) $d))
          ($candidate-tree (first $result))
         )
         (preOrder $candidate-tree)))

;; TEST CASES: Selection from Discrete Domain

;; Case 0: Pick index 0 -> PLUS
!(assertEqual (build-candidate 0) PLUS)

;; Case 1: Pick index 1 -> MINUS
!(assertEqual (build-candidate 1) MINUS)

;; Case 2: Pick index 2 -> MULT
!(assertEqual (build-candidate 2) MULT)

;; Case 3: Pick index 3 -> DIV
!(assertEqual (build-candidate 3) DIV)

;; SUMMARY
;; As shown above, the GDK allows the evolutionary search to "toggle" between 
;; arbitrary MeTTa atoms (PLUS, MINUS, etc.) rather than just being limited 
;; to Boolean inclusion/exclusion (LSK/SSK).
