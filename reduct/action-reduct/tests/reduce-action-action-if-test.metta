!(import! &self ../../../utilities/general-helpers)
!(import! &self ../action-vocab)
!(import! &self ../action-helpers)
!(import! &self ../reduce-action-action-if)

;; ============================================================================
;; reduceActionActionIfSameBranch: identical branches → condition + common body
;; ============================================================================

!(assertEqual
  (reduceActionActionIfSameBranch (action_action_if (goto_obj stick) turn_left turn_left))
  (and_seq (exec_seq (goto_obj stick)) turn_left))

;; ============================================================================
;; reduceActionActionIf: static-result-based folding of action_action_if
;; ============================================================================

!(assertEqual
  (reduceActionActionIf (action_action_if turn_left (goto_obj stick) move_forward))
  (and_seq turn_left (goto_obj stick)))
