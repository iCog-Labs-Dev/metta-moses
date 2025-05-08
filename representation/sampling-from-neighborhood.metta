(= (updateInst $knobmaper $dist $len $newinst)
    ( if (== $dist 0) 
        $newinst
        (let* (
            (($rand) (lazyRandomSelector 0 (- $len 1) 1)) ; I don't know what dim means. So, I used $len
            ((mkDiscKnob $knob (mkMultip $multi) (mkDiscSpec $curSpec) $def $disAll) (List.getByIdx $knobmaper $rand))
            ($upper (- $multi 1))
            ($randomSpec (+ ((py-atom random.randint) 0 $upper) 1)) 
            ($updatedinst  (if (== $randomSpec $curSpec)
                        (List.replaceAt $newinst $rand (mkDiscKnob $knob (mkMultip $multi) (mkDiscSpec 0) $def $disAll)) 
                        (List.replaceAt $newinst $rand (mkDiscKnob $knob (mkMultip $multi) (mkDiscSpec $randomSpec) $def $disAll))
                        )))
             (updateInst $knobmaper (- $dist 1) $len $updatedinst))))

(: sfn (-> Number Number (List DiscreteKnob) $Instance (List Instance)))
(= (sfn $samplesize $dist $knobmaper $centerInst)
    (if (== $samplesize 0) Nil
    (let* ( 
            ($knoblen (List.length $knobmaper))
            ($instlen (List.length $centerInst)))
            (if (== $knoblen $instlen) 
                    (let* (
                ($updatedinstant (updateInst $knobmaper $dist $instlen $centerInst))
                ($restinstances (sfn (- $samplesize 1) $dist $knobmaper $centerInst))
                ($final (List.append $updatedinstant $restinstances))
                )
                $final
            )
            (Error (The length of center instance must equal with knob maper) ())))
    ))
