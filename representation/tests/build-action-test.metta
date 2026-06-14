!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/ordered-multimap)
!(import! &self ../../utilities/lazy-random-selector)
!(import! &self ../../utilities/nodeId)
!(import! &self ../../utilities/tree)

!(import! &self ../../scoring/bscore)

!(import! &self ../../representation/knob-representation)
!(import! &self ../../representation/lsk)
!(import! &self ../../representation/logical-probe)
!(import! &self ../../representation/sample-logical-perms)
!(import! &self ../../representation/add-logical-knobs)
!(import! &self ../../representation/build-logical)
!(import! &self ../../representation/logical-canonize)
!(import! &self ../../representation/build-action)
!(import! &self ../../representation/build-knobs)
!(import! &self ../../representation/representation)

!(py-call (random.seed 12))

(= (moveTree) (mkTree (mkNode move_forward) ()))
(= (turnTree) (mkTree (mkNode turn_left) ()))
(= (actionPerms) ((moveTree) (turnTree)))

;; Structural action operators are classified separately from domain actions.
!(assertEqual (isActionOperator and_seq) True)
!(assertEqual (isActionOperator action_bool_if) True)
!(assertEqual (isActionOperator seq_exec) True)
!(assertEqual (isActionOperator move_forward) False)

!(assertEqual (isBuiltinAction move_forward (move_forward turn_left)) True)
!(assertEqual (isBuiltinAction ahead_blocked (move_forward turn_left)) False)
!(assertEqual (isBuiltinAction and_seq (move_forward turn_left)) False)
!(assertEqual (isBuiltinAction action_bool_if (move_forward turn_left)) False)

;; Action permutation sampling keeps the base action domain.
!(assertEqual
  (let $perms (sampleActionPerms (move_forward turn_left) (A B))
    (and (is-member move_forward $perms)
         (is-member turn_left $perms)))
  True)

!(assertEqual
  (sampleActionPerms (move_forward) (A B))
  (move_forward))

!(assertEqual
  (sampleActionPerms (move_forward turn_left) ())
  (move_forward turn_left))

;; Embedded ASK constructors retain their defaults.
!(assertEqual
  (let ($controlled $ask) (actionSubtreeKnob (actionPerms))
    ((getRawKnobMultip $ask) (getKnobDefault $ask)))
  ((mkMultip 3) (mkDiscSpec 0)))

!(assertEqual
  (let ($controlled $ask) (simpleActionSubtreeKnob (moveTree))
    ((getRawKnobMultip $ask) (getKnobDefault $ask)))
  ((mkMultip 2) (mkDiscSpec 1)))

;; Embedded ASK candidate reconstruction still maps 0 to absent, 1..N to perms.
!(assertEqual
  (getCandidateHelper
    (mkInst (0))
    (mkTree (mkNode and_seq)
      ((mkKnob (mkNullVex (actionPerms))
               (mkASK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) (actionPerms))
               0))))
  (mkTree (mkNode and_seq) ()))

!(assertEqual
  (getCandidateHelper
    (mkInst (1))
    (mkTree (mkNode and_seq)
      ((mkKnob (mkNullVex (actionPerms))
               (mkASK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) (actionPerms))
               0))))
  (mkTree (mkNode and_seq) ((moveTree))))

!(assertEqual
  (getCandidateHelper
    (mkInst (2))
    (mkTree (mkNode and_seq)
      ((mkKnob (mkNullVex (actionPerms))
               (mkASK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) (actionPerms))
               0))))
  (mkTree (mkNode and_seq) ((turnTree))))

;; Simple-action ASK preserves recursive candidate expansion into the subtree.
!(assertEqual
  (let* (($origTree (mkTree (mkNode and_seq) (cons (moveTree) ())))
         (($updatedTree $ask) (simpleActionSubtreeKnob $origTree (mkNodeId (1))))
         (($candidate $srcId $dstId) (appendToASK $updatedTree $ask (mkTree (mkNode and_seq) ()) (mkNodeId (0)) 1)))
    ($candidate $srcId $dstId))
  ((mkTree (mkNode and_seq) (cons (moveTree) ())) (mkNodeId (1)) (mkNodeId (1))))

!(assertEqual
  (let* (($origTree (mkTree (mkNode and_seq) (cons (moveTree) ())))
         (($updatedTree $ask) (simpleActionSubtreeKnob $origTree (mkNodeId (1))))
         (($candidate $srcId $dstId) (appendToASK $updatedTree $ask (mkTree (mkNode and_seq) ()) (mkNodeId (0)) 0)))
    ($candidate $srcId $dstId))
  ((mkTree (mkNode and_seq) ()) (mkNodeId (0)) (mkNodeId (0))))

;; Action-subtree ASK appends selected perms but stops recursive expansion.
!(assertEqual
  (let* (($origTree (mkTree (mkNode and_seq) ()))
         (($updatedTree $ask) (actionSubtreeKnob $origTree (mkNodeId (0)) ((moveTree))))
         (($candidate $srcId $dstId) (appendToASK $updatedTree $ask (mkTree (mkNode and_seq) ()) (mkNodeId (0)) 1)))
    ($candidate $srcId $dstId))
  ((mkTree (mkNode and_seq) (cons (moveTree) ())) (mkNodeId (0)) (mkNodeId (0))))

