;; Verbatim port of the Infromation theoretic bits function from c++
;; Params: $knobMap: A map of knobs with their multiplicities
;; Returns: Sum of the multiplicities of the knobs in the map
(: informationTheoreticBits (-> (MultiMap (NodeId (DiscSpec $knob))) Number))
(= (informationTheoreticBits $knobMap)
    (chain (List.map second (MultiMap.values $knobMap)) $knobs
      (chain (List.map getKnobMultip $knobs) $multips
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

;; Counts the number of instances at a specific distance from a given instance.
;; Params:
;;   $kbMap: Contains DiscKnobMap and DiscMap
;;   $inst: Reference instance
;;   $dist: Distance to measure
;;   $startIdx: Starting index
;;   $maxCount: Maximum count to return (e.g., 20).
;; Returns:
;;   Count of instances at distance $dist from $inst

; a helper function to the countNeighborhood method
(: countNeighborhoodFromIdx (-> KnobMap Instance Number Number Number Number))
(= (countNeighborhoodFromIdx (mkKbMap $dscKbMp (mkDscMp $dscMp)) $inst $dist $startIdx $maxCount)
(if (== $dist 0) 
    1 
    (if (>= $startIdx (MultiMap.length $dscMp)) 
        0
        (let $updatedNumInstances (countNeighborhoodFromIdx (mkKbMap $dscKbMp (mkDscMp $dscMp)) $inst $dist (+ $startIdx 1) $maxCount)   
          (if  (> $updatedNumInstances $maxCount) 
               $updatedNumInstances
               (let*
                 (
                    (($kbSpec $knob) (MultiMap.getByIdx $startIdx $dscMp))
                    ((mkMultip $multip) (getKnobMultip $knob))
                    ($uUpdatedNumInstances (+ $updatedNumInstances (* (- $multip 1) (countNeighborhoodFromIdx (mkKbMap $dscKbMp (mkDscMp $dscMp)) $inst (- $dist 1) (+ $startIdx 1) $maxCount))))
                 )
                 $uUpdatedNumInstances))))))

; countNeighborhood 
(: countNeighborhood (-> KnobMap Instance Number Number Number))
(= (countNeighborhood $kbMap $inst $dist $maxCount)
(countNeighborhoodFromIdx $kbMap $inst $dist 0 $maxCount))