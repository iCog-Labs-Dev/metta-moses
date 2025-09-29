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
;;         $argLabels: list of argument labels (input variables) from the ITable
;; Returns: Representation
; (: representation (-> (Tree $a) Expression Representation))
; (= (representation $exemplar $argLabels)
; (let*
; (
;     (($updatedTree $dscMp) (buildKnobs $exemplar NilMMap $argLabels))
;     ($dscKbMp (crtDiscKnobMap (mkDscMp $dscMp) (mkDscKbMp NilMap) 0))
; )   
; (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $updatedTree)
; ))

(: representation (-> Number (Tree $a) (ITable $a) Symbol bool Expression Symbol Expression))
(= (representation 
            $nDeme                      ;; number of demes to spawn (number of distinct feature sets)
            $exemplar                   ;; tree around which multiple representations are to be built
            (mkITable $table $labels)   ;; table from which to select features and base the representations with
            $ft-selection-algo          ;; feature selection algorithm to be used -- symbol 
            $prune-exemplar             ;; bool to decide to prune the exemplar or keep the exemplar as is
            $enforced-fts               ;; set of features to be enforced in to selected features
            $scorerType         ;; can MI or precision_bscore
        )
        
        (let*   (
                  (() (println! (Inside Representation)))
                  ($exemplar-fts (treeFtsIndices $exemplar $labels))           ;; exemplarFtsIndices function in deme/expand-deme.metta
                 ($all-labels (getInputLabels $labels))                       ;; getInputLabels in deme/expand-deme.metta
                                                                                                                            ;;Default Values  ;;miConf PrePenalty  PreMInActivation   PreMaxActivation  PrePositive   ScorerType
                 ($ft-set-pop (featureSelector $ft-selection-algo (mkITable $table $labels) 0.0 $exemplar 2 2 False () False 2 False ja $nDeme 50.0   1.0            0.5               1.0               True         $scorerType))     ;; applies the right parameteres for feature selection based on selected selection algorithm 
                 (() (println! (Selected Features after feature Selection $ft-set-pop)))
                 ($exemplar-arg-seq                                           ;; apply exemplar feature pruning
                     (if $prune-exemplar
                           (map-atom $ft-set-pop $ft-set 
                              (let* (($diff-ft (subtraction-atom $exemplar-fts $ft-set))
                                     ($ft-names (fsToNames $labels $diff-ft))
                                     ($pruned-xmplr (pruneExemplar $exemplar $ft-names))
                                     ($final-args (subtraction-atom $ft-set $exemplar-fts)))  

                                 ($pruned-xmplr (fsToNames $labels $final-args))))
                           
                           (map-atom $ft-set-pop $ft-set 
                                 (let* (($agg (union-atom $ft-set $exemplar-fts))
                                        ($final-args (fsToNames $labels $agg)))  
                                        
                                    ($exemplar $final-args))))) 
                  ($with-enforced-fts                                         ;; enforce features
                     (if (== $enforced-fts ())
                           $exemplar-arg-seq
                           (let $sampled-enforced-fts (sampleEnforcedFts $enforced-fts)           ;; from feature-selection/select-top-features.metta
                                    (map-atom $exemplar-arg-seq ($xmplr $args)
                                             (let $acc (union-atom $args $sampled-enforced-fts) ($xmplr $acc))))))  
                  ($filter-empty-args (filter-atom $with-enforced-fts ($xmplr $args) (eval (not (== $args ()))))))      ;; filter out exemplar arg pairs that have empty arg list

                     (map-atom $filter-empty-args ($xmplr $argLabels) 
                           (let* ((($updatedTree $dscMp) (buildKnobs $xmplr NilMMap $argLabels))            ;; BUILD representations on 
                                  ($dscKbMp (crtDiscKnobMap (mkDscMp $dscMp) (mkDscKbMp NilMap) 0)))        ;; MULITPLE args selected using the feature selection
                                 
                                 (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $updatedTree)))))

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
          (chain (appendTo $tree (first $knobIdxPair) $candidate $parentId $d) $updatedCnd

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


