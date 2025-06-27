(: DiscMap Type)   
(: DiscKnobMap Type)
(: mkDscMp (-> (MultiMap (DiscSpec $knob)) DiscMap))
(: mkDscKbMp (-> (Map (NodeId Number)) DiscKnobMap))
(: KnobMap Type)
(: mkKbMap (-> DiscKnobMap DiscMap KnobMap))
(: Representation Type)
(: mkRep (-> KnobMap (Tree $a) Representation)) 

;; helper function to representation
;; Converts DiscMap (multimap of knobSpec & knob) to DiscKnobMap (map of location & index)
;; Params: DiscMap
;; Returns: DiscKnobMap
(: crtDiscKnobMap (-> DiscMap DiscKnobMap Number DiscKnobMap))
(= (crtDiscKnobMap (mkDscMp NilMMap) (mkDscKbMp $dkm) $index) (mkDscKbMp $dkm))
(= (crtDiscKnobMap (mkDscMp (ConsMMap ($kbSpec $kb) $tail)) (mkDscKbMp $dkm) $index)
   (let*
   (
    ($loc (getKnobLoc $kb))
    ($updatedDkm (Map.insert ($loc $index) $dkm == nodeId<))
   ) 
   (crtDiscKnobMap (mkDscMp $tail) (mkDscKbMp $updatedDkm) (+ $index 1))
  ))

;; representation constructor
;; Params: Tree (Exemplar)
;; Returns: Representation
(: representation (-> (Tree $a) Representation))
(= (representation $exemplar)
(let*
(
    (($updatedTree $dscMp) (buildKnobs $exemplar NilMMap))
    ($dscKbMp (crtDiscKnobMap (mkDscMp $dscMp) (mkDscKbMp NilMap) 0))
)   
(mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $updatedTree)
))

(: getCandidate (-> Representation Instance (Tree $a)))
(= (getCandidate $repObj $inst)
   (trace! (Converting instance: $inst to tree) (chain (getCandidateRec $repObj $inst (mkNodeId (0)) (mkNodeId (0)) (mkNullVex Nil)) $candidate
    (cleanTree $candidate))))
     ;; (trace! (Done converting instance to tree $candidate) $candidate))))

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


