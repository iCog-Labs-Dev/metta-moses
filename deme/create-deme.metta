;; Represents a population of program instances with the same representation 
;; but different knob settings, along with their scores
(: Deme Type)
(: mkDeme (-> Representation (InstanceSet $score) DemeId Deme))

;; Creates a new deme with an empty instance set
;; Params:
;;   $exemplar: The exemplar tree
;;   $nExpansion: total number of deme expansions (generations) set to 0 -- a constant number or a generation demes
;;   $nDemes: Number of feature sets to select out of feature selection and demes to spawn
;; Return: A new empty deme with the specified representation and ID
(: createDeme (-> (Tree $a) Number Number Deme)) 
(= (createDeme $exemplar $nExpansion $nDeme)
   (let*
   (
    ($demeIds (createDemeIds $nExpansion $nDeme))
    ($representation (createRepresentation $exemplar))
    ($demeId (List.getByIdx $demeIds 0))
   )
   (mkDeme $representation (mkSInstSet Nil) $demeId)))
