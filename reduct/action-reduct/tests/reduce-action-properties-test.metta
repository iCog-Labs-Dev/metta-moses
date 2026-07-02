!(import! &self ../../../utilities/general-helpers)
!(import! &self ../action-properties)
!(import! &self ../reduce-action-properties)

;; ============================================================================
;; reduceOpposite: cancel opposite action pairs inside exec_seq
;; ============================================================================

!(assertEqual
  (reduceOpposite (exec_seq turn_left turn_right move_forward))
  (exec_seq move_forward))

;; ============================================================================
;; reduceIdempotent: collapse repeated idempotent actions in sequences
;; ============================================================================

!(assertEqual
  (reduceIdempotent (exec_seq dummy_idempotent_action dummy_idempotent_action dummy_idempotent_action))
  (exec_seq dummy_idempotent_action))

;; ============================================================================
;; reduceAdditive: merge adjacent additive actions by summing arguments
;; ============================================================================

;; Same additive key → arguments are summed
!(assertEqual
  (reduceAdditive (and_seq (dummy_additive_action 2 same) (dummy_additive_action 3 same)))
  (and_seq (dummy_additive_action 5 same)))
;; Different additive key → no merge
!(assertEqual
  (reduceAdditive (and_seq (dummy_additive_action 2 left) (dummy_additive_action 3 right)))
  (and_seq (dummy_additive_action 2 left) (dummy_additive_action 3 right)))

;; ============================================================================
;; reduceZeroNeutral: zero-valued neutral argument → action_success
;; ============================================================================

!(assertEqual
  (reduceZeroNeutral (dummy_zero_neutral_action 0 target))
  action_success)

;; ============================================================================
;; reduceModularArgument: wrap modular arguments into canonical range
;; ============================================================================

!(assertEqual
  (let* (($r (reduceModularArgument (dummy_modular_action 4 40)))
         ($args (cdr-atom $r))
         ($a0 (car-atom $args))
         ($a1 (car-atom (cdr-atom $args))))
    (and (isApproxEq $a0 -2.28) (isApproxEq $a1 -20)))
  True)
