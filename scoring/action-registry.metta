;; Action-domain registry. Holds exactly three things:
;;   (a) structural/cleanup operator membership (structuralActionOp /
;;       cleanupActionOp atoms) -- the pluggable analog of the hard-coded
;;       isActionOperator list in representation/knob-representation.metta;
;;   (b) domain-NAME registration (&actionDomains) for CLI routing
;;       (registerActionDomain / isRegisteredActionDomain);
;;   (c) the actionDomain* config sentinels (bottom of file).
;; Per-domain action/perception VOCABULARIES do NOT live here: they live
;; ONLY in the domain's config clauses -- (= (actionDomainActions <domain>)
;; (quote (...))) and the matching actionDomainPerceptions clause -- read
;; through configListSafe (scoring/action-score.metta). Spaces (not clause
;; lists) so domain packages loaded at any later time can register
;; themselves without editing this file.
;;
;; SENTINEL BASE CLAUSES (the load-order enabler): PeTTa compiles a call site
;; as a real call only if at least ONE clause of the callee exists when the
;; caller loads; clauses added by LATER-loaded files are then dispatched
;; dynamically at runtime. So this file, loaded FIRST, pins one never-matching
;; base clause for every actionDomain* config predicate that the scoring
;; layer calls. Without these, those call sites would compile as inert DATA
;; and no later-loaded domain clause could ever fire. (Operator dispatch
;; needs NO sentinel: the evaluator reduce-dispatches bare operator heads on
;; a cons-built term, the boolean engine's mechanism -- see
;; scoring/action-eval.)

!(bind! &actionRegistry (new-space))
!(bind! &actionDomains (new-space))

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
;; (Defined BEFORE the registration API: its idempotency guards call these,
;; and PeTTa compiles a call site as a real call only if the callee already
;; has a clause.)
(= (isRegisteredActionOperator $op)
   (not (== (collapse (match &actionRegistry (structuralActionOp $op) $op)) ())))
(= (isRegisteredCleanupActionOp $op)
   (not (== (collapse (match &actionRegistry (cleanupActionOp $op) $op)) ())))
(= (isRegisteredActionDomain $domain)
   (not (== (collapse (match &actionDomains (actionDomain $domain) $domain)) ())))

;; ---- Registration API (called by domain packages at load time) ----
;; IDEMPOTENT: import! does not dedupe, so a domain package loaded twice
;; would double every registration -- each register skips the add-atom when
;; the entry is already present.
(= (registerActionOperator $op)
   (if (isRegisteredActionOperator $op)
       ()
       (add-atom &actionRegistry (structuralActionOp $op))))
(= (registerActionDomain $domain)
   (if (isRegisteredActionDomain $domain)
       ()
       (add-atom &actionDomains (actionDomain $domain))))

;; ---- Sentinel base clauses (see header) ----
;; Domain-config predicates the scoring layer calls before any domain package
;; loads (Stage 2 compiles its call sites against these):
(= (actionDomainRunEpisode actionDomainSentinel $exp $variant) -1.0)
(= (actionDomainOpponents actionDomainSentinel) ())
(= (actionDomainBestScore actionDomainSentinel $n) 0)
(= (actionDomainActions actionDomainSentinel) ())
(= (actionDomainPerceptions actionDomainSentinel) ())
