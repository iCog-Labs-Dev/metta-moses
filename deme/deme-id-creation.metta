;; Classic MOSES creates one deme per expansion unless dynamic feature
;; selection is enabled (n_demes defaults to 1). The expansion count starts
;; at 0 (moses_statistics in moses_params.h).

;; Number to string conversion
(= (numStr $n) (py-call (str $n)))
;; A DemeId wraps a string such as "1" or a pair expression ($nExpansion . $i).

;; createDemeIds -- creates the deme ids for one deme expansion
;;          $nExpansion -- the number of expansions done so far
;;          $nDeme      -- the number of demes to spawn
;; (: createDemeIds (-> Number Number (List DemeId)))
(= (createDemeIds $nExpansion $nDeme)
    (if (> $nDeme 1)
        (demeIdList (+ $nExpansion 1) (- $nDeme 1))
        (let $demeId (mkDemeId (numStr (+ $nExpansion 1))) ($demeId))))

;; demeIdList -- creates the deme ids ($nExpansion . 0) .. ($nExpansion . $nDeme)
(= (demeIdList $nExpansion $nDeme)
    (map-atom (genList 0 $nDeme) $i (mkDemeId ($nExpansion . $i))))
