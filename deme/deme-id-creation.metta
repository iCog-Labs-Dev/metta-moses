;; unless dynamic feature selection is enabled only one deme is created
;; feature selection is not used so just one deme will be created in our case or is it?
;; n_demes of the feature selector params is set to 1 by default
;; the number of expansion is set to zero (0) in moses_params.h in the moses_statistics struct

;; for number to string conversion
; (= (numStr $n) (py-call (str $n)))
;; DemeId Type
; (: DemeId Type)
; (: mkDemeId (-> String DemeId)) ;; this deviates from earlier type definition for the type constructor. It was defined like (: mkDemeId (-> Number DemeId)

;; createDemeIDs -- creates demeIDs for deme expansion
;;          $nExpansion -- total number of deme expansions (generations) set to 0 -- a constant number or a generation demes
;;          $nDemes     -- Number of feature sets to select out of feature selection and demes to spawn
; (: createDemeIds (-> Number Number (List DemeId)))
(= (createDemeIds $nExpansion $nDeme)
    (if (> $nDeme 1)
        (demeIdList (+ $nExpansion 1) (- $nDeme 1) Nil)
        (chain (+ $nExpansion 1) $n 
            ;(chain (numStr $n) $str  ;; removed number to string conversion, because its causing errors in test cases
                (chain (mkDemeId $n) $demeId (Cons $demeId Nil)))))
            ;)

;; demeIdList -- recursive function for creating list of demeId's           
(= (demeIdList $nExpansion $nDeme $list)
    (if (< $nDeme 0)
        $list
        (let* ((($str1 $str2)($nExpansion $nDeme))
                ($demeId (mkDemeId ($str1 . $str2)))
                ($newList (eval (List.prepend $demeId $list))))

                (demeIdList $nExpansion (- $nDeme 1) $newList)))) 