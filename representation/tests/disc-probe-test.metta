!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/nodeId)
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
!(import! &self ../../utilities/tree)
!(import! &self ../../representation/lsk)
!(import! &self ../../representation/knob-representation)
!(import! &self ../../representation/disc-probe)
!(import! &self ../../representation/logical-probe)

;; Helper to extract disallowed list
(= (getDisallowed $lsk)
   (let (mkDiscKnob $k $m $c $d $dis) (getDiscKnob $lsk) $dis))

;; --- Test 1: Useful Knob ---
;; Adding B to (AND A) -> (AND A B). Should be ALLOWED.
!(assertEqual 
    (let* (
          ($exemplar (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
          (($updatedTree $lsk) (logicalSubtreeKnob $exemplar (mkNodeId (0)) (mkTree (mkNode B) ())))
          ($probedLsk (discProbe $updatedTree (mkNodeId (0)) $lsk))
         )
         (== (getDisallowed $probedLsk) ()))
    True)

;; --- Test 2: Redundant Present Setting ---
;; Adding (OR A) to (AND A) -> (AND A (OR A)) -> A. Should be DISALLOWED.
!(assertEqual 
    (let* (
          ($exemplar (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
          ($subtree (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) ())))
          (($treeWithNull $nullId) (appendChild $exemplar (mkNodeId (0)) (mkNullVex (cons $subtree ()))))
          ($lsk (mkLSK (mkDiscKnob (mkKnob $nullId) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())))
          ($probedLsk (discProbe $treeWithNull (mkNodeId (0)) $lsk))
         )
         (List.contains (mkDiscSpec 1) (getDisallowed $probedLsk)))
    True)

;; --- Test 3: Subsumption Redundancy ---
;; Adding (OR A B) to (AND A) -> (AND A (OR A B)) -> A. Should be DISALLOWED.
!(assertEqual 
    (let* (
          ($exemplar (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
          ($subtree (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))))
          (($treeWithNull $nullId) (appendChild $exemplar (mkNodeId (0)) (mkNullVex (cons $subtree ()))))
          ($lsk (mkLSK (mkDiscKnob (mkKnob $nullId) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())))
          ($probedLsk (discProbe $treeWithNull (mkNodeId (0)) $lsk))
         )
         (List.contains (mkDiscSpec 1) (getDisallowed $probedLsk)))
    True)

;; --- Test 4: Deep Nesting Allowed ---
;; The reducer does not lower complexity for this useful nested OR candidate, so it stays allowed.
!(assertEqual 
    (let* (
          ($inner (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode C) ()) ()))))
          ($mid (mkTree (mkNode OR) (cons (mkTree (mkNode B) ()) (cons $inner ()))))
          ($exemplar (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) ())))
          (($treeWithNull $nullId) (appendChild $exemplar (mkNodeId (0)) (mkNullVex (cons $mid ()))))
          ($lsk (mkLSK (mkDiscKnob (mkKnob $nullId) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())))
          ($probedLsk (discProbe $treeWithNull (mkNodeId (0)) $lsk))
         )
         (List.contains (mkDiscSpec 1) (getDisallowed $probedLsk)))
    False)

;; --- Test 5: Conflict Redundancy (AND A (NOT A)) ---
;; Adding (NOT A) to (AND A) -> (AND A (NOT A)) -> False. Should be DISALLOWED.
!(assertEqual 
    (let* (
          ($exemplar (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
          (($treeWithNull $nullId) (appendChild $exemplar (mkNodeId (0)) (mkNullVex (cons (mkTree (mkNode A) ()) ()))))
          ($lsk (mkLSK (mkDiscKnob (mkKnob $nullId) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())))
          ($probedLsk (discProbe $treeWithNull (mkNodeId (0)) $lsk))
         )
         (List.contains (mkDiscSpec 2) (getDisallowed $probedLsk)))
    True)

;; --- Test 6: Double Negation Handling ---
;; Adding (NOT (NOT B)) to (AND A) -> (AND A B). Should be ALLOWED.
!(assertEqual 
    (let* (
          ($exemplar (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
          ($subtree (mkTree (mkNode NOT) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode B) ()) ())) ())))
          (($treeWithNull $nullId) (appendChild $exemplar (mkNodeId (0)) (mkNullVex (cons $subtree ()))))
          ($lsk (mkLSK (mkDiscKnob (mkKnob $nullId) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())))
          ($probedLsk (discProbe $treeWithNull (mkNodeId (0)) $lsk))
         )
         (List.contains (mkDiscSpec 1) (getDisallowed $probedLsk)))
	    False)

;; --- Test 7: All-disallowed knobs are discarded by logicalProbe ---
;; Adding (OR A) to (AND A) has present and negated settings that both reduce.
!(assertEqual
    (let* (
          ($exemplar (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
          (($knobs $updatedTree) (logicalProbe $exemplar (mkNodeId (0)) ((mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) ()))) True (seed)))
         )
         (== $knobs (seed)))
    True)

;; --- Test 8: In-exemplar knobs use effective default mapping ---
;; For an existing A child, effective 0 maps back to actual present (1).
!(assertEqual
    (let* (
          ($exemplar (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
         (($updatedTree $lsk) (logicalSubtreeKnob $exemplar (mkNodeId (0)) (mkTree (mkNode A) ())))
          ($probedLsk (discProbe $updatedTree (mkNodeId (0)) $lsk))
         )
         (and (== (mapEffectiveDiscSpec $probedLsk 0) 1)
              (not (List.contains (mkDiscSpec 1) (getDisallowed $probedLsk)))))
    True)
