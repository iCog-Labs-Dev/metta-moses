;; Knob Mapper
;; Finds all knobs associated with a given node id and returns them as a list.
;; the MultiMap is used to store the association between node ids and a tuple of disc specification and knob.

;; (: findDiscKnob (-> KnobMap NodeId ($knob Number))) ;; TODO: Give specific type for key and value
(= (findDiscKnob (mkKbMap (mkDscKbMp $itDiscKnob) (mkDscMp $disc)) $nodeId)
   (if (== True (eval (Map.contains $nodeId $itDiscKnob)))
       (chain (eval (Map.getByKey $nodeId $itDiscKnob)) $discIdx
       (chain (eval (MultiMap.getByIdx $discIdx $disc)) $discKnobPair
         ( (eval (second $discKnobPair)) $discIdx)))

       (() -1)))
