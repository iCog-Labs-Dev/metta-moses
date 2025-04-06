;; metapopulation parameteres as type
(: MetapopParams Type)
(: maxCandPerDeme MetapopParams)
(: mkMaxCandPerDeme (-> Number maxCandPerDeme))

(: complexityTemperature MetapopParams)
(: mkCompTemp (-> Number complexityTemperature))

(: discardDominated MetapopParams)
(: mkDiscardDominated (-> Bool discardDominated))

(: capCoef MetapopParams)
(: mkCapCoef (-> Number capCoef))

;; adding typed parameters in the atomspace
! (bind! &params (new-space))
! (add-reduct &params 
    (superpose ((mkCapCoef 50)
                (mkDiscardDominated False)
                (mkCompTemp 4)
                (mkMaxCandPerDeme -1))))

;; metapopulation parameter getter function
(: getMpParam (-> hyperon::space::DynSpace MetapopParams $a))
(= (getMpParam $space $type)
    (match $space ($ctor $x)
        (let $t (get-type ($ctor $x)) (if (== $t $type) $x (empty)))))

;; metapopulation parameter setter function
(: setMpParam (-> hyperon::space::DynSpace MetapopParams $a (->)))
(= (setMpParam $space $type $newval)
    (match $space ($ctor $val) (let $t (get-type ($ctor $val)) (if (== $t $type) 
        (let () (remove-atom $space ($ctor $val)) (add-atom $space ($ctor $newval))) (empty)))))
