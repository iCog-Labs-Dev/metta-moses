;; Represents a population of program instances with the same representation 
;; but different knob settings, along with their scores
; (: Deme Type)
; (: mkDeme (-> Representation (InstanceSet $score) DemeId Deme))
;; createDeme create demes with empty instance set -- appends deme ID's to them as well
;;             $demeIds --    list of deme ids (cons ...)
;;             $exemplar --   the exemplar tree which the demes are going to be based on 
;;             $table    --   table of input data 
;;             $algo     --   the chosen feature selection algo
;;             $prune-exemplar     --   bool shall we prune the exemplar or not?
;;             $enforced-features  --   tuple of enorced features to be sample during feature selection, if any, in the form of arg selection-probabality pair
;;             returns ↠ tuple of demes
; (: createDeme (-> Number (List DemeId) (Tree $a) (ITable $a) Symbol Bool Expression Symbol Expression)) 
(= (createDeme $nDeme $demeIds $exemplar (mkITable $table $labels) $algo $prune-exemplar $enforced-fts $scorerType)
      (let* 
            (
                  ($reps (createRepresentation $nDeme $exemplar (mkITable $table $labels) $algo $prune-exemplar $enforced-fts  $scorerType))
            ) 
            (loopCreateDeme $demeIds $reps ()) ;; FIX: Optimize this using zip implementation in PeTTa. It can be faster.
      ) 
)
;; Game strategy createDeme - creates demes with empty instance sets for game strategies
;;             $nDeme --      number of demes to create
;;             $demeIds --    list of deme ids (cons ...)
;;             $exemplar --   the exemplar tree which the demes are going to be based on 
;;             returns ↠ tuple of demes
; (: createDeme (-> Number (List DemeId) (Tree $a) Expression))
(= (createDeme $nDeme $demeIds $exemplar)
      (let* 
            (
                  ($reps (createRepresentation $nDeme $exemplar))
            )  
            (loopCreateDeme $demeIds $reps ())
      ) 
)

;; Ant action-domain createDeme - creates action representations with embedded
;; ASK knobs using the domain-local action/perception vocabulary.
;; Classic C++ MOSES discards a representation whose field set is empty and
;; asks the outer loop to try another exemplar.  An empty action knob map is
;; the MeTTa equivalent: there is no coordinate that hill climbing can vary.
(= (antRepresentationExpandable
      (mkRep (mkKbMap (mkDscMp $mmp)) $tree))
   (> (MultiMap.length $mmp) 0))

;; Filter each randomized representation independently.  Some random builds
;; of the same exemplar can expose knobs while others expose none, so rejecting
;; an exemplar by tree shape would incorrectly throw useful demes away.
(= (antExpandableRepresentations $representations)
   (filter-atom $representations $rep
     (antRepresentationExpandable $rep)))

(= (createDeme $nDeme $demeIds $exemplar (mkAntContext $steps $complexityRatio $actions $perceptions))
      (let*
            (
                  ($demeCount (genList 0 (- $nDeme 1)))
                  ($candidateReps (map-atom $demeCount $x
                        (representation
                              1
                              $exemplar
                              (mkITable () ())
                              None
                              False
                              ()
                              mi
                              True
                              $actions
                              $perceptions)))
                  ($reps (antExpandableRepresentations $candidateReps))
            )
            (loopCreateDeme $demeIds $reps ())
      )
)


(= (loopCreateDeme $demeIds $reps $acc)
(if (== $reps ()) 
    $acc
    (let* (
            ($h (car-atom $reps))
            ($t (cdr-atom $reps)))
         (let* (
                 ($demeId (List.head $demeIds))
                 ($deme (mkDeme $h (mkSInstSet ()) $demeId))
                 ($new-acc (union-atom $acc ($deme))))
               (loopCreateDeme (List.tail $demeIds) $t $new-acc)))))
