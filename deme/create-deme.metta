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
                  ((mkDemeId $firstDemeId) (List.head $demeIds))
                  ($featureSelectionDeme
                    (py-call (demeSpaceName.featureSelectionDemeSpaceName $firstDemeId)))
                  ($_ (clearSpace $featureSelectionDeme))
                  ($_ (add-atom $featureSelectionDeme (mkRep () ())))
                  ($_ (add-atom $featureSelectionDeme (mkSInstSet ())))
                  ($_ (add-atom $featureSelectionDeme (mkDemeId ())))
                  ($candidateReps
                    (createRepresentation $nDeme $exemplar (mkITable $table $labels) $algo $prune-exemplar $enforced-fts $scorerType $featureSelectionDeme))
                  ($reps (expandableRepresentations $candidateReps))
            ) 
            (loopCreateDemeSpace $demeIds $reps ()) ;; FIX: Optimize this using zip implementation in PeTTa. It can be faster.
      ) 
)

;; Action createDeme - the action/perception vocabularies ride as ARGUMENTS
;; (5-ary: no collision with the 8-arg boolean clause above); same body
;; shape. This layer just forwards them --
;; the one params read happens at the deme boundary in expand-deme.metta.
;;             $nDeme --       number of demes to create
;;             $demeIds --     list of deme ids (cons ...)
;;             $exemplar --    the exemplar tree which the demes are going to be based on
;;             $actions --     tuple of domain action symbols (knob vocabulary)
;;             $perceptions -- tuple of perception symbols (may be ())
;;             returns ↠ tuple of demes
; (: createDeme (-> Number (List DemeId) (Tree $a) Expression Expression Expression))
(= (createDeme $nDeme $demeIds $exemplar $actions $perceptions)
      (let $reps (createRepresentation $nDeme $exemplar $actions $perceptions)
            (loopCreateDemeSpace $demeIds $reps ())))

;; Classic C++ MOSES discards every representation whose field set is empty,
;; regardless of the scoring domain. An empty MeTTa disc map is equivalent:
;; there is no coordinate that an optimizer can vary.
(= (representationExpandable
      (mkRep (mkKbMap (mkDscMp $mmp)) $tree))
   (> (MultiMap.length $mmp) 0))
(= (representationExpandable
      (mkRep (mkKbMap $dscKbMp (mkDscMp $mmp)) $tree))
   (> (MultiMap.length $mmp) 0))

;; Filter each randomized representation independently.  Some random builds
;; of the same exemplar can expose knobs while others expose none, so rejecting
;; an exemplar by tree shape would incorrectly throw useful demes away.
(= (expandableRepresentations $representations)
   (filter-atom $representations $rep
     (representationExpandable $rep)))

;; Store each expandable representation and its initial state in a DemeSpace.
(= (loopCreateDemeSpace $demeIds $reps $acc)
   (if (== $reps ())
       $acc
       (let*
         (
           ($h (car-atom $reps))
           ($t (cdr-atom $reps))
           ($demeId (List.head $demeIds))
           ((mkDemeId $id) $demeId)
         )
         (if (representationExpandable $h)
             (let*
               (
                 ($demeSpace (py-call (demeSpaceName.demeSpaceName $id)))
                 ($_ (clearSpace $demeSpace))
                 ($_ (add-atom $demeSpace $h))
                 ($_ (add-atom $demeSpace (mkSInstSet ())))
                 ($_ (add-atom $demeSpace (mkDemeId $id)))
                 ($new-acc (union-atom $acc ($demeSpace)))
               )
               (loopCreateDemeSpace (List.tail $demeIds) $t $new-acc))
             (loopCreateDemeSpace (List.tail $demeIds) $t $acc)))))
