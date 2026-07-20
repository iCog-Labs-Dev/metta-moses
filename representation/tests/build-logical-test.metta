!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/ordered-multimap)
!(import! &self ../../utilities/lazy-random-selector)
!(import! &self ../../utilities/nodeId)
!(import! &self ../../utilities/tree)

!(import! &self ../../scoring/boolean-ops)
!(import! &self ../../scoring/bscore)
!(import! &self ../../scoring/action-registry)

!(import! &self ../logical-canonize)
!(import! &self ../knob-representation)
!(import! &self ../lsk)
!(import! &self ../logical-probe)
!(import! &self ../sample-logical-perms)
!(import! &self ../add-logical-knobs)
!(import! &self ../build-logical)
!(import! &self ../build-action)

(= (tree1) (mkTree (mkNode AND)
                  (
                    (mkTree (mkNode A) ())
                    (mkTree (mkNode B) ())
                    (mkTree (mkNode OR)
                      (
                        (mkTree (mkNode C) ()))))))

;; buildLogical should materially change the tree and produce many knobs
!(assertEqual (let ($updatedTree $MMap) (buildLogical (tree1) () (A B))
                     (and (== $updatedTree (mkTree (mkNode AND) ((mkTree (mkNode OR) ((mkTree (mkNode AND) ((mkTree (mkNode C) ()) (mkKnob (mkNullVex ((mkTree (mkNode A) ()))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 8) (mkKnob (mkNullVex ((mkTree (mkNode B) ()))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 9) (mkKnob (mkNullVex ((mkTree (mkNode OR) ((mkTree (mkNode NOT) ((mkTree (mkNode A) ()))) (mkTree (mkNode B) ()))))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 10) (mkKnob (mkNullVex ((mkTree (mkNode OR) ((mkTree (mkNode A) ()) (mkTree (mkNode B) ()))))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 11))) (mkKnob (mkNullVex ((mkTree (mkNode A) ()))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 4) (mkKnob (mkNullVex ((mkTree (mkNode B) ()))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 5) (mkKnob (mkNullVex ((mkTree (mkNode AND) ((mkTree (mkNode A) ()) (mkTree (mkNode B) ()))))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 6) (mkKnob (mkNullVex ((mkTree (mkNode AND) ((mkTree (mkNode NOT) ((mkTree (mkNode A) ()))) (mkTree (mkNode B) ()))))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 7) (mkTree (mkNode AND) ((mkKnob (mkNullVex ((mkTree (mkNode A) ()))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 12) (mkKnob (mkNullVex ((mkTree (mkNode B) ()))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 13) (mkKnob (mkNullVex ((mkTree (mkNode OR) ((mkTree (mkNode NOT) ((mkTree (mkNode A) ()))) (mkTree (mkNode B) ()))))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 14) (mkKnob (mkNullVex ((mkTree (mkNode OR) ((mkTree (mkNode A) ()) (mkTree (mkNode B) ()))))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 15))))) (mkKnob (mkTree (mkNode OR) ((mkTree (mkNode A) ()) (mkKnob (mkNullVex ((mkTree (mkNode B) ()))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 16) (mkKnob (mkNullVex ((mkTree (mkNode AND) ((mkTree (mkNode NOT) ((mkTree (mkNode A) ()))) (mkTree (mkNode B) ()))))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 17) (mkKnob (mkNullVex ((mkTree (mkNode AND) ((mkTree (mkNode A) ()) (mkTree (mkNode B) ()))))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 18))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ())) 0) (mkKnob (mkTree (mkNode OR) ((mkTree (mkNode B) ()) (mkKnob (mkNullVex ((mkTree (mkNode A) ()))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 19) (mkKnob (mkNullVex ((mkTree (mkNode AND) ((mkTree (mkNode NOT) ((mkTree (mkNode A) ()))) (mkTree (mkNode B) ()))))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 20) (mkKnob (mkNullVex ((mkTree (mkNode AND) ((mkTree (mkNode A) ()) (mkTree (mkNode B) ()))))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 21))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ())) 1) (mkKnob (mkNullVex ((mkTree (mkNode OR) ((mkTree (mkNode A) ()) (mkTree (mkNode B) ()))))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 2) (mkKnob (mkNullVex ((mkTree (mkNode OR) ((mkTree (mkNode NOT) ((mkTree (mkNode A) ()))) (mkTree (mkNode B) ()))))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 3) (mkTree (mkNode OR) ((mkKnob (mkNullVex ((mkTree (mkNode A) ()))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 22) (mkKnob (mkNullVex ((mkTree (mkNode B) ()))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 23) (mkKnob (mkNullVex ((mkTree (mkNode AND) ((mkTree (mkNode A) ()) (mkTree (mkNode B) ()))))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 24) (mkKnob (mkNullVex ((mkTree (mkNode AND) ((mkTree (mkNode NOT) ((mkTree (mkNode A) ()))) (mkTree (mkNode B) ()))))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 25))))))
(MultiMap.equals $MMap (((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())))))))
True)

;; =============================================================================
;; Action-domain buildAction cases (replace the retired game-strategy cases).
;; The ttt play* symbols ride as an ordinary action vocabulary argument and
;; perceptions are () everywhere, which makes the permutation sampler
;; deterministic (it returns the vocabulary verbatim). canwin is an inert
;; perception symbol.
;; =============================================================================
!(py-call (random.seed 12))

(= (pwTree) (mkTree (mkNode playwin) ()))
(= (pbTree) (mkTree (mkNode playblock) ()))
(= (pcTree) (mkTree (mkNode playcenter) ()))
(= (pcrTree) (mkTree (mkNode playcorner) ()))
(= (psTree) (mkTree (mkNode playside) ()))
(= (cwTree) (mkTree (mkNode canwin) ()))
(= (tttActs) (playwin playblock playcenter playcorner playside))
(= (tttMoveTrees) ((pwTree) (pbTree) (pcTree) (pcrTree) (psTree)))

;; (a) A single-action and_seq still registers at least one knob (branch-robust:
;; the C++ p=80 policy is probabilistic but every branch adds a knob).
!(assertEqual
  (let ($updatedTree $mmp) (buildAction (mkTree (mkNode and_seq) ((pwTree))) () (tttActs) ())
    (> (MultiMap.length $mmp) 0))
  True)

;; (b) An EMPTY and_seq always gets the all-vocabulary knob as its first child:
;; node (1) is the full-vocabulary ASK knob (multip |vocab|+1 = 6, idx 0). This
;; holds on every random branch since an empty and_seq forces knob insertion.
!(assertEqual
  (let ($updatedTree $mmp) (buildAction (mkTree (mkNode and_seq) ()) () (tttActs) ())
    (getNodeById $updatedTree (mkNodeId (1))))
  (mkKnob (mkNullVex (tttMoveTrees))
          (mkASK (mkDiscKnob (mkMultip 6) (mkDiscSpec 0) (mkDiscSpec 0) ()) (tttMoveTrees))
          0))

;; (c) A two-action and_seq is materially rewritten and registers knobs.
!(assertEqual
  (let* (
      (($updatedTree $mmp) (buildAction (mkTree (mkNode and_seq) ((pcTree) (pcrTree))) () (tttActs) ()))
    )
    (and (not (== $updatedTree (mkTree (mkNode and_seq) ((pcTree) (pcrTree)))))
         (> (MultiMap.length $mmp) 0)))
  True)

;; (d) A two-action vocabulary gives the first registered knob multip |vocab|+1 = 3.
!(assertEqual
  (let ($updatedTree $mmp) (buildAction (mkTree (mkNode and_seq) ()) () (playwin playblock) ())
    (getRawKnobMultip (car-atom (MultiMap.values $mmp))))
  (mkMultip 3))

;; (e) An action_bool_if is rewritten deterministically: the perception child is
;; preserved and each action branch is wrapped in an and_seq carrying a
;; full-vocabulary knob (idx 0 and 1). MMap length is exactly 2.
!(assertEqual
  (let ($updatedTree $mmp)
       (buildAction (mkTree (mkNode action_bool_if) ((cwTree) (pcTree) (pbTree))) () (tttActs) ())
    ((getNodeById $updatedTree (mkNodeId (1)))
     (getNodeById $updatedTree (mkNodeId (2 1)))
     (getNodeById $updatedTree (mkNodeId (2 2)))
     (getNodeById $updatedTree (mkNodeId (3 1)))
     (getNodeById $updatedTree (mkNodeId (3 2)))
     (MultiMap.length $mmp)))
  ((cwTree)
   (pcTree)
   (mkKnob (mkNullVex (tttMoveTrees))
           (mkASK (mkDiscKnob (mkMultip 6) (mkDiscSpec 0) (mkDiscSpec 0) ()) (tttMoveTrees)) 0)
   (pbTree)
   (mkKnob (mkNullVex (tttMoveTrees))
           (mkASK (mkDiscKnob (mkMultip 6) (mkDiscSpec 0) (mkDiscSpec 0) ()) (tttMoveTrees)) 1)
   2))
