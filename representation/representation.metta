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
        (representation $nDeme $exemplar (mkITable $table $labels) $ft-selection-algo $prune-exemplar $enforced-fts $scorerType True))

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
                        (not (== (scoreTreeHelper $labels $expTree $row)
                                 (index-atom $row (- $len 1)))))))
     (if (ric-constant-output $wrongRows $len)
         (mkITable $columns $labels)
         (mkITable (Table.transpose (ric-blank-xmplr-fts (treeFtsIndices $exemplar $labels) $wrongRows $len)) $labels))))

;; On the rows the exemplar gets wrong its own features still track the output, so
;; feature selection would just hand back the features the exemplar already uses and
;; the search would never gain a new one. Classic blanks those columns rather than
;; dropping them: a constant column carries no mutual information so it is never
;; selected, and every remaining column keeps its index.
(= (ric-blank-xmplr-fts $fts $rows $len)
   (map-atom $rows $row
      (map-atom (genList 0 (- $len 1)) $i
         (if (once (is-member $i $fts)) False (index-atom $row $i)))))

(= (ric-is-xmplr-ft $i $fts)
   (> (size-atom (filter-atom $fts $f (== $f $i))) 0))

;; True when the output column (last column) holds at most one distinct value.
;; The empty row set counts as constant, which covers the correct-everywhere case.
(= (ric-constant-output $rows $len)
   (<= (size-atom (unique-atom (map-atom $rows $r (index-atom $r (- $len 1))))) 1))

(= (representation
;; Boolean representation constructor with optional logical disc probing
            $nDeme
            $exemplar
            (mkITable $table $labels)
            $ft-selection-algo
            $prune-exemplar
            $enforced-fts
            $scorerType
            $disable-discprobe
        )
        
        (let* (
                  ;; ($_ (println! (Inside Representation)))
                  ($exemplar-fts  (filter-atom (treeFtsIndices $exemplar $labels) $x (not (== $x -1))))
                  ;; ($_ (println! (exemplar features $exemplar-fts)))          ;; exemplarFtsIndices function in deme/expand-deme.metta
                 ($all-labels (getInputLabels $labels))                       ;; getInputLabels in deme/expand-deme.metta
                 ;; ($_ (println! "before featureSelector"))
                 ($ft-set-pop (if (== $ft-selection-algo None)
                                  ((genList 0 (- (List.length $labels) 2))) ;; Applying all labels as features
                                  (featureSelector $ft-selection-algo (restrictToIncorrect $exemplar (mkITable $table $labels)) 0.0 $exemplar 2 2 False () False 2 False ja $nDeme $scorerType)) ;; FS on the exemplar's mispredicted rows (classic restrict_incorrect, with full-table fallback)
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
                                    (($updatedTree $dscMp) (buildKnobs $xmplr () $argLabels $disable-discprobe (param ignoreOps)))            ;; BUILD representations on
                                    ($_ (resetState &knobCount))
                                    ;; ($_ (println! (Building representation for arg labels: $argLabels)))
                                    ;; ($_ (println! (updated tereeeeee dddddddddddd disc mappppp ($updatedTree $dscMp))))
                                    ;; ($_ (println! ""))
                                    ;; ($dscKbMp (crtDiscKnobMap (mkDscMp $dscMp) (mkDscKbMp ()) 0)))        ;; MULITPLE args selected using the feature selection
	                                    ($dscKbMp (mkDscMp $dscMp)))        ;; MULITPLE args selected using the feature selection
	                                 (mkRep (mkKbMap $dscKbMp) $updatedTree)))))

;; Lean action overload (3-ary; the boolean overloads are 8-ary):
;; an episodic representation needs exactly the exemplar and the two
;; vocabularies. The table/feature-selection/discprobe slots of the wider
;; overloads exist only for signature compatibility -- buildKnobs'
;; action path never consults them -- so they are not parameters here at
;; all rather than hardcoded placeholders.
(= (representation $exemplar $actions $perceptions)
         (let* (
                  (($updatedTree $dscMp) (buildKnobs $exemplar () () $actions $perceptions (param ignoreOps)))
                  ($_ (resetState &knobCount))
                  ($dscKbMp (mkDscMp $dscMp))
               )
               (mkRep (mkKbMap $dscKbMp) $updatedTree)))

