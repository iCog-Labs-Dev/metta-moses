!(import! &self ../../../utilities/general-helpers)
!(import! &self ../action-vocab)
!(import! &self ../action-helpers)
!(import! &self ../reduce-action-if)

;; ============================================================================
;; reduceActionIf: constant-condition and identical-branch folding for
;; action_bool_if (Rule 1)
;; ============================================================================

;; condition statically True: take then-branch
!(assertEqual (reduceActionIf (action_bool_if True A B)) A)
;; condition statically False: take else-branch
!(assertEqual (reduceActionIf (action_bool_if False A B)) B)
;; both branches equal: condition is irrelevant
!(assertEqual (reduceActionIf (action_bool_if C A A)) A)

;; ============================================================================
;; reduceConstCondActionIf: fold X_action_if with constant action condition
;; (Rule 3)
;; ============================================================================

;; action_action_if with condition action_failure → else-branch
!(assertEqual (reduceConstCondActionIf (action_action_if action_failure A B)) B)
;; action_action_if with condition action_success → then-branch
!(assertEqual (reduceConstCondActionIf (action_action_if action_success A B)) A)

;; bool_action_if with condition action_failure → else-branch
!(assertEqual (reduceConstCondActionIf (bool_action_if action_failure A B)) B)
;; bool_action_if with condition action_success → then-branch
!(assertEqual (reduceConstCondActionIf (bool_action_if action_success A B)) A)

;; contin_action_if with condition action_failure → else-branch
!(assertEqual (reduceConstCondActionIf (contin_action_if action_failure A B)) B)
;; contin_action_if with condition action_success → then-branch
!(assertEqual (reduceConstCondActionIf (contin_action_if action_success A B)) A)

;; ============================================================================
;; reduceNotCondActionBoolIf: push NOT out of action_bool_if condition
;; (standalone mirror — not in default pipeline)
;; ============================================================================

!(assertEqual
  (reduceNotCondActionBoolIf (action_bool_if (NOT (near stick tree)) turn_right step_forward))
  (action_bool_if (near stick tree) step_forward turn_right))

;; ============================================================================
;; reduceActionBoolIfSubCond: propagate known condition into branches
;; (standalone mirror — not in default pipeline)
;; ============================================================================

!(assertEqual
  (reduceActionBoolIfSubCond (action_bool_if (near stick tree) (and_seq (action_bool_if (near stick tree) step_forward turn_left)) (and_seq (action_bool_if (near stick tree) sit (goto_obj stick)))))
  (action_bool_if (near stick tree) (and_seq (action_bool_if True step_forward turn_left)) (and_seq (action_bool_if False sit (goto_obj stick)))))
