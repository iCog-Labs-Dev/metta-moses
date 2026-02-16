  
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
;; Game representation constructor with execution guard
;; Params: Tree (Exemplar), Number of demes
;; Returns: List of Representations
;;(: representation (-> (Tree $a) Number (List Representation)))
(= (representation $exemplar $nDeme)
   (let* (
      ($demeCount (eval (range 0 1 $nDeme)))
     
      ($result (collapse (let $x (superpose $demeCount)
         (let*
            (
               (($updatedTree $dscMp) (eval (buildKnobs $exemplar NilMMap ())))
               ($dscKbMp (eval (crtDiscKnobMap (mkDscMp $dscMp) (mkDscKbMp NilMap) 0)))
               ($rep (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $updatedTree))
            )   
               $rep))))
   )
   $result))
;; (: representation (-> Number (Tree $a) (ITable $a) Symbol bool Expression Symbol Expression))
(= (representation
;; Boolean representation constructor with feature selection
;; Params: Number of demes, Tree (Exemplar), ITable, feature selection params
;; Returns: List of Representations
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
;; Uses preOrder+buildTree to unwrap mkNullVex for games, cleanTree for boolean
;; (: getCandidate (-> Representation Instance (Tree $a)))
(= (getCandidate $repObj $inst)
   (let*
      (
         ($_ (println! "[getCandidate] Starting..."))
         ($_ (println! (  RepObj: $repObj)))
         ($_ (println! (  Instance: $inst)))
         ($parentid (mkNodeId (0)))
         ($srcid (mkNodeId (0)))
         ($_ (println! "[getCandidate] Calling getCandidateRec..."))
         ($candidate (getCandidateRec $repObj $inst $parentid $srcid (mkNullVex Nil)))
         ($_ (println! "[getCandidate] Got candidate tree"))
         ;; Check if this is a game strategy (PRIORITIZED-OR at root)
         ($rootNode (eval (getNodeById (eval (getRepTree $repObj)) $srcid)))
         ($rootValue (eval (getNodeValue $rootNode)))
         ($rootSymbol (if (== (get-metatype $rootValue) Expression) 
                 (car-atom (cdr-atom $rootValue))
                 $rootValue))
         ($isGameStrategy (== $rootSymbol PRIORITIZED-OR))
         ($_ (println! (  Is game strategy: $isGameStrategy)))
      )
      ;; Game: Just return candidate as-is (NullVex have meaning for strategies)
      ;; Boolean: cleanTree (unwraps mkNullVex + applies reductions)
      (if $isGameStrategy
          (let* (
             ($_ (println! "[getCandidate] Processing as game strategy..."))
             ($_ (println! (  Candidate: $candidate)))
             ($_ (println! "[getCandidate] Returning game strategy tree as-is"))
          )
          $candidate)
          (let* (
             ($_ (println! "[getCandidate] Processing as boolean expression..."))
             ($cleaned (eval (cleanTree $candidate)))
             ($_ (println! "[getCandidate] Returning boolean tree"))
          )
          $cleaned))
   ))
   ; (trace! (Converting instance: $inst to tree) (chain (getCandidateRec $repObj $inst (mkNodeId (0)) (mkNodeId (0)) (mkNullVex Nil)) $candidate
   ;  (cleanTree $candidate)))
    
    
     ;;((( (trace! (Done converting instance to tree $candidate) $candidate))))


;; Assumes the reverseLookupTable's order never changes during this call.
;; (: getCandidateRec (-> Representation Instance NodeId NodeId (Tree $a) (Tree $a)))
; (= (getCandidateRec (mkRep $knobMapObj $tree) (mkInst $inst) $parentId $srcId $candidate)
;    ;; Find the knob associated with src (if any)
;    (chain (findDiscKnob $knobMapObj $srcId) $knobIdxPair
;       (if (~= (second $knobIdxPair) -1)
;           (chain (List.getByIdx $inst (second $knobIdxPair)) $d
;           (chain (appendTo $tree (first $knobIdxPair) $candidate $parentId $d) $updatedCnd

;           ;; The C++ version needs to call the getCandidateRec 
;           ;;  on the newly added node of the candidate but we 
;           ;;  already took care of that addition using the appendTo
;           ;;  function. Therefore that part is ommited here.
;           $updatedCnd))

;          ;; No knob found. Just copy.
;          (chain (getNodeById $tree $srcId) $src ;; Get node value using id
;          (chain (appendChild $candidate $parentId (mkTree (getNodeValue $src) Nil)) $cndChIdPair ;; AppendChild returns a pair of tree and appended child Id
;          (chain (getChildren $src) $srcChildren
;          (chain (List.foldl applyGetCandidateRec ((mkRep $knobMapObj $tree) (mkInst $inst) (second $cndChIdPair) (first $cndChIdPair) 1) $srcChildren) $state
;             (let ((mkRep $knobMapObj $tree) (mkInst $inst) $newParentId $finalCnd $_) $state $finalCnd)))))))
; )
(= (getCandidateRec (mkRep $knobMapObj $tree) (mkInst $inst) $parentId $srcId $candidate)
   (let* (
      ($_ (println! "[getCandidateRec] Starting..."))
      ($_ (println! (  parentId: $parentId)))
      ($_ (println! (  srcId: $srcId)))
      ($knobIdxPair (eval (findDiscKnob $knobMapObj $srcId)))
      ($_ (println! "[getCandidateRec] Found knob index pair"))
      ($_ (println! (  knobIdxPair: $knobIdxPair)))
      ($knobIdx (eval (second $knobIdxPair)))
      ($_ (println! (  knobIdx: $knobIdx)))
   )
      (if (not (== $knobIdx -1))
         ;; Knob Found - apply instance value
         (let* (
               ($_ (println! "[getCandidateRec] Knob found, applying instance value..."))
               ($d (eval (List.getByIdx $inst $knobIdx)))
               ($_ (println! (  Instance value d: $d)))
               ($knob (eval (first $knobIdxPair)))
               ($_ (println! (  Knob: $knob)))
               ($_ (println! "[getCandidateRec] Calling appendTo..."))
               ($updatedCnd (eval (appendTo $tree $knob $candidate $parentId $d)))
               ($_ (println! "[getCandidateRec] appendTo complete"))
            )
            $updatedCnd)
         ;; No Knob - copy structure
         (let* (
               ($_ (println! "[getCandidateRec] No knob, copying structure..."))
               ($src (eval (getNodeById $tree $srcId)))
               ($_ (println! (  Source node: $src)))
               ;; Check if source is NullVex - if so, skip it and process children directly
               ($isNullVex (eval (isNullVertex $src)))
               ($_ (println! (  Is NullVex: $isNullVex)))
            )
            (if $isNullVex
               ;; NullVex: Don't copy it, just process its children with current candidate
               (let* (
                  ($_ (println! "[getCandidateRec] Skipping NullVex, processing children directly..."))
                  ($srcchildren (eval (getChildren $src)))
                  ($childCount (eval (List.length $srcchildren)))
                  ($_ (println! (  Children count: $childCount)))
                  ;; Use special fold function that uses srcId as base
                  ($state (eval (List.foldl applyGetCandidateRecForNullVex ((mkRep $knobMapObj $tree) (mkInst $inst) $parentId $candidate $srcId 1) $srcchildren)))
                  ($_ (println! "[getCandidateRec] Folded NullVex children"))
                  (((mkRep $knobmapobj $tree) (mkInst $inst) $newparentid $finalcnd $srcIdBase $d) $state)
               )
               $finalcnd)
               ;; Regular node: Copy it
               (let* (
                  ($nodeValue (eval (getNodeValue $src)))
                  ($_ (println! (  Node value: $nodeValue)))
                  ($cndchidpair (eval (appendChild $candidate $parentId (mkTree $nodeValue Nil))))
                  ($_ (println! "[getCandidateRec] Appended child"))
                  ($srcchildren (eval (getChildren $src)))
                  ($childCount (eval (List.length $srcchildren)))
                  ($_ (println! (  Children count: $childCount)))
                  ($state (eval (List.foldl applyGetCandidateRec ((mkRep $knobMapObj $tree) (mkInst $inst) (eval (second $cndchidpair)) (eval (first $cndchidpair)) 1) $srcchildren)))
                  ($_ (println! "[getCandidateRec] Folded children"))
                  (((mkRep $knobmapobj $tree) (mkInst $inst) $newparentid $finalcnd $d) $state)
               )
               $finalcnd))))))
;; (: applyGetCandidateRec (-> (Tree $a)
;;                             (Representation Instance NodeId (Tree $a) Number)
;;                             (Representation Instance NodeId (Tree $a) Number)))
; (= (applyGetCandidateRec $_ ($repObj $inst (mkNodeId $parentId) $candidate $chIdx))
;    (chain (if (== $parentId (0)) (mkNodeId ($chIdx)) (mkNodeId (unionAtom $parentId ($chIdx)))) $srcId ;; Skip 0 from tree id.
;    (chain (getCandidateRec $repObj $inst (mkNodeId $parentId) $srcId $candidate) $updatedCnd
;       ($repObj $inst (mkNodeId $parentId) $updatedCnd (+ 1 $chIdx)))))

(= (applyGetCandidateRec $tr ($repObj $inst (mkNodeId $parentId) $candidate $chIdx))
   (let* (
         ($_ (println! "[applyGetCandidateRec] parentId: $parentId, chIdx: $chIdx"))
         ($srcId (if (== $parentId (0)) (mkNodeId ($chIdx)) (mkNodeId (eval (concatT $parentId ($chIdx))))))
         ($_ (println! (  Computed srcId: $srcId)))
         ($updatedCnd (eval (getCandidateRec $repObj $inst (mkNodeId $parentId) $srcId $candidate)))
      )
      ($repObj $inst (mkNodeId $parentId) $updatedCnd (+ 1 $chIdx))))