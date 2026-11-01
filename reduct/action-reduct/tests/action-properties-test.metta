!(import! &self ../../../utilities/general-helpers)
!(import! &self ../action-properties)

;; ============================================================================
;; isIdempotent: only dummy_idempotent_action is idempotent by default
;; ============================================================================
!(assertEqual (isIdempotent dummy_idempotent_action) True)
!(assertEqual (isIdempotent move_forward) False)
!(assertEqual (isIdempotent turn_left) False)

;; ============================================================================
;; isReversible / getReversal: turn_left and turn_right are a reversible pair
;; ============================================================================
!(assertEqual (isReversible turn_left) True)
!(assertEqual (isReversible turn_right) True)
!(assertEqual (isReversible move_forward) False)

!(assertEqual (getReversal turn_left) turn_right)
!(assertEqual (getReversal turn_right) turn_left)
!(assertEqual (getReversal move_forward) move_forward)

;; ============================================================================
;; isAdditive: only dummy_additive_action at index 0 is additive
;; ============================================================================
!(assertEqual (isAdditive dummy_additive_action 0) True)
!(assertEqual (isAdditive dummy_additive_action 1) False)
!(assertEqual (isAdditive move_forward 0) False)

;; ============================================================================
;; isZeroNeutral: only dummy_zero_neutral_action at index 0
;; ============================================================================
!(assertEqual (isZeroNeutral dummy_zero_neutral_action 0) True)
!(assertEqual (isZeroNeutral dummy_zero_neutral_action 1) False)
!(assertEqual (isZeroNeutral move_forward 0) False)

;; ============================================================================
;; isModulo / moduloMin / moduloMax: only dummy_modular_action at indices 0, 1
;; ============================================================================
!(assertEqual (isModulo dummy_modular_action 0) True)
!(assertEqual (isModulo dummy_modular_action 1) True)
!(assertEqual (isModulo dummy_modular_action 2) False)
!(assertEqual (isModulo move_forward 0) False)

!(assertEqual (isApproxEq (moduloMin dummy_modular_action 0) -3.14) True)
!(assertEqual (isApproxEq (moduloMax dummy_modular_action 0) 3.14) True)
!(assertEqual (isApproxEq (moduloMin dummy_modular_action 1) -30) True)
!(assertEqual (isApproxEq (moduloMax dummy_modular_action 1) 30) True)
!(assertEqual (moduloMin move_forward 0) 0)
!(assertEqual (moduloMax move_forward 0) 0)
