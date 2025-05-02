(: Representation Type)
(: mkRep (-> KnobMap (Tree $a) Representation))

(: KnobMap Type)
(: mkKbMap (-> (Map (NodeId Number)) (MultiMap (DiscSpec $knob)) KnobMap))

(: getCandidate -> Representation Instance (Tree $a))
(= (getCandidate $repObj $inst)
   (chain (getCandidateRec $repObj $inst (mkNodeId (0)) (mkNodeId (0)) (mkNullVex Nil)) $candidate
      (cleanTree $candidate)))

;; Assumes the reverseLookupTable's order never changes during this call.
(: getCandidateRec (-> Representation Instance NodeId NodeId (Tree $a) (Tree $a)))
(= (getCandidateRec (mkRep $knobMapObj $tree) (mkInst $inst) $parentId $srcId $candidate)
   ;; Find the knob associated with src (if any)
   (chain (findDiscKnob $knobMapObj $srcId) $knobIdxPair
      (if (~= (second $knobIdxPair) -1)
          (chain (List.getByIdx $inst (second $knobIdxPair)) $d
          (chain (appendTo (first $knobIdxPair) $candidate $parentId $d) $updatedCnd

          ;; The C++ version needs to call the getCandidateRec 
          ;;  on the newly added node of the candidate but we 
          ;;  already took care of that addition using the appendTo
          ;;  function. Therefore that part is ommited here.
          $updatedCnd))

         ;; No knob found. Just copy.
         (chain (getNodeById $tree $srcId) $src ;; Get node value using id
         (chain (appendChild $candidate $parentId (mkTree (getNodeValue $src) Nil)) $cndChIdPair ;; AppendChild returns a pair of tree and appended child Id
         (chain (getChildren $src) $srcChildren
         (chain (List.foldl applyGetCandidateRec ((mkRep $knobMapObj $tree) (mkInst $inst) (second $cndChIdPair) (first $cndChIdPair) 1) $srcChildren) $state
            (let ((mkRep $knobMapObj $tree) (mkInst $inst) $newParentId $finalCnd $_) $state $finalCnd)))))))
)


(: applyGetCandidateRec (-> (Tree $a)
                            (Representation Instance NodeId (Tree $a) Number)
                            (Representation Instance NodeId (Tree $a) Number)))
(= (applyGetCandidateRec $_ ($repObj $inst (mkNodeId $parentId) $candidate $chIdx))
   (chain (if (== $parentId (0)) (mkNodeId ($chIdx)) (mkNodeId (unionAtom $parentId ($chIdx)))) $srcId ;; Skip 0 from tree id.
   (chain (getCandidateRec $repObj $inst (mkNodeId $parentId) $srcId $candidate) $updatedCnd
      ($repObj $inst (mkNodeId $parentId) $updatedCnd (+ 1 $chIdx)))))


