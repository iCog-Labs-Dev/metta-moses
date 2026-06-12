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

!(assertEqual (isActionOperator and_seq) True)
!(assertEqual (isActionOperator action_bool_if) True)
!(assertEqual (isActionOperator seq_exec) True)
!(assertEqual (isActionOperator move_forward) False)

!(assertEqual (isBuiltinAction move_forward) True)
!(assertEqual (isBuiltinAction and_seq) False)
!(assertEqual (isBuiltinAction move_forward (move_forward turn_left)) True)
!(assertEqual (isBuiltinAction ahead_blocked (move_forward turn_left)) False)

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

!(assertEqual
  (let ($controlled $ask) (actionSubtreeKnob (actionPerms))
    ((getRawKnobMultip $ask) (getKnobDefault $ask)))
  ((mkMultip 3) (mkDiscSpec 0)))

!(assertEqual
  (let ($controlled $ask) (simpleActionSubtreeKnob (moveTree))
    ((getRawKnobMultip $ask) (getKnobDefault $ask)))
  ((mkMultip 2) (mkDiscSpec 1)))

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

!(assertEqual
  (let* (
    ($origTree (mkTree (mkNode and_seq) ((moveTree))))
    (($updatedTree $mmp) (buildAction $origTree (mkNodeId (0)) () (move_forward turn_left) (A B)))
  )
    (and (> (MultiMap.length $mmp) 0)
         (not (== $updatedTree $origTree))))
  True)

!(assertEqual
  (let* (
    ($origTree (mkTree (mkNode action_bool_if) ((mkTree (mkNode A) ()) (moveTree) (turnTree))))
    (($updatedTree $mmp) (buildAction $origTree (mkNodeId (0)) () (move_forward turn_left) (A B)))
  )
    (>= (MultiMap.length $mmp) 0))
  True)

!(assertEqual
  (let ($updatedTree $mmp) (buildAction (mkTree (mkNode and_seq) ()) (mkNodeId (0)) () (move_forward turn_left) (A B))
    (> (MultiMap.length $mmp) 0))
  True)

!(assertEqual
  (let ($updatedTree $mmp) (buildKnobs (mkTree (mkNode and_seq) ((moveTree))) () () (move_forward turn_left) (A B))
    (> (MultiMap.length $mmp) 0))
  True)

!(assertEqual
  (let* (
    ($reps (representation
             3
             (mkTree (mkNode and_seq) ((moveTree)))
             (mkITable ((true true) (false false)) (A Output))
             hc
             False
             ()
             mi
             (move_forward turn_left)
             (A)))
    ((mkRep (mkKbMap (mkDscMp $mmp)) $tree) (car-atom $reps))
  )
    (and (== (length $reps) 1)
         (and (> (MultiMap.length $mmp) 0)
         (not (== $tree (mkTree (mkNode and_seq) ((moveTree)))))))
  )
  True)

!(assertEqual
  (let* (
    ($tree (mkTree (mkNode OR) ((mkTree (mkNode A) ()))))
    (($updatedTree $mmp) (buildKnobs $tree () (A B) (move_forward turn_left) (A B)))
  )
    (> (MultiMap.length $mmp) 0))
  True)

!(assertEqual
  (let* (
    ($tree (mkTree (mkNode PRIORITIZED-OR) ((mkTree (mkNode playcenter) ()) (mkTree (mkNode playcorner) ()) (mkTree (mkNode playblock) ()))))
    (($updatedTree $mmp) (buildKnobs $tree () (playcenter playcorner playblock) () ()))
  )
    (> (MultiMap.length $mmp) 0))
  True)

!(assertEqual
  (actionCanonize (mkTree (mkNode and_seq) ((moveTree))))
  (mkTree (mkNode and_seq) ((moveTree))))

!(assertEqual
  (actionCanonize (moveTree))
  (mkTree (mkNode and_seq) ((moveTree))))

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
  (actionCleanup (mkTree (mkNode and_seq) ((moveTree))))
  (mkTree (mkNode and_seq) ((moveTree))))
