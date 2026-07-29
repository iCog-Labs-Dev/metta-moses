;; ---------------------------------------------------------------------------
;; Action Operator Vocabulary and Constants
;; ---------------------------------------------------------------------------

;; Constants
;; action_success - Terminal successful action
;; action_failure - Terminal failed action

;; Operators:
;; and_seq         - Sequential execution: execute all, stop/fail at first failure
;; or_seq          - Sequential execution: execute until first success
;; exec_seq        - Sequential execution: execute all, ignore results
;; action_not      - Negation of action result
;; action_bool_if  - Conditional branch with boolean condition
;; bool_action_if  - Conditional branch (boolean output) with action condition
;; contin_action_if - Conditional branch (continuous output) with action condition
;; action_action_if - Conditional branch (action output) with action condition
;; action_while    - Loop while action succeeds
;; bool_while      - Loop while boolean condition is true

;; ---------------------------------------------------------------------------
;; Domain Environment Actions property facts
;; ---------------------------------------------------------------------------

;; alwaysSucceeds: static action_result oracle used by reducers.
;;
;; This must be conservative for the generic MeTTa port. The C++ ant vocabulary
;; marks move_forward/turn_left/turn_right as always_succeeds because the
;; example-ant world permits those actions and reports action_success for them.
;; In other domains, especially pet-brain grid worlds with blocked movement,
;; move_forward/step_forward may fail or be impossible. Keep such movement
;; actions Unknown unless a domain-specific vocabulary imports stronger facts.

(= (alwaysSucceeds $action)
   (is-member $action (turn_left turn_right)))

;; referenceAntAlwaysSucceeds records the original C++ ant-vocabulary facts for
;; reference/parity fixtures. Generic reducers intentionally do not call it.
(= (referenceAntAlwaysSucceeds $action)
   (is-member $action (move_forward turn_left turn_right)))
