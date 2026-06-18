;; getHcFtPop -- returns list of (score ft-set pairs) as (cons ..)
;;            -- takes list of scored instances and an empty List () as accumulator
(: getHcFtPop (-> (List (ScoredInstance Number)) Expression (List $a)))
(= (getHcFtPop  () $acc) ())
(= (getHcFtPop (cons (mkSInst (mkPair (mkInst $list) $score)) $sInsts) $acc) 
  (chain (getHcFtPop $sInsts $acc) $new-acc
    (chain ($score (bitsToIndices $list 0 ())) $score-ft-set-pair
      (cons $score-ft-set-pair $new-acc))))

;; hcFtSetPop  -- runs the hill climbing feature selector using a center instance 
;;             -- returns tuple of (score ft-set) pairs
(: hcFtSetPop (-> (ITable $a) Instance Number Number Number Number Bool Symbol Expression))      
(= (hcFtSetPop $iTable $centerInst $scorerType)
  (let* (
         ;; ($_ (println! (debug inside hcFtSetPop)))
         (((mkInst $inst1) (mkSInstSet $list) $state) (hillClimbing (mkSInstSet ()) $iTable (mkInst $centerInst) (applyMutualInformationBasedScore $scorerType))) ;; runs the hillclimbing feature selector
         ($list-of-scoreset-pairs (getHcFtPop $list ()))                                                    ;; separates the scores from the the previous output and puts them in a score feature-set pair tuple -- as list of
         ($unique-pairs (List.tFoldl $list-of-scoreset-pairs union-atom exp ()))                            ;; finds unquie such pairs duplicats removed -- by way of union-atom
         ($size (size-atom $unique-pairs))
        )

         (sortPairs pairMax $unique-pairs $size ())
  )
)                                                       ;; sort using score
