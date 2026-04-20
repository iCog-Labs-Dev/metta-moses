!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/ordered-multimap)
!(import! &self ../../utilities/map)
!(import! &self ../../utilities/nodeId)
!(import! &self ../../utilities/tree)

!(import! &self ../lsk)
!(import! &self ../knob-mapper)
!(import! &self ../knob-representation)
!(import! &self ../representation)




(= (lsk1)
        (mkLSK
            (mkDiscKnob
              (mkKnob (mkNodeId (2 3)))
              (mkMultip 3)
              (mkDiscSpec 0)
              (mkDiscSpec 0)
              ())
            ))

(= (lsk2)
        (mkLSK
            (mkDiscKnob
              (mkKnob (mkNodeId (3)))
              (mkMultip 3)
              (mkDiscSpec 0)
              (mkDiscSpec 0)
              ())
            ))

(= (lsk3)
        (mkLSK
            (mkDiscKnob
              (mkKnob (mkNodeId (1)))
              (mkMultip 3)
              (mkDiscSpec 1)
              (mkDiscSpec 1)
              ())
            ))

(= (knobMapObj) (mkKbMap
                      (mkDscKbMp (cons ((mkNodeId (2 3)) 0) (cons ((mkNodeId (3)) 1) (cons ((mkNodeId (1)) 2) ()))))
                      (mkDscMp (cons ((mkDiscSpec 1) (lsk1)) (cons ((mkDiscSpec 0) (lsk2)) (cons ((mkDiscSpec 1) (lsk3)) ()))))))


!(assertEqual (findDiscKnob (knobMapObj) (mkNodeId (2 3))) ((lsk1) 0))
!(assertEqual (findDiscKnob (knobMapObj) (mkNodeId (0))) (() -1))
!(assertEqual (findDiscKnob (knobMapObj) (mkNodeId (2 2))) (() -1))
!(assertEqual (findDiscKnob (knobMapObj) (mkNodeId (3))) ((lsk2) 1))
!(assertEqual (findDiscKnob (knobMapObj) (mkNodeId (1))) ((lsk3) 2))
