;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;       NodeId           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; (i i i ...) : the id would be in the form of a tuple
; it contains a list of indexes the node is found starting from the outer 
; Ex: (AND (OR A B) (OR C D))
;     AND -> 0
;      A  -> (1 0)
;      C  -> (2 1)

(: NodeId Type)
(: mkNodeId (-> $tuple NodeId))
(= (mkNodeId $tuple) $tuple)
(: Node Type)

;;Finds and returns a specific node from an expressions using its NodeId
;;   params: $exp: the expression
;;           $NodeId: the NodeId of the node to be found from the $exp
;;   returns: the node at the positions specified by the NodeId
(: getNodeById (-> Tree NodeId Node))
(= (getNodeById $exp $NodeId)
(let* 
   (
      ($index (car-atom $NodeId))
      ($nodeAtIndex (index-atom $exp $index))
      ($nodeType (get-metatype $nodeAtIndex))
      ($nextIndexes (cdr-atom $NodeId))
   )
   (if (== $nodeType Symbol) 
       $nodeAtIndex 
       (if (== $nextIndexes ()) 
           $nodeAtIndex
           (getNodeById $nodeAtIndex (mkNodeId $nextIndexes))
       )
   )
)
)
