  
;; (: DiscKnobMap Type)
;; (: mkDscMp (-> (MultiMap (DiscSpec $knob)) DiscMap))
;; (: mkDscKbMp (-> (Map (NodeId Number)) DiscKnobMap))
;; (: KnobMap Type)
;; (: mkKbMap (-> DiscKnobMap DiscMap KnobMap))
;; (: Representation Type)
;; (: mkRep (-> KnobMap (Tree $a) Representation)) 

;; helper function to representation
;; Converts DiscMap (multimap of knobSpec & knob) to DiscKnobMap (map of location & index)
;; Params: DiscMap
;; Returns: DiscKnobMap
;; (: crtDiscKnobMap (-> DiscMap DiscKnobMap Number DiscKnobMap))
(= (crtDiscKnobMap (mkDscMp NilMMap) (mkDscKbMp $dkm) $index) (mkDscKbMp $dkm))
(= (crtDiscKnobMap (mkDscMp (ConsMMap ($kbSpec $kb) $tail)) (mkDscKbMp $dkm) $index)
   (let*
   (
    ($loc (eval (getKnobLoc $kb)))
    ($updatedDkm (eval (Map.insert ($loc $index) $dkm == nodeId<)))
   ) 
   (eval (crtDiscKnobMap (mkDscMp $tail) (mkDscKbMp $updatedDkm) (+ $index 1)))
  ))

;; Game representation constructor with execution guard
;; Params: Tree (Exemplar), Number of demes
;; Returns: List of Representations
(= (representation $exemplar $nDeme)
   (let* (
      ($demeCount (eval (range 0 1 $nDeme)))
     
      ($result (collapse (let $x (superpose $demeCount)
         (let*
            (
               (($updatedTree $dscMp) (eval (buildKnobs $exemplar NilMMap ())))
               ($dscKbMp (eval (crtDiscKnobMap (mkDscMp $dscMp) (mkDscKbMp NilMap) $x)))
               ($rep (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $updatedTree))
            )   
               $rep))))
   )
   $result))

;; Boolean representation constructor with feature selection
;; Params: Number of demes, Tree (Exemplar), ITable, feature selection params
;; Returns: List of Representations
(= (representation
            $nDeme                      ;; number of demes to spawn (number of distinct feature sets)
            $exemplar                   ;; tree around which multiple representations are to be built
            (mkITable $table $labels)   ;; table from which to select features and base the representations with
            $ft-selection-algo          ;; feature selection algorithm to be used -- symbol 
            $prune-exemplar             ;; bool to decide to prune the exemplar or keep the exemplar as is
            $enforced-fts               ;; set of features to be enforced in to selected features
            $scorerType                 ;; can MI or precision_bscore
        )
        
        (let* (
                  ($_ (println! (Inside Representation)))
                  ($exemplar-fts  (filter-atom (eval (treeFtsIndices $exemplar $labels)) $x (not (== $x -1))))
                  ($_ (println! (exemplar features $exemplar-fts)))          ;; exemplarFtsIndices function in deme/expand-deme.metta
                 ($all-labels (eval (getInputLabels $labels)))                       ;; getInputLabels in deme/expand-deme.metta
                 ($_ (println! "before featureSelector"))                                                                                                           ;;Default Values  ;;miConf PrePenalty  PreMInActivation   PreMaxActivation  PrePositive   ScorerType
                 ($ft-set-pop (eval (featureSelector $ft-selection-algo (mkITable $table $labels) 0.0 $exemplar 2 2 False () False 2 False ja $nDeme 50.0   1.0            0.5               1.0               True         $scorerType)))     ;; applies the right parameteres for feature selection based on selected selection algorithm 
                 ($_ (println! (Selected Features after feature Selection $ft-set-pop)))
                 ($exemplar-arg-seq                                           ;; apply exemplar feature pruning
                     (if $prune-exemplar
                           (map-atom $ft-set-pop $ft-set 
                              (let* (($diff-ft (subtraction-atom $exemplar-fts $ft-set))
                                    ($_ (println! (diffffffff $diff-ft)))
                                     ($ft-names (eval (fsToNames $labels $diff-ft)))
                                     ($pruned-xmplr (eval (pruneExemplar $exemplar $ft-names)))
                                     ($final-args (subtraction-atom $ft-set $exemplar-fts)))  

                                 ($pruned-xmplr (eval (fsToNames $labels $final-args)))))
                           
                           (map-atom $ft-set-pop $ft-set 
                                 (let* (($agg (eval (union-atom-set $ft-set $exemplar-fts)))
                                        ($final-args (eval (fsToNames $labels $agg)))
                                        )  
                                        
                                    ($exemplar $final-args)))))
                  ($_ (println! (Exemplar arg sets after pruning: $exemplar-arg-seq))) 
                  ($with-enforced-fts                                         ;; enforce features
                     (if (== $enforced-fts ())
                           $exemplar-arg-seq
                           (let $sampled-enforced-fts (eval (sampleEnforcedFts $enforced-fts))           ;; from feature-selection/select-top-features.metta
                                    (map-atom $exemplar-arg-seq ($xmplr $args)
                                             (let $acc (eval (concatT $args $sampled-enforced-fts)) ($xmplr $acc))))))  
                  ($_ (println! (With enforced features: $with-enforced-fts)))
                  ($filter-empty-args (filter-atom $with-enforced-fts ($xmplr $args) (eval (not (== $args ())))))
                  ($_ (println! (After filtering empty args: $filter-empty-args)))
              )      ;; filter out exemplar arg pairs that have empty arg list

                     (map-atom $filter-empty-args ($xmplr $argLabels) 
                           (let* (
                                    ($_ (println! (Building representation for arg labels: $argLabels)))
                                    (($updatedTree $dscMp) (trace! (" done buildknobs (:) ") (eval (buildKnobs $xmplr NilMMap $argLabels))))            ;; BUILD representations on 
                                    ($_ (println! (Building representation for arg labels: $argLabels)))
                                    ($_ (println! (updated tereeeeee dddddddddddd disc mappppp ($updatedTree $dscMp))))
                                    ($_ (println! ""))
                                  ($dscKbMp (eval (crtDiscKnobMap (mkDscMp $dscMp) (mkDscKbMp NilMap) 0))))        ;; MULITPLE args selected using the feature selection
                                 
                                 (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $updatedTree)))))

