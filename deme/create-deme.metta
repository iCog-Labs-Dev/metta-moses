;; A DemeSpace is an atomspace for one deme. It holds a population of program
;; instances with the same representation but different knob settings, along with
;; their scores: one (mkRep ...), one (mkSInstSet ...) and one (mkDemeId ...).

;; Reset a DemeSpace to its initial state, with an empty instance set.
(= (initDemeSpace $demeSpace $rep $id)
   (let* (($_clear (clearSpace $demeSpace))
          ($_rep (add-atom $demeSpace $rep))
          ($_set (add-atom $demeSpace (mkSInstSet ())))
          ($_id (add-atom $demeSpace $id)))
     $demeSpace))

;; createDeme creates a DemeSpace with an empty instance set for each deme id.
;;             $nDeme --      number of demes to create
;;             $demeIds --    list of deme ids (cons ...)
;;             $exemplar --   the exemplar tree which the demes are going to be based on
;;             $table    --   table of input data
;;             $algo     --   the chosen feature selection algo
;;             $pruneExemplar     --   prune the exemplar or not
;;             $enforcedFts  --   tuple of enforced features to sample during feature selection, if any, as (arg selection-probability) pairs
;;             $scorerType --  the feature-set scorer type
;;             returns ↠ tuple of DemeSpaces
;; (: createDeme (-> Number (List DemeId) (Tree $a) (ITable $a) Symbol Bool Expression Symbol Expression)) 
(= (createDeme $nDeme $demeIds $exemplar (mkITable $table $labels) $algo $pruneExemplar $enforcedFts $scorerType)
      (let* 
            (
                  ((mkDemeId $firstDemeId) (List.head $demeIds))
                  ($featureSelectionDeme
                    (py-call (demeSpaceName.featureSelectionDemeSpaceName $firstDemeId)))
                  ($_init (initDemeSpace $featureSelectionDeme (mkRep () ()) (mkDemeId ())))
                  ($candidateReps
                    (createRepresentation $nDeme $exemplar (mkITable $table $labels) $algo $pruneExemplar $enforcedFts $scorerType $featureSelectionDeme))
                  ($reps (expandableRepresentations $candidateReps))
            ) 
            (createDemeSpaces $demeIds $reps)
      ) 
)

;; Action createDeme: the action/perception vocabularies come as arguments
;; (5-ary: no collision with the 8-arg boolean clause above). The params
;; are read once, at the deme boundary in expand-deme.metta.
;;             $nDeme --       number of demes to create
;;             $demeIds --     list of deme ids (cons ...)
;;             $exemplar --    the exemplar tree which the demes are going to be based on
;;             $actions --     tuple of domain action symbols (knob vocabulary)
;;             $perceptions -- tuple of perception symbols (may be ())
;;             returns ↠ tuple of DemeSpaces
;; (: createDeme (-> Number (List DemeId) (Tree $a) Expression Expression Expression))
(= (createDeme $nDeme $demeIds $exemplar $actions $perceptions)
      (let $reps (createRepresentation $nDeme $exemplar $actions $perceptions)
            (createDemeSpaces $demeIds $reps)))

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
;; A rep that is not expandable still uses up its id (the action path does not
;; pre-filter), so pair the ids with the reps before the filter.
(= (createDemeSpaces $demeIds $reps)
   (let* (
          ($pairs (List.zip $reps $demeIds))
          ($expandable (filter-atom $pairs ($rep $demeId) (representationExpandable $rep)))
         )
     (map-atom $expandable ($rep $demeId) (createDemeSpace $rep $demeId))))

(= (createDemeSpace $rep (mkDemeId $id))
   (let $demeSpace (py-call (demeSpaceName.demeSpaceName $id))
     (initDemeSpace $demeSpace $rep (mkDemeId $id))))
