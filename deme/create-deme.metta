;; Represents a population of program instances with the same representation 
;; but different knob settings, along with their scores
(: Deme Type)
(: mkDeme (-> Representation (InstanceSet $score) DemeId Deme))

;; Creates a new deme with an empty instance set
;; Params:
;;   $demeIds: List of DemeIds to create the deme
;;   $exemplar: The exemplar tree
;;   $nExpansion: total number of deme expansions (generations) set to 0 -- a constant number or a generation demes
;;   $nDemes: Number of feature sets to select out of feature selection and demes to spawn
;;   $acc: Accumulator for the demes being created
;; Returns: A list of demes created from the given parameters
(: createDeme (-> (List DemeId) (Tree $a) Number Number Expression Expression)) 
(= (createDeme $demeIds $exemplar $nExpansion $nDeme $acc)
   (if (== $demeIds Nil) $acc
   (let*
   (
    ($representation (createRepresentation $exemplar))
    ($demeId (List.head $demeIds))
    ($updatedDemesList (cons-atom (mkDeme $representation (mkSInstSet Nil) $demeId) $acc))
   )
   (createDeme (List.tail $demeIds) $exemplar $nExpansion $nDeme $updatedDemesList)
   )))

