;; ---------------------------------------------------------------------------
;; Domain property declarations and default fallbacks
;; ---------------------------------------------------------------------------

;; Note: The default ant-problem actions lack idempotent, additive, zero-neutral,
;; or modular properties. Dummy actions (dummy_*) are mapped here specifically
;; to serve as mock elements for unit-testing these properties' reduction rules.

;; The core action reduction rules (like reduceIdempotent, reduceAdditive, and
;; reduceModularArgument) are written to be domain-independent. They form a
;; general action reduction engine. By defining the interface hooks here in
;; action-properties.metta, we separate the generic reduction engine from the
;; specific vocabulary. Later, if one wants to use this engine for a different
;; problem, e.g., a robotic arm domain with a rotate(angle) action or a
;; grid-world turtle domain with a step_forward(distance) action, one can
;; easily add those properties here without modifying any code inside the
;; core reduction rules.

;; Checks if an action is idempotent. Real-world example: actions like
;; "stop" or "grab_food" (repeating them consecutively has no extra effect).
(= (isIdempotent $action)
   (== $action dummy_idempotent_action))

;; Checks if an action is reversible. Ant problem example: "turn_left"
;; and "turn_right" are opposite actions that undo each other.
(= (isReversible $action)
   (is-member $action (turn_left turn_right)))

;; Returns the reversing action. Ant problem example: the reversal of
;; "turn_left" is "turn_right", and vice-versa.
(= (getReversal $action)
   (case $action
     ((turn_left turn_right)
      (turn_right turn_left)
      ($else $action))))

;; Checks if sequential actions can sum their argument. Real-world example:
;; two sequential moves "step(1)" and "step(2)" can sum to "step(3)".
(= (isAdditive $action $index)
   (is-member ($action $index)
              ((dummy_additive_action 0))))

;; Checks if an argument of 0 makes the action a no-op. Real-world
;; example: "step(0)" immediately succeeds without moving the agent.
(= (isZeroNeutral $action $index)
   (is-member ($action $index)
              ((dummy_zero_neutral_action 0))))

;; Checks if an argument is periodic/modular. Real-world example:
;; rotation angles that wrap around every 360 degrees or 2pi radians.
(= (isModulo $action $index)
   (is-member ($action $index)
              ((dummy_modular_action 0)
               (dummy_modular_action 1))))

;; Returns the lower bound of a periodic argument (e.g. -3.14 for radians
;; or -180 for degrees).
(= (moduloMin $action $index)
   (case ($action $index)
     (((dummy_modular_action 0) -3.14)
      ((dummy_modular_action 1) -30)
      ($else 0))))

;; Returns the upper bound of a periodic argument (e.g. 3.14 for radians
;; or 180 for degrees).
(= (moduloMax $action $index)
   (case ($action $index)
     (((dummy_modular_action 0) 3.14)
      ((dummy_modular_action 1) 30)
      ($else 0))))
