;; Verbatim port of the Infromation theoretic bits function from c++
;; Params: $knobMap: A map of knobs with their multiplicities
;; Returns: Sum of the multiplicities of the knobs in the map
(: informationTheoreticBits (-> (MultiMap (NodeId (DiscSpec $knob))) Number))
(= (informationTheoreticBits $knobMap)
    (chain (List.map second (MultiMap.values $knobMap)) $knobs
      (chain (List.map getMultiplicity $knobs) $multips
        (chain (List.foldr add (mkMultip 0) $multips) $res
          (let (mkMultip $val) $res $val)))))

;; Verbatim port of the Estimate neighborhood function from c++
;; Params: $distance: The hamming distance from the current knob
;;         $knobMap: A map of knobs with their multiplicities
;; Returns: 2 * Sum of the multiplicities of the knobs in the map
(: estimateNeighborhood (-> Number (MultiMap (NodeId (DiscSpec $knob))) Number))
(= (estimateNeighborhood $distance $knobMap)
   (if (== $distance 0)
       1
       (let $nnEstimate (informationTheoreticBits $knobMap) (* 2 $nnEstimate)))) ;; INFO: Could use a safe binomial coefficient here if the estiamte starts becoming very large.
