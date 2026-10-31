;; ---------------------------------------------------------------------------
;; reduceDoubleActionNot (C++ reduce_double_action_not)
;; ---------------------------------------------------------------------------
;;
;; action_not is the action-result inverter: it flips action_success to
;; action_failure and vice versa. Two nested negations cancel each other:
;;
;;   action_not(action_not(A)) -> A
;;
;; This is the action analogue of double-negation elimination in boolean logic.
;; The rule fires only when the immediate child is itself an action_not node;
;; it does not recurse deeper to look for deeper cancellations (the iterative
;; outer loop handles multi-step convergence).

;; Match with (if (= $expr PATTERN) ...), not unify: unify evaluates the branch it returns, and
;; with scoring/action-ops loaded an evaluated action term runs as an action.
(= (reduceDoubleActionNot $expr)
   (if (= $expr (action_not (action_not $action))) $action $expr))
