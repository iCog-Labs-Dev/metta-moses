;; Action-operator registry. Holds exactly two things:
;;   (a) structural operator membership (structuralActionOp atoms) -- the
;;       pluggable analog of the hard-coded isActionOperator list in
;;       representation/knob-representation.metta;
;;   (b) cleanup-relevant operator membership (cleanupActionOp atoms) --
;;       the flattenable / identity-reducible sequence combinators.
;; That is ALL the framework registers about actions. Everything an
;; EXPERIMENT contributes -- its fitness function, best-score function, and
;; action/perception vocabularies -- binds through the global params
;; (actionFitness / actionBestScore / actionActions / actionPerceptions;
;; see parameters/defaults.metta and scoring/action-score.metta). There is
;; no domain-name registration and no per-domain config-clause family.
;;
;; A space (not clause lists) so operator packages loaded at any later time
;; can register additional structural operators without editing this file.
;; Operator dispatch needs NO sentinel clauses: the evaluator
;; reduce-dispatches bare operator heads on a cons-built term, the boolean
;; engine's mechanism -- see scoring/action-eval.

!(bind! &actionRegistry (new-space))

;; ---- Structural action operators (mirrors the legacy list at
;;      representation/knob-representation.metta:39-43) ----
!(add-atom &actionRegistry (structuralActionOp and_seq))
!(add-atom &actionRegistry (structuralActionOp or_seq))
!(add-atom &actionRegistry (structuralActionOp seq_exec))
!(add-atom &actionRegistry (structuralActionOp action_not))
!(add-atom &actionRegistry (structuralActionOp action_bool_if))
!(add-atom &actionRegistry (structuralActionOp bool_action_if))
!(add-atom &actionRegistry (structuralActionOp contin_action_if))
!(add-atom &actionRegistry (structuralActionOp action_action_if))
!(add-atom &actionRegistry (structuralActionOp action_success))
!(add-atom &actionRegistry (structuralActionOp action_failure))
!(add-atom &actionRegistry (structuralActionOp action_while))
!(add-atom &actionRegistry (structuralActionOp bool_while))
!(add-atom &actionRegistry (structuralActionOp return_success))
!(add-atom &actionRegistry (structuralActionOp repeat_n))

;; Cleanup-relevant sequence combinators (flattenable / identity-reducible).
!(add-atom &actionRegistry (cleanupActionOp and_seq))
!(add-atom &actionRegistry (cleanupActionOp or_seq))
!(add-atom &actionRegistry (cleanupActionOp seq_exec))

;; ---- Membership predicates ----
;; (Defined BEFORE the registration API: its idempotency guard calls these,
;; and PeTTa compiles a call site as a real call only if the callee already
;; has a clause.)
(= (isRegisteredActionOperator $op)
   (not (== (collapse (match &actionRegistry (structuralActionOp $op) $op)) ())))
(= (isRegisteredCleanupActionOp $op)
   (not (== (collapse (match &actionRegistry (cleanupActionOp $op) $op)) ())))

;; ---- Registration API (called by operator packages at load time) ----
;; IDEMPOTENT: import! does not dedupe, so a package loaded twice would
;; double every registration -- the register skips the add-atom when the
;; entry is already present.
(= (registerActionOperator $op)
   (if (isRegisteredActionOperator $op)
       ()
       (add-atom &actionRegistry (structuralActionOp $op))))
