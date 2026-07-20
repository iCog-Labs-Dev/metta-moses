!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/ordered-multimap)
!(import! &self ../../utilities/lazy-random-selector)
!(import! &self ../../utilities/nodeId)
!(import! &self ../../utilities/tree)

!(import! &self ../../scoring/boolean-ops)
!(import! &self ../../scoring/bscore)

!(import! &self ../../scoring/action-registry)
!(import! &self ../../representation/knob-representation)
!(import! &self ../../representation/lsk)
!(import! &self ../../representation/logical-probe)
!(import! &self ../../representation/logical-canonize)
!(import! &self ../../representation/sample-logical-perms)
!(import! &self ../../representation/add-logical-knobs)
!(import! &self ../../representation/build-logical)
!(import! &self ../../representation/build-action)
!(import! &self ../../representation/build-knobs)

!(py-call (random.seed 0))

;; =============================================================================
;; buildKnobs (3-arity / 4-arity) - logical path
;; =============================================================================

;; Minimal boolean exemplar used to verify logical knob decoration.
(= (tree1) (mkTree (mkNode OR)
                        (cons (mkTree (mkNode C) ()) ())))

;; 3-arity entry point should canonize/decorate a logical tree and register knobs.
!(assertEqual (let* (
    (($updatedTree $MMap) (buildKnobs (tree1) () (A B)))
    ($treeChanged (not (== $updatedTree (tree1))))
    ($hasKnobs (> (MultiMap.length $MMap) 0))
)
(and $treeChanged $hasKnobs)
) True)

;; 4-arity entry point should keep the same logical behavior with explicit disc-probe control.
!(assertEqual (let* (
    (($updatedTree $MMap) (buildKnobs (tree1) () (A B) True))
    ($treeChanged (not (== $updatedTree (tree1))))
    ($hasKnobs (> (MultiMap.length $MMap) 0))
)
(and $treeChanged $hasKnobs)
) True)


;; =============================================================================
;; buildKnobs (5-arity) - action-domain dispatch (replaces retired strategy path)
;; =============================================================================
;; The ttt play* symbols ride as an ordinary action vocabulary argument;
;; perceptions are () (deterministic sampling). canwin is an inert perception.
(= (pwTree) (mkTree (mkNode playwin) ()))
(= (pbTree) (mkTree (mkNode playblock) ()))
(= (pcTree) (mkTree (mkNode playcenter) ()))
(= (pcrTree) (mkTree (mkNode playcorner) ()))
(= (cwTree) (mkTree (mkNode canwin) ()))
(= (tttActs) (playwin playblock playcenter playcorner playside))

;; (a) A non-and_seq structural root (or_seq) is canonized: the root becomes
;; and_seq and the original or_seq subtree is preserved as child (1). Only the
;; structure is pinned -- or_seq children are not recursed and the root-knob
;; insertion is probabilistic, so the knob count is left unpinned.
!(assertEqual
  (let ($updatedTree $mmp) (buildKnobs (mkTree (mkNode or_seq) ((pwTree))) () () (tttActs) ())
    ((getNodeValue (getNodeById $updatedTree (mkNodeId (0))))
     (getNodeById $updatedTree (mkNodeId (1)))))
  ((mkNode and_seq) (mkTree (mkNode or_seq) ((pwTree)))))

;; (b) Multi-child twin: the original or_seq subtree is still child (1).
!(assertEqual
  (let ($updatedTree $mmp) (buildKnobs (mkTree (mkNode or_seq) ((pcTree) (pcrTree))) () () (tttActs) ())
    (getNodeById $updatedTree (mkNodeId (1))))
  (mkTree (mkNode or_seq) ((pcTree) (pcrTree))))

;; (c) A bare domain-action root is canonized to and_seq and registers knobs
;; (branch-robust: every branch adds at least one knob).
!(assertEqual
  (let ($updatedTree $mmp) (buildKnobs (pwTree) () () (tttActs) ())
    (and (== (getNodeValue (getNodeById $updatedTree (mkNodeId (0)))) (mkNode and_seq))
         (> (MultiMap.length $mmp) 0)))
  True)

