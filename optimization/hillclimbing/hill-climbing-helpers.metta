;; Infromation theoretic bits
;; (: informationTheoreticBits (-> (MultiMap (Pair NodeId (DiscSpec $knob))) Number))
(: informationTheoreticBits (-> (MultiMap (NodeId (DiscSpec $knob))) Number))
(= (informationTheoreticBits $knobMap)
    (chain (List.map second (MultiMap.values $knobMap)) $knobs
      (chain (List.map getMultiplicity $knobs) $multips
        (chain (List.foldr add (mkMultip 0) $multips) $res
          (let (mkMultip $val) $res $val)))))

;; Estimate neighborhood
