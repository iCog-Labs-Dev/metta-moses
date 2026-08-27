;; ============================================================================
;; Generic ActionDomain Runner
;; ============================================================================

;; Legacy adapter for callers that still configure action domains through
;; global parameters.
(= (actionDomainFromParams)
   (mkActionDomain
      (mkActionSpace
         (param actions)
         (param perceptions)
         (param fitness)
         (param bestScore))
      ()))



;; Default population containing the empty action program.
(= (defaultActionExemplar $nTrials $cpxPen)
   (let $worst
      (* -1.0 $nTrials)

      (mkExemplar
         (mkTree (mkNode and_seq) ())
         (mkDemeId "1")
         (mkCscore $worst 0 $cpxPen 0 $worst)
         (mkBScore (List.repeat $nTrials -1.0)))))

;; Use domain-provided initial exemplars, or the default empty program.
(= (actionDomainInitialPopulation $domain $nTrials $cpxPen)
   (let $initial (actionDomainInitialExemplars $domain)

      (if (== $initial ())
          ((defaultActionExemplar $nTrials $cpxPen))
          $initial)))


;; Resolve the domain's best reachable score.
;; Fall back to a value that cannot be reached when the domain does not
;; provide a valid numeric score.
;; Best reachable score
(= (actionDomainBestPossibleScore $domain $nTrials)
   (let $fn (actionDomainBestScore $domain)
      (let $result (collapse ($fn $nTrials))
           (if (== $result ())
               (pow-math 10 308)

               (let $score (car-atom $result)
                    (if (== (get-type $score) Number)
                     $score
                    (pow-math 10 308)))))))

;; Execute MOSES for an explicit ActionDomain.
(= (moses-run-action $domain)

   (let*
      (
        ($seed (param seed))
        ($maxGen (param maxGen))

        ($nDeme (param nDeme))
        ($optimizer (optimizer-for (param optAlgo)))

        ($cpxPen (param complexityRatio))

        ($nTrials (param nTrials))
        
        ($_seed (py-call (random.seed $seed)))
        ($_genCount (set-param genCount $maxGen))

        ($bestPossibleScore (actionDomainBestPossibleScore $domain $nTrials))
        ($metaPop (actionDomainInitialPopulation $domain $nTrials $cpxPen))

        ($result (runMoses $maxGen $bestPossibleScore $metaPop
              0
              $nDeme
              (mkActionCtx $nTrials $cpxPen)
              $optimizer))

        ($newResult (mapG cleanedExemplar $result))
        ($_cut (cut))
      )
      (FinalResult $newResult)))

;; Bridge domain-owned configuration to the existing MOSES parameter-based
;; internals. This keeps the generic runner compatible with code that still
;; reads action configuration from global parameters.
(= (runActionDomainInternal $domain)

   (let*
      (

        ($actions (actionDomainActions $domain))
        ($perceptions (actionDomainPerceptions $domain))
        ($fitness (actionDomainFitness $domain))
        ($bestScore (actionDomainBestScore $domain))
       
        
        ($_actions (set-param actions $actions))
        ($_perceptions (set-param perceptions $perceptions))
        ($_fitness (set-param fitness $fitness))
        ($_bestScore (set-param bestScore $bestScore))
    
        ($result (moses-run-action $domain))
      )
      $result))


;; Public explicit-domain entry point.
(= (runActionDomain $domain)
   (runActionDomainInternal $domain))


;; Legacy entry point for parameter-based action domains.
(= (runCurrentActionDomain)
   (runActionDomain (actionDomainFromParams)))