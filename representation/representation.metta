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
(= (crtDiscKnobMap (mkDscMp ()) (mkDscKbMp $dkm) $index) (mkDscKbMp $dkm))
(= (crtDiscKnobMap (mkDscMp (cons ($kbSpec $kb) $tail)) (mkDscKbMp $dkm) $index)
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
;     (($updatedTree $dscMp) (buildKnobs $exemplar () $argLabels))
;     ($dscKbMp (crtDiscKnobMap (mkDscMp $dscMp) (mkDscKbMp ()) 0))
; )   
; (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $updatedTree)
; ))
;; Game representation constructor with execution guard
;; Params: Tree (Exemplar), Number of demes
;; Returns: List of Representations
;;(: representation (-> (Tree $a) Number (List Representation)))
(= (representation $exemplar $nDeme)
   (let* (
          ($demeCount (range 0 1 $nDeme))
        
          ($result (map-atom $demeCount $x 
                      (let*
                        (
                          (($updatedTree $dscMp) (buildKnobs $exemplar () ()))
                          ($dscKbMp (crtDiscKnobMap (mkDscMp $dscMp) (mkDscKbMp ()) 0))
                          ($rep (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $updatedTree)))   
                          $rep))))
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
                  ;; ($_ (println! (Inside Representation)))
                  ($exemplar-fts  (filter-atom (treeFtsIndices $exemplar $labels) $x (not (== $x -1))))
                  ;; ($_ (println! (exemplar features $exemplar-fts)))          ;; exemplarFtsIndices function in deme/expand-deme.metta
                 ($all-labels (getInputLabels $labels))                       ;; getInputLabels in deme/expand-deme.metta
                 ;; ($_ (println! "before featureSelector"))
                 ($ft-set-pop (if (== $ft-selection-algo None)
                                  ((genList 0 (- (List.length $labels) 2))) ;; Applying all labels as features
                                  (featureSelector $ft-selection-algo (mkITable $table $labels) 0.0 $exemplar 2 2 False () False 2 False ja $nDeme 50.0 1.0 0.5 1.0 True $scorerType)) ;; applies the right parameteres for feature selection based on selected selection algorithm 
                 )
                 ;; ($_ (println! (Selected Features after feature Selection $ft-set-pop)))
                 ($exemplar-arg-seq                                           ;; apply exemplar feature pruning
                     (if $prune-exemplar
                           (map-atom $ft-set-pop $ft-set 
                              (let* (($diff-ft (subtraction-atom $exemplar-fts $ft-set))
                                    ;; ($_ (println! (diffffffff $diff-ft)))
                                     ($ft-names (fsToNames $labels $diff-ft))
                                     ($pruned-xmplr (pruneExemplar $exemplar $ft-names))
                                     ($final-args (subtraction-atom $ft-set $exemplar-fts)))  

                                 ($pruned-xmplr (fsToNames $labels $final-args))))

                           (map-atom $ft-set-pop $ft-set 
                                 (let* (($agg (union-atom-set $ft-set $exemplar-fts))
                                        ($final-args (fsToNames $labels $agg))
                                        )  

                                    ($exemplar $final-args)))))
                  ;; ($_ (println! (Exemplar arg sets after pruning: $exemplar-arg-seq))) 
                  ($with-enforced-fts                                         ;; enforce features
                     (if (== $enforced-fts ())
                           $exemplar-arg-seq
                           (let $sampled-enforced-fts (sampleEnforcedFts $enforced-fts)           ;; from feature-selection/select-top-features.metta
                                    (map-atom $exemplar-arg-seq ($xmplr $args)
                                             (let $acc (concatT $args $sampled-enforced-fts) ($xmplr $acc))))))  
                  ;; ($_ (println! (With enforced features: $with-enforced-fts)))
                  ($filter-empty-args (filter-atom $with-enforced-fts ($xmplr $args) (not (== $args ()))))
                  ;; ($_ (println! (After filtering empty args: $filter-empty-args)))
              )      ;; filter out exemplar arg pairs that have empty arg list

                     (map-atom $filter-empty-args ($xmplr $argLabels) 
                           (let* (
                                    ;; ($_ (println! (Building representation for arg labels: $argLabels)))
                                    ;; ($_ (println! (" done buildknobs (:) ")))            ;; BUILD representations on 
                                    (($updatedTree $dscMp) (buildKnobs $xmplr () $argLabels))            ;; BUILD representations on 
                                    ;; ($_ (println! (Building representation for arg labels: $argLabels)))
                                    ;; ($_ (println! (updated tereeeeee dddddddddddd disc mappppp ($updatedTree $dscMp))))
                                    ;; ($_ (println! ""))
                                    ($dscKbMp (crtDiscKnobMap (mkDscMp $dscMp) (mkDscKbMp ()) 0)))        ;; MULITPLE args selected using the feature selection
                                 (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $updatedTree)))))

