!(import! &self ../lsk)
!(import! &self ../knob-mapper)
!(import! &self ../representation)
!(import! &self ../knob-representation)

!(import! &self ../../utilities/map)
!(import! &self ../../utilities/tree)
!(import! &self ../../utilities/nodeId)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/ordered-multimap)



(= (lsk1)
        (mkLSK
            (mkDiscKnob
              (mkKnob (mkNodeId (2 3)))
              (mkMultip 3)
              (mkDiscSpec 0)
              (mkDiscSpec 0)
              Nil)
            ))

(= (lsk2)
        (mkLSK
            (mkDiscKnob
              (mkKnob (mkNodeId (3)))
              (mkMultip 3)
              (mkDiscSpec 0)
              (mkDiscSpec 0)
              Nil)
            ))

(= (lsk3)
        (mkLSK
            (mkDiscKnob
              (mkKnob (mkNodeId (1)))
              (mkMultip 3)
              (mkDiscSpec 1)
              (mkDiscSpec 1)
              Nil)
            ))

(= (knobMapObj) (mkKbMap
                      (mkDscKbMp (ConsMap ((mkNodeId (2 3)) 0) (ConsMap ((mkNodeId (3)) 1) (ConsMap ((mkNodeId (1)) 2) NilMap))))
                      (mkDscMp (ConsMMap ((mkDiscSpec 1) (lsk1)) (ConsMMap ((mkDiscSpec 0) (lsk2)) (ConsMMap ((mkDiscSpec 1) (lsk3)) NilMMap))))))


!(assertEqual (findDiscKnob (knobMapObj) (mkNodeId (2 3))) ((lsk1) 0))
!(assertEqual (findDiscKnob (knobMapObj) (mkNodeId (0))) (() -1))
!(assertEqual (findDiscKnob (knobMapObj) (mkNodeId (2 2))) (() -1))
!(assertEqual (findDiscKnob (knobMapObj) (mkNodeId (3))) ((lsk2) 1))
!(assertEqual (findDiscKnob (knobMapObj) (mkNodeId (1))) ((lsk3) 2))
