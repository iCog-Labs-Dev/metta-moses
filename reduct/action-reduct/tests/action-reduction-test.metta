;; ---------------------------------------------------------------------------
;; Integration Tests for Action Reduction Dispatcher
;; ---------------------------------------------------------------------------

!(import! &self ../../../utilities/general-helpers)
!(import! &self ../../../utilities/tree)
!(import! &self ../action-vocab)
!(import! &self ../action-helpers)
!(import! &self ../action-properties)
!(import! &self ../reduce-action-if)
!(import! &self ../reduce-action-action-if)
!(import! &self ../reduce-const-action-seq)
!(import! &self ../reduce-action-not)
!(import! &self ../reduce-action-while)
!(import! &self ../reduce-seq-result)
!(import! &self ../reduce-null-vertices)
!(import! &self ../reduce-action-properties)
!(import! &self ../action-reduction)

;; --- 1. applyActionRuleDownwards (downward rule pass) ---
!(assertEqual
  (applyActionRuleDownwards levelNode (and_seq A (and_seq B C) (or_seq D (or_seq E F)) (exec_seq G (exec_seq H I))))
  (and_seq A B C (or_seq D E F) (exec_seq G H I)))

;; --- 2. Integration: fixed-point reduction via actionReduce ---
!(assertEqual (actionReduce (and_seq action_success A action_failure B)) (and_seq A action_failure))
!(assertEqual (actionReduce (action_bool_if True (and_seq) X)) action_success)
!(assertEqual (applyDefaultRulesPass (and_seq action_success A action_failure B)) (and_seq A action_failure))
!(assertEqual
  (applyActionRuleDownwards reduceActionIf (and_seq (action_bool_if True A B) (action_bool_if False C D)))
  (and_seq A D))
!(assertEqual (preconditionsCheck (and_seq A B)) (and_seq A B))
!(assertEqual
  (actionReduce (or_seq action_failure move_forward B))
  (or_seq move_forward B))

;; --- 3. Public reducer does not apply standalone-only rules ---
!(assertEqual
  (actionReduce (action_bool_if (NOT (near stick tree)) A B))
  (action_bool_if (NOT (near stick tree)) A B))

!(assertEqual
  (actionReduce (action_action_if turn_left (goto_obj stick) move_forward))
  (action_action_if turn_left (goto_obj stick) move_forward))

;; --- 4. Integration: property-based reductions via actionReduce ---
!(assertEqual
  (actionReduce (exec_seq turn_left turn_right))
  action_success)

!(assertEqual
  (actionReduce (and_seq turn_left turn_right))
  (and_seq turn_left turn_right))

;; --- 5. Tree cleanup integration ---
!(assertEqual
  (preOrder (cleanActionTree (buildTree (exec_seq turn_left turn_right))))
  action_success)

!(assertEqual
  (preOrder (cleanActionTree (buildTree (and_seq))))
  action_success)

!(assertEqual
  (preOrder (cleanActionTree (buildTree (or_seq))))
  action_failure)

!(assertEqual
  (preOrder (cleanActionTree (buildTree (exec_seq))))
  action_success)
