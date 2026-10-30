;; getHcFtPop -- returns list of (score ft-set pairs) as (cons ..)
;;            -- takes list of scored instances and an empty List () as accumulator
;; (: getHcFtPop (-> (List (ScoredInstance Number)) Expression (List $a)))
(= (getHcFtPop  () $acc) ())
(= (getHcFtPop (cons (mkSInst (mkPair (mkInst $list) $score)) $sInsts) $acc)
  (let* (($newAcc (getHcFtPop $sInsts $acc))
         ;; Reduced on its own line: inside ($score (bitsToIndices ...)) the pair's
         ;; head is a number, so the call would never be evaluated.
         ($ftSet (bitsToIndices $list 0 ()))
         ($scoreFtSetPair ($score $ftSet)))
    (cons $scoreFtSetPair $newAcc)))

;; hcFtSetPop  -- runs the hill climbing feature selector using a center instance
;;             -- returns tuple of (score ft-set) pairs
;;      $scorerType     -- the scorer to score feature sets with, mi or pre
;;      $fsHyperparams  -- the scorer hyper parameters as one list, in the order
;;                         defaultFsHyperparams builds them
;; Commented out: ITable has no type definition, so every call reduces to Empty.
;; (: hcFtSetPop (-> (ITable $a) Instance Symbol Expression Expression))
(= (hcFtSetPop $iTable $centerInst $scorerType $fsHyperparams)
  (let* (
         ;; ($_ (println! (debug inside hcFtSetPop)))
         ($fsParams (withFsScorer $fsHyperparams $scorerType))
         (((mkInst $inst1) (mkSInstSet $list) $state) (hillClimbing (mkSInstSet ()) $iTable (mkInst $centerInst) (mkParams applyMutualInformationBasedScore $fsParams))) ;; runs the hillclimbing feature selector
         ($listOfScoresetPairs (getHcFtPop $list ()))                                                    ;; separates the scores from the previous output and puts them in a score feature-set pair tuple -- as list of
         ($uniquePairs (List.tFoldl $listOfScoresetPairs union-atom toExp ()))                          ;; union-atom concatenates, so this fold keeps duplicates
         ($size (size-atom $uniquePairs))
        )

         (sortPairs pairMax $uniquePairs $size ())
  )
)                                                       ;; sort using score
