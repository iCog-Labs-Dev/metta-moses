!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/ordered-multimap) 
!(import! &self ../../utilities/lazy-random-selector)
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

!(import! &self ../../scoring/action-registry)
!(import! &self ../../representation/knob-representation)
!(import! &self ../lsk)
!(import! &self ../../representation/logical-canonize)
!(import! &self ../../representation/logical-probe)
!(import! &self ../sample-logical-perms) 
!(import! &self ../add-logical-knobs)
!(import! &self ../build-action)
!(import! &self ../../scoring/boolean-ops)
!(import! &self ../../scoring/bscore)


!(py-call (random.seed 0))
;; Testcase for the addLogicalKnobs 

!(assertEqual (let* 
(
    (($updatedTree $mm)
     (addLogicalKnobs (mkTree (mkNode AND)
        ((mkTree (mkNode A) ()) (mkTree (mkNode B) ())))
        True () (A B)))
    ($mmpsEqual
     (MultiMap.equals $mm
     (((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))))))

    ($treesEqual
     (== $updatedTree
     (mkTree (mkNode AND) ((mkKnob (mkTree (mkNode A) ()) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ())) 0) (mkKnob (mkTree (mkNode B) ()) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ())) 1) (mkKnob (mkNullVex ((mkTree (mkNode OR) ((mkTree (mkNode A) ()) (mkTree (mkNode B) ()))))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 2) (mkKnob (mkNullVex ((mkTree (mkNode OR) ((mkTree (mkNode NOT) ((mkTree (mkNode A) ()))) (mkTree (mkNode B) ()))))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 3))))
    )
)
(and $mmpsEqual $treesEqual)
) True)

!(resetState &knobCount)

;; Testcase for the addLogicalKnobs 
!(assertEqual (let* 
(
    (($updatedTree $mm)
     (addLogicalKnobs 
       (mkTree (mkNode AND)
        (cons (mkTree (mkNode A) ())
          (cons (mkTree (mkNode OR)
                  (cons (mkTree (mkNode B) ())
                  (cons (mkTree (mkNode C) ()) ())))())))
       True () (A B)))
    ($_ (println! (Tree: $updatedTree)))
    ($mmpsEqual 
     (MultiMap.equals $mm
                      (((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))))))

    ($treesEqual 
     (== $updatedTree
     (mkTree (mkNode AND) ((mkTree (mkNode OR) ((mkTree (mkNode B) ()) (mkTree (mkNode C) ()))) (mkKnob (mkTree (mkNode A) ()) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ())) 0) (mkKnob (mkNullVex ((mkTree (mkNode B) ()))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 1) (mkKnob (mkNullVex ((mkTree (mkNode OR) ((mkTree (mkNode A) ()) (mkTree (mkNode B) ()))))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 2) (mkKnob (mkNullVex ((mkTree (mkNode OR) ((mkTree (mkNode NOT) ((mkTree (mkNode A) ()))) (mkTree (mkNode B) ()))))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 3))) )
    )
)
(and $mmpsEqual $treesEqual)
) True)

!(resetState &knobCount)

;; =============================================================================
;; Action-subtree knobs via addActionKnobs (replace the retired game-strategy
;; addLogicalKnobs cases). The ttt play* symbols ride as an ordinary action
;; vocabulary argument; perceptions are () so sampling is fully deterministic
;; (no random draws, no knobCount involvement -- addActionKnobs takes an
;; explicit knob index).
;; =============================================================================
(= (pwTree) (mkTree (mkNode playwin) ()))
(= (pfTree) (mkTree (mkNode playfork) ()))
(= (pbTree) (mkTree (mkNode playblock) ()))
(= (pcTree) (mkTree (mkNode playcenter) ()))
(= (pcrTree) (mkTree (mkNode playcorner) ()))
(= (psTree) (mkTree (mkNode playside) ()))
(= (tttActs) (playwin playblock playcenter playcorner playside))
(= (tttMoveTrees) ((pwTree) (pbTree) (pcTree) (pcrTree) (psTree)))

;; (a) A five-action vocabulary appends a single ASK knob (multip |vocab|+1 = 6)
;; as the new 3rd child of the two-child and_seq.
!(assertEqual
  (let ($updatedSubtree $mmp) (addActionKnobs (mkTree (mkNode and_seq) ((pcTree) (pcrTree))) True () (tttActs) ())
    ((MultiMap.length $mmp)
     (getRawKnobMultip (car-atom (MultiMap.values $mmp)))
     (getNodeById $updatedSubtree (mkNodeId (3)))))
  (1
   (mkMultip 6)
   (mkKnob (mkNullVex (tttMoveTrees))
           (mkASK (mkDiscKnob (mkMultip 6) (mkDiscSpec 0) (mkDiscSpec 0) ()) (tttMoveTrees))
           0)))

;; (b) A single-action vocabulary gives multip 2, knob appended at (2).
!(assertEqual
  (let ($updatedSubtree $mmp) (addActionKnobs (mkTree (mkNode and_seq) ((pcTree))) True () (playcenter) ())
    ((MultiMap.length $mmp)
     (getRawKnobMultip (car-atom (MultiMap.values $mmp)))
     (getNodeById $updatedSubtree (mkNodeId (2)))))
  (1
   (mkMultip 2)
   (mkKnob (mkNullVex ((pcTree)))
           (mkASK (mkDiscKnob (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ()) ((pcTree)))
           0)))

;; (c) A three-action vocabulary gives multip 4, knob appended at (4).
!(assertEqual
  (let ($updatedSubtree $mmp) (addActionKnobs (mkTree (mkNode and_seq) ((pcTree) (pcrTree) (pbTree))) True () (playcenter playcorner playblock) ())
    ((MultiMap.length $mmp)
     (getRawKnobMultip (car-atom (MultiMap.values $mmp)))
     (getNodeById $updatedSubtree (mkNodeId (4)))))
  (1
   (mkMultip 4)
   (mkKnob (mkNullVex ((pcTree) (pcrTree) (pbTree)))
           (mkASK (mkDiscKnob (mkMultip 4) (mkDiscSpec 0) (mkDiscSpec 0) ()) ((pcTree) (pcrTree) (pbTree)))
           0)))

;; (d) A two-action vocabulary yields an effective multiplicity of 3.
!(assertEqual
  (let ($updatedSubtree $mmp) (addActionKnobs (mkTree (mkNode and_seq) ((pcTree))) True () (playcenter playcorner) ())
    (getKnobMultip (car-atom (MultiMap.values $mmp))))
  (mkMultip 3))

;; (e) Vocabulary-independence: the perms stored in the knob are EXACTLY the
;; caller-supplied action trees, proving the old hardcoded five-move alphabet is
;; gone -- an arbitrary vocabulary rides through untouched.
!(assertEqual
  (let* (
      (($updatedSubtree $mmp) (addActionKnobs (mkTree (mkNode and_seq) ((pwTree))) True () (playwin playfork playblock) ()))
      ((mkKnob (mkNullVex $perms) $ask $i) (getNodeById $updatedSubtree (mkNodeId (2))))
    )
    $perms)
  ((pwTree) (pfTree) (pbTree)))
