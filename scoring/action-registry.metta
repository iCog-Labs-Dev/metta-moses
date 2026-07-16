;; Action-domain registry: which operator symbols are structural combinators,
;; which are cleanup-relevant, and which actions/perceptions the CURRENTLY
;; loaded domain package contributes. Spaces (not clause lists) so domain
;; packages loaded at any later time can register themselves without editing
;; this file -- the pluggable analog of the hard-coded isActionOperator list
;; in representation/knob-representation.metta.
;;
;; SENTINEL BASE CLAUSES (the load-order enabler): PeTTa compiles a call site
;; as a real call only if at least ONE clause of the callee exists when the
;; caller loads; clauses added by LATER-loaded files are then dispatched
;; dynamically at runtime. So this file, loaded FIRST, pins one never-matching
;; base clause for actionOp and for every actionDomain* config predicate that
;; the generic evaluator / scoring layer calls. Without these, those call
;; sites would compile as inert DATA and no later-loaded operator or domain
;; clause could ever fire. (Probe-verified: late-loaded actionOp clauses
;; dispatch through an engine compiled against the sentinel alone.)

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

;; ---- Registration API (called by domain packages at load time) ----
(= (registerActionOperator $op)
   (add-atom &actionRegistry (structuralActionOp $op)))
(= (registerDomainAction $op)
   (add-atom &actionRegistry (domainAction $op)))
(= (registerDomainPerception $op)
   (add-atom &actionRegistry (domainPerception $op)))
(= (registerActionDomain $domain)
   (add-atom &actionDomains (actionDomain $domain)))

;; ---- Membership predicates ----
(= (isRegisteredActionOperator $op)
   (not (== (collapse (match &actionRegistry (structuralActionOp $op) $op)) ())))
(= (isRegisteredCleanupActionOp $op)
   (not (== (collapse (match &actionRegistry (cleanupActionOp $op) $op)) ())))
(= (isRegisteredDomainAction $op)
   (not (== (collapse (match &actionRegistry (domainAction $op) $op)) ())))
(= (isRegisteredDomainPerception $op)
   (not (== (collapse (match &actionRegistry (domainPerception $op) $op)) ())))
(= (isRegisteredActionDomain $domain)
   (not (== (collapse (match &actionDomains (actionDomain $domain) $domain)) ())))

;; ---- Listers ----
(= (registeredDomainActions)
   (collapse (match &actionRegistry (domainAction $a) $a)))
(= (registeredDomainPerceptions)
   (collapse (match &actionRegistry (domainPerception $p) $p)))

;; resetActionDomain: drop every domainAction/domainPerception registration
;; (a new domain package re-registers its own). Collapse the matches FIRST,
;; then remove -- never mutate the space while match is iterating it.
(= (resetActionDomain)
   (let* (($as (collapse (match &actionRegistry (domainAction $a) $a)))
          ($ps (collapse (match &actionRegistry (domainPerception $p) $p)))
          ($ra (map-atom $as $a (remove-atom &actionRegistry (domainAction $a))))
          ($rp (map-atom $ps $p (remove-atom &actionRegistry (domainPerception $p)))))
     ()))

;; ---- Sentinel base clauses (see header) ----
;; actionOp: one clause per operator, added by scoring/action-ops (structural)
;; and by domain packages (actions/perceptions). The sentinel op symbol is
;; never produced by any tree, so this clause never fires in practice.
(= (actionOp actionOpSentinel $children $world) (mkARes False $world))

;; Domain-config predicates the scoring layer calls before any domain package
;; loads (Stage 2 compiles its call sites against these):
(= (actionDomainRunEpisode actionDomainSentinel $exp $variant) -1.0)
(= (actionDomainOpponents actionDomainSentinel) ())
(= (actionDomainBestScore actionDomainSentinel $n) 0)
(= (actionDomainActions actionDomainSentinel) ())
(= (actionDomainPerceptions actionDomainSentinel) ())
