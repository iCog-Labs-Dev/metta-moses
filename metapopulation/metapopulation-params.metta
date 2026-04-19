;; The following type defintions and type constructors are commented out because the implementaiton in PeTTa no longer makes use of them
;; The code here has not been used anywhere to my knowledge 
; ;; metapopulation parameteres as type
; (: MetapopParams Type)
; (: maxCandPerDeme MetapopParams)
; (: mkMaxCandPerDeme (-> Number maxCandPerDeme))

; (: complexityTemperature MetapopParams)
; (: mkCompTemp (-> Number complexityTemperature))

; (: discardDominated MetapopParams)
; (: mkDiscardDominated (-> Bool discardDominated))

; (: capCoef MetapopParams)
; (: mkCapCoef (-> Number capCoef))

;; adding typed parameters in the atomspace
!(bind! &params (new-space))
; !(add-atom &params (mkCapCoef 50))
; !(add-atom &params (mkDiscardDominated False))
; !(add-atom &params (mkCompTemp 4))
; !(add-atom &params (mkMaxCandPerDeme -1))

!(add-atom &params (capCoef 50))
!(add-atom &params (discardDominated False))
!(add-atom &params (compTemp 4))
!(add-atom &params (maxCandPerDeme -1))

;; explore ways to make add-reduct work in petta
; !(eval (add-reduct &params 
;     (superpose ((mkCapCoef 50)
;                 (mkDiscardDominated False)
;                 (mkCompTemp 4)
;                 (mkMaxCandPerDeme -1)))))

;; metapopulation parameter getter function
; (: getMpParam (-> %Undefined% Symbol $a))
; (= (getMpParam $space $type)
;     (match $space ($ctor $x)
;         (let $t (get-type ($ctor $x)) (if (== $t $type) $x (empty)))))

(= (getMpParam $space $param)
    (let $r (collapse (match $space ($param $x) $x)) (if (= $r ()) () (car-atom $r))))

;; metapopulation parameter setter function
; (: setMpParam (-> %Undefined% MetapopParams $a (->)))
(= (setMpParam $space $param $newval)
    (match $space ($param $val)
        (let $_ (remove-atom $space ($param $val)) (add-atom $space ($param $newval)))))