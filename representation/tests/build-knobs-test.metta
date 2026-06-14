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
;; buildKnobs - PRIORITIZED-OR strategy path
;; =============================================================================

;; Simple strategy tree verifies buildKnobs dispatches PRIORITIZED-OR roots.
(= (gameTree1) (mkTree (mkNode PRIORITIZED-OR)
                  (cons (mkTree (mkNode playcenter) ())
                  (cons (mkTree (mkNode playcorner) ()) ()))))

;; Single-child strategy trees should still get strategy knobs.
!(assertEqual (let* (
    (($updatedTree $MMap) (buildKnobs
                            (mkTree (mkNode PRIORITIZED-OR)
                                   (cons (mkTree (mkNode playwin) ()) ()))
                            () (playwin playblock)))
    ($mmLength (MultiMap.length $MMap))
)
(== $mmLength 5)
) True)

;; Multi-child strategy trees should register the expected root knobs.
!(assertEqual (let* (
    (($updatedTree $MMap) (buildKnobs (gameTree1) () (playcenter playcorner)))
    ($mmLength (MultiMap.length $MMap))
)
(== $mmLength 5)
) True)

;; Strategy knob building should modify the original PRIORITIZED-OR tree.
!(assertEqual (let* (
    (($updatedTree $MMap) (buildKnobs
                            (mkTree (mkNode PRIORITIZED-OR)
                                   (cons (mkTree (mkNode playwin) ()) ()))
                            () (playwin playblock)))
    ($treeChanged (not (== $updatedTree (mkTree (mkNode PRIORITIZED-OR)
                                               (cons (mkTree (mkNode playwin) ()) ())))))
)
$treeChanged
) True)

;; Nested PRIORITIZED-OR trees protect recursive strategy handling.
(= (complexGameTree) (mkTree (mkNode PRIORITIZED-OR)
                            (cons (mkTree (mkNode playcenter) ())
                            (cons (mkTree (mkNode PRIORITIZED-OR)
                                         (cons (mkTree (mkNode playcorner) ())
                                         (cons (mkTree (mkNode playblock) ()) ())))
                            ()))))

;; Nested strategy trees should create knobs for more than the root alone.
!(assertEqual (let* (
    (($updatedTree $MMap) (buildKnobs (complexGameTree) () (playcenter playcorner playblock)))
    ($mmLength (MultiMap.length $MMap))
    ($hasNestedKnobs (>= $mmLength 10))
)
$hasNestedKnobs
) True)

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