;; Helper function to extract tree from representation
(= (getRepTree (mkRep $knobMapObj $tree)) $tree)

;; Universal getCandidate that works for both boolean and game strategies
;; Uses preOrder+buildTree to unwrap mkNullVex for games, cleanTree for boolean
;; (: getCandidate (-> Representation Instance (Tree $a)))
(= (getCandidate $repObj $id $inst)
   (case (match &treeSpace ($id $inst $tree) $tree)
             (($tree $tree)
             (Empty 
                (let*
                    (
                      ($parentid (mkNodeId (0)))
                      ($srcid (mkNodeId (0)))
                      ;; ($_ (println! ($parentid   $srcid)))
                      ((mkRep $kmo $tr) $repObj)
                      ;; ($_ (println! (Tree: (preOrder $tr))))
                      ($candidate (getCandidateRec $repObj $inst $parentid $srcid $parentid (mkNullVex ())))
                      ;; ($_ (println! (Found candidate: (preOrder $candidate))))
                      ($rootNode (getNodeById (getRepTree $repObj) $srcid))
                      ($rootValue (getNodeValue $rootNode))
                      ($rootSymbol (if (== (get-metatype $rootValue) Expression) 
                              (car-atom (cdr-atom $rootValue))
                              $rootValue))
                      ($isGameStrategy (== $rootSymbol PRIORITIZED-OR))
                      ($finalTree (if $isGameStrategy
                                      (let* (
                                              ($expr (preOrder $candidate))
                                              ($cleanTree (buildTree $expr)))
                                            $cleanTree)
                                      (cleanTree $candidate)))

                      ($_ (add-atom &treeSpace ($id $inst $finalTree)))
                      ;; ($_ (println! (Cleaned Tree: $cleanedTree)))
                    )
                    $finalTree)))))
   ; (trace! (Converting instance: $inst to tree) (chain (getCandidateRec $repObj $inst (mkNodeId (0)) (mkNodeId (0)) (mkNullVex ())) $candidate
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
;          (chain (appendChild $candidate $parentId (mkTree (getNodeValue $src) ())) $cndChIdPair ;; AppendChild returns a pair of tree and appended child Id
;          (chain (getChildren $src) $srcChildren
;          (chain (List.foldl applyGetCandidateRec ((mkRep $knobMapObj $tree) (mkInst $inst) (second $cndChIdPair) (first $cndChIdPair) 1) $srcChildren) $state
;             (let ((mkRep $knobMapObj $tree) (mkInst $inst) $newParentId $finalCnd $_) $state $finalCnd)))))))
; )

;; ------------------------------------------------------------------
;; Bottom-up candidate reconstruction (replaces the previous top-down builder).
;;
;; The old builder threaded a growing $candidate and inserted every node with
;; appendChild (getNodeById + replaceNodeById on the candidate) once per node.
;; Profiling showed getCandidate was ~98% of a demo run (see
;; docs/performance-bottlenecks.md). This version assembles each subtree
;; bottom-up and returns it, so a parent receives its children already built and
;; never walks/rebuilds a growing candidate.
;;
;; buildNodeBU returns a 0- or 1-element tuple: () when the rep node is absent
;; (knob setting 0), or ($subtree) otherwise. Output is identical to the old
;; builder (verified by representation-test and byte-identical benchmark output).
;; ------------------------------------------------------------------

