!(import! &self ../../../utilities/general-helpers)
!(import! &self ../action-vocab)
!(import! &self ../action-helpers)
!(import! &self ../reduce-action-not)

;; ============================================================================
;; reduceDoubleActionNot: double negation elimination (Rule 6)
;; ============================================================================

!(assertEqual (reduceDoubleActionNot (action_not (action_not A))) A)
