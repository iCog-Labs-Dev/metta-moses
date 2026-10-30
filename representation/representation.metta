;; (: DiscMap Type)
;; (: mkDscMp (-> (MultiMap (DiscSpec $knob)) DiscMap))
;; (: KnobMap Type)
;; (: mkKbMap (-> DiscMap KnobMap))
;; (: Representation Type)
;; (: mkRep (-> KnobMap (Tree $a) Representation))

;; (: representation (-> Number (Tree $a) (ITable $a) Symbol bool Expression Symbol Expression))
(= (representation
;; Boolean representation constructor with feature selection
;; Params: Number of demes, Tree (Exemplar), ITable, feature selection params
;; Returns: List of Representations
            $nDeme                      ;; number of demes to spawn (number of distinct feature sets)
            $exemplar                   ;; tree around which multiple representations are to be built
            (mkITable $table $labels)   ;; table from which to select features and base the representations with
            $ftSelectionAlgo          ;; feature selection algorithm to be used -- symbol 
            $pruneExemplar             ;; bool to decide to prune the exemplar or keep the exemplar as is
            $enforcedFts               ;; set of features to be enforced in to selected features
            $scorerType                 ;; can MI or precision_bscore
        )
        (representation $nDeme $exemplar (mkITable $table $labels) $ftSelectionAlgo $pruneExemplar $enforcedFts $scorerType True))

;; restrictToIncorrect -- classic restrict_incorrect: feed feature selection only
;; the rows the exemplar mispredicts, with the exemplar's own columns blanked out.
;; Falls back to the untouched table when it is already correct everywhere, or when
;; the wrong rows share one output (zero MI).
;; The ITable is column-major, so the rows are read through Table.transpose and the
;; restricted rows are transposed back into columns.
(= (restrictToIncorrect $exemplar (mkITable $columns $labels))
   (let* (($expTree (preOrder $exemplar))
          ($len (List.length $labels))
          ($rows (Table.transpose $columns))
          ($wrongRows (filter-atom $rows $row
                        (!= (scoreTreeHelper $labels $expTree $row)
                            (index-atom $row (- $len 1))))))
     (if (isConstantOutput $wrongRows $len)
         (mkITable $columns $labels)
         (mkITable (Table.transpose (blankExemplarFeatures (treeFtsIndices $exemplar $labels) $wrongRows $len)) $labels))))

;; On the rows the exemplar gets wrong its own features still track the output, so
;; feature selection would just hand back the features the exemplar already uses and
;; the search would never gain a new one. Classic blanks those columns rather than
;; dropping them: a constant column carries no mutual information so it is never
;; selected, and every remaining column keeps its index.
(= (blankExemplarFeatures $fts $rows $len)
   (map-atom $rows $row
      (map-atom (genList 0 (- $len 1)) $i
         (if (once (is-member $i $fts)) False (index-atom $row $i)))))

;; True when the output column (last column) holds at most one distinct value.
;; The empty row set counts as constant, which covers the correct-everywhere case.
(= (isConstantOutput $rows $len)
   (<= (size-atom (unique-atom (map-atom $rows $r (index-atom $r (- $len 1))))) 1))

(= (representation
;; Boolean representation constructor with optional logical disc probing
            $nDeme
            $exemplar
            (mkITable $table $labels)
            $ftSelectionAlgo
            $pruneExemplar
            $enforcedFts
            $scorerType
            $discProbeDisabled
        )
        
        (let* (
                  ;; ($_ (println! (Inside Representation)))
                  ($exemplarFts  (filter-atom (treeFtsIndices $exemplar $labels) $x (!= $x -1)))
                  ;; ($_ (println! (exemplar features $exemplarFts)))          ;; exemplarFtsIndices function in deme/expand-deme.metta
                 ($allLabels (getInputLabels $labels))                       ;; getInputLabels in deme/expand-deme.metta
                 ;; ($_ (println! "before featureSelector"))
                 ($ftSetPop (if (== $ftSelectionAlgo None)
                                  ((genList 0 (- (List.length $labels) 2))) ;; Applying all labels as features
                                  (featureSelector $ftSelectionAlgo (restrictToIncorrect $exemplar (mkITable $table $labels)) 0.0 $exemplar 2 2 False () False 2 False ja $nDeme $scorerType)) ;; FS on the exemplar's mispredicted rows (classic restrict_incorrect, with full-table fallback)
                 )
                 ;; ($_ (println! (Selected Features after feature Selection $ftSetPop)))
                 ($exemplarArgSeq                                           ;; apply exemplar feature pruning
                     (if $pruneExemplar
                           (map-atom $ftSetPop $ftSet 
                              (let* (($diffFt (subtraction-atom $exemplarFts $ftSet))
                                    ;; ($_ (println! (diffffffff $diffFt)))
                                     ($ftNames (fsToNames $labels $diffFt))
                                     ($prunedXmplr (pruneExemplar $exemplar $ftNames))
                                     ($finalArgs (subtraction-atom $ftSet $exemplarFts)))  

                                 ($prunedXmplr (fsToNames $labels $finalArgs))))

                           (map-atom $ftSetPop $ftSet 
                                 (let* (($agg (union-atom-set $ftSet $exemplarFts))
                                        ($finalArgs (fsToNames $labels $agg))
                                        )  

                                    ($exemplar $finalArgs)))))
                  ;; ($_ (println! (Exemplar arg sets after pruning: $exemplarArgSeq))) 
                  ($withEnforcedFts                                         ;; enforce features
                     (if (== $enforcedFts ())
                           $exemplarArgSeq
                           (let $sampledEnforcedFts (sampleEnforcedFts $enforcedFts)           ;; from feature-selection/select-top-features.metta
                                    (map-atom $exemplarArgSeq ($xmplr $args)
                                             (let $acc (concatT $args $sampledEnforcedFts) ($xmplr $acc))))))  
                  ;; ($_ (println! (With enforced features: $withEnforcedFts)))
                  ($filterEmptyArgs (filter-atom $withEnforcedFts ($xmplr $args) (!= $args ())))
                  ;; ($_ (println! (After filtering empty args: $filterEmptyArgs)))
              )      ;; filter out exemplar arg pairs that have empty arg list

                     (map-atom $filterEmptyArgs ($xmplr $argLabels) 
                           (let* (
                                    ;; ($_ (println! (Building representation for arg labels: $argLabels)))
                                    ;; ($_ (println! (" done buildknobs (:) ")))
                                    (($updatedTree $dscMp) (buildKnobs $xmplr () $argLabels $discProbeDisabled (param ignoreOps)))
                                    ($_ (resetState &knobCount))
                                    ;; ($_ (println! (Building representation for arg labels: $argLabels)))
                                    ;; ($_ (println! (updated tree and disc map ($updatedTree $dscMp))))
                                    ;; ($_ (println! ""))
                                    ($discMap (mkDscMp $dscMp)))
                                 (mkRep (mkKbMap $discMap) $updatedTree)))))

;; Action representation: the exemplar and the two vocabularies.
;; It builds one representation per call.
(= (representation $exemplar $actions $perceptions)
         (let* (
                  (($updatedTree $dscMp) (buildKnobs $exemplar () () $actions $perceptions (param ignoreOps)))
                  ($_ (resetState &knobCount))
                  ($discMap (mkDscMp $dscMp))
               )
               (mkRep (mkKbMap $discMap) $updatedTree)))

