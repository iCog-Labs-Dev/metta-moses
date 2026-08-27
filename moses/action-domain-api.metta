;; ============================================================================
;; ActionDomain API
;; ============================================================================

;; Action-specific configuration kept inside the domain.
(= (mkActionSpace $actions $perceptions $fitness $bestScore)
   (ActionSpace $actions $perceptions $fitness $bestScore))

(= (actionSpaceActions (ActionSpace $actions $perceptions $fitness $bestScore)) 
   $actions)

(= (actionSpacePerceptions (ActionSpace $actions $perceptions $fitness $bestScore)) 
   $perceptions)

(= (actionSpaceFitness (ActionSpace $actions $perceptions $fitness $bestScore)) 
   $fitness)

(= (actionSpaceBestScore (ActionSpace $actions $perceptions $fitness $bestScore)) 
   $bestScore)



;; An ActionDomain contains its action space and optional initial exemplars.
(= (mkActionDomain $space $initialExemplars)
    (ActionDomain $space $initialExemplars))

(= (actionDomainSpace (ActionDomain $space $initialExemplars)) 
   $space)

(= (actionDomainInitialExemplars (ActionDomain $space $initialExemplars)) 
   $initialExemplars)


;; Convenience accessors
(= (actionDomainActions $domain)
   (actionSpaceActions (actionDomainSpace $domain)))

(= (actionDomainPerceptions $domain)
   (actionSpacePerceptions (actionDomainSpace $domain)))

(= (actionDomainFitness $domain)
   (actionSpaceFitness (actionDomainSpace $domain)))

(= (actionDomainBestScore $domain)
   (actionSpaceBestScore (actionDomainSpace $domain)))


;; Uniform access to domain configuration.
(= (actionDomainParam $domain actions)
   (actionDomainActions $domain))

(= (actionDomainParam $domain perceptions)
   (actionDomainPerceptions $domain))

(= (actionDomainParam $domain fitness)
   (actionDomainFitness $domain))

(= (actionDomainParam $domain bestScore)
   (actionDomainBestScore $domain))