;; child node id from a base id and 1-based index (matches the old applyGetCandidateRec)
(= (childIdOf (mkNodeId $base) $idx)
   (if (== $base (0)) (mkNodeId ($idx)) (mkNodeId (concatT $base ($idx)))))

;; Build the children tuple for $children (a tuple of source child nodes) based at
;; $baseId. Absent children (knob = 0) are dropped; ids stay rep-relative.
(= (buildChildrenBU $repObj $inst $baseId $children $idx)
   (if (== $children ())
       ()
       (let* (
              (($c $rest) (decons-atom $children))
              ($built (buildNodeBU $repObj $inst (childIdOf $baseId $idx)))
              ($restBuilt (buildChildrenBU $repObj $inst $baseId $rest (+ $idx 1)))
             )
         (if (== $built ())
             $restBuilt
             (cons-atom (car-atom $built) $restBuilt)))))

;; Build the subtree for the rep node at $srcId. Returns () (absent) or ($subtree).
(= (buildNodeBU (mkRep $knobMapObj $tree) (mkInst $inst) $srcId)
   (let $knobIdxPair (findDiscKnob $knobMapObj $srcId)
      (if (== (second $knobIdxPair) -1)
          (buildCopyBU (mkRep $knobMapObj $tree) (mkInst $inst) $srcId)
          (buildKnobBU (mkRep $knobMapObj $tree) (mkInst $inst)
                       (first $knobIdxPair) (List.getByIdx $inst (second $knobIdxPair))))))

;; No knob here: copy the source node's value and recurse into its children.
(= (buildCopyBU (mkRep $knobMapObj $tree) (mkInst $inst) $srcId)
   (let* (
          ($src (getNodeById $tree $srcId))
          ($built (buildChildrenBU (mkRep $knobMapObj $tree) (mkInst $inst) $srcId (getChildren $src) 1))
         )
      ((mkTree (getNodeValue $src) $built))))

;; Knob here: pick the target subtree (unwrapping a null vertex), build its
;; children, then present (1), negate (2), or drop (0) per the knob setting $d.
(= (buildKnobBU (mkRep $knobMapObj $tree) (mkInst $inst) $knob $d)
   (let* (
          ((mkNodeId $targetId) (getNodeId $knob))
          ($targetTree (getNodeById $tree (mkNodeId $targetId)))
          (($subtree $newBaseId) (if (== True (isNullVertex $targetTree))
                                     ((car-atom (getChildren $targetTree)) (mkNodeId (union-atom $targetId (1))))
                                     ($targetTree (mkNodeId $targetId))))
          ($builtChildren (buildChildrenBU (mkRep $knobMapObj $tree) (mkInst $inst) $newBaseId (getChildren $subtree) 1))
          ($presentNode (mkTree (getNodeValue $subtree) $builtChildren))
         )
      (case $d
         ((0 ())
          (1 ($presentNode))
          (2 ((mkTree (mkNode NOT) ($presentNode))))
          ($other (Error ($d $knob) "Invalid disc specification"))))))

;; getCandidateRec keeps its 6-arg signature for the top-level call and the direct
;; tests; $parentId/$dstId/$candidate are vestigial (the bottom-up builder does not
;; thread a partial candidate) and are ignored.
(= (getCandidateRec (mkRep $knobMapObj $tree) (mkInst $inst) $parentId $srcId $dstId $candidate)
   (car-atom (buildNodeBU (mkRep $knobMapObj $tree) (mkInst $inst) $srcId)))

;; (applyGetCandidateRec removed — it was the per-child fold helper for the old
;;  top-down getCandidateRec, which is now superseded by the bottom-up builder
;;  above (buildNodeBU/buildChildrenBU). The appendTo/appendToLSK/appendToSSK
;;  functions in lsk.metta are retained since they are still exercised directly
;;  by representation/tests/lsk-test.metta.)
