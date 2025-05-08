(= (updateInst $knobmaper $dist $len $newinst)
    ( if (== $dist 0) 
        $newinst
        (let* (
            (($rand) (lazyRandomSelector 0 (- $len 1) 1)) ; I don't know what dim means. So, I used $len
            ((mkDiscKnob $knob (mkMultip $multi) (mkDiscSpec $curSpec) $def $disAll) (List.getByIdx $knobmaper $rand))
            ($upper (- $multi 1))
            ($randomSpec (+ (random-int &rng 0 $upper) 1)) 
            ($updatedinst  (if (== $randomSpec $curSpec)
                        (List.replaceAt $newinst $rand (mkDiscKnob $knob (mkMultip $multi) (mkDiscSpec 0) $def $disAll)) 
                        (List.replaceAt $newinst $rand (mkDiscKnob $knob (mkMultip $multi) (mkDiscSpec $randomSpec) $def $disAll))
                        )))
             (updateInst $knobmaper (- $dist 1) $len $updatedinst))))

(: sfn (-> Number Number (List DiscreteKnob) (List DiscreteKnob) (List (List DiscreteKnob))))
(= (sfn $samplesize $dist $knobmaper $centerinst) ;I couldn't figure out how to use knobmapper, I just use it to keep $centerinst unchanged
    (if (== $samplesize 0) Nil
    (let* ( 
            ($knoblen (List.length $knobmaper))
            ($instlen (List.length $centerinst)))
            (if (== $knoblen $instlen) 
                    (let* (
                ($updatedinstant (updateInst $knobmaper $dist $instlen $centerinst))
                ($restinstances (sfn (- $samplesize 1) $dist $knobmaper $centerinst))
                ($final (List.append $updatedinstant $restinstances))
                )
                $final
            )
            (Error ($knoblen $instlen) "Not Equal")))
    ))

; (= (sfn $samplesize $dist $centerinst) (sfn $samplesize $dist $centerinst)) ; if the knobmapper is useless