;; Helper function to extract tree from representation
(= (getRepTree (mkRep $knobMapObj $tree)) $tree)

;; Universal getCandidate that works for both boolean and game strategies
;; Skips cleanTree for PRIORITIZED-OR (game strategies)
(= (getCandidate $repObj $inst)
   (let*
      (
         ($parentid (mkNodeId (0)))
         ($srcid (mkNodeId (0)))
         ($candidate (getCandidateRec $repObj $inst $parentid $srcid (mkNullVex Nil)))
         ;; Check if this is a game strategy (PRIORITIZED-OR at root)
         ($rootNode (eval (getNodeById (eval (getRepTree $repObj)) $srcid)))
         ($rootValue (eval (getNodeValue $rootNode)))
         ($isGameStrategy (== $rootValue PRIORITIZED-OR))
      )
      ;; Skip cleanTree for game strategies, apply it for boolean logic
      (if $isGameStrategy
          $candidate
          (eval (cleanTree $candidate)))
   ))

(= (getCandidateRec (mkRep $knobMapObj $tree) (mkInst $inst) $parentId $srcId $candidate)
   (let $knobIdxPair (eval (findDiscKnob $knobMapObj $srcId))
      (if (not (== (eval (second $knobIdxPair)) -1))
         ;; Knob Found - apply instance value
         (let* (
               ($d (eval (List.getByIdx $inst (eval (second $knobIdxPair)))))
               ($updatedCnd (eval (appendTo $tree (eval (first $knobIdxPair)) $candidate $parentId $d)))
            )
            $updatedCnd)
         ;; No Knob - copy structure
         (let* (
               ($src (eval (getNodeById $tree $srcId)))
               ($cndchidpair (eval (appendChild $candidate $parentId (mkTree (eval (getNodeValue $src)) Nil))))
               ($srcchildren (eval (getChildren $src)))
               ($state (eval (List.foldl applyGetCandidateRec ((mkRep $knobMapObj $tree) (mkInst $inst) (eval (second $cndchidpair)) (eval (first $cndchidpair)) 1) $srcchildren)))
               (((mkRep $knobmapobj $tree) (mkInst $inst) $newparentid $finalcnd $d) $state)
            )
              $finalcnd))))

(= (applyGetCandidateRec $tr ($repObj $inst (mkNodeId $parentId) $candidate $chIdx))
   (let* (
         ($srcId (if (== $parentId (0)) (mkNodeId ($chIdx)) (mkNodeId (eval (concatT $parentId ($chIdx))))))
         ($updatedCnd (eval (getCandidateRec $repObj $inst (mkNodeId $parentId) $srcId $candidate)))
      )
      ($repObj $inst (mkNodeId $parentId) $updatedCnd (+ 1 $chIdx))))
