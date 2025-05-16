;; This is a helper function for sfn (sampling from neighborhood) that updates the 
;; central instance for a specified number of times, determined by $dist.
;; 
;; Parameters:
;;      $dist: The required distance from the central instance.
;;      $len: The length of the central instance.
;;      $disc: A multi-map (extracted from the knob mapper) of DiscSpec logicalSubtreeKnob, 
;;             used to retrieve the lsk (logical subtree knob) from which the knob multiplicity 
;;             can be obtained.
;;      $newinst: The original central instance.
(: updatedInst (-> Number Number (MultiMap (DiscSpec logicalSubtreeKnob)) (List Number) (List Number)))
(= (updateInst $dist $len $disc $newinst)
    ( if (== $dist 0) 
        $newinst
        (let* (
            (($rand) (lazyRandomSelector 0 (- $len 1) 1)) 
            (($decspec (mkLSK (mkDiscKnob $knob (mkMultip $multi) $spec $spec1 $speclist) $tree)) (MultiMap.getByIdx $rand $disc))
            ($curspec (List.getByIdx $newinst $rand))
            ($upper (- $multi 1))
            ($randomspec (+ (random-int &rng 0 $upper) 1)) 
            ($updatedinst  (if (== $randomspec $curSpec)
                        (List.replaceAt $newinst $rand 0) 
                        (List.replaceAt $newinst $rand $randomspec)
                        )))
             (updateInst (- $dist 1) $len $disc $updatedinst))))



;; This function generates $samplesize instances that are within a distance (difference in knob specifications) 
;; of $dist  from the central instance. It uses the knobmapper to extract the multiplicity of the knob,
;; as the central instance only contains the list of specifications.
;; Parameters:
;;      $samplesize: The number of instances to be generated.
;;      $dist: The distance from the central instance.
;;      $knobmapper: The knob mapper used to extract the multiplicity of the knob.
;;      $centralinstance: The instance from which other instances will be generated.
(: sfn (-> Number Number knobMap Instance (List Instance)))
(= (sfn $samplesize $dist (mkKbMap $itDiscKnob $disc) (mkInst $centralinst)) 
    (if (== $samplesize 0) Nil
    (let* ( 
            ($knoblen (MultiMap.length $disc))
            ($instlen (List.length $centralinst)))
            (if (== $knoblen $instlen) 
                    (let* (
                ($updatedinst (updateInst $dist $instlen $disc $centralinst))
                ($restinstances (sfn (- $samplesize 1) $dist (mkKbMap $itDiscKnob $disc) (mkInst $centralinst)))
                ($inst (mkInst $updatedinst))
                ($final (List.append $inst $restinstances))
                )
                $final
            )
            (Error ($knoblen $instlen) "Not Equal")))
    ))