!(assertEqual
  (let* (($origTree (mkTree (mkNode and_seq) ()))
         (($updatedTree $ask) (actionSubtreeKnob $origTree (mkNodeId (0)) ((moveTree))))
         (($candidate $srcId $dstId) (appendToASK $updatedTree $ask (mkTree (mkNode and_seq) ()) (mkNodeId (0)) 0)))
    ($candidate $srcId $dstId))
  ((mkTree (mkNode and_seq) ()) (mkNodeId (0)) (mkNodeId (0))))

;; Direct probes produce action knobs with the expected ASK defaults.
!(assertEqual
  (let ($tree $mmp) (addActionKnobsAt (mkTree (mkNode and_seq) ()) (mkNodeId (0)) (mkNodeId (0)) True () (move_forward turn_left) (A B))
    (> (MultiMap.length $mmp) 0))
  True)

!(assertEqual
  (let* (($origTree (mkTree (mkNode and_seq) (cons (moveTree) ())))
         (($updatedTree $mmp) (addSimpleActionKnobsAt $origTree (mkNodeId (0)) (mkNodeId (1)) True () (move_forward turn_left) (A B)))
         ($ask (car-atom (MultiMap.values $mmp))))
    ($updatedTree (getKnobDefault $ask)))
  ((mkTree (mkNode and_seq) (cons (moveTree) ())) (mkDiscSpec 1)))

;; action_bool_if keeps its perception child and wraps action branches.
!(assertEqual
  (let* (($origTree (mkTree (mkNode action_bool_if)
                     (cons (mkTree (mkNode A) ())
                     (cons (moveTree)
                     (cons (turnTree) ())))))
         (($updatedTree $mmp) (buildAction $origTree (mkNodeId (0)) () (move_forward turn_left) (A B)))
         ($perception (getNodeById $updatedTree (mkNodeId (1))))
         ($branchA (getNodeById $updatedTree (mkNodeId (2))))
         ($branchB (getNodeById $updatedTree (mkNodeId (3)))))
    (and (== $perception (mkTree (mkNode A) ()))
         (and (== $branchA (mkTree (mkNode and_seq)
                              (cons (moveTree)
                              (cons (mkNullVex ()) ()))))
         (and (== $branchB (mkTree (mkNode and_seq)
                              (cons (turnTree)
                              (cons (mkNullVex ()) ()))))
              (== (MultiMap.length $mmp) 2)))))
  True)

;; and_seq follows the C++ probabilistic path and produces knobs with this seed.
!(assertEqual
  (let* (($origTree (mkTree (mkNode and_seq) (cons (moveTree) ())))
         (($updatedTree $mmp) (buildAction $origTree (mkNodeId (0)) () (move_forward turn_left) (A B))))
    (and (> (MultiMap.length $mmp) 0)
         (not (== $updatedTree $origTree))))
  True)

!(assertEqual
  (let ($updatedTree $mmp) (buildAction (mkTree (mkNode and_seq) ()) (mkNodeId (0)) () (move_forward turn_left) (A B))
    (> (MultiMap.length $mmp) 0))
  True)

;; buildKnobs dispatches action, logical, and strategy roots correctly.
!(assertEqual
  (let ($updatedTree $mmp) (buildKnobs (mkTree (mkNode and_seq) (cons (moveTree) ())) () () (move_forward turn_left) (A B))
    (> (MultiMap.length $mmp) 0))
  True)

!(assertEqual
  (let* (($tree (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) ())))
         (($updatedTree $mmp) (buildKnobs $tree () (A B) (move_forward turn_left) (A B))))
    (> (MultiMap.length $mmp) 0))
  True)

!(assertEqual
  (let* (($tree (mkTree (mkNode PRIORITIZED-OR)
                  (cons (mkTree (mkNode playcenter) ())
                  (cons (mkTree (mkNode playcorner) ())
                  (cons (mkTree (mkNode playblock) ()) ())))))
         (($updatedTree $mmp) (buildKnobs $tree () (playcenter playcorner playblock) () ())))
    (> (MultiMap.length $mmp) 0))
  True)

;; Canonize and cleanup mirror the C++ action pre/post passes.
!(assertEqual
  (actionCanonize (mkTree (mkNode and_seq) (cons (moveTree) ())))
  (mkTree (mkNode and_seq) (cons (moveTree) ())))

!(assertEqual
  (actionCanonize (moveTree))
  (mkTree (mkNode and_seq) (cons (moveTree) ())))

!(assertEqual
  (actionCleanup (mkTree (mkNode and_seq) ()))
  (mkNullVex ()))

!(assertEqual
  (actionCleanup (mkTree (mkNode or_seq) ()))
  (mkNullVex ()))

!(assertEqual
  (actionCleanup (mkTree (mkNode seq_exec) ()))
  (mkNullVex ()))

!(assertEqual
  (actionCleanup (mkTree (mkNode action_failure) ()))
  (mkTree (mkNode action_failure) ()))

!(assertEqual
  (actionCleanup (mkTree (mkNode and_seq) (cons (moveTree) ())))
  (mkTree (mkNode and_seq) (cons (moveTree) ())))
