!(import! &self ../../../utilities/general-helpers)
!(import! &self ../action-vocab)
!(import! &self ../action-helpers)
!(import! &self ../reduce-action-while)

;; ============================================================================
;; reduceActionWhileAlwaysFails: body always fails → drop while wrapper
;; (Rule 13)
;; ============================================================================

!(assertEqual (reduceActionWhileAlwaysFails (action_while action_failure)) action_failure)

;; ============================================================================
;; reduceBoolWhileDependCond: constant boolean condition folding (Rule 14)
;; ============================================================================

!(assertEqual (reduceBoolWhileDependCond (bool_while True A)) A)
!(assertEqual (reduceBoolWhileDependCond (bool_while False A)) action_success)

;; ============================================================================
;; findRepeatingPeriod: helper to detect repeated patterns in tuple args
;; ============================================================================

!(assertEqual (findRepeatingPeriod (A B C A B C)) 3)
!(assertEqual (findRepeatingPeriod (A B C A B D)) 6)

;; ============================================================================
;; reduceRepeatInActionWhile: remove repetition inside action_while body
;; (Rule 8)
;; ============================================================================

!(assertEqual (reduceRepeatInActionWhile (action_while (and_seq A A))) (action_while A))
!(assertEqual (reduceRepeatInActionWhile (action_while (and_seq A B A B))) (action_while (and_seq A B)))
!(assertEqual (reduceRepeatInActionWhile (action_while (and_seq A B C A B C))) (action_while (and_seq A B C)))

;; ============================================================================
;; reduceRepeatOutActionWhile: remove prefix that duplicates while body
;; (Rule 7)
;; ============================================================================

!(assertEqual (reduceRepeatOutActionWhile (and_seq A B (action_while B))) (and_seq A (action_while B)))
!(assertEqual (reduceRepeatOutActionWhile (and_seq A B X Y (action_while (and_seq X Y)))) (and_seq A B (action_while (and_seq X Y))))

;; ============================================================================
;; reduceBoolWhileSubCond: propagate known condition into while body
;; (standalone mirror — not in default pipeline)
;; ============================================================================

!(assertEqual
  (reduceBoolWhileSubCond (bool_while (near stick tree) (and_seq (action_bool_if (near stick tree) step_forward turn_left))))
  (bool_while (near stick tree) (and_seq (action_bool_if True step_forward turn_left))))
