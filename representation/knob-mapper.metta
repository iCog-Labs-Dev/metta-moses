;; Knob Mapper
;; Finds all knobs associated with a given node id and returns them as a list.
;; the MultiMap is used to store the association between node ids and a tuple of disc specification and knob.

(: findDiscKnob (-> NodeId (MultiMap ($k $v)) (List $v)))
(= (findDiscKnob  $nodeId NilMMap ) Nil)
(= (findDiscKnob $nodeId (ConsMMap ($id ($spec $knob)) $tail))
    (if (== $nodeId $id) 
        (Cons $knob (findDiscKnob $nodeId $tail))
        (findDiscKnob $nodeId $tail)
    )
)