;; (d) A nested and_seq containing an action_bool_if registers several knobs.
;; The floor >= 3 is branch-robust: the action_bool_if alone contributes two
;; branch knobs and the outer and_seq contributes at least one more.
!(assertEqual
  (let ($updatedTree $mmp)
       (buildKnobs (mkTree (mkNode and_seq) ((pcTree) (mkTree (mkNode action_bool_if) ((cwTree) (pwTree) (pbTree))))) () () (tttActs) ())
    (>= (MultiMap.length $mmp) 3))
  True)


;; =============================================================================
;; buildKnobs (5-arity) - action path
;; =============================================================================

;; Single action in an action sequence exercises the basic action branch.
(= (simpleActionTree) (mkTree (mkNode and_seq)
                        (cons (mkTree (mkNode move_forward) ()) ())))

;; 5-arity entry point should dispatch action operators to buildAction.
!(assertEqual (let* (
    (($updatedTree $MMap) (buildKnobs (simpleActionTree) () () (move_forward turn_left) (A B)))
    ($hasKnobs (> (MultiMap.length $MMap) 0))
)
$hasKnobs
) True)

;; Conditional action tree checks action_bool_if branch traversal.
(= (actionIfTree) (mkTree (mkNode action_bool_if)
                    (cons (mkTree (mkNode ahead_blocked) ())
                    (cons (mkTree (mkNode move_forward) ())
                    (cons (mkTree (mkNode turn_left) ()) ())))))

;; action_bool_if should still create action-selection knobs.
!(assertEqual (let* (
    (($updatedTree $MMap) (buildKnobs (actionIfTree) () () (move_forward turn_left) (ahead_blocked A B)))
    ($hasKnobs (> (MultiMap.length $MMap) 0))
)
$hasKnobs
) True)

;; Degenerate one-action domains should still get simple action knobs.
!(assertEqual (let* (
    (($updatedTree $MMap) (buildKnobs (simpleActionTree) () () (move_forward) (ahead_blocked A B)))
    ($hasKnobs (> (MultiMap.length $MMap) 0))
)
$hasKnobs
) True)

;; Custom action/perception symbols model caller-provided discrete domains.
(= (actions) (grab release walk))
(= (perceptions) (door-open has-item))

;; Multiple custom leaves verify that non-built-in action symbols are recognized.
(= (customLeafActionTree) (mkTree (mkNode and_seq)
                             (cons (mkTree (mkNode grab) ())
                             (cons (mkTree (mkNode walk) ()) ()))))

;; Mixed custom tree combines plain action leaves with a conditional action.
(= (myActionTree) (mkTree (mkNode and_seq)
                     (cons (mkTree (mkNode grab) ())
                     (cons (mkTree (mkNode walk) ())
                     (cons (mkTree (mkNode action_bool_if)
                           (cons (mkTree (mkNode door-open) ())
                           (cons (mkTree (mkNode release) ())
                           (cons (mkTree (mkNode grab) ()) ())))) ())))))

;; Multiple custom action leaves should register at least one action knob.
!(assertEqual (let* (
    (($updatedTree $MMap) (buildKnobs (customLeafActionTree) () () (actions) (perceptions)))
    ($hasKnobs (> (MultiMap.length $MMap) 0))
)
$hasKnobs
) True)

;; ASK permutations should preserve the original subtree, not only its operator.
!(assertEqual (let* (
    (($controlledSubtree $ask) (simpleActionSubtreeKnob (mkTree (mkNode walk) ())))
    ((mkASK $discKnob $perms) $ask)
)
(and (== $controlledSubtree (mkTree (mkNode walk) ()))
     (== $perms (cons (mkTree (mkNode walk) ()) ())))
) True)

;; Custom action trees with conditionals should go through the full action path.
!(assertEqual (let* (
    (($updatedTree $MMap) (buildKnobs (myActionTree) () () (actions) (perceptions)))
    ($hasKnobs (> (MultiMap.length $MMap) 0))
)
$hasKnobs
) True)
