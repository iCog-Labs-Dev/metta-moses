;; Represents a population of program instances with the same representation 
;; but different knob settings, along with their scores
(: Deme Type)
(: mkDeme (-> Representation (InstanceSet $score) DemeId Deme))
;; createDeme create demes with empty instance set -- appends deme ID's to them as well
;;             $demeIds --    list of deme ids (Cons ...)
;;             $exemplar --   the exemplar tree which the demes are going to be based on 
;;             $table    --   table of input data 
;;             $algo     --   the chosen feature selection algo
;;             $prune-exemplar     --   bool shall we prune the exemplar or not?
;;             $enforced-features  --   tuple of enorced features to be sample during feature selection, if any, in the form of arg selection-probabality pair
;;             returns ↠ tuple of demes
(: createDeme (-> Number (List DemeId) (Tree $a) (ITable $a) Symbol Bool Expression Expression)) 
(= (createDeme $nDeme $demeIds $exemplar (mkITable $table $labels) $algo $prune-exemplar $enforced-fts)
      (let* ((() (println! (creating representations ....)))
             ($reps (createRepresentation $nDeme $exemplar (mkITable $table $labels) $algo $prune-exemplar $enforced-fts))
             (() (println! (done making representations ...))))  
         (loopCreateDeme $demeIds $reps ())))


;; ================================================================================
;; Helper Functions
;; ================================================================================

;; Get representation from deme
(: getRep (-> Deme Representation))
(= (getRep (mkDeme $rep $instSet $id)) $rep)

;; Get instance set from deme
(: getInstanceSet (-> Deme (InstanceSet $score)))
(= (getInstanceSet (mkDeme $rep $instSet $id)) $instSet)

;; Creates a new deme with an empty instance set
;; Params:
;;   $demeIds: List of DemeIds to create the deme
;;   $exemplar: The exemplar tree
;;   $nExpansion: total number of deme expansions (generations) set to 0 -- a constant number or a generation demes
;;   $nDemes: Number of feature sets to select out of feature selection and demes to spawn
;;   $acc: Accumulator for the demes being created
;;   $argLabels: list of argument labels (input variables) from the ITable
;; Returns: A list of demes created from the given parameters
(: createDeme (-> (List DemeId) (Tree $a) Number Number Expression Expression Expression)) 
(= (createDeme $demeIds $exemplar $nExpansion $nDeme $acc $argLabels)
   (if (== $demeIds Nil) $acc
   (let*
   (
    ($representation (createRepresentation $exemplar $argLabels))
    ($demeId (List.head $demeIds))
    ($updatedDemesList (cons-atom (mkDeme $representation (mkSInstSet Nil) $demeId) $acc))
   )
   (createDeme (List.tail $demeIds) $exemplar $nExpansion $nDeme $updatedDemesList $argLabels)
   )))


(= (loopCreateDeme $demeIds $reps $acc)
      (if-decons-expr $reps $h $t
            (let* (($demeId (List.head $demeIds)) 
                   ($deme (mkDeme $h (mkSInstSet Nil) $demeId))
                   ($new-acc (union-atom $acc ($deme))))
                  
                  (loopCreateDeme (List.tail $demeIds) $t $new-acc))
               $acc))    

