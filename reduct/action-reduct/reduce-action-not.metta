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

(= (reduceDoubleActionNot $expr)
   (unify $expr (action_not (action_not $action)) $action $expr))
